#!/bin/bash
# Script para montar enlace de USBs con nombre CASSETTE*

TMP_BADGES=$(mktemp /tmp/badges.XXXXXX)
TMP_ITEMS=$(mktemp /tmp/items.XXXXXX)
trap 'rm -f "$TMP_BADGES" "$TMP_ITEMS"' EXIT

# Buscar dispositivos USB con nombre CASSETTE*
USB_LIST=()
for dev in /dev/disk/by-label/CASSETTE*; do
    [ -e "$dev" ] || continue
    
    LABEL=$(basename "$dev")
    # Buscar el punto de montaje actual
    MOUNT_POINT=$(findmnt -n -o TARGET "$dev" 2>/dev/null)
    
    if [ -n "$MOUNT_POINT" ]; then
        STATUS="montado"
        STATUS_COLOR="green"
        EXTRA="$MOUNT_POINT"
    else
        STATUS="no montado"
        STATUS_COLOR="red"
        EXTRA="sin montar"
    fi
    
    # Agregar al array: nombre|estado|color|extra
    USB_LIST+=("${LABEL}|${STATUS}|${STATUS_COLOR}|${EXTRA}")
done

if [ ${#USB_LIST[@]} -eq 0 ]; then
    # Modo demo: items de ejemplo para testing
    USB_LIST+=("CASSETTE-01|montado|green|/media/CASSETTE-01")
    USB_LIST+=("CASSETTE-02|no montado|red|sin montar")
    USB_LIST+=("CASSETTE-03|montado|green|/mnt/cassette3")
fi

# Badge de estado general
TOTAL=${#USB_LIST[@]}
MOUNTED=$(printf '%s\n' "${USB_LIST[@]}" | grep -c '|montado|' || true)

cat > "$TMP_BADGES" <<EOF
[
  {"text": "USBs: ${TOTAL}", "color": "cyan", "anchor": "tr"},
  {"text": "Montadas: ${MOUNTED}", "color": "green", "anchor": "tr", "layer": 1},
  {"text": "CASSETTE", "color": "yellow", "anchor": "tl"}
]
EOF

# Usar choose en lugar de filter para debug
PAN_ITEMS=()
for item in "${USB_LIST[@]}"; do
    IFS='|' read -r LABEL STATUS COLOR EXTRA <<< "$item"
    PAN_ITEMS+=("${LABEL} [${STATUS}] (${EXTRA})")
done

SELECTED=$(pan choose -t "Seleccionar USB" --badge "$TMP_BADGES" --badge-anchor tl "${PAN_ITEMS[@]}") || exit 1

# Extraer solo el nombre (antes del primer espacio)
USB_NAME=$(echo "$SELECTED" | awk '{print $1}')

# Verificar que no esté ya montado
MOUNT_POINT=$(findmnt -n -o TARGET "/dev/disk/by-label/${USB_NAME}" 2>/dev/null)

if [ -z "$MOUNT_POINT" ]; then
    # Crear punto de montaje y montar
    MOUNT_POINT="/media/${USB_NAME}"
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount "/dev/disk/by-label/${USB_NAME}" "$MOUNT_POINT"
    
    if [ $? -ne 0 ]; then
        echo "Error al montar ${USB_NAME}"
        exit 1
    fi
fi

# Crear enlace simbólico en Music
LINK_NAME="${PWD}/${USB_NAME}"

if [ -L "$LINK_NAME" ]; then
    rm "$LINK_NAME"
fi

ln -s "$MOUNT_POINT" "$LINK_NAME"
echo "Enlace creado: ${LINK_NAME} -> ${MOUNT_POINT}"