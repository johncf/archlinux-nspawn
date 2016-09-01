# archlinux-nspawn

A script to setup a [systemd-nspawn][] container in Arch Linux.

To setup the container, follow these steps:

```sh
$ touch /path/to/root/pacstrap-here
$ sudo /path/to/setup.sh /path/to/root
```

`pacstrap-here` does not have any functional significance, it's just to make things doubly sure.

To boot into the container with X- and networking support:

```sh
$ xhost +local:
$ sudo systemd-nspawn -b -D /path/to/root --network-veth \
    --bind=/var/cache/pacman/pkg --bind=/tmp/.X11-unix \
    --bind-ro=$HOME/.Xauthority:/home/$USER/.Xauthority
```

`$HOME` represents your user's home directory in the host, and `$USER` represents the user name within the container (the same as `$USER` variable in `setup.sh`).

Having your host's networking controlled by [systemd-networkd][] is the easiest way to setup networking for the container. Otherwise, you should manually setup a bridge between the two. See `man systemd-nspawn` for more options.

Now, from within the container, you may install, say `firefox`, and launch it as:

```sh
$ DISPLAY=:0 firefox
```

Enjoy!

### Notes about `setup.sh`

- It was originally borrowed (stolen) from the [docker repo][]
- It downloads and installs [aura-bin][] from AUR
- It fetches and populates my [dotfiles][] on `$USER`'s home directory
- There are more "personalizations", so verify before use

[systemd-nspawn]: https://wiki.archlinux.org/index.php/Systemd-nspawn
[systemd-networkd]: https://wiki.archlinux.org/index.php/Systemd-networkd
[dotfiles]: https://github.com/critiqjo/devenv
[aura-bin]: https://aur.archlinux.org/packages/aura-bin/
[docker repo]: https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh
