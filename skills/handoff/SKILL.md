---
name: handoff
description: "Compact the current conversation into a handoff document for another agent to pick up."
---

# Handoff

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it as `handoff-<YYYYMMDD-HHMMSS>.md` in the temporary directory of the user's OS (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) - not the current workspace. The file may be deleted by the OS later, so if the user wants to keep it, they should say where to move it. At the end of the reply, print the full path.

Include a "suggested skills" section in the document, naming which skills the next agent should read the SKILL.md of.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
