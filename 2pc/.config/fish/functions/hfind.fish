function hfind
    set -l selected_command (history | fzf --height 40% --reverse)
    if test -n "$selected_command"
        commandline -- $selected_command
    end
end
