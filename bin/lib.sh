#!/usr/bin/env bash
# Shared helpers; source this, don't execute it.

# Repo root, so scripts work no matter which directory you run them from
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# install_config <src relative to config/> <dest>
# Copies a file or a whole directory, creating parent directories as needed.
install_config() {
    local src="$DOTFILES/config/$1" dest="$2"

    if [[ -d $src ]]; then
        mkdir -p "$dest"
        cp -rT "$src" "$dest"
    elif [[ -f $src ]]; then
        install -Dm644 "$src" "$dest"
    else
        echo "missing: $src" >&2
        return 1
    fi

    echo "installed $1 -> $dest"
}
