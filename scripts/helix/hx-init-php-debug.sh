#!/bin/bash
# hx-init-php-debug — Set up PHP debug config for current project
# Usage: hx-init-php-debug [server_root_folder]
#
# Creates .helix/languages.toml in current directory
# with proper path mappings for brown/podman containers.

set -e

TEMPLATE_DIR="$HOME/.config/dotstate/storage/templates/helix-php"
TEMPLATE="$TEMPLATE_DIR/languages.toml.template"
LOCAL_PATH="$(pwd)"
SERVER_ROOT="${1:-$(basename "$LOCAL_PATH")}"

if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Template not found: $TEMPLATE"
    exit 1
fi

mkdir -p ".helix"

# Replace placeholders
sed -e "s|HOME|$HOME|g" \
    -e "s|PROJECT|$SERVER_ROOT|g" \
    -e "s|LOCAL_PATH|$LOCAL_PATH|g" \
    "$TEMPLATE" > ".helix/languages.toml"

echo "✅ Created .helix/languages.toml"
echo "   Server root: /var/www/html/$SERVER_ROOT"
echo "   Local path:  $LOCAL_PATH"
echo ""
echo "   Restart Helix to pick up changes."
