#!/bin/sh
# Hook configs stay free of usernames and Node install paths.
# shortcut: nvm/fnm/volta are skipped, add their bin dir here if a machine uses one.
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
cd "$(dirname "$0")" || exit 1
exec node "$@"
