---
name: grill-me
description: "Grill the user relentlessly about a plan, decision, or idea. Use
  when the user wants to stress-test their thinking, or uses any 'grill' trigger
  phrases."
---

# Grill me

## Principles

Interview the user until you reach a shared understanding. Map the plan as a
**design tree**: each decision branches into the decisions that depend on it.
The **frontier** contains decisions whose prerequisites are settled: questions
you can ask now without guessing at answers you have not heard.

Find facts yourself; leave decisions to the user. When a question needs an
environment fact (filesystem, tools, etc.), dispatch a subagent to find it.
Treat a running exploration as an unsettled prerequisite. Ask the rest of the
frontier while only its dependent questions wait.

## Workflow

1. Ask the whole frontier in one round. Number each question, give your
  recommended answer, and word it so "yes" accepts that recommendation.
2. Wait for the user's answers before starting the next round.
3. Recompute the frontier: settled decisions unblock their dependents. A
  question depending on another open question belongs to a later round.
4. Continue until the frontier is empty and every branch has been visited. Do
  not act on the plan until the user confirms the shared understanding.

Use this format for each round:

```text
❓ **Q1** - **<question title>**: <question body, with choices if needed>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, with choices if needed>

➡️ <your recommended answer>
```
