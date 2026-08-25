# Guía de Inkscape CLI (harness para agentes)

Setup: **Inkscape (flatpak) + `cli-anything-inkscape` (CLI pip) + skill de
opencode**. Permite que un agente cree/edite diseños vectoriales (SVG) y
exporte a PNG/PDF/EPS por línea de comandos, sin tocar la GUI.

## Las tres capas

| Capa | Qué es | Rol |
|------|--------|-----|
| **Inkscape** | App real (flatpak) | El trabajo pesado: render/export real |
| **CLI** | Paquete pip `cli-anything-inkscape` | La "mano": comandos para manipular SVG + invocar inkscape |
| **Skill** | `SKILL.md` en `~/.agents/skills/` | El "manual" que se inyecta al agente para saber qué comandos usar |

Sin la skill el agente puede igual usar el CLI (descubriendo con `--help`),
pero va más lento. El CLI es lo imprescindible.

## Requisitos

- Python 3.10+
- Inkscape (el CLI busca el binario `inkscape` en PATH; con flatpak hace falta
  un symlink, ver abajo)
- `pip` (instalación `--user`)
- `npx` (para la skill)

## Instalación

### 1. Inkscape (flatpak)

```bash
flatpak install -y org.inkscape.Inkscape
```

> En esta máquina ya estaba instalado (v1.4.4, origin `fedora`, system).

### 2. El symlink de flatpak — IMPORTANTE

El harness busca el binario `inkscape` con `shutil.which("inkscape")`, pero el
flatpak expone el wrapper como `org.inkscape.Inkscape` (no `inkscape`). Sin el
symlink, la exportación vía inkscape (PDF/EPS) falla.

```bash
ln -s /var/lib/flatpak/exports/bin/org.inkscape.Inkscape ~/.local/bin/inkscape
```

Verificar:

```bash
inkscape --version
# → Inkscape 1.4.4 ...
```

### 3. El CLI (pip)

```bash
pip install --user cli-anything-inkscape
```

Instala el ejecutable `cli-anything-inkscape` en `~/.local/bin` (que ya está
en PATH).

### 4. La skill (opencode)

```bash
npx skills add hkuds/cli-anything@cli-anything-inkscape -g -y
```

Se instala en `~/.agents/skills/cli-anything-inkscape/`.

## Uso básico

> Gotcha: el CLI es **stateless por invocación**. No guarda el documento entre
> comandos; hay que pasar `--project <archivo>.json` antes de cada subcomando.

```bash
export PATH="$HOME/.local/bin:$PATH"

# Crear documento
cli-anything-inkscape --project test.json document new -o test.json

# Agregar una forma (el flag global --project va ANTES del subcomando)
cli-anything-inkscape --project test.json shape add-rect --x 20 --y 20 --width 100 --height 80 -s "fill:#ff0000"

# Exportar
cli-anything-inkscape --project test.json export png test.png --overwrite
```

Subcomandos disponibles: `document`, `shape`, `text`, `style`, `transform`,
`layer`, `gradient`, `path`, `session`, `export`.

## Nota sobre exportación

- `export png` renderiza con **Pillow** (solo formas básicas: rect, círculo,
  texto…). No usa inkscape.
- `export pdf` / `export eps` **sí usan inkscape** → acá es donde el symlink
  del punto 2 es obligatorio. Si inkscape no está, devuelven un fallback o
  error.

## Desinstalación / eliminación

```bash
# 1. Skill de opencode
npx skills remove cli-anything-inkscape -g -y
# (alternativa a mano: rm -rf ~/.agents/skills/cli-anything-inkscape)

# 2. CLI de pip
pip uninstall -y cli-anything-inkscape

# 3. Symlink de flatpak
rm ~/.local/bin/inkscape

# 4. (Opcional) Inkscape flatpak completo
flatpak uninstall -y org.inkscape.Inkscape
```

> `npx skills remove` sin argumentos abre un menú interactivo si no te
> acordás del nombre exacto.

## Verificación rápida

```bash
inkscape --version                          # symlink OK
cli-anything-inkscape --help                # CLI OK
ls ~/.agents/skills/cli-anything-inkscape   # skill OK
```

## Seguridad

El repo upstream es `HKUDS/CLI-Anything` (Apache-2.0, ~48k ⭐, activo).
Auditado al instalarlo: sin `shell=True`, sin red, sin `eval/exec`, deps
limpias (`click`, `prompt-toolkit`, `defusedxml`). Es un proyecto con
hardening activo (migración a `defusedxml`, fixes de path traversal).