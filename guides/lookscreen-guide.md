# Guía de bloqueo de pantalla (lock screen)

Setup: **niri + Noctalia**, con todo el bloqueo unificado en la pantalla de
Noctalia. Esta guía explica cómo funciona cada pieza y por qué, para poder
replicarla o debuggearla en otra máquina.

## Objetivo

Que el bloqueo sea siempre el de Noctalia, sin importar el disparador:

- Manual (tecla)
- Por inactividad (timeout)
- Al suspender (antes de dormir la máquina)

`swaylock` queda solo como último recurso si Noctalia no responde.

## Las tres capas

### 1. Bloqueo manual — bind de niri

En `~/.config/niri/config.kdl`:

```kdl
Super+Alt+L hotkey-overlay-title="Lock the Screen: noctalia" {
    spawn-sh "noctalia msg session lock || swaylock";
}
```

Primero le pide a Noctalia que bloquee por IPC (`noctalia msg session lock`);
si falla, cae a swaylock. El `||` es el patrón fallback que se repite en toda
la config.

### 2. Suspensión

Dos mecanismos conviven y apuntan al mismo lado:

- **Noctalia**: en `~/.config/noctalia/settings.json`, sección session,
  `"lockOnSuspend": true`. Noctalia escucha el PrepareForSleep de logind y
  muestra su lock screen.
- **swayidle** con hook `before-sleep` (ver capa 3), como red de seguridad.

Ambos terminan bloqueando lo mismo (el protocolo `ext-session-lock-v1`
admite un solo cliente a la vez), así que da igual quién gane la carrera:
el resultado visual es el de Noctalia.

### 3. Inactividad — unidad systemd de usuario

`~/.config/systemd/user/swayidle.service`:

```ini
[Service]
ExecStart=/usr/bin/swayidle -w \
    timeout 601 'niri msg action power-off-monitors' \
    timeout 600 'noctalia msg session lock || swaylock -f' \
    before-sleep 'noctalia msg session lock || swaylock -f'
Restart=on-failure
```

- A los **600 s** sin actividad → lock.
- A los **601 s** → apaga los monitores (DPMS de niri).
- En `before-sleep` (suspend) → lock.

## El bug original: el anillito azul y verde

Ese circulito era el **indicador de autenticación de swaylock**: su pantalla
por defecto (fondo liso + anillo que se pone azul/verde al validar la
contraseña).

La unidad tenía antes:

```
before-sleep 'swaylock -f'
```

O sea: al suspender, swayidle disparaba swaylock *directo*, que tomaba el
session-lock antes que Noctalia y ganaba la carrera contra el
`lockOnSuspend` de Noctalia. Resultado: al despertar aparecía la pantalla
de swaylock en vez de la de Noctalia.

**Fix aplicado**: que tanto el timeout como `before-sleep` llamen primero a
`noctalia msg session lock`, dejando swaylock solo como fallback.

## Shells que interfieren: DMS

DankMaterialShell (DMS) trae su propio lock screen e idle manager, que
peleaban con Noctalia por los mismos recursos (session-lock, timers de
inactividad). Se desinstaló del sistema por eso.

Si algún día se reinstala: deshabilitar su módulo de lock/idle, o van a
aparecer pantallas de bloqueo aleatorias según cuál tome el lock primero.

> Nota: GDM sigue activo como display-manager pero no interfiere con el
> locking actual (el problema de DMS era su lock propio).

## Notas de diseño

- El **idle manager interno de Noctalia queda deshabilitado**
  (`"idle": { "enabled": false }`) para no duplicar daemons: ya hay un
  swayidle gestionando timeouts. Si se habilitara, además activaría el
  auto-suspend a los 30 min (`"suspendTimeout": 1800`), cambio de
  comportamiento no deseado.
- Los tiempos viven todos en la unidad de systemd, no en Noctalia: un solo
  lugar para ajustar.

## Restaurar en otra PC

```bash
systemctl --user daemon-reload
systemctl --user enable --now swayidle.service
```

## Verificación rápida

```bash
# El servicio corre con los args esperados
pgrep -a swayidle

# Está habilitado
systemctl --user is-enabled swayidle

# Probar: suspender y comprobar que aparece el lock de Noctalia
```
