if status is-interactive
    # Commands to run in interactive sessions can go here
end

# starship (opcional)
if command -q starship
    starship init fish | source
end

set fish_greeting ""

# zoxide (replaces cd)
zoxide init fish | source
alias cd=z

# fastfetch --logo "~/.config/fastfetch/logo.txt"

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if test -d "$PNPM_HOME" && not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# opencode
fish_add_path "$HOME/.opencode/bin"

# dotstate y binarios locales
fish_add_path "$HOME/.local/bin"
