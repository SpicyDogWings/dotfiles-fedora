#!/bin/bash

# rename_mp3.sh - Elimina identificador [xxx] de nombres de archivos MP3
# Uso: ./rename_mp3.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Encontrar archivos .mp3 con patrón [identificador]
mp3_files=()
for f in *.mp3; do
  [[ "$f" == *\[*\].mp3 ]] && mp3_files+=("$f")
done

if [ ${#mp3_files[@]} -eq 0 ]; then
  pan log error "No se encontraron archivos .mp3 con identificador [xxx]"
  exit 1
fi

# Crear badge con conteo
TMP_BADGES=$(mktemp /tmp/badges.XXXXXX)
trap 'rm -f "$TMP_BADGES"' EXIT

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
pan spin -l -t "Renombrando archivos..." -- bash -c "
count=0
for old_name in \"${mp3_files[@]}\"; do
  new_name=\"\${old_name/ \[*\]/}\"
  if [ \"\$old_name\" != \"\$new_name\" ]; then
    mv \"\$old_name\" \"\$new_name\"
    echo \"✓ \$old_name → \$new_name\"
    ((count++))
  fi
done
"
