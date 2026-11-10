# Glances

Glances (`monitor/`) uses the host PID namespace and network to see host processes and interfaces. The web UI only listens on `127.0.0.1`, so it is reachable through Caddy only (`glances.caddy`).

```bash
$ cp -r templates/containers/monitor ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start glances.service
```

Glances has no login by default, and its API exposes the process list. Keep it off the internet.

The container only sees its own mounts. To show disk usage, add a read-only `Volume=` per data disk (see the comment in `glances.container`).

Glances has no access to the Podman socket, so the containers plugin is empty. Use Cockpit for containers.
