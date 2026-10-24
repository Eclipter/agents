# ~/.agents

This repo is a directory for the common source of truth for agent instructions. Edit skills, hooks, and `AGENTS.md` here. Harnesses read those files through symlinks.

## Setup

- Clone the repo

- Move the repo to ~/.agents directory (or merge with an existing one)

- For every harness, symlink paths to the matching paths in this repo if that harness reads the same format.

  Example:

  - `~/.cursor/skills` -> `~/.agents/skills`
  - `~/Library/Application Support/Cursor/AgentStores/cursor_agent_stores/u218146771/files/skills` -> `~/.agents/skills` (Cursor changes the skills directory when "Sync Skills for Cloud Agents" is enabled)
  - `~/.cursor/hooks` -> `~/.agents/hooks`
  - `~/.codex/hooks` -> `~/.agents/hooks`
  - `~/.codex/AGENTS.md` -> `~/.agents/AGENTS.md`

  The hook list is a separate format per harness:

  - `~/.cursor/hooks.json` -> `~/.agents/hooks/cursor.json`
  - `~/.codex/hooks.json` -> `~/.agents/hooks/codex.json`

- Cursor rules use Cursor's own format in its customization settings. The user copies items from `AGENTS.md` into those settings by hand.

## Working here

Agents work on `main` and commit on `main`.

When using the `implement` workflow, skip the tests.
