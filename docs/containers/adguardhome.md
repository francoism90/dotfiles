# AdGuard Home

AdGuard Home (`dns/`) blocks ads and rewrites `*.home.example.com` to the server, so Caddy gets the requests. DNS (port 53) is served directly; only the web UI goes through Caddy (`adguard.caddy`).

Port 53 conflicts with the systemd-resolved stub listener, and needs a lower unprivileged port start (this replaces the `80` from the [Caddy](caddy.md) step):

```bash
# mkdir -p /etc/systemd/resolved.conf.d
# printf '[Resolve]\nDNSStubListener=no\n' > /etc/systemd/resolved.conf.d/adguardhome.conf
# ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
# systemctl restart systemd-resolved
# echo 'net.ipv4.ip_unprivileged_port_start=53' > /etc/sysctl.d/99-unprivileged-ports.conf
# sysctl --system
# firewall-cmd --permanent --add-service=dns
# firewall-cmd --reload
$ cp -r templates/containers/dns ~/.config/containers/systemd/
$ systemctl --user daemon-reload
$ systemctl --user start adguardhome.service
```

Open `https://adguard.home.example.com` and keep the admin interface on port `3000` in the setup wizard. Add a DNS rewrite for `*.home.example.com` to the server address, and point your router's DHCP DNS to the server.
