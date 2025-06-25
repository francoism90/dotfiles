# dotfiles

This is a selection of settings and preferences for my [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) and [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/).

> Note: Commands prepend with `# <command>` should be executed as `root` (sudo), `$ <command>` as your normal user.

## System

### RPMFusion

```bash
# rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

Reboot to apply changes:

```bash
$ systemctl reboot
```

### NVIDIA (open-driver)

See the following sources for more information:
- https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#OSTree_.28Silverblue.2FKinoite.2Fetc.29
- https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#Kernel_Open

```bash
# rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia
```
