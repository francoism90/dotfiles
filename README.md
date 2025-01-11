# dotfiles

This is a selection of settings and preferences for my [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) and [Bluefin](https://projectbluefin.io/) installation.

## Anaconda kickstart

1. Download the network installer ISO from <https://fedoraproject.org/atomic-desktops/silverblue/download/>
2. Boot the ISO and stop at Grub screen
3. Highlight "Install Fedora", press <kbd>e</kbd> and append:
  ```text
  inst.ks=https://raw.githubusercontent.com/francoism90/dotfiles/main/silverblue.ks
  ```
or when using an USB-device labelled `LIVE`:
  ```text
  inst.ks=hd:LABEL=LIVE:/silverblue.ks
  ```
or when using an USB directly:
```text
inst.ks=hd:nvme0n1p3:/silverblue.ks
```

4. Press <kbd>F10</kbd> to start the installation using the kickstart file

## Maintenance

Reference:

- <https://rpmfusion.org/Howto/OSTree>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>

To show difference after upgrades:

```bash
rpm-ostree db diff -c
```

## nofile

Increasing `nofile` limits may be needed for certain applications and games to work.

See <https://access.redhat.com/solutions/1257953> for more details.

> **NOTE:** Reboot the system to apply increased limits.

## Filesystem

### Trim

Enable the `fstrim` timer:

```bash
sudo systemctl enable fstrim.timer --now
``` 

### Encryption

If you are using encryption on a NVMe/SSD, you may want to improve performance by disabling the workqueue.

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details.

### Btrfs

If you are using Btrfs, you may want to use <https://github.com/kdave/btrfsmaintenance>:

```bash
rpm-ostree install btrfsmaintenance
nano /etc/sysconfig/btrfsmaintenance
```

Enable the timers:

```bash
sudo systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
```

## Software

### Toolbox

It is discourage to install (large) software on the ostree. Try to use Flatpaks and toolboxes (`toolbox create` and `toolbox enter`) as much as possible.

You can pull the latest toolbox, using:

```bash
podman pull fedora-toolbox:41
```

To update a toolbox:

```bash
toolbox enter
sudo dnf update && sudo dnf upgrade
```

You can create multiple toolboxes, and even manage them using [Podman Desktop](https://podman-desktop.io/).

### Firefox

To replace the provided default Firefox package, with the Firefox Flathub version for example:

```bash
rpm-ostree override remove firefox firefox-langpacks
```

> **NOTE:** You can also hide the desktop entry itself.

### Brave

Depending on your hardware, you may need to enable/disable different flags. See <https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md#vaapi-on-linux> for details.

### Podman

Enable and use rootless containers:

- <https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md>
- <https://wiki.archlinux.org/title/Podman#Rootless_Podman>

To learn more about Podman Quadlet, the following resources may be useful:

- <https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html>
- <https://www.redhat.com/sysadmin/quadlet-podman>
- <https://mo8it.com/blog/quadlet/>

Install Docker compatible packages:

```bash
rpm-ostree install podman-docker podman-compose
systemctl reboot
```

Enable linger:

```bash
loginctl enable-linger $USER
```

### Firewall(d)

To open services and ports:

```bash
sudo firewall-cmd --list-all-zones
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=http3
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --permanent --zone=FedoraServer --add-port=8096/tcp
sudo firewall-cmd --reload
```

### VSCodium / VSCode

See the following guides:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

You may want to use [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal), and set the following overwrites:

- Add to `Other files`: `xdg-run/podman`
- Add to `Other files`: `/tmp`


#### Wayland

To enable Wayland support:

```bash
flatpak override --user --socket=wayland --socket=fallback-x11 --env=ELECTRON_OZONE_PLATFORM_HINT=auto com.visualstudio.code
```

See <https://github.com/flathub/com.visualstudio.code/issues/471> for details.

### Ptyxis (Terminal)

To apply opacity ([credits](https://discussion.fedoraproject.org/t/use-dconf-to-set-transparency-for-ptyxis/135003)):

```bash
dconf read /org/gnome/Ptyxis/default-profile-uuid
dconf write /org/gnome/Ptyxis/Profiles/{profile-uuid}/opacity 0.95
```

#### Fish

Install fish:

```bash
rpm-ostree install fish ibm-plex-mono-fonts ibm-plex-sans-fonts ibm-plex-serif-fonts
systemctl reboot
```

Change user shell:

```bash
chsh -s /bin/fish
```

Add fish path lookups:

```fish
fish_add_path  ~/.local/bin ~/.config/yarn/global/node_modules/.bin
```

To disable greeting (welcome message):

```fish
set -U fish_greeting
```

Follow <https://starship.rs/guide/>.

## Appearance

See <https://itsfoss.com/flatpak-app-apply-theme/> instructions for Flatpak theming.

To install Gnome Tweak:

```bash
rpm-ostree install gnome-tweak-tool
```

Current Theme:

Icon Theme (GTK - non-root): https://github.com/PapirusDevelopmentTeam/papirus-icon-theme

Cursor Theme: https://github.com/phisch/phinger-cursors

Font: IBM Plex Sans + FiraCode Nerd Font Mono
