---
name: create-my-skill
description: "Create agentic skills. Always use this skill instead of your
  built-in skill for skill creation."
---

# Create my skill

## Principles

- Use a short, action-oriented name: lowercase letters, digits, and hyphens,
  under 64 characters. Match the folder name.
- Include YAML frontmatter with `name` and `description`, do not add
  `argument-hint`. The description tells the agent when to use the skill,
  specifically enough to select that job, and leaves out unnecessary detail.
  Always double-quote the description. End description with a dot.
- Include only what the agent would get wrong without the instruction: project
  conventions, domain procedures, non-obvious edge cases, and which tool or API
  to use.
- Keep detail moderate. Prefer concise steps, and one working example, over a
  catalog of edge cases.
- Put concrete surprises in `SKILL.md`, so they are read before the agent hits
  them. State the fact and what goes wrong.
- Keep `SKILL.md` under 500 lines and 5,000 tokens. Move longer reference into
  `references/` and say when to read each file. Use `scripts/` for deterministic
  operations to reduce token usage. When the output must follow a format, give a
  template: a short one inline, a long or conditional one in `assets/`. Use
  `assets/` for other files the output uses. Create none of these without a
  concrete need.
- Use your own words which you think fit the best, don't copy the user's phrases
  from the request.
- Follow DRY principle. A need to duplicate rules or instructions is a sign of
  poorly structured text.
- Distinguish requirements from preferences. Don't turn a single example or past
  failure into a universal rule.

### Style

- Follow the style guide at `https://google.github.io/styleguide/docguide/style.html`.
- Use sentence case for headings.
- Don't use numbered headings.
- Top-level heading must be a capitalized copy of the skill name. Examples:
  - `verify-ux-ui`: Verify UX/UI.
  - `commit-message`: Commit message.
- Use numbered lists when sequence matters (e.g., a list of actions) and marked
  lists when doesn't.
- Use 2 spaces for a single indent.
- Section name conventions:
  - "Principles" - for static rules. Usually level-2 heading; always preceds
    "Workflow".
  - "Workflow" - for active steps. Usually level-2 heading.
  - Other sections can be called arbitrarily.
- When mentioning a skill, quote its name in backticks and omit the word "skill"
  after it.

## Workflow

### Analyze the request

1. Check for an existing skill that covers the job. If one exists, stop and
   report that. If the user asked to change that skill, edit it.
2. If the agent already does the whole job without extra instructions, stop and
   say so.
3. Don't make strategic decisions for the user, suggest only.

### Write a skill

Write a skill, while applying the naming, content, and style requirements above to the requested skill.

### Visualize skill workflow

1. Skip the step if the skill doesn't invoke other skills.
2. Use `visualize-skill-workflow` to get both a Mermaid diagram and an SVG file.
3. Add the Mermaid source and SVG to `workflow/` in the corresponding skill
   directory.
4. Add the SVG as a link to the README.md. Example:

  ```text
  ## Skill workflows

  ### Implement

  [![`implement` workflow](skills/sdlc/implement/workflow/workflow.svg)](skills/sdlc/implement/workflow/workflow.svg)
  ```

### Commit and review

1. Use `commit`.
2. Report that you're done with "✅". Extend the answer from the single emoji
   only if there's something important to report or discuss, no need to write
   empty phrases like "the skill is done and waiting for your review" or list
   your results.
3. When the user makes changes, review them against the rules above. Enforce the
   rules strictly unless the user explicitly disagrees with them.
