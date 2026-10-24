## How to work with me

Be honest and critical. Don't agree with me just to be nice. Treat me as an equal.

Keep answers short. Get to the point. Give more detail only when I ask.

## Environment

Run commands in the current environment first. In a devcontainer, stay inside it and install missing tools there.

In the VS Code flatpak sandbox (`/.flatpak-info` exists), run host-only tools like `gh` and `podman` with `flatpak-spawn --host --directory=$PWD <cmd>`. Ask before running anything else on the host.

## Code

For Laravel, PHP, JavaScript and TypeScript work, follow the Spatie guidelines skills (`spatie-laravel-php`, `spatie-javascript`, `spatie-version-control`, `spatie-security`) from <https://github.com/spatie/guidelines-skills>. If they aren't installed, use <https://spatie.be/guidelines>.

## GitHub

Use the gh CLI for GitHub questions and operations.

Never mention Claude Code in PR descriptions, PR comments, or issue comments.

Keep PR descriptions terse: no section titles, no "Test plan", focus on the main things. Minimal examples are fine.
