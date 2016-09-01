#!/usr/bin/env bash

set -e

if [ "$#" -ne "1" ]; then
    echo "Usage: $0 /path/to/root"
    exit 1
fi

ROOTFS="$1"
PACMAN_EXTRA_PKGS='git neovim tmux zsh'
USER="john"

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
IFS=','
PKGIGNORE="${PKGIGNORE[*]}"
unset IFS

pacstrap -c -d -i $ROOTFS base base-devel dbus systemd abs $PACMAN_EXTRA_PKGS --ignore $PKGIGNORE

arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime"
echo 'en_US.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS locale-gen
echo 'qontain' > $ROOTFS/etc/hostname

cp $SCR_DIR/bashrc $ROOTFS/root/.bashrc
cp $SCR_DIR/inputrc $ROOTFS/root/.inputrc
arch-chroot $ROOTFS /bin/sh -c "useradd -m -G wheel $USER"
arch-chroot $ROOTFS /bin/sh -c "su -c 'cd ~ && curl -fLo aura-bin.tgz https://aur.archlinux.org/cgit/aur.git/snapshot/aura-bin.tar.gz && tar xf aura-bin.tgz && cd aura-bin && makepkg' $USER"
arch-chroot $ROOTFS /bin/sh -c "pacman -U --noconfirm /home/$USER/aura-bin/*.pkg.tar.xz"
arch-chroot $ROOTFS /bin/sh -c "su -c 'cd ~ && git clone https://github.com/teenyhop/devenv.git && cd devenv && ./install.sh' $USER"
arch-chroot $ROOTFS /bin/sh -c "usermod -s /bin/zsh $USER"
arch-chroot $ROOTFS /bin/sh -c "systemctl enable systemd-networkd && systemctl enable systemd-resolved"
arch-chroot $ROOTFS /bin/sh -c "ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf"
