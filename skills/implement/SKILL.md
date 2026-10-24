---
name: implement
description: "Use for any change."
---

# Implement

## Principles

- **Do not decide for the user.** Any choice that is not dictated by the plan, the prompt, or the code is the user's. Ask the user at the moment it comes up, with concrete options and the one you recommend first. Do not resolve it silently and do not push it to the final report. Ask all open questions in one call when you can, and as early as you can. Do not ask about what the code or the repository already answers.
- Use subagents for main subtasks, following the `subagents` skill.
- **Do not guess scope.** The task is what the plan item or the prompt says. Extra features, drive-by refactors, and unrelated cleanups stay out of the commit; if any look worth doing, ask the user.
- **Tests and docs are part of the task.** A change without them is unfinished.
- **Never commit red.** Failing tests, a failing linter, or a broken build block the commit.
- **No secrets.** Do not stage `.env`, keys, or tokens. If they show up in the diff, stop and say so.

## Workflow

### 1. Find the work

If the prompt contains a concrete task, use it and skip to step 2.

Otherwise find the plan. In parallel:

- `git ls-files` filtered for `PLAN*`, `ROADMAP*`, `TODO*`, `TASKS*`, `BACKLOG*`, `docs/**/plan*`, `docs/**/roadmap*`, `.cursor/plans/**`, and `*.md` files whose headings contain "plan", "roadmap", or "todo"
- `AGENTS.md`, `README*`, and `docs/**` for a link to the plan
- `git log -20 --format='%s'` and `git status --short`, to see what was just done and what is in flight

If several plan files exist, take the one that is most recently changed and not marked done or archived. If none can be found, or two candidates are equally plausible, ask the user which one to use (or where the plan is) and wait.

In the plan, take items that are not done (unchecked boxes, "todo", "planned", or the first unfinished phase). Skip items marked blocked, deferred, or waiting on a decision.

### 2. Pick the batch

Choose one item, or a pool of items that fit one commit:

- they touch the same module, files, or data model;
- one is a natural continuation of another, or they would conflict if done apart;
- together they stay reviewable: roughly one logical change, not a release.

Do not mix unrelated areas, and do not bundle a risky item (migration, public API change, deletion) with small ones.

Read the code the batch touches: callers, tests, fixtures, config, exports. Write down every place the change must reach.

When the work comes from the plan and the argument did not name a specific item, do not choose the batch yourself: offer several candidate batches to ask the user, the one you would take first, each with one line on what it covers and why it fits together. Wait for the answer. If the prompt or the argument named the task, there is nothing to ask here.

### 3. Create a new branch

Skip the step if there's no git repo; work in place.

Create a new git branch in a new git worktree in the folder next to the project folder, from the current HEAD of the project's checkout. Name them conventionally, not with codex/, etc.

Files the worktree lacks (untracked or modified plan files, gitignored files such as `.env`, dependency folders like `node_modules`) must be taken from the main checkout (symlink or copy) when the checks or the plan need them. Plan and doc edits end up committed in the worktree branch.

### 4. Implement

- Follow the surrounding code: its structure, naming, error handling, and libraries.
- Prefer what the repository already has over new code or new dependencies.
- If the plan item is ambiguous or admits several readings, ask which one is meant before writing code for it.
- If the work turns out much larger than the plan suggested, or a design choice comes up that the code does not settle (a new dependency, a public interface, a data format, a behavior change beyond the item), stop and ask.
- Difficulty and scale of the task is not a problem which should stop you from making a feature till the end.
- Names are accurate and form one consistent naming scheme across the project.

### 5. Update tests

- Find the tests that cover the touched code and fix those the change breaks.
- Add tests for new behavior and for the edge cases the change introduces: empty, invalid, error, and boundary inputs.
- For a bug fix, add a test that fails without the fix.
- Use the project's existing test framework, layout, and fixtures. Do not add a new framework.
- Do not weaken or delete a test to make it pass. If a test looks wrong, ask before changing it.

### 6. Run the checks

Find the commands in the repository (`Makefile`, `package.json`, `pyproject.toml`, CI config, `AGENTS.md`), not from memory.

- Review the changes with `ponytail-review` skill and fix any issues.
- Run the tests for the touched area first, then the full suite when it is fast enough.
- Run the linter, formatter check, and type checker the project uses on the changed files.
- On a failure, fix the cause and re-run. If a failure is unrelated to your change (it also fails on a clean tree), do not touch it; ask whether to fix it in this commit, skip it, or stop.
- If the change affects UI, follow `verify-app` before moving on. This step is not advisory.

Do not continue until the checks are green. If you cannot get them green, leave the changes uncommitted and ask the user how to proceed, naming what blocks.

### 7. Update docs

Run the `update-docs` workflow scoped to what the change touched: docs that mention the changed behavior, commands, config keys, endpoints, or layout, plus the docs that the new behavior needs.

Also update the plan:

- Remove the finished items from the plan.
- If follow-ups turned up along the way, ask whether to add them to the plan; add only what the user confirms.

### 8. Commit

- Skip the step if there's no git repo.
- Check `git status --short` and `git diff --stat`. Stage ONLY the changes that belong to this batch. If it is unclear whether a change belongs to this batch, ask the user.
- Write the message by the `commit-msg` rules: repository convention first, otherwise recent commit style, otherwise English Conventional Commits. The subject describes the change to the system, not the plan item number.
- Commit. Do not push, amend, or rewrite history unless the user asked.
- If a hook rejects the commit, fix the cause and make a new commit. Do not use `--no-verify`.

### 9. Merge

- Skip the step if there's no git repo.
- Find out `<branch>`. They can be (from the biggest priority to the least):
  - "eclipter" or "vladimir-sidorov".
  - "dev".
  - "main" (choose only if there is no "dev").
- Ask the user:
  - Question: **Review the `<your-working-branch>` branch. The commit `<explain what the commit does in plain words, from the operational point of view>`**.
  - Answer options: "Merge into `<branch-selected-2-steps-above>`" and the "type another answer" default one.
  - No need to justify your question by explaining that it's said here to ask the user.
  - Stop your work until the user answers.
  - Repeat the workflow in your worktree until the user selects to merge.
  - Skip the question if there are no changes in the app itself (only docs, etc.).
- If the main checkout has uncommitted changes, stash them, merge and then pop.
- Squash-merge your branch into `<branch>`.
- Remove your working git branch and git worktree.

### 10. Report

Report with the following form:

- ✅ **Done:** — the plan items (or the task) completed, the integration commit hash and subject.

- 🕑 **Plan:** — what remains and what was added.

- ❌ **Not checked:** — what was skipped and why. Don't mention steps that were skipped because of project rules.
