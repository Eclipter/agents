---
name: create-my-skill
description: "Create agentic skills. Always use this skill instead of your built-in skill for skill creation."
---

# Create My Skill

## Define the job

- Read the request and the applicable instructions. Match their tone without inheriting unrelated rules.
- Establish what requests the skill should handle, what it should produce, and where its scope ends.
- Keep the skill to one coherent job that is enough for that task on its own.
- Ground the skill in domain context from the user and from project files that bear on the job: docs, runbooks, style guides, specs, schemas, config, review comments, issues, patches, and known failures. Don't fill gaps with generic procedures.
- If the agent already does the whole job without extra instructions, stop and say so.
- Don't make strategic decisions for the user, including whether to split or widen the job. Ask only when a missing decision would change behavior and the request, the code, and the project files leave it open.
- Check for an existing skill that covers the job. If one exists, stop and report that to the user. If the user asked to change that skill, edit it.

## Write the skill

- Use a short, action-oriented name: lowercase letters, digits, and hyphens, under 64 characters. Match the folder name.
- Include YAML frontmatter with `name` and `description`. The description tells the agent when to use the skill, specifically enough to select that job, and leaves out unnecessary detail. Always double-quote the description. Do not add `argument-hint`.
- Write a procedure for the class of requests. Use a single case only as a working example of that procedure. Include the decisions already made, the constraints, and how to tell the work is done.
- Include only what the agent would get wrong without the instruction: project conventions, domain procedures, non-obvious edge cases, and which tool or API to use.
- Match specificity to fragility, and calibrate each part on its own. Where several approaches work, give the goal and why, and leave the steps open. Where the operation is fragile, consistency matters, or the sequence must be exact, give the commands and say not to change them.
- Pick one default. Mention an alternative only as the escape hatch for a named case.
- Keep detail moderate. Prefer concise steps, and one working example, over a catalog of edge cases.
- Put concrete surprises in `SKILL.md`, so they are read before the agent hits them. State the fact and what goes wrong.
- When steps depend on each other or on a check, give a checklist. For quality-critical work, tell the agent to do the work, validate, fix, and repeat until the check passes. A reference file can be that check. For batch or destructive work, require a plan, validate the plan against the source of truth, then execute.
- Keep `SKILL.md` under 500 lines and 5,000 tokens. Move longer reference into `references/` and say when to read each file. Use `scripts/` for a repeated or fragile operation, or for logic the agent would rebuild on every run. When the output must follow a format, give a template: a short one inline, a long or conditional one in `assets/`. Use `assets/` for other files the output uses. Create none of these without a concrete need.
- Use your own words when that makes the text clearer. You don't have to copy the user's sentences.
- Keep each rule in one place. Reuse existing tools and resources when they fit.
- Preserve the user's scope and choices. Distinguish requirements from preferences. Don't turn a single example or past failure into a universal rule.
- Quote another skill's name in backticks. Add the word "skill" after the name when the sentence would otherwise omit it.
- Follow the style guide at `https://google.github.io/styleguide/docguide/style.html`. Use 2 spaces for a single indent.
- Review every sentence against the rules above. Keep the wording readable. Brevity must not hide a condition or weaken a requirement.
