# Memos

Memos (`memos/`) only listens on `127.0.0.1`, so it is reachable through Caddy only (`memos.caddy`). It stores its data in SQLite in the `memos-data` volume. Start it:

```bash
$ cp -r templates/containers/memos ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start memos.service
```

Open `https://memos.home.example.com` and create your account (the first one becomes the admin). Then disable registration in Settings → System, so nobody else can sign up.
