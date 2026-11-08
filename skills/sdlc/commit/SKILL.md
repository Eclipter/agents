---
name: commit
description: "Create a Git commit or commits."
---

# Commit

## Principles

If the calling workflow manages upstream synchronization or history rewriting,
follow that workflow's preparation instead.

## Workflow

### Prepare

1. Fetch upstream if configured.
2. If branches have diverged or the local branch is behind upstream and has
  uncommitted changes, stop and report.
3. Fast-forward if behind.

### Commit

1. Inspect `git status --short`, staged and unstaged diffs, and untracked files.
  Stage only changes in the requested scope. Preserve unrelated work and its
  staging state; exclude it from the commit. If the scope is unclear, ask.
2. Use `commit-message` for the message. Skip its reply section. For independent
  changes, stage and commit each atomic change separately, regenerating the
  message for its actual staged contents.
3. Commit. Do not push, amend, or rewrite history unless it's asked explicitly.
  If a hook rejects the commit, fix the cause and retry; never use
  `--no-verify`.
4. Verify the resulting commit and working tree. Report the hash and subject,
  plus any changes left uncommitted.
