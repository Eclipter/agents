---
name: diagnose
description: "Find the root cause of an issue by isolating it step by step, and explain it in plain words. Changes nothing."
---

# Diagnose

One run, one cause: collect evidence, narrow the issue down until nothing is left to narrow, and explain the cause so the user understands it without prior technical knowledge.

The argument after the command is the symptom: an error message, a failing command, a log path, a screen, or a description. Without an argument, take the issue from the conversation.

## Principles

- **Read-only.** Do not fix, refactor, or commit anything. Temporary probes (extra logging, a scratch script, a reproduction) are fine; remove them before the report.
- **Isolate till the end.** Stop only when the cause is a concrete thing that can be changed or replaced, or when no available access can narrow it further. "Processor error" is not a cause; "the physical processor fails under load, most likely due to its age; it needs to be replaced" is.
- **Evidence over guesses.** Every step of the chain from symptom to cause is backed by something observed: a log line, a command output, a reproduction, a code path. Mark anything not proven as a hypothesis, with how likely it is.
- **Use all access you have.** Logs, system tools, the code, git history, configs, the running app, the browser, Computer Use. Run read-only diagnostics yourself instead of asking the user to.
- **Do not decide for the user.** If narrowing further needs something only the user can do or allow (physical access, credentials, a destructive test, a reboot), ask the user, with concrete options and the one you recommend first.
- Use subagents where it pays off, following the `subagents` skill. Delegate: independent hypotheses or layers checked in parallel, wide searches through big logs/code/history, and comparing against a working case. Keep in the main thread: the chain of reasoning, anything that depends on the previous step's result, and the final conclusion. Do not delegate trivial checks that take one command. Subagents only collect evidence (read-only, same rules as above); you verify their key findings yourself before putting them in the report.

## Workflow

### 1. Pin the symptom

- Write down exactly what happens, what was expected, where, and since when.
- Reproduce it. If it cannot be reproduced, collect what is left of it: logs, crash reports, history, timestamps.
- Check what changed recently: `git log`, `git status`, updates, config, environment.

### 2. Narrow it down

Repeat until the cause is concrete:

- List the layers the symptom passes through (hardware, OS, network, service, app, module, function, data).
- Pick the check that splits the remaining suspects in half, run it, and drop what it rules out.
- Compare with a working case when one exists: another machine, an older commit (`git bisect`), other input, a clean config.
- When several suspects remain that can be checked independently, run one subagent per suspect in parallel, each with the symptom, its suspect, and what evidence to return.
- Keep a short trail of each check and what it showed.

### 3. Confirm

- Show that the cause explains every observed symptom, not just the main one.
- When possible, prove it: toggle the cause and watch the symptom appear and disappear.
- Remove all temporary probes.

### 4. Report

- 🎯 **Cause:** — as concrete as the evidence allows, with how sure you are.

- 🛠 **What to do:** — the fix or replacement, in plain words. If you don't know how to resolve it, say so honestly.

- ❌ **Not checked:** — what could not be checked and why, and what remains a hypothesis.
