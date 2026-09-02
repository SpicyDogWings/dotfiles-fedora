#!/bin/bash
# Install Biome (LSP), Oxc tools (oxfmt, oxlint), and HTML tree-sitter queries

set -e

BIN_DIR="$HOME/.local/bin"

echo "==> Installing Biome (via pnpm)..."
mkdir -p /tmp/biome-install
cd /tmp/biome-install
pnpm init -y >/dev/null 2>&1
pnpm add @biomejs/biome >/dev/null 2>&1
cp node_modules/.pnpm/@biomejs+cli-linux-x64@*/node_modules/@biomejs/cli-linux-x64/biome "$BIN_DIR/biome"
chmod +x "$BIN_DIR/biome"
rm -rf /tmp/biome-install
echo "✅ Biome installed: $(biome --version)"

echo "==> Installing oxfmt..."
curl -fsSL "https://github.com/oxc-project/oxc/releases/latest/download/oxfmt-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/oxfmt.tar.gz
tar -xzf /tmp/oxfmt.tar.gz -C /tmp/
cp /tmp/oxfmt-x86_64-unknown-linux-gnu "$BIN_DIR/oxfmt"
chmod +x "$BIN_DIR/oxfmt"
rm -f /tmp/oxfmt.tar.gz /tmp/oxfmt-x86_64-unknown-linux-gnu
echo "✅ oxfmt installed: $(oxfmt --version)"

echo "==> Installing oxlint..."
curl -fsSL "https://github.com/oxc-project/oxc/releases/latest/download/oxlint-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/oxlint.tar.gz
tar -xzf /tmp/oxlint.tar.gz -C /tmp/
cp /tmp/oxlint-x86_64-unknown-linux-gnu "$BIN_DIR/oxlint"
chmod +x "$BIN_DIR/oxlint"
rm -f /tmp/oxlint.tar.gz /tmp/oxlint-x86_64-unknown-linux-gnu
echo "✅ oxlint installed: $(oxlint --version)"

echo ""
echo "==> Fetching and building tree-sitter grammars..."
hx --grammar fetch
hx --grammar build
echo "==> Copying query files to runtime..."
bash "$(dirname "$0")/install-helix-queries.sh"

echo ""
echo "All tools installed to $BIN_DIR"
