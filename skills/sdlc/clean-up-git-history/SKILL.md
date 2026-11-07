---
name: clean-up-git-history
description: "Use when the user asks to clean up Git history."
---

# Clean up Git history

## Principles

Rebuild the largest history only this user depends on. Keep the final tree
identical. Finish locally, then ask before any push.

Use `commit` for every resulting commit, including the first. If the staged
contents change while you build that commit, run `commit` again. This workflow
may rewrite local history, and it decides whether to push. If `commit` is
missing, locate it before writing a message. Do not use a generic initial-commit
message.

## Workflow

### Start

Resolve the repository and branch. Stop if a rebase, merge, or cherry-pick is in
progress in this checkout or a linked worktree. Do not initialize a repository
inside an existing one.

If there is no repository, initialize it and stage only the project files that
belong. Leave out secrets, generated files, unrelated files, and files the
project ignores. If nothing belongs, do not invent a commit.

Keep uncommitted work out unless the user included it. Preserve the staged and
unstaged split. To set it aside, use `git stash push --include-untracked` with a
message, and keep that stash until the restore checks out.

### Choose the rewrite range

Fetch relevant remotes without merging. From refs, upstreams, merge bases,
worktrees, other remotes, session context, and collaboration rules, decide who
depends on these commits. Also check the host's default and protected branches,
pull requests, dependent branches, releases, and commits cited by hash. Missing
remote access or refs does not make the history private.

Freeze shared branch history, commits merged into it, tags and releases others
use, bases other people build on, and every ancestor of those commits. A private
ref, an author name, or a branch name does not prove ownership.

Rewrite exclusive commits back to that base even after they were pushed. Decide
from who depends on those commits. A remote-tracking ref, a lack of merges, or
publication is not evidence of who depends on them.

A merge does not end the rewrite. Keep shared parents, and reorganize only
exclusive commits. Use `--root` only when every reachable commit is exclusive. A
shallow boundary is not a root.

Record the range, the frozen parents, the branch, and the evidence. Use the
unchanged base and `base..HEAD` for a straight line, and name each boundary of a
merge. Record the upstream branch and its object ID, or that none exists. Name
the range and what limits it, then rewrite that range without asking for
approval. Ask with the structured question tool only when missing evidence would
move the boundary, and continue work that does not depend on the answer. If
every commit is shared, say that no rewrite is available and stop.

### Plan the new commits

Read each message and patch, including merges, renames, modes, binaries, and
submodules. Do not plan from subjects and diffstats. When the patch does not
show why the change exists, read the surrounding code. Do not invent intent. Map
the old commits to the new series before you start.

Fold experiments, fixups, and corrections into the change they finish. Drop a
change and its revert only when nothing remains and the pair is not needed to
understand later history. Split unrelated changes. Keep tests, docs, and config
with the change they belong to. Put prerequisites first. Each commit must be
understandable, checkable, and revertible on its own. Do not split for
appearance, and do not squash the whole range by default.

Take message language from repository rules, then from history outside this
range, then from `commit`. Keep authors, co-authors, and valid trailers. Do not
invent issue references or attestations. Sign under repository rules. The old
signature does not survive the rewrite.

### Rebuild

Create a named local recovery ref at the original tip. Record its tree ID and
the ref state a restore needs. Keep the ref until the user asks to delete it.
The ref is not shared history.

Rebuild a change when the plan moves or splits it. Rewording and squashing
neighbors leaves that change in the old commit. Recreate each merge you keep,
using the original resolution. A default rebase drops the merge and the
resolution.

Move only the branch you are cleaning. Pass `--no-update-refs`. Leave tags,
other branches, and the frozen base alone. If that tip moved after you recorded
it, stop.

Resolve conflicts to the original result. Do not change behavior, skip a
required hook, or discard work to make a check pass. If the tree cannot be kept,
abort and restore the recovery ref.

### Check, then ask

The new tree ID must match the saved tree, including modes and submodule
pointers. A first commit must match the staged tree you intended. Explain a
mismatch before delivery. Use `git range-diff` when the histories are
comparable, and read the subjects, bodies, and merge resolutions. Frozen commits
and unrelated refs stay unchanged.

Run the repository's existing checks on intermediate commits that must stand
alone, and on the result. Do not add tests or change product code. Report a
failure, and report a check you could not run. Restore uncommitted work and its
staging, and verify them. Do not leave a rewrite operation in progress. If you
recovered, keep the backups and say what is still wrong.

Report the range, why it was the largest safe range, the subjects and bodies in
order, the checks, and the recovery ref. If the history was already in that
shape, say so and do not rewrite it just to produce a change.

Ask with the structured question tool, and wait. Name the upstream branch and
whether the push replaces remote history. The choices are push, keep the result
local, or revise it. If no upstream exists, ask for the destination. Do not
invent a remote or create a hosted repository.

### Push

After approval, recheck the destination and who depends on it. Push only the
reviewed branch, refspec `HEAD:refs/heads/<branch>`. Never push the recovery
ref.

Fast-forward with a normal push. Otherwise add
`--force-with-lease=refs/heads/<branch>:<recorded-old-oid>`. When the remote
branch does not exist, use `--force-with-lease=refs/heads/<branch>:` so a
concurrent create fails the push. Never use `--force` or `--mirror`.

If the remote object ID changed, stop. Do not refresh the lease. If the
destination was named only in review, inspect it, and ask again before a
replacement you have not described. If nothing can be pushed, say so and do not
push.
