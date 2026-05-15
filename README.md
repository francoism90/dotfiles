# dotfiles

This is a selection of settings, notes and preferences for my devices.

## System

### Maintenance

Useful references:

- <https://secureblue.dev/>
- <https://docs.getaurora.dev/>
- <https://github.com/ublue-os/ucore>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/tips-and-tricks/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>
- <https://rpmfusion.org/Howto/OSTree>

### Journal

To get the last boot log:

```bash
$ journalctl --list-boots
$ journalctl -b -0
```

### Package management

To upgrade on ublue images:

```bash
$ ujust update-system
```

To upgrade on CoreOS images:

```bash
$ rpm-ostree upgrade
```

To show a changelog after upgrades:

```bash
$ rpm-ostree db diff -c
```

To search for packages:

```bash
$ rpm-ostree search <term>
```

To install overlay packages (only when needed, e.g. kernel modules):

```bash
# rpm-ostree install <package> --dry-run
# rpm-ostree install <package>
```

To list all current installed packages:

```bash
$ rpm -qa
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

To upgrade Homebrew packages on ublue images:

```bash
brew update; brew upgrade; brew cleanup
```

### LUKS TPM unlock

```bash
$ ujust setup-luks-tpm-unlock
```

### Upgrade firmwares

```bash
$ ujust update-firmware
```

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

#### Maintenance Scripts

If you are using Btrfs, you may want to use <https://github.com/kdave/btrfsmaintenance>:

```bash
# rpm-ostree install btrfsmaintenance
# nano /etc/sysconfig/btrfsmaintenance
```

Enable the timers:

```bash
# systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
```

#### Disable CoW

To disable CoW on a specific directory (e.g. for downloads, databases or VMs):

```bash
# chattr +C /var/mnt/downloads
```

#### Deduplication

To use [bees](https://github.com/Zygo/bees) (a deduplication agent):

```bash
# btrfs filesystem show /
# rpm-ostree install bees
# cp /etc/bees/beesd.conf.sample /etc/bees/<uuid-from-above>.conf
# nano /etc/bees/<uuid-from-above>.conf
# systemctl start beesd@<uuid-from-above>
```

> Note: Use the UUID from `btrfs filesystem show` output.

## Hardware

Setting `/etc/modprobe.d/module.conf` does not work on Atomic releases. Instead, append kernel parameters using `rpm-ostree kargs --append "module.parameter=foo"`.

To list current kernel parameters, use `rpm-ostree kargs` and `rpm-ostree kargs --editor` to open an editor.

### AMDGPU

For latest AMD/Intel hardware support, you may want to install firmware packages:

> Note: This is only relevant for Fedora IoT and CoreOS.

```bash
# rpm-ostree install amd-gpu-firmware amd-ucode-firmware
```

#### Bug: Page flip timeout

If you have `page flip timeouts` (freezing screen) on AMD systems, you may want to disable panel refreshing:

```bash
# rpm-ostree kargs --append "amdgpu.dcdebugmask=0x10"
```

### Intel

#### Xe driver

See <https://wiki.archlinux.org/title/Intel_graphics#Testing_the_new_experimental_Xe_driver> for details.

Note your PCI ID with:

```bash
$ lspci -nnd ::03xx
03:00.0 VGA compatible controller [0300]: Intel Corporation DG2 [Arc A310] [8086:56a6] (rev 05)
```

To test the new experimental Xe driver, append the following kernel parameters:

```bash
# rpm-ostree kargs --append="i915.force_probe=foo" --append="xe.force_probe=56a6"
```

### Realtek RTW89

The Realtek RTW89 module may have issues related to power management on Linux. Power management can be disabled by appending:

```bash
# rpm-ostree kargs --append "rtw89_pci.disable_aspm_l1=y rtw89_pci.disable_aspm_l1ss=y"
```

## Software

### Toolbox

It is discouraged to install (large) software on the ostree. Try to use Flatpaks, Distroboxes and toolboxes (`toolbox create` and `toolbox enter`) as alternatives.

You can pull the latest toolbox using:

```bash
$ podman pull fedora-toolbox:44
```

To update packages inside a toolbox:

```bash
$ toolbox enter
# dnf update && dnf upgrade
```

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

On Secureblue (rootless) container images may be blocked by the policy, to allow everything (insecure):

```bash
mkdir -p $HOME/.config/containers && \
jq '.transports.docker["docker.io"] = [{"type": "insecureAcceptAnything"}] | 
    .transports.docker["localhost"] = [{"type": "insecureAcceptAnything"}] | 
    .transports["containers-storage"] = {"": [{"type": "insecureAcceptAnything"}]}' \
    /usr/etc/containers/policy.json > $HOME/.config/containers/policy.json
```

To install Docker compatible packages:

```bash
$ ujust install-docker
```

Enable linger (e.g. keep containers running after logging out):

```bash
$ loginctl enable-linger $USER
```

To automatically manage container updates:

```bash
# systemctl enable podman-auto-update.timer --now
$ systemctl --user enable podman-auto-update.timer --now
```

### Firewalld

To open services and ports:

```bash
$ firewall-cmd --get-default-zone
$ firewall-cmd --get-active-zones
# firewall-cmd --list-all-zones
# firewall-cmd --list-all
# firewall-cmd --permanent --add-service=kdeconnect
# firewall-cmd --permanent --add-service=syncthing
# firewall-cmd --permanent --add-port=22000/tcp
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

Install the VSCode Podman SDK (stable) extension:

```bash
$ flatpak install --system com.visualstudio.code.tool.podman
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
$ flatpak override --user --socket=wayland --socket=fallback-x11 --env=ELECTRON_OZONE_PLATFORM_HINT=auto com.visualstudio.code
```

See <https://github.com/flathub/com.visualstudio.code/issues/471> for details.

### Solaar

Install the [udev rule](https://github.com/flathub/io.github.pwr_solaar.solaar#udev-rule) for Wayland to `/etc/udev/rules.d/42-logitech-unify-permissions.rules`.

To start [Solaar](https://flathub.org/en/apps/io.github.pwr_solaar.solaar) on startup and with the window hidden:

```bash
flatpak run --branch=stable --arch=x86_64 --command=solaar io.github.pwr_solaar.solaar --window=hide
```

### Fish

> Note: Set `/usr/bin/fish` as the shell in your terminal application.

Install fish:

```bash
$ brew install fish
```

To change the user's shell (set the default shell in Konsole instead):

```bash
$ chsh -s /usr/bin/fish <user>
```

Add user-local bin to fish path:

```fish
$ fish_add_path ~/.local/bin
```

To disable the greeting (welcome message):

```fish
$ set -U fish_greeting
```

For distrobox containers:

```fish
$ alias --save arch 'distrobox enter arch -- fish'
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
