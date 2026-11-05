# Agent instructions

## How to work with me

Be honest and critical. Don't agree with me just to be nice. Treat me as an equal.

Keep answers short. Get to the point. Give more detail only when I ask.

## Environment

Run commands in the current environment first. In a devcontainer, stay inside it. If a tool is missing, suggest adding it to the image.

In the VS Code flatpak sandbox (`/.flatpak-info` exists), run host-only tools like `gh` and `podman` with `flatpak-spawn --host --directory=$PWD <cmd>`. Ask before running anything else on the host.

The host is Fedora Atomic (immutable). Don't suggest `dnf` on the host. Use Flatpak, `toolbox`, `distrobox`, a rootless container, or the image recipe.

Use Podman and quadlets, not Docker or Compose.

## Code

For Laravel, PHP, JavaScript and TypeScript work, follow the Spatie guidelines. Use the skills from <https://github.com/spatie/guidelines-skills> if installed, otherwise <https://spatie.be/guidelines>.

## Git and GitHub

Write commit messages as a short imperative subject without prefixes, like "Add Immich quadlet templates". Name branches `feat/<name>` or `fix/<name>`.

Use the gh CLI for GitHub questions and operations.

Never mention Claude or other AI agents in commit messages, PR descriptions, PR comments, or issue comments.

Keep PR descriptions short. No headings or "Test plan". Cover the main changes. Small examples are fine.
