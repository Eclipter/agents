---
name: verify-app
description: "Verify an application change in action before declaring the task done. Use after implementing or fixing UI, layout, styling, routing, client state, or rendered data in web, desktop (macOS/Windows/Linux), mobile, CLI/TUI, or game apps."
---

# Verify App

A screenshot shows appearance, not behavior. Before declaring the task complete, confirm the change works in the app.

## Steps

1. Exercise the changed feature end to end the way a real user would, and confirm behavior, not just appearance. Web: browser tools. Native and desktop (macOS, Windows, Linux): Computer Use or the platform's UI automation and screenshots. Mobile: simulator or emulator. CLI/TUI: run the command with real inputs and check output and exit codes. Games: play the changed path and check the on-screen result.

2. Check every screen, mode, or command that shares the state, data, or components you touched, and the surrounding flows, to catch regressions.

3. Cover the edge states your change touches: empty, error, and variants such as routes, flags, window sizes, devices, or inputs. If layout or styling changed, check the layouts a real user will see.

4. If verification finds a problem, fix it and re-verify. If verification is impossible (no simulator, no access), say so in the report with the reason.
