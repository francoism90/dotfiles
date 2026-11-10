# Administration

## Shell

To change the user shell:

```bash
sudo usermod --shell /bin/fish $USER
```

## Package management

To list all current installed packages:

```bash
rpm -qa
```

To check configuration differences:

```bash
# ostree admin config-diff
```

To update Flatpaks:

```bash
$ flatpak update
# flatpak update --system
```

To repair Flatpaks, which may be needed on upgrades:

```bash
$ flatpak repair --user -vvv
# flatpak repair --system -vvv
```

## Journal

To get the last boot log:

```bash
journalctl --list-boots
journalctl -b -0
```

## Firewalld

To open services and ports, replace `FedoraServer` with the target zone:

```bash
$ firewall-cmd --get-default-zone
$ firewall-cmd --get-active-zones
# firewall-cmd --list-all-zones
# firewall-cmd --list-all
# firewall-cmd --permanent --add-service=kdeconnect
# firewall-cmd --permanent --add-service=syncthing
# firewall-cmd --permanent --add-port=9090/tcp
# firewall-cmd --permanent --add-port=9090/udp
# firewall-cmd --permanent --zone=FedoraServer --add-service=http
# firewall-cmd --permanent --zone=FedoraServer --add-service=https
# firewall-cmd --permanent --zone=FedoraServer --add-service=http3
# firewall-cmd --zone=FedoraServer --remove-service=http
# firewall-cmd --zone=FedoraServer --remove-port=9090/tcp
# firewall-cmd --reload
```
