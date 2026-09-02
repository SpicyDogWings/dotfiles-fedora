#!/bin/bash
# Wrapper that kills any existing phpDebug.js before starting a new one
# This prevents EADDRINUSE errors on port 9003

# Kill any existing phpDebug.js processes (except ourselves)
pkill -f "phpDebug.js" 2>/dev/null

# Small delay to let the port be released
sleep 0.2

# Start the real adapter
exec node "$HOME/.local/libexec/php-debug/out/phpDebug.js" "$@"
