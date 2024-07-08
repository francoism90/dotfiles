# Fedora Silverblue - Postinstall

Personal settings for Fedora Silverblue, with lovely help from:

- <https://rpmfusion.org/Howto/OSTree>
- <https://github.com/iaacornus/silverblue-postinstall_upgrade>

## Maintenance

```bash
rpm-ostree upgrade
flatpak repair
flatpak uninstall -y --unused
flatpak update -y --appstream
```

## RPM Fusion

RPM Fusion provides software that the Fedora Project or Red Hat doesn't want to ship.
See <https://rpmfusion.org/RPM%20Fusion> for details.

Add the repositories:

```bash
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
systemctl reboot
```

You can now install overlayed packages or packages inside a toolbox from RPM Fusion.

### Upgrading

To upgrade on major releases, e.g. Fedora Silverblue 39 > 40:

```bash
rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release \
    --install rpmfusion-free-release --install rpmfusion-nonfree-release
```

If you ever get in trouble on upgrading, you can reset the current ostree (create a backup first):

```bash
rpm-ostree status
rpm-ostree reset
systemctl reboot
```

Redo the giving steps and reinstall your packages.

## nofile

Increasing `nofile` limits may be needed for certain applications and games to work.

Append the following to `/etc/security/limits.conf`:

```bash
$ cat /etc/security/limits.conf
*           hard    nofile  65535
*           soft    nofile	8192
```

Depending on the situation, this file may not be used. You also need to adjust the systemd configuration:

```bash
# mkdir -p /etc/systemd/system.conf.d/
# cat /etc/systemd/system.conf.d/10-filelimit.conf
[Service]
LimitNOFILE=65535
```

```bash
# mkdir -p /etc/systemd/user.conf.d/
# cat /etc/systemd/user.conf.d/10-filelimit.conf
[Service]
LimitNOFILE=65535
```

Reboot the system to apply the increased limits.

## Hardware acceleration

> **NOTE:** Enable this only when needed outside Flatpaks, and make sure RPM Fusion is configured first!

See <https://rpmfusion.org/Howto/OSTree> when using Intel/NVIDIA, and if you require Broadcom/DVB firmwares.

### AMDGPU

Override the current mesa-va-drivers:

```bash
rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
```

### FFMpeg

```bash
rpm-ostree install libavcodec-freeworld libva-utils
```

After a reboot, you can check support hardware decoding profiles using `vainfo`:

```bash
Trying display: wayland
libva info: VA-API version 1.20.0
libva info: Trying to open /usr/lib64/dri/radeonsi_drv_video.so
libva info: Found init function __vaDriverInit_1_20
libva info: va_openDriver() returns 0
vainfo: VA-API version: 1.20 (libva 2.20.1)
vainfo: Driver version: Mesa Gallium driver 23.3.1 for AMD Radeon Graphics (radeonsi, renoir, LLVM 17.0.6, DRM 3.54, 6.6.8-200.fc39.x86_64)
vainfo: Supported profile and entrypoints
      VAProfileMPEG2Simple            : VAEntrypointVLD
      VAProfileMPEG2Main              : VAEntrypointVLD
      VAProfileVC1Simple              : VAEntrypointVLD
      VAProfileVC1Main                : VAEntrypointVLD
      VAProfileVC1Advanced            : VAEntrypointVLD
      VAProfileH264ConstrainedBaseline: VAEntrypointVLD
      VAProfileH264ConstrainedBaseline: VAEntrypointEncSlice
      VAProfileH264Main               : VAEntrypointVLD
      VAProfileH264Main               : VAEntrypointEncSlice
      VAProfileH264High               : VAEntrypointVLD
      VAProfileH264High               : VAEntrypointEncSlice
      VAProfileHEVCMain               : VAEntrypointVLD
      VAProfileHEVCMain               : VAEntrypointEncSlice
      VAProfileHEVCMain10             : VAEntrypointVLD
      VAProfileHEVCMain10             : VAEntrypointEncSlice
      VAProfileJPEGBaseline           : VAEntrypointVLD
      VAProfileVP9Profile0            : VAEntrypointVLD
      VAProfileVP9Profile2            : VAEntrypointVLD
      VAProfileNone                   : VAEntrypointVideoProc
```

> **NOTE:** Most applications still require to force VA-API support.

### GStreamer

> **TIP:** You can also use Gnome Software to install additional codecs.

```bash
rpm-ostee install rpm-ostree install gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-vaapi
```

### Brave

To enable VA-API on the [Brave Browser](https://flathub.org/apps/com.brave.Browser) Flatpak package, create the `~/.var/app/com.brave.Browser/config/brave-flags.conf` file, with the following content:

```bash
--ignore-gpu-blocklist
--enable-zero-copy
--enable-gpu-rasterization
--use-gl=angle
--use-angle=vulkan
--enable-accelerated-video-decode
--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,OneTimePermission,OverlayScrollbar
```

Depending on your hardware, you may need to enable/disable different flags. See <https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md#vaapi-on-linux> for details.

## Filesystems

### Encryption

If you are using encryption on a NVMe/SSD, you may want to improve performance by disabling the workqueue.

See <https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance> for details.

### Btrfs

If you are using Btrfs, you may want to enable <https://github.com/kdave/btrfsmaintenance>:

```bash
rpm-ostree install btrfsmaintenance
nano /etc/sysconfig/btrfsmaintenance
```

Enable the services:

```bash
sudo systemctl enable btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer --now
```

## Software

It is discourage to install (large) software on the ostree. Try to use Flatpaks and toolboxes (`toolbox create` and `toolbox enter`) as much as possible.

You can pull the latest toolbox, using:

```bash
podman pull fedora-toolbox:40
```

To update the Toolbox:

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

#### Podman

If you use Podman, and need Docker compatibility:

```bash
rpm-ostree install podman-docker
```

If possible, enable and use rootless containers: <https://wiki.archlinux.org/title/Podman#Rootless_Podman>

### Theming

> **TIP:** See <https://itsfoss.com/flatpak-app-apply-theme/> instructions for Flatpak theming.

```bash
rpm-ostree install gnome-tweak-tool
```

When using GTK-3 apps, see <https://github.com/lassekongo83/adw-gtk3> for details.

```bash
flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
```

After a reboot, you can apply theme settings using Gnome Tweaks.
