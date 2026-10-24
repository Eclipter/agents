---
name: loop
description: "Work through a project plan or todo list by launching subagents with implement or fix."
---

# Loop

Own the scheduling and integration of plan tasks until no actionable work
remains. Delegate each concrete task to a subagent using `implement` or `fix`.
Invoking this skill authorizes task selection within the requested plan scope.

## Find and classify the work

Read project instructions, the requested plan or todo list, repository status,
and relevant code. If no source is named, use the plan-discovery rules in
`implement`. Ask through the structured questions tool
only when the source or scope cannot be resolved from available context.

Keep a compact task ledger with the source item, chosen skill, prerequisites,
possible obsolescence, affected areas, status, and assigned agent. Preserve plan
priorities and explicit limits. Skip completed, deferred, and explicitly blocked
items; do not invent follow-up work.

Choose the skill from the task's intended outcome:

- Use `fix` for broken existing behavior: errors, regressions,
  incorrect results, crashes, or failures against an established requirement.
  Include the symptom and evidence; let `fix` establish the root cause.
- Use `implement` for new capabilities and planned changes,
  including refactoring, migrations, tests, and documentation without a reported
  malfunction. A planned feature not yet built is an implementation; an
  existing feature failing its promised behavior is a fix.

Resolve the choice from the plan and code without asking the user to choose a
skill. Ask only if the intended behavior itself is unresolved. Keep separate bugs
as separate `fix` assignments. Group implementation items only when they form
one logical change under `implement`'s batch rules.

## Choose the largest safe batch

Inspect dependencies before dispatch, including relationships the plan leaves
implicit. Hold a task when another unfinished task must establish its interface,
data model, behavior, or shared implementation first.

Also hold work that another task could make unnecessary. Examples include
patching a component scheduled for replacement, addressing several symptoms
that may share one root cause, or updating tests or docs for behavior about to
change. Name the specific task and reason for each hold; a vague possibility
must not serialize unrelated work. Run the prerequisite, replacement, or root
cause task first. Resolve mutual holds using project priorities and code
evidence; ask about an unresolved product decision instead of deadlocking.

Choose the largest set of ready tasks that can safely run together within the
available agent capacity and any user-specified parallelism cap. Account for
the coordinator, existing agents, and capacity workers need for their own
delegation. Follow `subagents` for model selection and
delegation; use only model identifiers actually supported by the current tool.
If its preferred model is unavailable, use a supported non-top-tier fallback
and state the substitution.

Tasks are independent only when they need no unfinished result from each other,
cannot reasonably obsolete each other, and can be integrated without competing
changes to the same behavior or shared contract. Serialize overlapping code
changes unless their separation is clear. Shared plan edits alone can be
reconciled during integration. Do not split one task artificially to fill slots.
If only one task is safe, launch one.

## Dispatch concrete assignments

Use the environment's subagent tools, not new user-owned chats. Read the chosen
skill before dispatch and include its name and resolved `SKILL.md` path in the
worker's prompt. Each prompt must contain:

- The exact task ID or source text, plan path, intended outcome, and acceptance
  criteria from the plan or established project behavior.
- An explicit instruction to use either `implement` or `fix`, read its skill
  file, and follow its tests, review, docs, commit, and integration workflow.
- The project path, current integrated base revision, prerequisite results,
  relevant evidence, and known concurrent work or files to avoid.
- A boundary: complete only this assignment; do not select additional plan
  items. The concrete assignment satisfies `implement`'s task-selection step.
- A request to report changed behavior, checks and results, branch/worktree and
  commits, plan edits, any newly discovered dependency or obsolete task, and any
  decision or approval needed.

Before dispatching each task in a Git project, check local and remote branches
and existing worktrees for work in progress (WIP) on that task. Inspect matching
branches' changes to confirm the task; do not rely on branch names alone. If WIP
exists, pass its branch, worktree, and remaining work to the worker and resume
there instead of creating a duplicate branch. If another agent is already
working on it, track that assignment instead of dispatching it again.

For tasks without existing WIP, let workers follow `implement`'s branch and
worktree rules. Ensure assignments use distinct branches and worktrees; do not
create competing edits in the same checkout. Without Git, delegate concurrent
edits only to disjoint files.

Workers may delegate within their assignment under `subagents`; they must not
start another `loop` or duplicate an active assignment. Keep within the shared
agent limit. If nested delegation needs capacity, reduce the active task count
or release completed agents before dispatching more work.

## Reassess and integrate

Wait through the subagent tools and handle each result as it arrives. Continue
independent work while a worker needs a decision. Surface unresolved questions
through the structured questions tool with the concrete choices and evidence;
never answer a required user approval on the user's behalf. Follow the called
skills' integration rules and approvals already granted in the conversation.

Review each result against its acceptance criteria and required checks. A
worker's completion message is not proof that its changes are integrated. In a
Git project, release dependent work only once the prerequisite is integrated
into the working base and verified. Serialize integration, reconcile plan edits
against the latest plan, and run checks appropriate to the combined changes.
If approval is pending, hold dependent tasks and continue unrelated ready work.

After every result, integration, failure, or new dependency, reread the affected
plan items and code. Recompute readiness and refill free capacity with the
largest safe set. Start new assignments from the latest integrated base. If an
active assignment becomes obsolete, stop or redirect its worker promptly and
preserve any useful work; do not erase unreviewed changes.

Revisit each held task after its blocking work is integrated. Verify whether
its acceptance criteria are already satisfied or its target has been removed.
Complete it only with evidence; otherwise dispatch the remaining work. Record
why an item was superseded using the project's plan conventions, without
claiming it was implemented or silently deleting unfinished work.

Investigate failures before retrying. Follow `subagents` for reasoning-related
retries; do not repeatedly relaunch an unchanged failing assignment. Preserve
blocked tasks and continue independent ones. Add newly discovered follow-ups
only with the authorization required by `implement`.

## Finish

Continue until the requested scope is complete, the user stops the loop, an
explicit run limit is reached, or all remaining tasks need unavailable input,
approval, or prerequisites. Do not stop after the first batch while ready work
remains. If subagent tools are unavailable, report that limitation rather than
claiming delegated execution.

Report completed and integrated tasks with commits and checks, tasks superseded
with evidence, and anything still waiting with its reason. Distinguish prepared
branches awaiting approval from integrated work. Do not describe a blocked or
partially completed plan as finished.
