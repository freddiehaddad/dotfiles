#!/bin/bash

OPTIONS="--verbose --recursive --relative"

rsync $OPTIONS "$HOME"/.zshrc .
rsync $OPTIONS "$HOME"/.config/{alacritty,awesome,btop,foot,hypr,starship.toml,sway,tmux/tmux.conf,waybar,wofi} .
rsync $OPTIONS /boot/loader/{entries,loader.conf} .
rsync $OPTIONS /etc/{makepkg.conf,mkinitcpio.conf,modules-load.d/openrgb.conf,pacman.conf,skel/.zshrc,systemd/network/20-ethernet.network,systemd/resolved.conf.d/20-multicastdns.conf,xdg/reflector/reflector.conf,xdg/user-dirs.conf,xdg/user-dirs.defaults,X11/xorg.conf.d/20-amdgpu.conf} .

# Requires sudo
echo "sudo access requried to backup the remaining files"
sudo rsync $OPTIONS /etc/{default/useradd,sudoers.d/20-users} .
sudo chown --recursive freddiehaddad:freddiehaddad ./etc
sudo rsync $OPTIONS /root/{.zshrc,.config/tmux} .
sudo chown --recursive freddiehaddad:freddiehaddad ./root
