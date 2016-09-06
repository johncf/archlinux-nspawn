#!/usr/bin/env bash

set -e

if [ "$#" -ne "1" ]; then
    echo "Usage: $0 /path/to/root"
    exit 1
fi

ROOTFS="$1"
EXTRA_PKGS='git neovim tmux zsh'
USER="nope"
HOSTNAME="qontain"
TIMEZONE="Asia/Kolkata"

ls $ROOTFS/pacstrap-here &>/dev/null || {
    echo "Please create an empty file at '$ROOTFS/pacstrap-here' to continue..."
    exit 1
}

hash pacstrap &>/dev/null || {
    echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
    exit 1
}

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null
SCR_DIR=$(pwd)
popd >/dev/null

export LANG="C.UTF-8"

# packages to ignore for space savings
PKGIGNORE=(
    cryptsetup
    device-mapper
    dhcpcd
    jfsutils
    linux
    lvm2
    man-db
    man-pages
    mdadm
    nano
    netctl
    openresolv
    pciutils
    pcmciautils
    reiserfsprogs
    s-nail
    systemd-sysvcompat
    usbutils
    vi
    xfsprogs
)
IFS=$'\n'
PKGIGNORE="${PKGIGNORE[*]}"
unset IFS

PKGS=(`comm -23 <(pacman -Sg base base-devel | cut -d' ' -f2 | sort | uniq) <(sort <<<"$PKGIGNORE")`)

pacstrap -c -d -i "$ROOTFS" "${PKGS[@]}" dbus systemd $EXTRA_PKGS

echo "$HOSTNAME" > "$ROOTFS"/etc/hostname

# set timezone
arch-chroot "$ROOTFS" /bin/sh -c "ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime"

# set locale
echo 'en_US.UTF-8 UTF-8' > "$ROOTFS"/etc/locale.gen
arch-chroot "$ROOTFS" locale-gen

cp $SCR_DIR/bashrc "$ROOTFS"/root/.bashrc
cp $SCR_DIR/inputrc "$ROOTFS"/root/.inputrc

# setup network
arch-chroot "$ROOTFS" /bin/sh -c "systemctl enable systemd-networkd && systemctl enable systemd-resolved"
arch-chroot "$ROOTFS" /bin/sh -c "ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf"

# add a wheel user
arch-chroot "$ROOTFS" /bin/sh -c "useradd -m -G wheel $USER"

# install aura-bin
arch-chroot "$ROOTFS" /bin/sh -c "pacman -S --noconfirm --asdeps abs"
arch-chroot "$ROOTFS" /bin/sh -c "su -c 'cd ~ && curl -fLo aura-bin.tgz https://aur.archlinux.org/cgit/aur.git/snapshot/aura-bin.tar.gz && tar xf aura-bin.tgz && cd aura-bin && makepkg' $USER"
arch-chroot "$ROOTFS" /bin/sh -c "pacman -U --noconfirm /home/$USER/aura-bin/*.pkg.tar.xz"

# populate dotfiles
arch-chroot "$ROOTFS" /bin/sh -c "su -c 'cd ~ && git clone https://github.com/teenyhop/devenv.git && cd devenv && ./install.sh' $USER"
arch-chroot "$ROOTFS" /bin/sh -c "usermod -s /bin/zsh $USER"

# manually run visudo and to uncomment the wheel line
