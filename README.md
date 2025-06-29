# dotfiles

This is a selection of settings, notes and preferences for my [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/), [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) and [Fedora IoT](https://fedoraproject.org/iot/) installations.

> Note: Commands prepend with `# <command>` should be executed as `root` (`sudo`).

## System

### Maintenance

Useful references:

- <https://docs.fedoraproject.org/en-US/fedora-silverblue/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/tips-and-tricks/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>
- <https://rpmfusion.org/Howto/OSTree>

### Package management

To show difference after upgrades:

```bash
rpm-ostree db diff -c
```

To search for packages:

```bash
rpm-ostree search <term>
```

To install an overlay packages:

```bash
rpm-ostree install <package>
```

To list all installed packages:

```bash
rpm -qa
```

### Firmware

Fedora IoT only has a limited firmware setup.

For AMD/Intel, you may want to install the `ucode` package (with GPU firmware):

```bash
rpm-ostree install amd-gpu-firmware amd-ucode-firmware
```

If you need `dri` support:

```bash
rpm-ostree install mesa-dri-drivers
```

### NVIDIA (Optimus)

> Tip: You may want to apply the steps in Secure Boot subsection first.

See the following sources for more information:

- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/#_using_nvidia_drivers>
- <https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#OSTree_.28Silverblue.2FKinoite.2Fetc.29>
- <https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#Kernel_Open>

```bash
# rpm-ostree install kmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-power nvidia-modprobe nvidia-persistenced nvidia-settings
# rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova-core --append=modprobe.blacklist=nouveau,nova-core --append=nvidia-drm.modeset=1 --append=initcall_blacklist=simpledrm_platform_driver_init
# systemctl enable nvidia-{suspend,resume,hibernate,persistenced}
systemctl reboot
```

#### Secure Boot

See <https://github.com/CheariX/silverblue-akmods-keys> for more details:

```bash
# rpm-ostree install rpmdevtools akmods
```

Install Machine Owner Key (MOK) - (the key may already exists - you don't have to overwrite):

```bash
# kmodgenca
# mokutil --import /etc/pki/akmods/certs/public_key.der
```

Clone the silverblue-akmods-keys project:

```bash
git clone https://github.com/CheariX/silverblue-akmods-keys
cd silverblue-akmods-keys
```

To allow building with the NVIDIA open driver (recommended if supported):

```bash
echo "%_with_kmod_nvidia_open 1" >> macros.kmodtool
```

Build akmods-keys:

```bash
# bash setup.sh
# rpm-ostree install akmods-keys-0.0.2-8.fc$(rpm -E %fedora).noarch.rpm
```

### TPM

> Tip: You may want to add a [passphrase](https://wiki.archlinux.org/title/Systemd-cryptenroll#Regular_password) as fallback.

The following resources may be helpful to setup TPM:

- <https://github.com/stenwt/silverblue-docs/blob/patch-1/modules/ROOT/pages/tips-and-tricks.adoc#enabling-tpm2-for-luks>
- <https://gist.github.com/jdoss/777e8b52c8d88eb87467935769c98a95>
- <https://wiki.archlinux.org/title/Systemd-cryptenroll>
- <https://community.frame.work/t/guide-setup-tpm2-autodecrypt/39005>

To set up TPM2 unlocking, first, find the LUKS device you want to enroll. This is probably in `/etc/crypttab`. You can also use `cryptsetup status /dev/mapper/luks*` to identify the device.

Next, enable the required initramfs and kernel features. Note that the initramfs command below will overwrite any other initramfs changes you have made:

```bash
# rpm-ostree kargs --append=rd.luks.options=tpm2-device=auto
# rpm-ostree initramfs --enable --arg=-a --arg=systemd-pcrphase
```

Then, using the device you identified with 'cryptsetup status' previously, enroll the device:

```bash
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3
```

Reboot; you should not be prompted to enter your LUKS passphrase on boot.

### tuned

You may want to install tuned on IoT-matchines:

```bash
rpm-ostree install tuned tuned-profiles-atomic
```

### Cockpit

Follow the [installation instructions](https://cockpit-project.org/running.html#coreos).

In addition you want to install `cockpit-networkmanager` and  `cockpit-files`.

## Filesystem

### Trim

Enable the `fstrim` timer:

```bash
# systemctl enable fstrim.timer --now
```

### Encryption

If you are using encryption on a NVMe/SSD, you may want to improve performance by disabling the workqueue.

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details.

### Btrfs

If you are using Btrfs, you may want to use <https://github.com/kdave/btrfsmaintenance>:

```bash
# rpm-ostree install btrfsmaintenance
# nano /etc/sysconfig/btrfsmaintenance
```

Enable the timers:

```bash
# systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
```

## Software

### Toolbox

It is discourage to install (large) software on the ostree. Try to use Flatpaks and toolboxes (`toolbox create` and `toolbox enter`) as much as possible.

You can pull the latest toolbox, using:

```bash
podman pull fedora-toolbox:42
```

To update a toolbox:

```bash
toolbox enter
sudo dnf update && sudo dnf upgrade
```

You can create multiple toolboxes, and even manage them using [Podman Desktop](https://podman-desktop.io/).

### Brave

Depending on your hardware, you may need to enable/disable different flags. See <https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md#vaapi-on-linux> for details.

### Podman

Enable and use rootless containers:

- <https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md>
- <https://wiki.archlinux.org/title/Podman#Rootless_Podman>

To learn more about Podman Quadlet, the following resources may be useful:

- <https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html>
- <https://www.redhat.com/sysadmin/quadlet-podman>
- <https://mo8it.com/blog/quadlet/>

To install Docker compatible packages:

```bash
rpm-ostree install podman-docker podman-compose
systemctl reboot
```

Enable linger (e.g. keep containers running after logging out):

```bash
loginctl enable-linger $USER
```

To automatically manage container updates:

```bash
# systemctl enable podman-auto-update.timer --now
systemctl --user enable podman-auto-update.timer --now
```

### Firewall(d)

To open services and ports:

```bash
# firewall-cmd --get-active-zones
# firewall-cmd --list-all-zones
# firewall-cmd --permanent --add-service=http
# firewall-cmd --permanent --add-service=https
# firewall-cmd --permanent --add-service=http3
# firewall-cmd --permanent --add-service=samba
# firewall-cmd --permanent --zone=FedoraServer --add-port=9090/tcp
# firewall-cmd --reload
```

### VSCodium / VSCode

See the following guides:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

You may want to use [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal), and set the following overwrites:

- Add to `Other files`: `xdg-run/podman`
- Add to `Other files`: `/tmp`

Use the command to launch `Preferences: Open User Settings (JSON)`, and append the following:

```bash
"dev.containers.dockerPath": "/app/tools/podman/bin/podman-remote",
"dev.containers.dockerSocketPath": "/run/user/1000/podman/podman.sock",
"dev.containers.logLevel": "info",
```

#### Wayland

To enable Wayland support:

```bash
flatpak override --user --socket=wayland --socket=fallback-x11 --env=ELECTRON_OZONE_PLATFORM_HINT=auto com.visualstudio.code
```

See <https://github.com/flathub/com.visualstudio.code/issues/471> for details.

### Samba

See <https://fedoraproject.org/wiki/SELinux/samba> for details.

### Fish

> Note: Change the shell to use in terminal application (`/usr/bin/fish`).

Install fish:

```bash
# rpm-ostree install fish
```

Add fish path lookups:

```fish
fish_add_path ~/.local/bin
```

To disable greeting (welcome message):

```fish
set -U fish_greeting
```

Follow <https://starship.rs/guide/> to enable oh-my-zsh features for fish-shell.
