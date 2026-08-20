# fnm
if test -d "$HOME/.local/share/fnm"
  set FNM_PATH "$HOME/.local/share/fnm"
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end
