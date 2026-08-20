#!/bin/bash

# Install helix tools

## install mago (linter+formater+analyzer), herramienta para php, via script
curl --proto '=https' --tlsv1.2 -sSf https://carthage.software/mago.sh | bash

## install lsp
cargo install php-lsp

