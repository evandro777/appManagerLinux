# Workspace AI Agent Instructions

This repository is a Bash-based Linux Mint application manager and installer.
It is centered on shell scripts, dialog menus, application install modules, and Mint Cinnamon-specific settings.

## Key files and structure

- `app-menu-init.sh` — main entrypoint and interactive menu workflow.
- `apps.sh` — app registry with categories, script bindings, and install status logic.
- `apps/` — per-application install scripts and Cinnamon-specific settings under `apps/mint-cinnamon/`.
- `includes/` — shared helpers, package header contract, and root/sudo permission handling.
- `README.md` — usage guidance and repository purpose.

## Project conventions

- App modules follow a shared CLI contract: `check`, `install`, `uninstall`, `name`, `help`, etc.
- Root permission handling is explicit: prefer non-root entry, use `sudo` when needed, and preserve `SUDO_USER`/`REAL_USER`.
- The repo uses `dialog` for interactive selection and stores selections temporarily for batch execution.
- New app support usually means adding metadata to `apps.sh` and a corresponding script in `apps/`.

## AI agent guidance

- Focus on Bash script maintenance, app install workflows, and Linux Mint/Cinnamon automation.
- Avoid broad refactors that change the repository design without explicit user approval.
- Do not perform destructive system operations or package installs unless the user explicitly requests them.
- Preserve permission patterns from `includes/root_restrict.sh`, `includes/root_restrict_but_sudo.sh`, and `includes/root_required.sh`.

## Custom agent available

- `AppManagerLinux Shell Maintainer` — workspace-specific shell/script persona at `.github/agents/appmanager-shell.agent.md`.

## Use this file for

- understanding repo intent and conventions
- choosing the right editing scope for shell work
- avoiding actions outside repository purpose
