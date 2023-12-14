# Arch Linux Dot Files

Various configuration files for my user and system settings. Most files can be
copied to the appropriate directory. Note that the `etc` and `boot` directories
are relative to the root.

## Installation

Some additional tweaking is required for some settings. They are detailed in
below.

### Mouse Cursor

Download the [Volantes] cursors, uncompress, and install.

```text
tar zxf volantes-cursors.tar.gz
cd volantes_cursors
mkdir -p $HOME/.icons/default
cp -vr . $HOME/.icons/default
gsettings set org.gnome.desktop.interface cursor-theme default
gsettings set org.gnome.desktop.interface cursor-size 48
```

### Networking

```text
ln -sf /run/systemd/resolve/stub-resolve.conf /etc/resolv.conf
hostnamectl hostname purpledragon
systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service
sytemctl enable systemd-resolved.service
sytemctl start systemd-resolved.service
```

### CUPS

```text
pacman -S --needed cups cups-browsed avahi nss-mdns
cp -r etc/systemd/resolved.conf.d /etc/systemd
cp etc/nsswitch.conf /etc
systemctl restart systemd-resolved.service
systemctl enable avahi-daemon.service
systemctl start avahi-daemon.service
systemctl enable cups.service
systemctl start cups.service
```

### Automatic TRIM

```text
systemctl enable fstrim.timer
systemctl start fstrim.timer
```

### Package Cache Clean

```text
systemctl enable paccache.timer
systemctl start paccache.timer
```

### Sound

To be performed if Pipewire, Wireplumber and other audio subsystems are
installed.

```text
systemctl --user enable --now pipewire pipewire.service
systemctl --user enable --now pipewire pipewire-pulse.service
```

### OpenRGB (AUR)

[openal] is needed for the OpenRGB Effects Plugin.

```text
pacman -S --needed qt5-wayland openal
git clone https://aur.archlinux.org/openrgb.git $HOME/projects/git
cd $HOME/projects/git/openrgb
makepkg --clean --cleanbuild --install --needed --rmdeps --syncdeps
```

### Tmux

```text
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Awesome WM

```text
pacman -S --needed awesome xorg xsel xcompmgr
```

### Zoom (AUR)

Install Zoom and dependencies:

```text
pacman -S --needed pipewire-v4l2 qt5-wayland xdg-desktop-portal \
                   xdg-desktop-portal-wlr
git clone https://aur.archlinux.org/zoom.git $HOME/projects/git
cd $HOME/projects/git/zoom
makepkg --clean --cleanbuild --install --needed --rmdeps --syncdeps
```

After first launch `$HOME/.config/zoomus.conf` will exist. Edit the file and set
the following values:

```text
enableWaylandShare=true
xwayland=false
```

Modify the `Exec=` line in `/usr/share/applications/Zoom.desktop`:

```text
Exec=env XDG_CURRENT_DESKTOP=GNOME QT_QPA_PLATFORM=wayland /usr/bin/zoom %U
```

[openal]: https://gitlab.com/OpenRGBDevelopers/OpenRGBEffectsPlugin#linux
[volantes]: https://www.gnome-look.org/p/1356095
