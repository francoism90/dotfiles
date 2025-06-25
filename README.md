# dotfiles

This is a selection of settings, notes and preferences for my [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/), [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/) and [Fedora CoreOS](https://fedoraproject.org/coreos/) installations.

> Note: Commands prepend with `# <command>` should be executed as `root` (sudo).

## System

### Maintenance

References:

- <https://rpmfusion.org/Howto/OSTree>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>

To show difference after upgrades:

```bash
rpm-ostree db diff -c
```

To search for packages:

```bash
rpm-ostree search <term>
```

### NVIDIA

> Tip: You may want to apply the steps in Secure Boot first.

See the following sources for more information:

- <https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#OSTree_.28Silverblue.2FKinoite.2Fetc.29>
- <https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#Kernel_Open>

```bash
# rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-power
# systemctl enable nvidia-{suspend,resume,hibernate} --now
```

#### Secure Boot

See <https://github.com/CheariX/silverblue-akmods-keys> for more details:

```bash
# rpm-ostree install rpmdevtools akmods
```

Install Machine Owner Key (MOK) - the key may already exists:

```bash
# kmodgenca
# mokutil --import /etc/pki/akmods/certs/public_key.der
```

Clone the project:

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

- <https://gist.github.com/jdoss/777e8b52c8d88eb87467935769c98a95>
- <https://wiki.archlinux.org/title/Systemd-cryptenroll>
- <https://community.frame.work/t/guide-setup-tpm2-autodecrypt/39005>

### nofile

Increasing `nofile` limits may be needed for certain applications and games to work.

See <https://access.redhat.com/solutions/1257953> for more details.

> **NOTE:** Reboot the system to apply increased limits.

## Filesystem

### Trim

Enable the `fstrim` timer:

```bash
sudo systemctl enable fstrim.timer --now
```

### Encryption

If you are using encryption on a NVMe/SSD, you may want to improve performance by disabling the workqueue.

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details.

### Btrfs

If you are using Btrfs, you may want to use <https://github.com/kdave/btrfsmaintenance>:

```bash
rpm-ostree install btrfsmaintenance
nano /etc/sysconfig/btrfsmaintenance
```

Enable the timers:

```bash
sudo systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
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

### Firefox

To replace the provided default Firefox package, with the Firefox Flathub version for example:

```bash
rpm-ostree override remove firefox firefox-langpacks
```

> **NOTE:** You can also hide the desktop entry itself.

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

### Firewall(d)

To open services and ports:

```bash
sudo firewall-cmd --list-all-zones
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=http3
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --permanent --zone=FedoraServer --add-port=8096/tcp
sudo firewall-cmd --reload
```

### VSCodium / VSCode

See the following guides:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

You may want to use [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal), and set the following overwrites:

- Add to `Other files`: `xdg-run/podman`
- Add to `Other files`: `/tmp`

#### Wayland

To enable Wayland support:

```bash
flatpak override --user --socket=wayland --socket=fallback-x11 --env=ELECTRON_OZONE_PLATFORM_HINT=auto com.visualstudio.code
```

See <https://github.com/flathub/com.visualstudio.code/issues/471> for details.

### Ptyxis (Terminal)

To apply opacity ([credits](https://discussion.fedoraproject.org/t/use-dconf-to-set-transparency-for-ptyxis/135003)):

```bash
dconf read /org/gnome/Ptyxis/default-profile-uuid
dconf write /org/gnome/Ptyxis/Profiles/{profile-uuid}/opacity 0.95
```

#### Fish

> Note: Change the shell to use in Konsole (or any terminal application).

Install fish:

```bash
# rpm-ostree install fish
```

Add fish path lookups:

```fish
fish_add_path  ~/.local/bin ~/.config/yarn/global/node_modules/.bin
```

To disable greeting (welcome message):

```fish
set -U fish_greeting
```

Follow <https://starship.rs/guide/> to offer oh-my-zsh features to fish.
