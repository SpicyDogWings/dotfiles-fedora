#!/bin/bash
# Check and install PHP debug adapter (vscode-php-debug) for Helix DAP
#
# Usage:
#   install-php-debug.sh         # Install or update
#   install-php-debug.sh --check # Only check if installed
#
# Requires: node, pnpm, git
# Installs to: ~/.local/libexec/php-debug/

set -e

ADAPTER_DIR="$HOME/.local/libexec/php-debug"
ADAPTER_JS="$ADAPTER_DIR/out/phpDebug.js"
SCRIPTS_DIR="$HOME/.config/dotstate/storage/scripts/helix"

check_only() {
    local ok=true
    if [ ! -f "$ADAPTER_JS" ]; then
        echo "❌ php-debug adapter not built"
        ok=false
    fi
    if [ ! -x "$HOME/.local/bin/hx-php-debug" ]; then
        echo "❌ hx-php-debug wrapper missing"
        ok=false
    fi
    if [ ! -x "$HOME/.local/bin/hx-dap" ]; then
        echo "❌ hx-dap helper missing"
        ok=false
    fi
    if [ ! -x "$HOME/.local/bin/hx-init-php-debug" ]; then
        echo "❌ hx-init-php-debug helper missing"
        ok=false
    fi
    if [ "$ok" = true ]; then
        echo "✅ php-debug adapter fully installed"
        exit 0
    fi
    exit 1
}

if [ "${1:-}" = "--check" ]; then
    check_only
fi

echo "==> Installing vscode-php-debug (Xdebug DAP adapter)..."

mkdir -p "$HOME/.local/libexec" "$HOME/.local/bin"

if [ -d "$ADAPTER_DIR" ]; then
    echo "    Already installed, updating..."
    cd "$ADAPTER_DIR"
    git pull --ff-only 2>/dev/null || true
else
    echo "    Cloning..."
    git clone --depth 1 https://github.com/xdebug/vscode-php-debug.git "$ADAPTER_DIR"
    cd "$ADAPTER_DIR"
fi

echo "    Installing dependencies..."
pnpm install --ignore-scripts

echo "    Building..."
pnpm exec tsc -p .
pnpm copyfiles

# Apply patch: force process.exit(0) after disconnect response
# This is required because vscode-php-debug doesn't exit after disconnect,
# which causes Helix to leave zombie processes and EADDRINUSE on port 9003
echo "    Applying process.exit patch..."
if grep -q "process.exit(0)" "$ADAPTER_JS"; then
        echo "    Patch already applied"
    else
        # Add process.exit(0) after sendResponse in disconnectRequest
        sed -i '/this.sendResponse(response);/a\        // FIX: Force exit after disconnect so Helix can clean up\n        setTimeout(() => process.exit(0), 50);' "$ADAPTER_JS"
        echo "    Patch applied"
    fi

# Install wrapper script (kills old processes before starting new one)
if [ -f "$SCRIPTS_DIR/hx-php-debug.sh" ]; then
    cp "$SCRIPTS_DIR/hx-php-debug.sh" "$HOME/.local/bin/hx-php-debug"
    chmod +x "$HOME/.local/bin/hx-php-debug"
    echo "    Installed hx-php-debug wrapper"
fi

# Link helper scripts
if [ -f "$SCRIPTS_DIR/hx-dap.sh" ]; then
    ln -sf "$SCRIPTS_DIR/hx-dap.sh" "$HOME/.local/bin/hx-dap"
    echo "    Linked hx-dap helper"
fi

if [ -f "$SCRIPTS_DIR/hx-init-php-debug.sh" ]; then
    ln -sf "$SCRIPTS_DIR/hx-init-php-debug.sh" "$HOME/.local/bin/hx-init-php-debug"
    echo "    Linked hx-init-php-debug helper"
fi

if [ -f "$ADAPTER_JS" ]; then
    echo "✅ PHP debug adapter installed"
    echo ""
    echo "    Add to ~/.config/helix/languages.toml:"
    echo ""
    cat <<TOML
[[language]]
name = "php"
[language.debugger]
name = "vscode-php-debug"
transport = "stdio"
command = "$HOME/.local/bin/hx-php-debug"
args = []
[[language.debugger.templates]]
name = "Listen for Xdebug"
request = "launch"
completion = ["ignored"]
args = { port = "9003" }
TOML
else
    echo "❌ Build failed"
    exit 1
fi
