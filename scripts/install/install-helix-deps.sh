#!/bin/bash

# Install helix tools for PHP development

## install mago (linter+formatter+analyzer) for PHP
curl --proto '=https' --tlsv1.2 -sSf https://carthage.software/mago.sh | bash

## install PHP language server
cargo install php-lsp

## install PHP debug adapter (vscode-php-debug for Helix DAP)
bash "$(dirname "$0")/install-php-debug.sh"
