# dotfiles

This is a selection of settings, notes and preferences for my [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/), [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) and [Fedora IoT](https://fedoraproject.org/iot/) Atomic installations (all are running Fedora 43).

> Note: Commands prepended with `# <command>` should be executed as `root` (`sudo`).

## System

### Maintenance

Useful references:

- <https://docs.fedoraproject.org/en-US/fedora-silverblue/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/tips-and-tricks/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>
- <https://rpmfusion.org/Howto/OSTree>

### Journal

To get the last boot log:

```bash
journalctl --list-boots
journalctl -b -0
```

### Package management

To show differences after upgrades:

```bash
rpm-ostree db diff -c
```

To search for packages:

```bash
rpm-ostree search <term>
```

To install overlay packages:

```bash
# rpm-ostree install <package> --dry-run
# rpm-ostree install <package>
```

To list all installed packages:

```bash
rpm -qa
```

To update Flatpaks:

```bash
flatpak update
```

To repair Flatpaks, which may be needed on upgrades:

```bash
flatpak repair --user -vvv
flatpak repair --system -vvv
```

### Kernel Modules

Setting `/etc/modprobe.d/module.conf` does not work on Atomic releases. Instead, append kernel parameters using `rpm-ostree kargs --append "module.parameter=foo"`.

To list current kernel parameters, use `rpm-ostree kargs` or `rpm-ostree kargs --editor` to open an editor.

#### Realtek RTW89

The Realtek RTW89 has many issues related to power management on Linux. Power management can be disabled by appending:

```bash
rpm-ostree kargs --append "rtw89_pci.disable_aspm_l1=Y rtw89_pci.disable_aspm_l1ss=Y"
```

#### AMD

This section is only relevant for Fedora IoT and CoreOS.

For latest AMD/Intel hardware support, you may want to install firmware packages:

```bash
# rpm-ostree install amd-gpu-firmware amd-ucode-firmware
```

If you need Hardware Video Acceleration support, such as when running Jellyfin:

```bash
# rpm-ostree install mesa-dri-drivers
```

##### Bug: Page flip timeout

If you have `page flip timeouts` (freezing screen) on AMD systems, you may want to disable panel refreshing:

```bash
# rpm-ostree kargs --append "amdgpu.dcdebugmask=0x10"
```

#### NVIDIA

> Tip: You may want to read and perform the steps in Secure Boot first.

Make sure RPMFusion's nvidia repo is enabled:

```bash
# sed -ie 's/enabled=0/enabled=1/g' /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo
# rpm-ostree refresh-md
```

Install the nvidia driver:

```bash
# rpm-ostree install akmod-nvidia
```

Append kernel parameters to prevent the nouveau driver from loading:

```bash
# rpm-ostree kargs --append "rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core"
```

Your final kernel parameters args may look something like this:

```bash
rd.luks.uuid=luks-<uuid> rd.luks.options=tpm2-device=auto rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core amdgpu.dcdebugmask=0x10 rhgb quiet root=UUID=<uuid> rootflags=subvol=root,compress=zstd:1 vconsole.keymap=us rw
```

Reboot to load the NVIDIA driver.

##### Secure Boot

After reboot, the `nvidia` module may reject loading when Secure Boot is enabled.

As a workaround, use <https://github.com/CheariX/silverblue-akmods-keys>.

> Tip: This package may also be used for other modules that need signing, such as VirtualBox.

Make sure the Machine Owner Key (MOK) is enrolled (the key may already exist and be enrolled; do not force):

```bash
# kmodgenca
# mokutil --import /etc/pki/akmods/certs/public_key.der
```

Clone the `silverblue-akmods-keys` project:

```bash
git clone https://github.com/CheariX/silverblue-akmods-keys
cd silverblue-akmods-keys
```

Install required deps:

```bash
rpm-ostree install --apply-live rpmdevtools akmods
```

Build and install the `akmods-keys` package:

```bash
# bash setup.sh
# rpm-ostree install akmods-keys-0.0.2-8.fc$(rpm -E %fedora).noarch.rpm
```

##### Optimus

If the device supports NVIDIA Optimus (e.g. hybrid graphics):

```bash
# systemctl enable nvidia-resume.service nvidia-hibernate.service nvidia-suspend.service nvidia-suspend-then-hibernate.service
```

To make sure the nouveau driver isn't loaded, mask the `nvidia-fallback.service`:

```bash
# systemctl mask nvidia-fallback
```

Reboot the system to apply the changes.

### TPM

> Tip: You may want to add a [passphrase](https://wiki.archlinux.org/title/Systemd-cryptenroll#Regular_password) as fallback.

The following resources may be helpful to set up TPM:

- <https://github.com/stenwt/silverblue-docs/blob/patch-1/modules/ROOT/pages/tips-and-tricks.adoc#enabling-tpm2-for-luks>
- <https://gist.github.com/jdoss/777e8b52c8d88eb87467935769c98a95>
- <https://wiki.archlinux.org/title/Systemd-cryptenroll>
- <https://community.frame.work/t/guide-setup-tpm2-autodecrypt/39005>

To set up TPM2 unlocking, first, find the LUKS device you want to enroll. This is probably in `/etc/crypttab`. You can also use `cryptsetup status /dev/mapper/luks*` to identify the device.

Next, enable the required initramfs and kernel features. Note that the initramfs command below will overwrite any other initramfs changes you have made:

```bash
# rpm-ostree initramfs --enable --arg=-a --arg=systemd-pcrphase
# rpm-ostree kargs --append=rd.luks.options=tpm2-device=auto
```

Identify the disk using `cryptsetup status`, and enroll the key:

```bash
# systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3
```

> Note: Replace `/dev/nvme0n1p3` with your actual LUKS partition. Using PCRs 0+7 may require re-enrollment after firmware/BIOS updates.

Reboot; you should not be prompted to enter your LUKS passphrase on boot.

#### Firmware upgrades

To re-enroll (which may be needed on firmware upgrades) or wipe the current TPM2 slot:

```bash
# systemd-cryptenroll /dev/nvme0n1p3 --wipe-slot=tpm2
```

Afterwards, follow the instructions to enroll the key.

### tuned

You may want to install tuned on IoT machines:

```bash
# rpm-ostree install tuned tuned-profiles-atomic
```

> Tip: You can change the power profile using Cockpit.

### Cockpit

Follow the [installation instructions](https://cockpit-project.org/running.html#coreos).

In addition, you may want to install `cockpit-networkmanager` and `cockpit-files`.

## Filesystem

### Mount Options

See <https://discussion.fedoraproject.org/t/root-mount-options-are-ignored-in-fedora-atomic-desktops-42/148562> for details.

### Trim

Enable the `fstrim` timer:

```bash
# systemctl enable fstrim.timer --now
```

### Encryption

If you are using encryption on an NVMe/SSD, you may want to improve performance by disabling the workqueue and trim support.

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details:

```bash
# cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh /dev/mapper/luks-<uuid>
```

> Note: Replace `<uuid>` with your LUKS device UUID from `/etc/crypttab`.

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

To use [bees](https://github.com/Zygo/bees) (a deduplication agent):

```bash
# btrfs filesystem show /
# rpm-ostree install bees
# cp /etc/bees/beesd.conf.sample /etc/bees/<uuid-from-above>.conf
# nano /etc/bees/<uuid-from-above>.conf
# systemctl start beesd@<uuid-from-above>
```

> Note: Use the UUID from `btrfs filesystem show` output.

## Software

### Toolbox

It is discouraged to install (large) software on the ostree. Try to use Flatpaks and toolboxes (`toolbox create` and `toolbox enter`), and/or [BoxBuddyRS](https://github.com/Dvlv/BoxBuddyRS) as much as possible.

You can pull the latest toolbox using:

```bash
podman pull fedora-toolbox:43
```

To update packages inside a toolbox:

```bash
toolbox enter
sudo dnf update && sudo dnf upgrade
```

You can create multiple toolboxes and even manage them using [Podman Desktop](https://podman-desktop.io/).

### Brave

Depending on your hardware, you may want to enable VA-API and/or Vulkan flags in `~/.var/app/com.brave.Browser/config/brave-flags.conf`.
The example below forces the use of VA-API, but it can be unstable and may need to be adjusted for your GPU vendor(s).

See the following resources for details:

- <https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md#vaapi-on-linux>
- <https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration>

### EasyEffects

See <https://github.com/JackHack96/EasyEffects-Presets> for additional presets.

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
# rpm-ostree install podman-docker podman-compose
# systemctl reboot
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

### Firewalld

To open services and ports:

```bash
# firewall-cmd --get-default-zone
# firewall-cmd --get-active-zones
# firewall-cmd --list-all-zones
# firewall-cmd --list-all
# firewall-cmd --permanent --zone=FedoraWorkstation --add-service=http
# firewall-cmd --permanent --zone=FedoraWorkstation --add-service=https
# firewall-cmd --permanent --zone=FedoraWorkstation --add-service=http3
# firewall-cmd --permanent --zone=FedoraWorkstation --add-service=samba
# firewall-cmd --permanent --zone=FedoraWorkstation --add-port=9090/udp
# firewall-cmd --permanent --zone=FedoraWorkstation --add-port=9090/tcp
# firewall-cmd --zone=FedoraWorkstation --remove-service=http
# firewall-cmd --zone=FedoraWorkstation --remove-port=9090/tcp
# firewall-cmd --reload
```

> Note: Replace `FedoraWorkstation` with your active zone.

### VSCodium / VSCode

See the following guides:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

Install the VSCode Podman SDK extension:

```bash
flatpak install com.visualstudio.code.tool.podman
```

Use Flatpak Permissions in Settings or [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal), and set the following overrides:

- Add to `Other files`: `xdg-run/podman`
- Add to `Other files`: `/tmp`

Use the command to launch `Preferences: Open User Settings (JSON)`, and append the following:

```json
"dev.containers.dockerPath": "/app/tools/podman/bin/podman-remote",
"dev.containers.dockerSocketPath": "/run/user/1000/podman/podman.sock",
"dev.containers.logLevel": "info"
```

> Note: Replace `1000` with your actual UID (run `id -u` to find it).

#### Wayland

To enable Wayland support:

```bash
flatpak override --user --socket=wayland --socket=fallback-x11 --env=ELECTRON_OZONE_PLATFORM_HINT=auto com.visualstudio.code
```

See <https://github.com/flathub/com.visualstudio.code/issues/471> for details.

### Samba

See <https://fedoraproject.org/wiki/SELinux/samba> for details:

```bash
# rpm-ostree install samba
# systemctl enable smb --now
```

> Note: You can also use SSHFS as an alternative.

### Solaar

To start [Solaar](https://flathub.org/en/apps/io.github.pwr_solaar.solaar) on startup and with the window hidden:

```bash
flatpak run --branch=stable --arch=x86_64 --command=solaar io.github.pwr_solaar.solaar --window=hide
```

> Note: Install the [udev rule](https://github.com/flathub/io.github.pwr_solaar.solaar#udev-rule) for Wayland to `/etc/udev/rules.d/42-logitech-unify-permissions.rules`.

### Fish

> Note: Set `/usr/bin/fish` as the shell in your terminal application.

Install fish:

```bash
# rpm-ostree install fish
```

To change the user's shell:

```bash
chsh -s /usr/bin/fish <user>
```

Add user-local bin to fish path:

```fish
fish_add_path ~/.local/bin
```

To disable the greeting (welcome message):

```fish
set -U fish_greeting
```

Follow <https://starship.rs/guide/> to enable oh-my-zsh-like features for fish-shell.

## Troubleshooting

### Dark themes not working

See instructions from the Flatpak Breeze repo: <https://github.com/flathub/org.gtk.Gtk3theme.Breeze>

### Error canonicalizing /boot/grub2/grubenv filename: No such file or directory

Create a blank environment block file:

```bash
# grub2-editenv create
```
