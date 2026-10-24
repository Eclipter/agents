---
name: vibe-sec
description: "Secure coding checklist for web apps: access control, XSS/CSRF, SSRF, injection, uploads, JWT, headers, API security. Use when writing or reviewing code that handles auth, user input, files, sessions, or external requests, or when the user asks for a security scan or audit."
---

<!-- Changed from https://github.com/BehiSecc/VibeSec-Skill. Apache License 2.0; see LICENSE. -->

# Secure Coding Guide for Web Applications

Approach code as a bug hunter and make it as secure as possible without breaking functionality.

- Fail closed: when a check errors out, deny access.
- Authentication and authorization on every endpoint, not just at routing.
- Validate input server-side; encode output for its context.
- When unsure, choose the more restrictive option.

## Topic router

Read only the reference files relevant to the code at hand. For a full audit or scan, read all of them.

| Topic | Reference | Read when |
| --- | --- | --- |
| Access control | [references/access-control.md](references/access-control.md) | Code decides who can read or change a resource (ownership, IDs, roles, sessions, tenants) |
| XSS, CSRF, client secrets, open redirect, passwords | [references/client-side.md](references/client-side.md) | Code renders user input, changes state from the browser, redirects, or handles passwords or secrets |
| SSRF, file upload, SQL injection, XXE, path traversal | [references/server-side.md](references/server-side.md) | Code fetches URLs, accepts files, builds queries, parses XML, or uses user input in paths |
| Security headers, JWT, mass assignment, GraphQL | [references/headers-jwt-api.md](references/headers-jwt-api.md) | Code sets response headers, issues or verifies JWTs, binds request bodies, or exposes GraphQL |
| Command injection, deserialization, CORS, rate limits, races, webhooks, sessions, secrets, dependencies | [references/misc.md](references/misc.md) | Code runs commands, parses serialized data, sets CORS, handles payments or webhooks, manages sessions, or ships config and dependencies |

## Audit output

When asked for a review or scan, report findings ranked Critical, High, Medium, Low. For each one give: file and line, what an attacker can do in one sentence, a minimal fix. Say which topics were checked and which were not. Report only issues you traced to real code paths; do not list generic advice. When writing new code, apply the rules silently and mention only the non-obvious choices.
