# Podman

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

Container updates (`podman-auto-update.timer`) are enabled for system and user on personal-os images.

## Container templates

[`templates/containers/`](../templates/containers/) has quadlets grouped per service. Copy a group, replace placeholders (e.g. `changeme` in `immich.env`) and start it:

```bash
$ mkdir -p ~/.config/containers/systemd
$ cp -r templates/containers/immich ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start immich-pod.service
```

Containers using `/dev/dri` (Jellyfin, Immich) need GPU access on the host:

```bash
# setsebool -P container_use_dri_devices on
# bash -c 'for g in render video; do grep -q "^$g:" /etc/group || grep "^$g:" /usr/lib/group >> /etc/group; done'
$ sudo usermod -aG render,video $USER
```

Large data bind mounts (Jellyfin media, Immich photos) skip `Z,U`, as relabeling and chowning them on every start is slow. Set the SELinux label and ownership once instead:

```bash
# semanage fcontext -a -t container_file_t '/mnt/media(/.*)?'
# semanage fcontext -a -t container_file_t '/mnt/photos(/.*)?'
# restorecon -RF /var/mnt/media /var/mnt/photos
$ sudo chown -R $USER:$USER /var/mnt/media /var/mnt/photos
```

Networking:

- Bridge (default): use `PublishPort=` for each port. Keeps containers isolated and is the right choice for most services.
- Host (`Network=host`): use when a service needs LAN discovery (broadcast or multicast, e.g. Syncthing local discovery, DLNA), many dynamic ports, or high throughput and many connections (e.g. qBittorrent, SABnzbd). Rootless bridge traffic goes through a userspace process (`pasta`), which costs CPU per packet. Ports below 1024 still need root or `net.ipv4.ip_unprivileged_port_start`.

Containers use `Restart=on-failure` with `SuccessExitStatus=143`, so a manual stop (e.g. from Cockpit) sticks while crashes still restart.

Setup per app (start with Caddy and AdGuard Home, as the others are reached through them):

- [Caddy](containers/caddy.md): reverse proxy
- [AdGuard Home](containers/adguardhome.md): DNS
- [Homarr](containers/homarr.md): dashboard
- [Glances](containers/glances.md): system monitor
- [Immich](containers/immich.md): photos
- [Jellyfin](containers/jellyfin.md): media
- [Memos](containers/memos.md): notes
- [qBittorrent and SABnzbd](containers/downloads.md): downloads
- [Syncthing](containers/syncthing.md): file sync
- [Vaultwarden](containers/vaultwarden.md): passwords
