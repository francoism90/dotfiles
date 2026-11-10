# Syncthing

Syncthing (`sync/`) uses host networking for local discovery. The GUI only listens on `127.0.0.1`, so it is reachable through Caddy only (`syncthing.caddy`).

```bash
$ cp -r templates/containers/sync ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start syncthing.service
```

Set a GUI password.
