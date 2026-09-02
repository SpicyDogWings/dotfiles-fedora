#!/bin/bash
# Copy tree-sitter queries from grammar sources to Helix runtime directory
# Fixes missing syntax highlighting when grammars are built but queries aren't linked

set -e

RUNTIME_DIR="${HELIX_RUNTIME:-$HOME/.config/helix/runtime}"
SOURCES_DIR="$RUNTIME_DIR/grammars/sources"

if [ ! -d "$SOURCES_DIR" ]; then
    echo "No grammar sources found at $SOURCES_DIR"
    echo "Run 'hx --grammar fetch' first."
    exit 1
fi

COPIED=0

for lang_dir in "$SOURCES_DIR"/*/queries; do
    lang=$(basename "$(dirname "$lang_dir")")
    target="$RUNTIME_DIR/queries/$lang"

    mkdir -p "$target"

    for f in "$lang_dir"/*.scm; do
        [ -f "$f" ] || continue
        cp "$f" "$target/"
        ((COPIED++))
    done
done

# Copy custom query files (textobjects, indents, tags, rainbows)
# These are not in the upstream tree-sitter grammars
CUSTOM_QUERIES_DIR="$(dirname "$0")/../custom-queries"
if [ -d "$CUSTOM_QUERIES_DIR" ]; then
    for lang_dir in "$CUSTOM_QUERIES_DIR"/*/; do
        lang=$(basename "$lang_dir")
        target="$RUNTIME_DIR/queries/$lang"
        mkdir -p "$target"
        for f in "$lang_dir"/*.scm; do
            [ -f "$f" ] || continue
            cp "$f" "$target/"
            ((COPIED++))
        done
    done
    echo "✅ Copied custom query files"
fi

echo "✅ Copied $COPIED query files to $RUNTIME_DIR/queries/"
