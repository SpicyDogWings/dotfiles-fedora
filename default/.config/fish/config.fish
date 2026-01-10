if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

set fish_greeting ""

fastfetch --logo "~/.config/fastfetch/logo.txt"

# opencode
fish_add_path /home/spicydogwings/.opencode/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

