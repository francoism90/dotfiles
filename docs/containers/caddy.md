# Caddy

Caddy (`caddy/`) is a reverse proxy with wildcard certificates through the Cloudflare DNS challenge, so no ports have to be opened to the internet. Replace `example.com` in `config/Caddyfile` and `config/sites/` and point the hostnames to the server in your local DNS.

Each site lives in its own file in `config/sites/`, imported by the `Caddyfile`. Remove the sites you don't use, and replace `192.168.1.10` with the address of your NAS. Matcher names (e.g. `@jellyfin`) must be unique across all files. Validate before reloading:

```bash
$ podman exec systemd-caddy caddy validate --config /etc/caddy/Caddyfile
```

Create a Cloudflare API token with `Zone:Zone:Read` and `Zone:DNS:Edit`, scoped to the zone, and store it as a Podman secret. Start the command with a space to keep the token out of your shell history:

```bash
$  printf '%s' '<token>' | podman secret create cloudflare-api-token -
$  printf '%s' '<token>' | podman secret create --replace cloudflare-api-token -
$ podman secret ls
```

Allow rootless containers to bind ports 80 (HTTP to HTTPS redirects) and 443, open the firewall and start Caddy:

```bash
# echo 'net.ipv4.ip_unprivileged_port_start=80' > /etc/sysctl.d/99-unprivileged-ports.conf
# sysctl --system
# firewall-cmd --permanent --add-service=http --add-service=https --add-service=http3
# firewall-cmd --reload
$ cp -r templates/containers/caddy ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start caddy.service
```

The image is built locally, so `podman auto-update` skips it. It is rebuilt on every start, pulling a newer Caddy base image when available. To update, or to apply `Caddyfile` changes without downtime:

```bash
$ systemctl --user restart caddy.service
$ systemctl --user reload caddy.service
```
