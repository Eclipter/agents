---
name: create-my-skill
description: "Create agentic skills. Always use this skill instead of your built-in skill for skill creation."
---

# Create My Skill

## Define the job

- Read the request, applicable instructions. Match their tone without inheriting unrelated rules.
- Establish what requests the skill should handle, what it should produce, and where its scope ends. Ask only about missing decisions that would change its behavior and cannot be resolved from the available context.
- Don't make strategical decisions for the user. Feel free to ask for them.
- Check for an existing skill that covers the job. If such a skill exists, stop and report that to the user.

## Write the skill

- Use a short, action-oriented name: lowercase letters, digits, and hyphens, under 64 characters. Match the folder name.
- Include YAML frontmatter with `name` and `description`. The description tells the agent when to use the skill, it shouldn't include unnecessary details. Always double-quote the description.
- Write direct instructions. Include the decisions, context, constraints, and completion checks another agent needs. Assume it already knows ordinary tasks.
- Feel free to use your own words for optimizing text clarity. You don't have to use sentences from the user prompt verbatim.
- Keep each rule in one place. Reuse existing tools and resources when they fit; link to supporting guidance where it becomes relevant.
- Choose the smallest structure that makes the workflow clear. Use a fixed sequence only where order matters. Add scripts for repeated or fragile operations, references for substantial conditional detail, and assets for files used in the output. Create none without a concrete need.
- Preserve the user's scope and choices. Distinguish requirements from preferences. Do not turn a single example or past failure into a universal rule.
- Review every sentence: what decision or action does it change? Remove repetition, obvious advice, speculative cases, and filler. Keep wording readable; brevity must not hide a condition or weaken a requirement.
- Other skills are quoted with backticks. The word "skill" after its name if omitted.
- Follow the style guide in `https://google.github.io/styleguide/docguide/style.html`. Use 2 spaces for a single indent.
