# Homarr

Homarr (`dashboard/`) only listens on `127.0.0.1`, so it is reachable through Caddy only (`homarr.caddy`). Create the encryption key (keep it, Homarr can't decrypt its data without it) and start it:

```bash
$ openssl rand -hex 32 | tr -d "\n" | podman secret create homarr-encryption-key -
$ cp -r templates/containers/dashboard ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start homarr.service
```

Open `https://homarr.home.example.com` and create your account. For integrations, use `http://169.254.1.3:<port>` (e.g. `:8096` for Jellyfin): it maps to the host's `127.0.0.1`, so Homarr reaches services directly, without DNS or Caddy. The `*.home.example.com` names don't resolve inside the container, as its DNS doesn't know AdGuard's rewrites.

Homarr has no access to the Podman socket. To manage containers, add Cockpit as an app (`https://cockpit.home.example.com/podman`, needs cockpit-podman).
