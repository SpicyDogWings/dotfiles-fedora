#!/bin/bash
# hx-install — Install Helix stable (Fedora package) + common deps

set -e

echo "==> Installing Helix (Fedora stable)..."
sudo dnf install -y helix

echo ""
echo "==> Installing common dependencies..."
bash "$(dirname "$0")/install-helix-deps.sh"

echo ""
echo "==> Installed:"
hx --version
