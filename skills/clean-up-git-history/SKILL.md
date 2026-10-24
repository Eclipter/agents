---
name: clean-up-git-history
description: "Use when the user asks to clean up, reorganize, squash, split, or rewrite Git history."
---

# Clean up Git history

Rebuild a coherent commit history within the largest scope that can be rewritten
without disrupting other users. Preserve the final project contents and finish
locally before asking for review and permission to push to `origin`.

## Establish the starting point

- Read repository instructions and commit conventions. Resolve the project
  directory and branch; check for an enclosing repository before initializing.
- Inspect the working tree, index, untracked files, worktrees, and operations in
  progress. If a rebase, merge, or cherry-pick is underway, stop and report.
- Initialize a repository if none exists. For a new or empty repository, inspect
  and stage the intended project contents and create the first commit. Exclude
  secrets, unrelated files, and generated files according to project rules.
  If nothing belongs in the commit, do not invent contents or an empty commit.
- Leave existing uncommitted work outside the rewrite unless explicitly
  included. Preserve its contents and staged/unstaged split, using a recorded
  stash with untracked files as needed. Retain it until restoration is verified.
- Use `commit-msg` for every resulting commit, including the first. Apply its
  inspection and message rules to the actual per-commit contents; reapply them
  if those contents change. Use its empty-history fallback, not a generic
  "Initial commit" message; locate the dependency if unavailable. This workflow
  authorizes local commits and rewriting and governs the final review flow.

## Determine the maximum rewrite scope

1. Inspect the graph, local and remote refs, upstreams, merge bases, ownership,
  and worktrees. Fetch relevant remotes without merging. Consult available
  hosting information for default/protected branches, pull requests, dependent
  branches, releases, and commit-hash references, plus session context and
  collaboration rules. Include dependencies on other remotes.
1. Keep commits others can depend on and all their ancestors unchanged: shared
  branch history, commits merged into it, release/tag anchors consumed by
  others, and bases for collaborators or downstream consumers. Changing an
  ancestor changes descendant hashes. A private ref alone does not make
  history shared; authorship and branch names alone do not establish exclusive
  ownership.
1. Expand through all commits established as exclusive to the user's work. A
  personal segment unmerged into shared history may be rewritten back to its
  shared base even when pushed to `origin`; its matching remote-tracking ref
  alone is no restriction. Absence of merges does not prove absence of users
  depending on it. Decide from collaboration evidence, not publication alone.
1. Inspect every parent path through merges. A merge need not stop cleanup:
  preserve shared parent histories while reorganizing exclusive commits. Use
  `--root` only if the entire reachable history is exclusive; a shallow boundary
  is not a root.
1. Record selected commits, fixed boundary parents, affected branch, and scope
  evidence. For a linear series, record the unchanged base and `base..HEAD`;
  for merges, record boundaries explicitly. Save the exact `origin` destination
  branch and its current object ID, or verified absence, for the push decision.

Briefly explain the scope and limiting dependency, then proceed without routine
approval. If missing ownership/dependency information changes the boundary, ask
a targeted structured question. Continue independent investigation and work
within the established scope. Missing remote access or refs does not establish
private use. If every commit is shared, report that no rewrite is available.

## Reconstruct the development logic

Before rewriting, research every selected commit: graph, full messages,
per-commit and aggregate diffs, and surrounding source, tests, configuration,
and documentation. Read large diffs in manageable pieces, not just statistics
or subjects. Inspect merge resolutions, binaries, renames, modes, and submodules
where present. Reconstruct what each change introduced, why, its dependencies,
and later corrections, replacements, or reversals without inventing intent.
Map original commits or hunks to an ordered plan for the resulting commits.

- Combine experiments, fixups, and corrections with the change they complete.
  Remove abandoned change/revert pairs only when they have no surviving effect
  or necessary historical meaning.
- Split unrelated concerns. Keep necessary tests, documentation, and
  configuration with their change.
- Order prerequisites first. Aim for independently understandable, checkable,
  and revertible commits without artificial splits or a default all-in-one
  squash.
- Choose a consistent message language and format from repository rules, then
  established history outside the rewrite range, then `commit-msg` defaults.
  Review each subject and whether a body is needed for motivation, constraints,
  or non-obvious decisions; omit bodies that retell the diff.
- Preserve authorship, co-authorship, and valid trailers. Do not invent issue
  references or attestations. Recreate signatures under repository signing
  rules; rewritten signatures cannot be represented as preserved.

## Rebuild the history

- Save a named local recovery ref for the original tip; record its tree ID and
  relevant branch/ref state. Keep the recovery ref unless the user asks to
  remove it; this new ref is not evidence of sharing.
- Use whichever Git operations implement the plan: interactive rebase,
  reword/edit/squash/fixup, reset with selective staging, cherry-pick, patches,
  or plumbing-based reconstruction. Do not limit cleanup to renaming or adjacent
  squashes.
- Recreate necessary merge resolutions explicitly: default rebase can drop
  merges, and recreating a merge need not preserve its manual resolutions.
- Move only the intended branch. Disable automatic updates to unrelated refs
  (`--no-update-refs` for rebase); do not retarget tags, other branches, or the
  base. Check for independent branch movement before replacing its tip.
- Resolve conflicts from the researched intent and original contents. Do not
  change product behavior, bypass required hooks, discard user work, or use
  destructive cleanup to make checks pass. Abort or recover from the saved ref
  if the intended result cannot be preserved.

## Verify and request review

- Require the rewritten tip's tree ID to match the saved original exactly,
  including modes and submodule pointers. For a first commit, verify the tree
  matches the intended staged contents. Investigate mismatches before delivery.
- Review the new graph, every patch, and subjects and bodies together. Use
  `git range-diff` where applicable; inspect merge resolutions separately.
  Confirm fixed boundary commits and unrelated refs stayed unchanged.
- Run relevant existing checks at changed intermediate boundaries to catch
  missing prerequisites, and appropriate checks on the final result. Do not add
  tests or change product code for this cleanup. Report existing failures or
  unavailable checks accurately.
- Restore and verify uncommitted work and its staging state. Leave no cleanup
  operation unfinished; if recovery is needed, retain backups and report the
  remaining issue instead of claiming completion.
- Show the rewritten range, why it was the maximum available scope, ordered
  subjects and any bodies, verification results, and recovery ref. If history
  was already clean, report that without manufacturing changes.
- End with a structured review/push question naming the exact `origin` branch
  and whether remote history would be replaced. Offer to push after review,
  keep it local, or revise it; wait for the answer. If `origin` is absent, ask
  for its destination during review; do not invent a remote or create a hosted
  repository.

After push approval, recheck the destination and collaboration scope. Push only
the reviewed branch, never recovery refs. Use a normal push for a fast-forward;
otherwise use `--force-with-lease=refs/heads/<branch>:<recorded-old-oid>` with
an explicit refspec. For a new branch, use an empty expected value to guard
against concurrent creation. Never use plain `--force` or `--mirror`. If the
destination changed, stop and reassess instead of refreshing the lease and
overwriting new work. If first supplied during review, inspect it and get
approval for any newly discovered history replacement. If nothing is pushable,
explain without pushing.
