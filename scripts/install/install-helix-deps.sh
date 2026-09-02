#!/bin/bash
# install-helix-deps — Common Helix dependencies (LSPs, formatters, tools)
# Shared between stable and nightly installations

set -e

BIN_DIR="$HOME/.local/bin"

echo "==> Installing Biome (LSP for HTML/JS/TS)..."
mkdir -p /tmp/biome-install
cd /tmp/biome-install
pnpm init -y >/dev/null 2>&1
pnpm add @biomejs/biome >/dev/null 2>&1
cp node_modules/.pnpm/@biomejs+cli-linux-x64@*/node_modules/@biomejs/cli-linux-x64/biome "$BIN_DIR/biome"
chmod +x "$BIN_DIR/biome"
rm -rf /tmp/biome-install
echo "✅ Biome: $(biome --version)"

echo "==> Installing oxfmt (formatter)..."
curl -fsSL "https://github.com/oxc-project/oxc/releases/latest/download/oxfmt-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/oxfmt.tar.gz
tar -xzf /tmp/oxfmt.tar.gz -C /tmp/
cp /tmp/oxfmt-x86_64-unknown-linux-gnu "$BIN_DIR/oxfmt"
chmod +x "$BIN_DIR/oxfmt"
rm -f /tmp/oxfmt.tar.gz /tmp/oxfmt-x86_64-unknown-linux-gnu
echo "✅ oxfmt: $(oxfmt --version)"

echo "==> Installing oxlint (linter)..."
curl -fsSL "https://github.com/oxc-project/oxc/releases/latest/download/oxlint-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/oxlint.tar.gz
tar -xzf /tmp/oxlint.tar.gz -C /tmp/
cp /tmp/oxlint-x86_64-unknown-linux-gnu "$BIN_DIR/oxlint"
chmod +x "$BIN_DIR/oxlint"
rm -f /tmp/oxlint.tar.gz /tmp/oxlint-x86_64-unknown-linux-gnu
echo "✅ oxlint: $(oxlint --version)"

echo "==> Installing mago (PHP linter+formatter+analyzer)..."
curl --proto '=https' --tlsv1.2 -sSf https://carthage.software/mago.sh | bash

echo "==> Installing PHP language server..."
cargo install php-lsp

echo "==> Installing PHP debug adapter..."
bash "$(dirname "$0")/install-php-debug.sh"

echo "==> Copying custom query files to runtime..."
bash "$(dirname "$0")/install-helix-queries.sh"

echo ""
echo "✅ All Helix dependencies installed to $BIN_DIR"
