#!/bin/bash
# hx-nightly — Build and install Helix nightly from master with DAP expensive-scope fix
# Usage: hx-nightly [build|install|clean|info]
#
# Commands:
#   build   Clone master, patch, and compile
#   install Install the already-built binary to ~/.local/bin/hx
#   clean   Remove build artifacts
#   info    Show current installed version

set -e

BUILD_DIR="$HOME/.cache/helix-build"
SRC_DIR="$BUILD_DIR/helix"
TMP_DIR="$BUILD_DIR/tmp"
INSTALL_DIR="$HOME/.local"
BIN="$INSTALL_DIR/bin/hx"

case "${1:-help}" in
    build)
        echo "==> Building Helix nightly from master..."
        echo ""

        mkdir -p "$BUILD_DIR" "$TMP_DIR"
        export TMPDIR="$TMP_DIR"

        if [ ! -d "$SRC_DIR" ]; then
            echo "==> Cloning helix master..."
            git clone --depth 1 https://github.com/helix-editor/helix.git "$SRC_DIR"
        else
            echo "==> Updating helix master..."
            cd "$SRC_DIR"
            git pull --ff-only
        fi

        cd "$SRC_DIR"

        echo "==> Applying DAP expensive-scope fix..."
        if grep -q 'scopes.iter().filter(|s| !s.expensive)' helix-term/src/commands/dap.rs; then
            echo "    Patch already applied."
        else
            sed -i 's/for scope in scopes\.iter() {/for scope in scopes.iter().filter(|s| !s.expensive) {/' \
                helix-term/src/commands/dap.rs
            echo "    Patch applied."
        fi

        echo "==> Compiling (this takes a few minutes)..."
        cargo build --release 2>&1 | tail -5

        echo ""
        echo "==> Build complete."
        echo "    Run 'hx-nightly install' to install to $BIN"
        ;;

    install)
        if [ ! -f "$SRC_DIR/target/release/hx" ]; then
            echo "❌ No binary found. Run 'hx-nightly build' first."
            exit 1
        fi

        echo "==> Installing hx to $BIN..."
        cd "$SRC_DIR"
        cargo install --path helix-term --locked --root "$INSTALL_DIR" --force 2>&1 | tail -3

        echo ""
        echo "==> Installed:"
        $BIN --version
        ;;

    clean)
        echo "==> Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        echo "✅ Cleaned."
        ;;

    info)
        if [ -f "$BIN" ]; then
            echo "==> Installed Helix:"
            $BIN --version
        else
            echo "No Helix found at $BIN"
        fi
        ;;

    *)
        echo "Usage: hx-nightly <build|install|clean|info>"
        echo ""
        echo "   build   Clone master, patch DAP fix, and compile"
        echo "   install Install the built binary to ~/.local/bin/hx"
        echo "   clean   Remove all build artifacts"
        echo "   info    Show installed version"
        exit 1
        ;;
esac
