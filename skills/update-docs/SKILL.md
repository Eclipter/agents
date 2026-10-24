---
name: update-docs
description: "Bring all documentation in the repository in line with the code (the code is the source of truth) and make it read as one coherent body of work."
disable-model-invocation: true
---

# Update docs

Two goals, in this priority order:

1. **Accuracy.** Every statement matches the code.
2. **Consistency.** Structure, formatting, terminology, and tone are uniform across all docs.

An optional argument after the command narrows the scope (a path, module, or topic, e.g. `/update-docs services/api`). Without an argument, the whole repository is processed.

## Principles

- **Do not touch the code.** In code files only comments and docstrings may be changed, never executable code. If the code looks like a bug rather than intended behavior, do not "fix" the code or bend the docs toward the desired behavior: describe the actual behavior and raise the question in the report.
- **Verifiable claims only.** Do not add unverifiable statements. Leave existing unverifiable ones unchanged and list them in the report.
- **Content changes need evidence, style changes need a convention.** Do not alter the meaning of correct text. Restyle freely, but only toward a convention established in step 2, never by personal taste.
- **One voice.** New and edited text must be indistinguishable from the rest of the docs. Do not leave a file half-old, half-new in style.
- **Do not translate.** Keep each document's language. If languages are mixed across docs, report it instead of translating.
- **History is read-only.** ADRs, RFCs, CHANGELOGs, release notes, migration notes, and archives describe the past; do not rewrite them. If something in them misleads readers today, mention it in the report.
- **No secrets.** Never copy real values from `.env`, vaults, keys, or tokens into docs. Use placeholders and variable names only.
- **Do not edit generated files.** Files marked as auto-generated are updated through their generator. If a generator exists, run it; otherwise note it in the report.

## Workflow

### 1. Inventory

Build the list of documentation with `git ls-files` so that `.gitignore` is respected. Exclude `node_modules`, `vendor`, `dist`, `build`, lock files, and generated artifacts.

Look for:

- Markdown, reStructuredText, AsciiDoc, and plain-text docs: `README*`, `docs/**`, `CONTRIBUTING*`, `ARCHITECTURE*`, `SECURITY*`, `AGENTS.md`, `CLAUDE.md`, wiki directories, `*.md`, `*.rst`, `*.adoc`
- Agent rules and instructions: `.cursor/rules/**`, `.cursor/commands/**`, `.github/copilot-instructions.md`
- API specs: OpenAPI/Swagger, GraphQL schemas, protobuf comments, Postman collections
- Config examples and their descriptions: `.env.example`, `*.example.*`, `*.sample.*`, comments in `docker-compose*`, Helm `values.yaml`, `Makefile` (`help`)
- Auxiliary docs: READMEs in subdirectories, doc comments in CI pipelines, Issue/PR templates
- Docstrings and JSDoc of the public API, when they diverge from signatures you are already reading

If the scope has more than 15 files, split the work across parallel `explore` subagents by module or documentation directory. Each subagent verifies its slice and returns a list of discrepancies with evidence.

### 2. Establish the style convention

Before editing, derive a style guide from the repository itself:

- If the project already defines one (`CONTRIBUTING*`, a docs style guide, `.markdownlint*`, `.vale.ini`, `.editorconfig`, `AGENTS.md`), follow it.
- Otherwise, take the dominant convention among the existing docs, with the root `README` as the tie-breaker. Look at:
  - heading levels, capitalization (sentence vs. title case), and section order for similar documents (README, module README, runbook)
  - list markers, numbering style, indentation, and table format
  - code fence languages, shell prompt style (`$` or none), inline-code usage for paths, commands, variables, and flags
  - terminology and spelling of product, service, and component names, and one term per concept
  - tone and person (imperative vs. descriptive, "you" vs. impersonal), admonition and note style, link style (relative paths, reference links)
  - line wrapping, blank lines, trailing newline, and diagram language (Mermaid vs. ASCII)
- Keep the resulting rules in mind for the whole run; mention in the report only those that caused notable changes.

### 3. Extract claims

For each document, list the verifiable facts:

- install, run, build, test, lint, and deploy commands
- paths, directory layout, file and module names
- environment variables, CLI flags, config keys, default values
- ports, hosts, URLs, endpoints, methods, request and response formats
- versions of languages, runtimes, dependencies, and images
- architecture: components, relationships, data flows, diagrams (Mermaid, ASCII, images with captions)
- roles, permissions, processes, dependencies between steps
- code and output examples
- internal links, anchors, and file references with line numbers

### 4. Verify against the code

For every claim, find the source of truth: code, manifests, configs, schemas, CI, Dockerfiles, migrations. Prefer the executable over the descriptive: a real argument parser outranks the `--help` text in a README, and a real settings module outranks a variable table.

Also collect what is **in the code but missing from the docs**: new variables, commands, services, endpoints, required setup steps. These are gaps, and they are filled where the document already covers an adjacent topic.

Classify each finding:

| Type | Action |
| --- | --- |
| Wrong | Fix according to the code |
| Outdated (removed or renamed) | Remove or rename the mention along with dependent paragraphs |
| Gap | Add a short description in the appropriate place |
| Dead link or anchor | Fix it; remove it if the target no longer exists |
| Duplicate or cross-doc contradiction | Align with the code and, where possible, link instead of copying |
| Style inconsistency (formatting, terminology, tone, structure) | Normalize to the convention from step 2 |
| Unclear (intended or a bug, no unambiguous source) | Do not change; include in the report |

### 5. Edit

- Edit file by file, fixing facts and normalizing style in the same pass, so each file is touched once.
- Do not break the table of contents, numbering, or anchors. If you rename a heading, update every link that points to it, including from other files.
- Apply terminology changes repo-wide, not in a single file.
- Command examples must work as written: correct paths, flags, and order.
- Update tables, lists, and diagrams as a whole rather than piecemeal, so old and new content are not mixed.
- Create a new section only if there is no suitable place for the topic. Create a new documentation file only if unavoidable, and link it from an existing one.
- Do not add dates, "updated on..." notes, mentions of this command, or comments about the edits to the docs themselves.

### 6. Validate

- Check that internal links and anchors point to existing files and headings.
- Run safe read-only commands from the docs (`--help`, `--version`, `config validate`, `lint`, `docker compose config`, and similar) and compare their output with what is written. Do not run deploys, migrations, deletions, outbound network calls, or anything that changes state.
- If the project has a documentation linter configured (markdownlint, vale, yamllint, etc.), run it on the changed files.
- Review the final `git diff` and make sure only docs changed. In code files, only comments and docstrings may differ, never executable code. Style edits must not alter meaning, code blocks, or command output.
- Spot-check consistency: similar documents should now share structure, formatting, and terminology.

### 7. Report

Keep the answer short and do not restate the obvious:

1. **Changed** — per file, one line on the substance of each factual edit. Style normalization is summarized once, as the conventions applied, not per file.
2. **Unconfirmed or needs a decision** — what exactly, where in the docs, where in the code, and how they differ. Include possible code bugs, outdated historical docs, and mixed document languages here.
3. **Not checked** — what was skipped and why (e.g. requires access to an external system).

If no discrepancies or inconsistencies were found, say so in one sentence.
