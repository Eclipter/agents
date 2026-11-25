---
name: commit-message
description: "Write the commit message. Do not stage, commit, or push."
---

# Commit message

## Principles

A repository commit convention (`CONTRIBUTING`, commitlint, `.gitmessage`)
overrides the rules below.

Do not quote secrets, tokens, or private keys. If they appear in the diff, say
they must not be committed instead of describing them as a normal change.

### Message scope

- Non-empty index: describe only staged changes. In one line, name what remains
  unstaged and will not be in this commit.
- Empty index: describe the working tree and say that nothing is staged.
- Several independent changes: one message per atomic commit, in apply order.

### Format

Take the language and shape from recent commits when the style is consistent.
Otherwise use English and Conventional Commits:

```text
type: imperative summary

Why this exists, only when the subject does not already say it.
```

`type`: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`,
`chore`, `style`, `revert`.

Add a `scope` in parentheses only when the repository already does, or when the
subject is ambiguous without it. A breaking change uses `type!:` and a `BREAKING
CHANGE:` trailer.

Subject line:

- Use imperative mood, as a continuation of "If applied, this commit will …".
- Describe the change to the system, not a file list or "update code".
- Omit the trailing period.
- Keep the whole line at most 50 characters, even when recent subjects are
  longer.
- Write something that belongs in a changelog.

Add a body only when the subject does not explain why. Separate it from the
subject with one blank line. Keep body lines under 72 characters where a break
is possible (soft limit). Do not retell the diff or write "this commit".

Include trailers only when real: `BREAKING CHANGE:`, `Fixes #n`, `Refs #n`. Do
not invent issue numbers.

## Workflow

### Inspect the changes

From the repository root, inspect in parallel:

- `git status --short`
- `git diff --cached` and `git diff --cached --stat`
- `git diff` and `git diff --stat`, when the index is empty or unstaged changes
  remain
- `git log -20 --format='%s%n%b%n---'`

If the repository has no commits yet, skip the log and use the default language
and format. For a diff larger than about 2,000 lines, read `--stat` and sample
key files instead of reading the whole diff.

### Reply

First, one line: staged, the whole tree, or several commits. Then each message
in its own fenced block, ready to paste into `git commit`. Nothing else.
