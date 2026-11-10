# dotfiles

This is a selection of settings, notes and preferences for my Linux devices.

Useful sources and references:

- <https://github.com/francoism90/personal-os/>
- <https://blue-build.org/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/tips-and-tricks/>
- <https://docs.fedoraproject.org/en-US/fedora-silverblue/troubleshooting/>
- <https://rpmfusion.org/Howto/OSTree>

## Installation

The files in `home/` are managed with [chezmoi](https://www.chezmoi.io/). On Aurora, install it with `ujust aurora-cli`, then clone and apply:

```bash
git clone https://github.com/francoism90/dotfiles.git ~/Code/dotfiles
chezmoi init --source ~/Code/dotfiles --apply
```

Edit files in `~/Code/dotfiles/home/`, then preview and apply:

```bash
chezmoi diff
chezmoi apply
```

If you edited a file in `~` instead, copy it back with `chezmoi re-add <file>`. To manage an additional file:

```bash
chezmoi add ~/.config/yt-dlp/config
```

Source names follow the [chezmoi conventions](https://www.chezmoi.io/reference/source-state-attributes/): `dot_config` becomes `.config`, and `private_` keeps the directory at `0700`.

## Documentation

- [Administration](docs/administration.md): shell, packages, journal, firewall
- [Podman](docs/podman.md): rootless containers and the [container templates](docs/podman.md#container-templates)
- [System](docs/system.md): kernel arguments, mounts, swap, Btrfs
- [VSCode / VSCodium / Zed](docs/vscode.md)
- [Troubleshooting](docs/troubleshooting.md)
