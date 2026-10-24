---
name: commit-msg
description: "Write the commit message. Do not stage, commit, or push unless the same message explicitly asks for a commit."
---

# commit-msg

## What to inspect

From the repository root, in parallel:

- `git status --short`
- `git diff --cached` and `git diff --cached --stat`
- `git diff` and `git diff --stat`, when the index is empty or unstaged changes remain
- `git log -20 --format='%s%n%b%n---'`
- If `git log` fails because the repository has no commits yet, skip the log and use the default language and format.
- If a diff is larger than about 2000 lines, read `--stat` and sample the key files instead of the whole diff.

A repository commit convention (`CONTRIBUTING`, commitlint, `.gitmessage`) overrides the rules below.

Do not quote secrets, tokens, or private keys. If they appear in the diff, say they must not be committed and do not describe them as a normal change.

## What the message covers

- Non-empty index: describe only staged changes. In one line, name what remains unstaged and will not be in this commit.
- Empty index: describe the working tree and say that nothing is staged.
- Several independent changes: one message per atomic commit, in apply order. Do not merge them into one.

## Format

Take the language and shape from recent commits when the style is consistent. Otherwise use English and Conventional Commits:

```text
type: imperative summary

Why this exists, only when the subject does not already say it.
```

`type`: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `style`, `revert`.

Add a `scope` in parentheses only when the repository already does, or when the subject is ambiguous without it. A breaking change uses `type!:` and a `BREAKING CHANGE:` trailer.

Subject line:

- imperative mood, as a continuation of "If applied, this commit will …";
- the change to the system, not a file list and not "update code";
- no trailing period;
- the whole line at most 72 characters;
- something that belongs in a changelog.

Add a body only when the "why" is not obvious from the subject. Separate it with a blank line and wrap near 72 characters. Do not retell the diff and do not write "this commit".

Trailers only when they are real: `BREAKING CHANGE:`, `Fixes #n`, `Refs #n`. Do not invent issue numbers.

## Reply

First, one line: staged, the whole tree, or several commits. Then each message in its own fenced block, ready to paste into `git commit`. Nothing else.
