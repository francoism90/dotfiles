# Jellyfin

Jellyfin (`media/`) only listens on `127.0.0.1`, so it is reachable through Caddy only (`jellyfin.caddy`). It needs [GPU access](../podman.md#container-templates) and a media bind mount labeled once on the host.

```bash
$ cp -r templates/containers/media ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start jellyfin.service
```

Add `127.0.0.1` to Dashboard → Networking → Known proxies, so Jellyfin sees the real client addresses.
