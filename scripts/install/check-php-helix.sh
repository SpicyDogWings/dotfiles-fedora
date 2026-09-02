#!/bin/bash
# Check all PHP + Helix development tools
# Usage: check-php-helix.sh

set +e

PASS=0
FAIL=0
WARN=0

check() {
    local name="$1"
    local cmd="$2"
    local hint="${3:-}"

    if eval "$cmd" >/dev/null 2>&1; then
        echo "✅ $name"
        ((PASS++))
    else
        echo "❌ $name"
        [ -n "$hint" ] && echo "   → $hint"
        ((FAIL++))
    fi
}

check_version() {
    local name="$1"
    local version_output="$2"

    if [ -n "$version_output" ]; then
        echo "✅ $name ($version_output)"
        ((PASS++))
    else
        echo "❌ $name"
        ((FAIL++))
    fi
}

echo "=== PHP + Helix Development Tools Check ==="
echo ""

# Core PHP tools
check_version "php-lsp" "$(php-lsp --version 2>/dev/null | head -1)"
check_version "intelephense" "$(intelephense --version 2>/dev/null | head -1)"
check_version "mago" "$(mago --version 2>/dev/null | head -1)"

echo ""

# Debug adapter
ADAPTER_JS="$HOME/.local/libexec/php-debug/out/phpDebug.js"
if [ -f "$ADAPTER_JS" ]; then
    echo "✅ vscode-php-debug (DAP adapter)"
    ((PASS++))
else
    echo "❌ vscode-php-debug (DAP adapter)"
    echo "   → Run: bash ~/.config/dotstate/storage/scripts/install/install-php-debug.sh"
    ((FAIL++))
fi

# Helper scripts
check "hx-dap (debug killer)" "command -v hx-dap"
check "hx-init-php-debug (project setup)" "command -v hx-init-php-debug"

echo ""

# Runtime deps
check "node" "which node"
check "pnpm" "which pnpm"
check "git" "which git"

echo ""

# Helix itself
check_version "helix" "$(hx --version 2>/dev/null || helix --version 2>/dev/null)"

echo ""
echo "=== Tree-sitter PHP highlighting ==="

PHP_HL="$HOME/.config/helix/runtime/queries/php/highlights.scm"
if [ -f "$PHP_HL" ]; then
    echo "✅ PHP highlight queries"
    ((PASS++))
else
    echo "❌ PHP highlight queries (missing: $PHP_HL)"
    echo "   → Run: bash ~/.config/dotstate/storage/scripts/install/install-helix-queries.sh"
    ((FAIL++))
fi

echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "Fix all with: bash ~/.config/dotstate/storage/scripts/install/install-helix-deps.sh"
    exit 1
fi

exit 0
