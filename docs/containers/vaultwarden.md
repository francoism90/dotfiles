# Vaultwarden

Vaultwarden (`vault/`) only listens on `127.0.0.1`, so it is reachable through Caddy only (`vault.caddy`). Replace `example.com` in `DOMAIN` and start it:

```bash
$ cp -r templates/containers/vault ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start vaultwarden.service
```

Open `https://vault.home.example.com` and create your account. Then set `SIGNUPS_ALLOWED=false` and restart the service, so nobody else can sign up.

Caddy passes the client address in `X-Real-IP`, so failed logins are logged with the real IP. `stream_close_delay` keeps WebSocket connections open for a while after a Caddy reload, instead of closing them right away.
