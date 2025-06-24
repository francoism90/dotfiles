# dotfiles

This is a selection of settings and preferences for my [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) and [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/).

> Note: Commands prepend with `# <command>` should be executed as `root`, `$ <command>` as your normal user.

## System

### RPMFusion

```bash
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

To install the `rpmfusion-nonfree-tainted` repository:

```bash
sudo rpm-ostree install https://download1.rpmfusion.org/nonfree/fedora/releases/42/Everything/x86_64/os/Packages/r/rpmfusion-nonfree-release-tainted-$(rpm -E %fedora)-1.noarch.rpm
```

Reboot to apply changes:

```bash
systemctl reboot`
```
