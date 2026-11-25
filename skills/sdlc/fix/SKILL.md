---
name: fix
description: "Diagnose an issue down to its root cause, explain it, then fix it
  with a test, docs, and a commit."
---

# Fix

One run, one bug: `diagnose` finds the cause, `implement` fixes it.

The argument after the command is the symptom, the same as for `diagnose`.
Without an argument, take the issue from the conversation.

## Principles

- **Fix the cause, not the symptom.** Fix it once, in the shared code, not in
  each place the symptom shows up.

## Workflow

### Diagnose

Run `diagnose` through its report (pin the symptom, narrow, confirm, report).
Its read-only rule applies only until that report is delivered; after it,
`implement`'s rules apply.

If the cause is not in what this project can change (hardware, a third-party
service, the user's environment), stop after the report: there is nothing to
commit.

If the cause is only a hypothesis, or several fixes are possible with different
trade-offs, ask which way to go. Otherwise continue without asking.

### Implement

Run `implement` from the code-reading part of "Pick the batch" onwards, with the
fix as the task:

- the scope is the cause found during diagnosis, nothing more;
- the failing test reproduces the original symptom;
- before the commit, check that the symptom is gone the same way `diagnose`
  reproduced it.

### Report

The `implement` report, with one line on top (this format is obligatory even for
small commits):

- 🎯 **Cause:** — one sentence from the diagnosis.
