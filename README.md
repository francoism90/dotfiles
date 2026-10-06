# dotfiles

This is a selection of settings, notes and preferences for my Linux devices.

Useful sources and references:

- <https://github.com/francoism90/personal-os/>
- <https://blue-build.org/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/tips-and-tricks/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>
- <https://rpmfusion.org/Howto/OSTree>

## Installation

The files in `config/` are installed with the scripts in `bin/`. They can be run from any directory:

```bash
git clone https://github.com/francoism90/dotfiles.git ~/Code/dotfiles
~/Code/dotfiles/bin/install-dotfiles
```

| Script                    | Installs                                                      |
| ------------------------- | ------------------------------------------------------------- |
| `bin/install-dotfiles`    | Bash aliases, Git, Fish, Nano and Flatpak app configuration   |
| `bin/install-claude-code` | Claude Code settings and `AGENTS.md`, then Claude Code itself |

> Note: Existing files at the destination are overwritten. Directories are merged, files that are not in this repository are kept.

To install an additional file or directory, add a line to one of the scripts:

```bash
install_config <path relative to config/> <destination>

# e.g.
install_config yt-dlp/config ~/.config/yt-dlp/config
```

## Administration

### Shell

To change the user shell:

```bash
sudo usermod --shell /bin/fish $USER
```

### Package management

To list all current installed packages:

```bash
rpm -qa
```

To check configuration differences:

```bash
# ostree admin config-diff
```

To update Flatpaks:

```bash
$ flatpak update
# flatpak update --system
```

To repair Flatpaks, which may be needed on upgrades:

```bash
$ flatpak repair --user -vvv
# flatpak repair --system -vvv
```

### Journal

To get the last boot log:

```bash
journalctl --list-boots
journalctl -b -0
```

### Podman

Enable and use rootless containers:

- <https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md>
- <https://wiki.archlinux.org/title/Podman#Rootless_Podman>

Following resources may be useful for Podman Quadlet:

- <https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html>
- <https://www.redhat.com/sysadmin/quadlet-podman>
- <https://mo8it.com/blog/quadlet/>

Enable linger (keep containers running after logging out):

```bash
loginctl enable-linger $USER
```

To automatically manage container updates:

```bash
# systemctl enable podman-auto-update.timer --now
$ systemctl --user enable podman-auto-update.timer --now
```

### VSCode / VSCodium / Zed

See the following resources for details:

- <https://github.com/francoism90/org.freedesktop.Sdk.Extension.podman>
- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

### Firewalld

To open services and ports, replace `FedoraServer` with the target zone:

```bash
$ firewall-cmd --get-default-zone
$ firewall-cmd --get-active-zones
# firewall-cmd --list-all-zones
# firewall-cmd --list-all
# firewall-cmd --permanent --add-service=kdeconnect
# firewall-cmd --permanent --add-service=syncthing
# firewall-cmd --permanent --add-port=9090/tcp
# firewall-cmd --permanent --add-port=9090/udp
# firewall-cmd --permanent --zone=FedoraServer --add-service=http
# firewall-cmd --permanent --zone=FedoraServer --add-service=https
# firewall-cmd --permanent --zone=FedoraServer --add-service=http3
# firewall-cmd --zone=FedoraServer --remove-service=http
# firewall-cmd --zone=FedoraServer --remove-port=9090/tcp
# firewall-cmd --reload
```

## System

### Kernel arguments

Setting `/etc/modprobe.d/module.conf` does not work on Atomic releases.
Instead, append kernel parameters using `rpm-ostree kargs --append "module.parameter=foo"`.

To list current kernel parameters, use `rpm-ostree kargs` and `rpm-ostree kargs --editor` to open an editor.

### Mount Options

See <https://discussion.fedoraproject.org/t/root-mount-options-are-ignored-in-fedora-atomic-desktops-42/148562> for details.

### Swap

On Fedore CoreOS swap is disabled by default. To enable it:

```bash
# tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
```

Reboot, or force-reload the `systemd-zram-setup` service:

```bash
# systemctl daemon-reload
# systemctl restart systemd-zram-setup@zram0.service
```

### Btrfs

#### Disable CoW

To disable CoW on a specific directory (e.g. for downloads, databases or VMs):

```bash
$ mkdir -p /var/mnt/downloads/appdata/qbittorrent
$ mkdir -p /var/mnt/downloads/data/torrents
# chattr +C /var/mnt/downloads/appdata/qbittorrent
# chattr +C /var/mnt/downloads/data/torrents
$ lsattr -d /var/mnt/downloads/appdata/* /var/mnt/downloads/data/*
```

#### Deduplication

To use deduplication agent [bees](https://github.com/Zygo/bees):

```bash
# btrfs filesystem show /
# cp /etc/bees/beesd.conf.sample /etc/bees/<uuid-from-above>.conf
# nano /etc/bees/<uuid-from-above>.conf
# systemctl start beesd@<uuid-from-above>
```

> Note: Use the UUID from `btrfs filesystem show` output.

## Troubleshooting

### Dark themes not working

See instructions from the Flatpak Breeze repo: <https://github.com/flathub/org.gtk.Gtk3theme.Breeze>

### Error canonicalizing /boot/grub2/grubenv filename: No such file or directory

Create a blank environment block file:

```bash
# grub2-editenv create
```
