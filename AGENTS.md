# Dotfiles

`config/` is installed by `bin/install-dotfiles` and `bin/install-claude-code` (overwrites destinations). Edit files here, not in `~`.

`templates/` are copied by hand, never installed by a script.

## Container templates

Rootless Podman quadlets, one subdirectory per service group. Deploy steps are in the README (Podman section); update them when adding a service.

- `AutoUpdate=registry`, except for databases.
- Named volumes use `Z,U`. Bind mounts to large data skip `Z,U`; label and chown them once on the host (see README).
- GPU access: `AddDevice=/dev/dri/` with `GroupAdd=keep-groups`.
- Validate: `QUADLET_UNIT_DIRS=$PWD/templates/containers /usr/libexec/podman/quadlet -user -dryrun`

This repo is public. Keep host and hardware details out, and use placeholders for secrets.
