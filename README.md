# dotfiles

This is a selection of settings, notes and preferences for my personal OpenSUSE [Aeon Desktop](https://aeondesktop.github.io/) and [MicroOS](https://microos.opensuse.org/) installation.

Hopefully the provided instructions are useful. :)

> Note: Commands prepend with `# <command>` should be executed as `root`, `$ <command>` as your normal user.

## System

To learn more about `transactional-update`: <https://kubic.opensuse.org/documentation/man-pages/transactional-update.8.html>.

For example, you may want to append the `--continue` and `-i` args to the `transaction-update` command when needed.

### Updating

> Note: Aeon and MicroOS only run the `transactional-update.timer` when plugged into AC.

To update the system automatically:

```bash
# systemctl enable transactional-update.timer transactional-update-cleanup.timer --now
```

To update the system manually, the preferred approach is to always use `dup`:

```bash
# transactional-update dup
# transactional-update reboot
```

To manage [automatic rebooting](https://github.com/SUSE/rebootmgr):

```bash
# mkdir -p /etc/rebootmgr
# cp /usr/share/rebootmgr/rebootmgr.conf /etc/rebootmgr/rebootmgr.conf
```

To update Flatpaks:

```bash
$ flatpak update
# flatpak update
```

### Maintenance

To clean-up old snapshots (also see <https://wiki.archlinux.org/title/Snapper#Delete_a_snapshot>):

```bash
# transactional-update cleanup
```

To install packages (only when needed):

```bash
# transactional-update pkg in <pkg1> <pkg2>
```

To continue on ongoing changes:

```bash
# transactional-update --continue <command>
# transactional-update --continue pkg in <pkg3>
```

To apply changes live (a reboot is always preferred):

```bash
# transactional-update apply
```

To view current repositories:

```bash
zypper lr
```

To view the packages installed by a repository:

```bash
zypper search -i -r <repo alias|#|URI>
zypper search -i -r packman
```

To list every package in a repository:

```bash
zypper pa -ir packman
```

To search for packages including versions:

```bash
zypper search -s <pkg>
zypper search -s --installed-only <pkg>
```

The following command may be useful when dealing with repo changes, however note this can be dangerous(!):

```bash
sudo transactional-update shell
zypper refresh --force
zypper dup --remove-orphaned --allow-name-change --allow-vendor-change
```

## Hardware

### Encryption (luks)

If you are using encryption on a NVMe/SSD, you may want to improve performance by disabling the workqueue and allow discards (e.g. trim):

```bash
# cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --allow-discards --persistent refresh aeon_root
```

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details.

### TPM

> Tip: You may want to add a [passphrase](https://wiki.archlinux.org/title/Systemd-cryptenroll#Regular_password) as fallback.

The following resources may be helpful:

- <https://en.opensuse.org/Portal:MicroOS/FDE>
- <https://github.com/openSUSE/sdbootutil/issues/118#issuecomment-2665975124>
- <https://gist.github.com/jdoss/777e8b52c8d88eb87467935769c98a95>
- <https://community.frame.work/t/guide-setup-tpm2-autodecrypt/39005>
- <https://wiki.archlinux.org/title/Systemd-cryptenroll>

If you use Full Disk Encryption (FDE) with a TPM, make sure to (re)enroll when needed (this may happen on an UEFI firmware update):

```bash
# SYSTEMD_LOG_LEVEL=debug sdbootutil --ask-pin update-predictions
```

To verify the current enrollment for an encryption partition:

```bash
# systemd-cryptenroll /dev/nvme0n1p2
SLOT TYPE
   0 password
   1 tpm2
   2 recovery
```

If for some reason the enrollment wasn't successful, you may want to reset the TPM and enroll a new key:

```bash
# sdbootutil unenroll --method=tpm2
# sdbootutil enroll --method=tpm2 --ask-pw
```

If for some reason you want to manually enroll:

```bash
# cat /etc/sysconfig/fde-tools | grep FDE_SEAL_PCR_LIST=
# systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=4+5+7+9 /dev/nvme0n1p2
```

> Please note this may require a couple of reboots, and possibly a TPM reset in the BIOS as well.

### tuned (power-management)

To enable [tuned](https://github.com/redhat-performance/tuned) when using MicroOS:

```bash
# transactional-update pkg in tuned tuned-profiles-atomic tuned-utils
# systemctl enable tuned --now
# tuned-adm profile atomic-host
# tuned-adm profile
```

> Tip: Other tuned profiles exists, e.g. database servers and powersaving profiles.

### NVIDIA (open-driver - recommended)

Make sure to apply to following adjustments first:
- <https://en.opensuse.org/SDB:NVIDIA_drivers>
- <https://en.opensuse.org/SDB:NVIDIA_drivers#Via_terminal_on_Aeon,_Kalpa,_Leap_Micro>

See <https://sndirsch.github.io/nvidia/2022/06/07/nvidia-opengpu.html> for details:

```bash
# transactional-update shell
# zypper in openSUSE-repos-MicroOS-NVIDIA
# zypper in nvidia-open-driver-G06-signed-kmp-default
# version=$(rpm -qa --queryformat '%{VERSION}\n' nvidia-open-driver-G06-signed-kmp-default | cut -d "_" -f1 | sort -u | tail -n 1)
zypper in nvidia-video-G06 == ${version} nvidia-compute-utils-G06 == ${version}
# zypper in nvidia-settings
# dracut -vf --regenerate-all
# exit
# systemctl reboot
```

Reboot the system, and validate if `dmesg` can load the NVIDIA driver:

```bash
NVRM: loading NVIDIA UNIX Open Kernel Module for x86_64  570.124.04  Release Build  (abuild@host)  Tue Mar  4 11:08:41 UTC 2025
```

> Note: See [SDB:NVIDIA Switcheroo Control](https://en.opensuse.org/SDB:NVIDIA_Switcheroo_Control) when using a device with Optimus (e.g. AMD/Intel + NVIDIA GPU).

### NVIDIA (closed-driver)

See [SDB:NVIDIA_drivers](https://en.opensuse.org/SDB:NVIDIA_drivers) for details.

You may get conflicts or warnings, it seems to work fine when you choose to ignore the missing library or package.
This seems to happen because the actual depency hasn't been provided yet. It's recommended to keep the snapshot without the NVIDIA drivers applied, just to always to be able to return to a clean state.

#### Secure Boot

If you use Secure Boot, make sure to always sign the nvidia.ko module (you may need to re-import this on UEFI-updates):

```bash
# mokutil --import /usr/share/nvidia-pubkeys/MOK-nvidia-driver-<version>-default.der
```

After a reboot, enroll the key using the provided password, and validate if the NVIDIA modules are loaded using something like `lsmod | grep nv` after startup.

### Kernel

> Note: only do this for testing or troubleshooting, it's recommended to always use the provided kernel instead.

If you want to run the latest [next/master kernel](<https://kernel.opensuse.org/master.html>):

```bash
# transactional-update shell
# zypper addrepo https://download.opensuse.org/repositories/Kernel:HEAD/standard/Kernel:HEAD.repo
# zypper refresh --force
# zypper install kernel-default-6.14~rc5 kernel-default-devel-6.14~rc5
# dracut -vf --regenerate-all
# exit
# systemctl reboot
```

> Note: you may need to remove older kernel versions manually, e.g. `zypper remove kernel-default-6.14~rc4 kernel-default-devel-6.14~rc4`.

#### Patching NVIDIA drivers

To built the latest NVIDIA drivers on a different kernel compared to main, see <https://forums.developer.nvidia.com/t/570-release-feedback-discussion/321956/70?page=3>:

```bash
# transactional-update shell
# cd /usr/src/kernel-modules/nvidia-<version>-default
# <patch> (if needed)
# dracut -vf --regenerate-all
# mokutil --import /usr/share/nvidia-pubkeys/MOK-nvidia-driver-<version>-default.der
# exit
# systemctl reboot
```

### Filesystem

#### Trim

To use periodic trimming, enable the `fstrim.timer` when using SSD/NVMe-drives:

```bash
# systemctl enable fstrim.timer --now
```

#### Btrfs

If you are using Btrfs, you may want to configure <https://github.com/kdave/btrfsmaintenance>:

```bash
# vi /etc/sysconfig/btrfsmaintenance
```

Enable the Btrfs maintenance timers:

```bash
# systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
```

To use [bees](https://github.com/Zygo/bees) (dedupe agent):

```bash
# transactional-update pkg in bees
# cp /etc/bees/beesd.conf.sample /etc/bees/<uuid>.conf
# nano /etc/bees/<uuid>.conf
# systemctl start beesd@<uuid>
```

#### zram (swap)

To enable [zwramswap](https://wiki.archlinux.org/title/Zram#Using_zramswap):

```bash
# transactional-update pkg in systemd-zram-service
# systemctl enable zramswap --now
```

## Software

It is discourage to install packages on the root filesystem, see the [Aeon Wiki](<https://en.opensuse.org/Portal:Aeon/SoftwareInstall>) for details.

You can use [BoxBuddy](https://github.com/Dvlv/BoxBuddyRS), [distrobox](https://github.com/89luca89/distrobox), and [Podman](https://github.com/containers/podman) instead.

### Fish

[Fish shell](https://fishshell.com/) can be used in a distrobox, and be set it as default container in Ptyxis and/or BoxBuddy.

Use BoxBuddy to create a container with the `opensuse/distrobox:latest` image (or prefered), afterwards install:

```bash
# zypper install fish starship
```

> Note: Follow <https://starship.rs/guide/> to setup Starship.

To add fish path lookups:

```fish
fish_add_path ~/.local/bin
```

To disable greeting (welcome message):

```fish
set -U fish_greeting
```

### Firewall

Aeon doesn't come with any firewall, this is by design. Instead you should control ports and services using Podman Quadlet, Flatpak and containers. On MicroOS firewalld should be included.

It's still possible to install `firewalld` on Aeon, but this may cause Flatpak/container network issues and is unsupported:

```bash
# transactional-update pkg in firewalld firewalld-bash-completion
# systemctl enable firewalld --now
```

To open ports/services:

```bash
# firewall-cmd --permanent --add-service=https
# firewall-cmd --permanent --add-port=8920/tcp
# firewall-cmd --reload
```

### Podman

To learn more about Podman Quadlet, see the following resources:

- <https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html>
- <https://www.redhat.com/sysadmin/quadlet-podman>
- <https://mo8it.com/blog/quadlet/>

To enable and use rootless containers:

- <https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md>
- <https://wiki.archlinux.org/title/Podman#Rootless_Podman>

To enable linger, e.g. keep containers running when logged out:

```bash
$ loginctl enable-linger $USER
# loginctl enable-linger root
```

### Codecs

> Note this is unsupported, and should only be needed if you want to use codecs outsides Flatpaks and containers (e.g. for audio devices).

You may need to install [codecs](https://en.opensuse.org/SDB:Installing_codecs_from_Packman_repositories) for additional audio and video support.

It is recommended to install the packages you need, as installing the full package using `oci` may break your system or cause version conflicts.

For full instructions, see <https://en.opensuse.org/SDB:Installing_codecs_from_Packman_repositories>.

### Brave

Depending on your hardware, you may want to enable VA-API and/or Vulkan flags in `~/.var/app/com.brave.Browser/config/brave-flags.conf`.
The given example forces the usage of VA-API, but it can be unstable and may need to be adjusted for your GPU-vendor(s).

See the following resources for details:

- <https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md#vaapi-on-linux>
- <https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration>

### VSCodium / VSCode

The following resources may be useful when you want to use devcontainers and Podman integration:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

You may want to use [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal) to set the following overwrites:

- Add to `Other files`: `xdg-run/podman:ro`
- Add to `Other files`: `/tmp:rw`

#### Wayland

To enable Wayland support:

```bash
flatpak override --user --socket=wayland --socket=fallback-x11 --env=ELECTRON_OZONE_PLATFORM_HINT=auto com.visualstudio.code
```

See <https://github.com/flathub/com.visualstudio.code/issues/471> for details.

### Samba (filesharing)

See the following links for details:

- <https://doc.opensuse.org/documentation/leap/reference/html/book-reference/cha-samba.html>
- <https://wiki.archlinux.org/title/Samba>

To install Samba:

```bash
# transactional-update pkg in samba
# smbpasswd -a <username>
# systemctl enable smb nmb --now
```

When you use firewalld:

```bash
# systemctl enable firewalld --now
# firewall-cmd --permanent --add-service={samba,samba-client,samba-dc}
# firewall-cmd --reload
```

To allow the sharing of home folders:

```bash
# setsebool -P samba_enable_home_dirs 1
# systemctl restart smb nmb
```

### Ptyxis (Terminal)

To apply opacity ([credits](https://discussion.fedoraproject.org/t/use-dconf-to-set-transparency-for-ptyxis/135003)):

```bash
dconf read /org/gnome/Ptyxis/default-profile-uuid
dconf write /org/gnome/Ptyxis/Profiles/{profile-uuid}/opacity 0.95
```

## Appearance

See <https://itsfoss.com/flatpak-app-apply-theme/> instructions for Flatpak theming.

Use [Refine](https://flathub.org/apps/page.tesk.Refine) to apply customization or [dconf-editor](https://flathub.org/apps/ca.desrt.dconf-editor) - look up keys in `/org/gnome/`.

### Current Theme

Icon Theme (GTK - non-root): <https://github.com/PapirusDevelopmentTeam/papirus-icon-theme>

Cursor Theme: <https://github.com/phisch/phinger-cursors>

Fonts: Adwaita Fonts + [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
