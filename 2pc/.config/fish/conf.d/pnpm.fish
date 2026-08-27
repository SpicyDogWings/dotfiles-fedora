# pnpm
if test -d "$HOME/.local/share/pnpm"
  set -gx PNPM_HOME "$HOME/.local/share/pnpm"
  set -gx PATH "$PNPM_HOME" $PATH
end
