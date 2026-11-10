# Dotfiles

`home/` is the chezmoi source directory (`.chezmoiroot`). Edit files here, not in `~`, and use chezmoi source names (`dot_`, `private_`). Check with `chezmoi diff`.

`templates/` are copied by hand, never installed by a script.

## Container templates

Rootless Podman quadlets, one subdirectory per service group. Deploy steps are in `docs/containers/<app>.md`, linked from `docs/podman.md`; add one when adding a service.

- `AutoUpdate=registry`, except for databases.
- Named volumes use `Z,U`. Bind mounts to large data skip `Z,U`; label and chown them once on the host (see `docs/podman.md`).
- GPU access: `AddDevice=/dev/dri/` with `GroupAdd=keep-groups`.
- Validate: `QUADLET_UNIT_DIRS=$PWD/templates/containers /usr/libexec/podman/quadlet -user -dryrun`

This repo is public. Keep host and hardware details out, and use placeholders for secrets.
