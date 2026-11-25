---
name: learn-english
description: "Give detailed English feedback on the message that invokes this skill."
disable-model-invocation: true
---

# Learn English

## Workflow

1. Review the user's English in the current message, excluding the invocation
   token and literal code, commands, and identifiers. If the message contains
   no English to review, ask the user to include text with the invocation.
2. Read sentence by sentence. Check grammar, sentence structure, spelling,
   capitalization, punctuation, word choice, idiom, usual word pairings,
   register, and ambiguity. Flag every issue you find, including small ones.
3. List the findings in message order. Quote the exact wording for each, give
   a correction or a more natural alternative, and explain why it helps.
   Label actual errors and optional style changes distinctly. Respect valid
   dialect and register choices, and explain any ambiguity that affects the
   correction.
4. Give a complete natural rewrite that preserves meaning, tone, and technical
   terms. If the wording already works, say so. If the message also asks you
   to do something, address that request and append the English feedback.
