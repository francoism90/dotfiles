# dotfiles

This is a selection of settings and preferences for my [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) installation.

## Maintenance

Reference:

- <https://rpmfusion.org/Howto/OSTree>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>

## nofile

Increasing `nofile` limits may be needed for certain applications and games to work.

See <https://access.redhat.com/solutions/1257953> for more details.

> **NOTE:** Reboot the system to apply increased limits.

## Filesystem

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
podman pull fedora-toolbox:40
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

### VSCodium / VSCode

See the following guides:

- <https://github.com/flathub/com.visualstudio.code/issues/426#issuecomment-2076130911>
- <https://github.com/jorchube/devcontainer-definitions>
- <https://github.com/VSCodium/vscodium/discussions/1487>

You may use [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal), and set the following overwrites:

- Add to `Other files`: `xdg-run/podman:ro`
- Add to `Variables`: `FLATPAK_ENABLE_SDK_EXT=podman,php83`

#### Extensions

Current extensions:

```bash
$ flatpak run com.visualstudio.code  --list-extensions | xargs -L 1 echo vsc --install-extension
aaron-bond.better-comments
amiralizadeh9480.laravel-extra-intellisense
bmewburn.vscode-intelephense-client
bradlc.vscode-tailwindcss
christian-kohler.npm-intellisense
christian-kohler.path-intellisense
davidanson.vscode-markdownlint
dbaeumer.vscode-eslint
devsense.composer-php-vscode
eamodio.gitlens
editorconfig.editorconfig
eriklynd.json-tools
esbenp.prettier-vscode
github.copilot
github.copilot-chat
github.github-vscode-theme
github.vscode-github-actions
jock.svg
ms-azuretools.vscode-docker
ms-vscode.atom-keybindings
onecentlin.laravel-blade
pkief.material-icon-theme
quicktype.quicktype
redhat.vscode-yaml
shd101wyy.markdown-preview-enhanced
sleistner.vscode-fileutils
streetsidesoftware.code-spell-checker
stylelint.vscode-stylelint
visualstudioexptteam.intellicode-api-usage-examples
visualstudioexptteam.vscodeintellicode
wmaurer.change-case
```

### Theming

See <https://itsfoss.com/flatpak-app-apply-theme/> instructions for Flatpak theming.

To add Gnome Tweak:

```bash
rpm-ostree install gnome-tweak-tool
```
