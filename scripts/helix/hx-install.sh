#!/bin/bash
# hx-install — Install Helix stable (Fedora package)
# Usage: hx-install

set -e

echo "==> Installing Helix (Fedora stable)..."
sudo dnf install -y helix

echo ""
echo "==> Installed:"
hx --version
