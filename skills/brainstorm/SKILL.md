---
name: brainstorm
description: "Use when the user describes their case and asks to explore solutions or compare the
  viable alternatives."
---

# Brainstorm

Find the distinct ways to solve the user's problem. Keep the final choice with
the user.

## Workflow

1. State the goal and identify the hard constraints. Treat preferences as
   comparison criteria. If a constraint is ambiguous and its interpretation
   changes which options qualify, ask the user to clarify it.
2. Look for all distinct, plausible approaches in scope. Group variants that
   would lead to the same decision. Check each approach against every hard
   constraint together, using one consistent set of stated assumptions.
3. Present the results under `Viable options` and `Omitted options`.
   - **Viable options.** Include only approaches that satisfy every hard
     constraint. Explain how each works. Compare only differences that affect
     the decision, at both the high level (overall approach and consequences)
     and the low level (implementation or operating details and their effects).
     State any shared context once. If only one qualifies, explain it on its
     own. If none qualify, say so.
   - **Omitted options.** Give each remaining approach one line with its name
     and the specific constraints it fails. If a constraint is unverified,
     name what needs checking. Keep rankings and trade-offs out of this list.

## Example

For notes that must be editable offline and retain prior versions:

### Viable options

A local Git repository makes edits easy to audit line by line and requires
explicit commits. An offline editor with automatic local version history saves
snapshots as you work and lets you restore an earlier version from the editor.

### Omitted options

- Browser editor that requires a connection. Fails offline editing.
- Plain text file without versioning or backups. Lacks prior versions.
