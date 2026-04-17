#!/usr/bin/env bash
pkill -x rofi && exit
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"

kb_cache="$HOME/.cache/hyde/keybinds_hint.rofi"

[ -f "$kb_cache" ] && {
    trap '$HOME/.config/hypr/scripts/hint-hyprland.py --format rofi > "$kb_cache" 2>/dev/null && echo "Keybind cache updated" ' EXIT
}

output="$(if
    ! cat "$kb_cache" 2> /dev/null
then
    "$HOME/.config/hypr/scripts/hint-hyprland.py" --format rofi 2>/dev/null | tee "$kb_cache"
fi)"
wait

if [ -z "$output" ]; then
    notify-send "Keybind Hint" "Initialization failed."
    exit 0
fi

if ! command -v rofi &> /dev/null; then
    echo "$output"
    echo "rofi not detected. Displaying on terminal instead"
    exit 0
fi

selected=$(echo -e "$output" | rofi -dmenu \
    -theme-str "entry { placeholder: \"\t⌨️ Keybindings \";}" \
    -mesg " Keybinds \t\tﴕ Description" \
    -i \
    -display-columns 1 \
    -display-column-separator ":::" \
    -theme "$HOME/.config/hypr/rofi/keybinds_hint.rasi" | sed 's/.*\s*//')

if [ -z "$selected" ]; then exit 0; fi

dispatch=$(awk -F ':::' '{print $2}' <<< "$selected" | xargs)
arg=$(awk -F ':::' '{print $3}' <<< "$selected" | xargs)
repeat=$(awk -F ':::' '{print $4}' <<< "$selected" | xargs)

RUN() {
    case "$(eval "hyprctl dispatch '$dispatch' '$arg'")" in *"Not enough arguments"*) exec $0 ;; esac
}

if [ -n "$dispatch" ] && [ "$(echo "$dispatch" | wc -l)" -eq 1 ]; then
    if [ "$repeat" = repeat ]; then
        while true; do
            repeat_command=$(echo -e "Repeat" | rofi -dmenu -no-custom -p - "[Enter] repeat; [ESC] exit" -theme "notification")
            if [ "$repeat_command" = "Repeat" ]; then
                RUN
            else
                exit 0
            fi
        done
    else
        RUN
    fi
else
    exec $0
fi
