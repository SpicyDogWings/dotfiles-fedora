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
ADAPTER_WRAPPER="$HOME/.local/bin/hx-dap"

check_only() {
    if [ -f "$ADAPTER_JS" ] && [ -x "$ADAPTER_WRAPPER" ]; then
        echo "✅ php-debug adapter installed"
        echo "   Binary: $ADAPTER_JS"
        echo "   Helper: $ADAPTER_WRAPPER"
        exit 0
    elif [ -f "$ADAPTER_JS" ]; then
        echo "⚠️  php-debug adapter built but helper missing"
        echo "   Run without --check to fix"
        exit 1
    else
        echo "❌ php-debug adapter not installed"
        exit 1
    fi
}

if [ "${1:-}" = "--check" ]; then
    check_only
fi

echo "==> Installing vscode-php-debug (Xdebug DAP adapter)..."

mkdir -p "$HOME/.local/libexec"

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

# Ensure helix helper scripts are linked
SCRIPTS_DIR="$HOME/.config/dotstate/storage/scripts/helix"
if [ -f "$SCRIPTS_DIR/hx-dap.sh" ]; then
    ln -sf "$SCRIPTS_DIR/hx-dap.sh" "$HOME/.local/bin/hx-dap"
    echo "    Linked hx-dap helper"
fi

if [ -f "$SCRIPTS_DIR/hx-init-php-debug.sh" ]; then
    ln -sf "$SCRIPTS_DIR/hx-init-php-debug.sh" "$HOME/.local/bin/hx-init-php-debug"
    echo "    Linked hx-init-php-debug helper"
fi

if [ -f "$ADAPTER_JS" ]; then
    echo "✅ PHP debug adapter installed at: $ADAPTER_JS"
else
    echo "❌ Build failed"
    exit 1
fi
