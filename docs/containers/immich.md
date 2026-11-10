# Immich

Immich (`immich/`) only listens on `127.0.0.1`, so it is reachable through Caddy only (`immich.caddy`). It needs [GPU access](../podman.md#container-templates) and a photos bind mount labeled once on the host. Replace `changeme` in `immich.env` and start the pod:

```bash
$ cp -r templates/containers/immich ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start immich-pod.service
```
