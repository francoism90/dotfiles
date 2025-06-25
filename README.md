# dotfiles

This is a selection of settings, notes and preferences for my [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/), [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/) and [Fedora CoreOS](https://fedoraproject.org/coreos/) installations.

> Note: Commands prepend with `# <command>` should be executed as `root` (sudo), `$ <command>` as your normal user.

## Software

### RPMFusion

```bash
# rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

Reboot to apply changes:

```bash
$ systemctl reboot
```

## System

### NVIDIA

See the following sources for more information:
- https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#OSTree_.28Silverblue.2FKinoite.2Fetc.29
- https://rpmfusion.org/Howto/NVIDIA?highlight=%28%5CbCategoryHowto%5Cb%29#Kernel_Open

```bash
# rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-power
```

```bash
# systemctl enable nvidia-{suspend,resume,hibernate} --now
```

#### Secure Boot

See https://github.com/CheariX/silverblue-akmods-keys for more details:

```bash
# rpm-ostree install --apply-live rpmdevtools akmods
```

Install Machine Owner Key (MOK):

```bash
# kmodgenca
# mokutil --import /etc/pki/akmods/certs/public_key.der
```

Clone the project:

```bash
git clone https://github.com/CheariX/silverblue-akmods-keys
cd silverblue-akmods-keys
```

To build with NVIDIA open driver:

```bash
echo "%_with_kmod_nvidia_open 1" >> macros.kmodtool
```

Build akmods-keys:

```bash
# bash setup.sh
# rpm-ostree install akmods-keys-0.0.2-8.fc$(rpm -E %fedora).noarch.rpm
```
