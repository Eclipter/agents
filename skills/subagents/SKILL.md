---
name: subagents
description: "Delegate main or independent subtasks to subagents."
---

# Subagents

Delegate main or independent subtasks to subagents.

- Pick the model by the tool you run in:
  - OpenCode: Nemotron 3.5 Super VL Medium;
  - Codex (ChatGPT): GPT-6.1 Terra Max;
  - Cursor: Grok 4.7 Medium (regular speed).
- Never use the top tier models for subagents.
- Relaunch the subagent with maximum resoning level available in case the subagent failed and you feel that it happened because of lack of reasoning.
- Give subagents narrow tasks and only the context they need.

## Waiting for subagents

- Continue independent work while subagents run. When only waiting remains, use
  completion notifications or a wait that returns as soon as a subagent finishes.
- Prefer an indefinite wait when supported. Otherwise, use the longest timeout
  allowed by the environment and active instructions, and wait again if it expires.
- Do not alternate sleeps with status checks or use short polling loops. Inspect
  status separately only when needed to make a decision or intervene.
