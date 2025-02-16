# dotfiles

This is a selection of settings and preferences for my OpenSUSE [Aeon Desktop](https://aeondesktop.github.io/) installation.

In most cases the given instructions should also work on MicroOS and Tumbleweed.

## Drivers

### NVIDIA

See the OpenSUSE Wiki for details:

- <https://en.opensuse.org/SDB:NVIDIA_drivers>
- <https://en.opensuse.org/SDB:NVIDIA_Switcheroo_Control>

You may get conflicts, it seems to work fine when you choose to ignore the missing library or package.

On Aeon you may need to remove the `--root-pw` option for the `mokutil --import` command, and give a password manually instead.

## Maintenance

## Filesystem

### Trim

Enable the `fstrim` when using a SSD/NVme-device timer:

```bash
sudo systemctl enable fstrim.timer --now
``` 

### Encryption

If you are using encryption on a NVMe/SSD, you may want to improve performance by disabling the workqueue and allowing discards:

```bash
sudo cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --allow-discards --persistent refresh aeon_root
```

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details.

### Btrfs

If you are using Btrfs, you may want to configure <https://github.com/kdave/btrfsmaintenance>:

```bash
sudo nano /etc/sysconfig/btrfsmaintenance
```

Enable the timers:

```bash
sudo systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
```

### zram

To enable [zwramswap](https://wiki.archlinux.org/title/Zram#Using_zramswap):

```bash
sudo systemctl enable zramswap.service --now
```

## Software

It is discourage to install software on the root filesystem, see the Aeon Wiki for details:

- <https://en.opensuse.org/Portal:Aeon/SoftwareInstall>

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

To enable linger, e.g. keep containers running when logged out:

```bash
loginctl enable-linger $USER
```

### Firewall

Aeon doesn't come with any firewall. Instead you should control ports and services using Podman Quadlet and containers.

It's still possible to install `firewalld`, but this may cause Flatpak and container network issues.

### VSCodium / VSCode

See the following guides:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

You may want to use [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal) to set the following overwrites:

- Add to `Other files`: `xdg-run/podman:ro`
- Add to `Other files`: `/tmp:rw`

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

Install fish in the OpenSUSE distrobox container:

```bash
sudo zypper install fish ibm-plex-mono-fonts ibm-plex-sans-fonts ibm-plex-serif-fonts
```

To add fish path lookups:

```fish
fish_add_path  ~/.local/bin ~/.config/yarn/global/node_modules/.bin
```

To disable greeting (welcome message):

```fish
set -U fish_greeting
```

Follow <https://starship.rs/guide/> to setup Starship.

## Appearance

See <https://itsfoss.com/flatpak-app-apply-theme/> instructions for Flatpak theming.

Use [Refine](https://flathub.org/apps/page.tesk.Refine) to apply customization or [dconf-editor](https://flathub.org/apps/ca.desrt.dconf-editor) - look up keys in `/org/gnome/`.

### Current Theme

Icon Theme (GTK - non-root): https://github.com/PapirusDevelopmentTeam/papirus-icon-theme

Cursor Theme: https://github.com/phisch/phinger-cursors

Fonts: [Inter](https://rsms.me/inter/) + [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
