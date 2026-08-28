# pnpm
if test -d "$HOME/.local/share/pnpm/bin"
  set -gx PNPM_HOME "$HOME/.local/share/pnpm"
  if not string match -q -- "$PNPM_HOME/bin" $PATH
    set -gx PATH "$PNPM_HOME/bin" $PATH
  end
end
