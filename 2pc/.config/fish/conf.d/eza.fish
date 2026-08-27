# eza (modern replacement for ls/exa)
# Requires: eza installed and a Nerd Font in the terminal.

if not command -q eza
    exit 0
end

alias ls="eza --icons=auto"
alias ll="eza --icons=auto --git --group-directories-first -la"
alias la="eza --icons=auto --group-directories-first -a"
alias tree="eza --icons=auto --tree"