#!/bin/bash

# Install helix tools for PHP development

## install mago (linter+formatter+analyzer) for PHP
curl --proto '=https' --tlsv1.2 -sSf https://carthage.software/mago.sh | bash

## install PHP language server
cargo install php-lsp

## install PHP debug adapter (vscode-php-debug for Helix DAP)
bash "$(dirname "$0")/install-php-debug.sh"

## fetch + build tree-sitter grammars and copy queries to runtime
echo "==> Fetching tree-sitter grammars..."
hx --grammar fetch
echo "==> Building grammars..."
hx --grammar build
echo "==> Copying query files to runtime..."
bash "$(dirname "$0")/install-helix-queries.sh"
