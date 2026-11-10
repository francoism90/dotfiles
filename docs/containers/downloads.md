# qBittorrent and SABnzbd

qBittorrent and SABnzbd (`downloads/`) use host networking, so set their listen address in the apps themselves. Change the address last, as the web UI is only reachable through Caddy afterwards (`qbittorrent.caddy`, `sabnzbd.caddy`):

```bash
$ cp -r templates/containers/downloads ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start qbittorrent.service sabnzbd.service
```

- qBittorrent (Tools → Options → Web UI): enable reverse proxy support with `127.0.0.1` as trusted proxy, and set the IP address to `127.0.0.1`.
- SABnzbd: add the hostname (e.g. `sabnzbd.home.example.com`) to Config → Special → `host_whitelist`, and set Config → General → SABnzbd Host to `127.0.0.1`.
