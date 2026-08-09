if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

set fish_greeting ""

# zoxide (replaces cd)
zoxide init fish | source
alias cd=z

# fastfetch --logo "~/.config/fastfetch/logo.txt"

# Pi
fish_add_path "/home/spicydogwings/.vite-plus/js_runtime/node/24.18.0/bin"

# Added by jcode installer
if not contains "/home/spicydogwings/.local/bin" $PATH
    set -gx PATH "/home/spicydogwings/.local/bin" $PATH
end

# pnpm
set -gx PNPM_HOME "/home/spicydogwings/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
