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

# opencode
fish_add_path "$HOME/.opencode/bin"

# dotstate y binarios locales
fish_add_path "$HOME/.local/bin"
