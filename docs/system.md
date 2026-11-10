# System

## Kernel arguments

Setting `/etc/modprobe.d/module.conf` does not work on Atomic releases.
Instead, append kernel parameters using `rpm-ostree kargs --append "module.parameter=foo"`.

To list current kernel parameters, use `rpm-ostree kargs` and `rpm-ostree kargs --editor` to open an editor.

## Mount Options

See <https://discussion.fedoraproject.org/t/root-mount-options-are-ignored-in-fedora-atomic-desktops-42/148562> for details.

## Swap

[personal-os](https://github.com/francoism90/personal-os) images ship zram swap as a drop-in (`/usr/lib/systemd/zram-generator.conf.d/90-personal-os.conf`). Override it per host in `/etc/systemd/zram-generator.conf.d/`.

## Btrfs

### Disable CoW

To disable CoW on a specific directory (e.g. for downloads, databases or VMs):

```bash
$ mkdir -p /var/mnt/downloads/appdata/qbittorrent
$ mkdir -p /var/mnt/downloads/data/torrents
# chattr +C /var/mnt/downloads/appdata/qbittorrent
# chattr +C /var/mnt/downloads/data/torrents
$ lsattr -d /var/mnt/downloads/appdata/* /var/mnt/downloads/data/*
```

### Deduplication

To use deduplication agent [bees](https://github.com/Zygo/bees):

```bash
# btrfs filesystem show /
# cp /etc/bees/beesd.conf.sample /etc/bees/<uuid-from-above>.conf
# nano /etc/bees/<uuid-from-above>.conf
# systemctl start beesd@<uuid-from-above>
```

> Note: Use the UUID from `btrfs filesystem show` output.
