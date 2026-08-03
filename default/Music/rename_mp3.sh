#!/bin/bash

# rename_mp3.sh - Elimina identificador [xxx] de nombres de archivos MP3
# Uso: ./rename_mp3.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Encontrar archivos .mp3 con patrón [identificador], (Official Video) o (Official Lyric Video) - case insensitive
shopt -s nocasematch
mp3_files=()
for f in *.mp3; do
  [[ "$f" == *\[*\].mp3 || "$f" =~ \(official\ (lyric\ )?video\) ]] && mp3_files+=("$f")
done
shopt -u nocasematch

if [ ${#mp3_files[@]} -eq 0 ]; then
  pan log error "No se encontraron archivos .mp3 con identificador [xxx]"
  exit 1
fi

# Crear badge con conteo
TMP_BADGES=$(mktemp /tmp/badges.XXXXXX)
TMP_RENAME=$(mktemp /tmp/rename.XXXXXX)
trap 'rm -f "$TMP_BADGES" "$TMP_RENAME"' EXIT

cat > "$TMP_BADGES" <<EOF
[{"text": "${#mp3_files[@]} archivos", "color": "cyan", "anchor": "tr"}]
EOF

# Confirmar
pan confirm -t "Renombrar MP3" \
  -m "¿Eliminar identificador de archivos MP3?" \
  -v warning -y "Renombrar" \
  --badge "$TMP_BADGES" || {
  pan log info "Cancelado"
  exit 0
}

# Ejecutar renames
cat > "$TMP_RENAME" <<'SCRIPT'
#!/bin/bash
count=0
for old_name in "$@"; do
  new_name="$old_name"
  new_name=$(echo "$new_name" | sed -E 's/ \[[^]]*\]//g')
  new_name=$(echo "$new_name" | sed -E 's/ \([Oo][Ff][Ff][Ii][Cc][Ii][Aa][Ll] [Ll][Yy][Rr][Ii][Cc] [Vv][Ii][Dd][Ee][Oo]\)//g')
  new_name=$(echo "$new_name" | sed -E 's/ \([Oo][Ff][Ff][Ii][Cc][Ii][Aa][Ll] [Vv][Ii][Dd][Ee][Oo]\)//g')
  if [ "$old_name" != "$new_name" ]; then
    mv "$old_name" "$new_name"
    pan log info "✓ $old_name → $new_name"
    ((count++))
  fi
done
SCRIPT

pan spin -l -t "Renombrando archivos..." -- bash "$TMP_RENAME" "${mp3_files[@]}"
