#!/bin/bash
# hx-dap — Helix DAP helper commands
# Usage: hx-dap <command>
#
# Commands:
#   kill    Kill running debug adapter processes
#   status  Show running debug adapter processes
#   config  Print recommended .helix/languages.toml for PHP project

set -e

ADAPTER_JS="$HOME/.local/libexec/php-debug/out/phpDebug.js"

case "${1:-}" in
    kill)
        echo "==> Killing debug adapter processes..."
        pkill -f "phpDebug.js" 2>/dev/null && echo "✅ Killed" || echo "No processes found"
        ;;

    status)
        echo "==> Debug adapter processes:"
        ps aux | grep "[p]hpDebug.js" || echo "None running"
        ;;

    config)
        echo "==> Recommended .helix/languages.toml for PHP project:"
        echo ""
        cat <<TOML
[[language]]
name = "php"
[language.debugger]
name = "vscode-php-debug"
transport = "stdio"
command = "node"
args = ["$ADAPTER_JS"]
[[language.debugger.templates]]
name = "Listen for Xdebug"
request = "launch"
completion = ["ignored"]
args = { port = "9003", serverSourceRoot = "/var/www/html/PROJECT", localSourceRoot = "$(pwd)" }
[[language.debugger.templates]]
name = "Launch current script"
request = "launch"
completion = ["filename"]
args = { program = "{0}", runtimeExecutable = "php" }
TOML
        echo ""
        echo "    ⚠️  Replace PROJECT with your container's document root folder name"
        ;;

    *)
        echo "Usage: hx-dap <kill|status|config>"
        echo ""
        echo "  kill    Kill running debug adapter processes"
        echo "  status  Show running debug adapter processes"
        echo "  config  Print recommended .helix/languages.toml for PHP project"
        exit 1
        ;;
esac
