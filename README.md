# ~/.agents

This repo is a directory for the common source of truth for agent instructions. Edit skills, hooks, and `AGENTS.md` here. Harnesses read those files through symlinks.

## Setup

- Clone the repo

- Move the repo to ~/.agents directory (or merge with an existing one)

- For every harness, symlink each path it reads to the matching path in this repo if that harness reads the same format. `ln` will not replace a path that already exists, so move (remove) a real directory aside first.

  The hook list is a separate format per harness, so `hooks.json` points at `hooks/cursor.json` or `hooks/codex.json`.

  Cursor:

  ```sh
  # ~/.cursor/skills -> ~/.agents/skills
  ln -s ~/.agents/skills ~/.cursor/skills

  # ~/.cursor/hooks -> ~/.agents/hooks
  ln -s ~/.agents/hooks ~/.cursor/hooks

  # ~/.cursor/hooks.json -> ~/.agents/hooks/cursor.json
  ln -s ~/.agents/hooks/cursor.json ~/.cursor/hooks.json
  ```

  Cursor changes the skills directory when "Sync Skills for Cloud Agents" is enabled:

  ```sh
  # ~/Library/Application Support/Cursor/AgentStores/cursor_agent_stores/u218146771/files/skills -> ~/.agents/skills
  ln -s ~/.agents/skills "$HOME/Library/Application Support/Cursor/AgentStores/cursor_agent_stores/u218146771/files/skills"
  ```

  Codex:

  ```sh
  # ~/.codex/AGENTS.md -> ~/.agents/AGENTS.md
  ln -s ~/.agents/AGENTS.md ~/.codex/AGENTS.md

  # ~/.codex/hooks -> ~/.agents/hooks
  ln -s ~/.agents/hooks ~/.codex/hooks

  # ~/.codex/hooks.json -> ~/.agents/hooks/codex.json
  ln -s ~/.agents/hooks/codex.json ~/.codex/hooks.json
  ```

- Cursor rules use Cursor's own format in its customization settings. The user copies items from `AGENTS.md` into those settings by hand.

## Skill workflows

Skills that invoke other skills as workflows. Each diagram shows a separate
entrypoint and its nested calls.

### Implement

[![`implement` workflow](skills/sdlc/implement/workflow/workflow.svg)](skills/sdlc/implement/workflow/workflow.svg)

### Fix

[![`fix` workflow](skills/sdlc/fix/workflow/workflow.svg)](skills/sdlc/fix/workflow/workflow.svg)

### Loop

Shows one representative assignment; independent assignments can run concurrently.

[![`loop` workflow](skills/sdlc/loop/workflow/workflow.svg)](skills/sdlc/loop/workflow/workflow.svg)

### Commit

[![`commit` workflow](skills/sdlc/commit/workflow/workflow.svg)](skills/sdlc/commit/workflow/workflow.svg)

### Clean up Git history

[![`clean-up-git-history` workflow](skills/sdlc/clean-up-git-history/workflow/workflow.svg)](skills/sdlc/clean-up-git-history/workflow/workflow.svg)

### Create my skill

[![`create-my-skill` workflow](skills/create-my-skill/workflow/workflow.svg)](skills/create-my-skill/workflow/workflow.svg)

## Instructions for agents

Agents work on `main` and commit on `main`.

When using the `implement` workflow, skip the tests.
