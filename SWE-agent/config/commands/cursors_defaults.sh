_reset_cursors() {
    export START_CURSOR=1
    export END_CURSOR=1
    echo "START_CURSOR=$START_CURSOR"
    echo "END_CURSOR=$END_CURSOR"
}

_constrain_cursors() {
    local total_lines=$(awk 'END {print NR}' "$CURRENT_FILE")
    total_lines=$((total_lines < 1 ? 1 : total_lines))  # if the file is empty, set total_lines to 1
    local start_line=$((CURRENT_LINE - WINDOW / 2))
    local end_line=$((CURRENT_LINE + WINDOW / 2))
    start_line=$((start_line < 1 ? 1 : start_line))
    end_line=$((end_line > total_lines ? total_lines : end_line))
    local warning_string=""

    if [ "$START_CURSOR" -lt "$start_line" ]; then
        warning_string+="START_CURSOR moved to $start_line\n"
        START_CURSOR=$start_line
    elif [ "$START_CURSOR" -gt "$end_line" ]; then
        START_CURSOR=$end_line
        warning_string+="START_CURSOR moved to $end_line\n"
    fi

    if [ "$END_CURSOR" -lt "$start_line" ]; then
        warning_string+="END_CURSOR moved to $start_line\n"
        END_CURSOR=$start_line
    elif [ "$END_CURSOR" -gt "$end_line" ]; then
        warning_string+="END_CURSOR moved to $end_line\n"
        END_CURSOR=$end_line
    fi

    export START_CURSOR END_CURSOR
    echo "START_CURSOR=$START_CURSOR"
    echo "END_CURSOR=$END_CURSOR"
    echo -e "$warning_string"
    echo "$START_CURSOR $END_CURSOR"
}

_print() {
    local cursor_warning=$(_constrain_cursors)
    local cursor_values=$(echo "$cursor_warning" | tail -n 1)
    cursor_warning=$(echo "$cursor_warning" | head -n -1)
    export START_CURSOR=$(echo "$cursor_values" | awk '{print $1}')
    export END_CURSOR=$(echo "$cursor_values" | awk '{print $2}')
    echo "START_CURSOR=$START_CURSOR"
    echo "END_CURSOR=$END_CURSOR"
    local total_lines=$(awk 'END {print NR}' "$CURRENT_FILE")
    echo "[File: $(realpath "$CURRENT_FILE") ($total_lines lines total)]"

    local start_line=$((CURRENT_LINE - WINDOW / 2))
    local end_line=$((CURRENT_LINE + WINDOW / 2))
    start_line=$((start_line < 1 ? 1 : start_line))
    end_line=$((end_line > total_lines ? total_lines : end_line))

    local lines=()
    local i=0
    while IFS= read -r line; do
        lines[i++]="$line"
    done < <(awk -v start="$start_line" -v end="$end_line" 'NR>=start && NR<=end {print}' "$CURRENT_FILE")

    local num_lines=${#lines[@]}
    if [ $start_line -gt 1 ]; then
        echo "($((start_line - 1)) more lines above)"
    fi

    for ((i=0; i<num_lines; i++)); do
        local line_number=$((start_line + i))
        if [ "$line_number" -eq "$START_CURSOR" ]; then
            echo "$START_CURSOR_MARK"
        fi

        if [ $i -ge 0 ] && [ $i -lt $num_lines ]; then
            echo "$line_number:${lines[i]}"
        fi

        if [ "$line_number" -eq "$END_CURSOR" ]; then
            echo "$END_CURSOR_MARK"
        fi
    done

    lines_below=$((total_lines - start_line - num_lines))
    lines_below=$((lines_below > 0 ? lines_below : 0))

    if [ "$lines_below" -gt 0 ]; then
        echo "($lines_below more lines below)"
    fi

    if [ -n "$cursor_warning" ]; then
        echo -e "$cursor_warning"
    fi
}

_constrain_line() {
    if [ -z "$CURRENT_FILE" ]; then
        echo "No file open. Use the open command first."
        return
    fi
    local max_line=$(awk 'END {print NR}' "$CURRENT_FILE")
    local half_window=$((WINDOW / 2))

    CURRENT_LINE=$((CURRENT_LINE > (max_line - half_window) ? (max_line - half_window) : CURRENT_LINE))
    CURRENT_LINE=$((CURRENT_LINE < half_window ? half_window : CURRENT_LINE))
}

# @yaml
# signature: set_cursors <start_line> <end_line>
set_cursors() {
    if [ -z "$CURRENT_FILE" ]; then
        echo "No file open. Use the open command first."
        return
    fi
    if [ $# -lt 2 ]; then
        echo "Usage: set_cursors <start_line> <end_line>"
        return
    fi
    local start_line=$1
    local end_line=$2
    local re='^[0-9]+$'
    if ! [[ $start_line =~ $re ]]; then
        echo "Usage: set_cursors <start_line> <end_line>"
        echo "Error: start_line must be a number"
        return
    fi
    if ! [[ $end_line =~ $re ]]; then
        echo "Usage: set_cursors <start_line> <end_line>"
        echo "Error: end_line must be a number"
        return
    fi
    if [ $start_line -gt $end_line ]; then
        echo "Usage: set_cursors <start_line> <end_line>"
        echo "Error: start_line must be less than or equal to end_line"
        return
    fi
    export START_CURSOR=$start_line
    export END_CURSOR=$end_line
    echo "START_CURSOR=$START_CURSOR"
    echo "END_CURSOR=$END_CURSOR"
    _print
}

# @yaml
# signature: open <path> [<line_number>]
open() {
    if [ -z "$1" ]; then
        echo "Usage: open <file>"
        return
    fi

    local line_number

    if [ -n "$2" ]; then
        if ! [[ $2 =~ ^[0-9]+$ ]]; then
            echo "Usage: open <file> [<line_number>]"
            echo "Error: <line_number> must be a number"
            return
        fi

        local max_line=$(awk 'END {print NR}' "$1")

        if [ $2 -gt $max_line ]; then
            echo "Warning: <line_number> ($2) is greater than the number of lines in the file ($max_line)"
            echo "Setting <line_number> to $max_line"
            line_number=$max_line
        elif [ $2 -lt 1 ]; then
            echo "Warning: <line_number> ($2) is less than 1"
            echo "Setting <line_number> to 1"
            line_number=1
        else
            line_number=$2
        fi
    else
        line_number=$((WINDOW / 2))
    fi

    if [ -f "$1" ]; then
        export CURRENT_FILE=$(realpath "$1")
        export CURRENT_LINE=$line_number
        echo "CURRENT_FILE=$CURRENT_FILE"
        echo "CURRENT_LINE=$CURRENT_LINE"
        _constrain_line
        _print
    else
        echo "File $1 not found"
    fi
}

# @yaml
# signature: scroll_down
scroll_down() {
    if [ -z "$CURRENT_FILE" ]; then
        echo "No file open. Use the open command first."
        return
    fi

    export CURRENT_LINE=$((CURRENT_LINE + WINDOW - OVERLAP))
    echo "CURRENT_LINE=$CURRENT_LINE"
    _constrain_line
    _print
}

# @yaml
# signature: scroll_up
scroll_up() {
    if [ -z "$CURRENT_FILE" ]; then
        echo "No file open. Use the open command first."
        return
    fi

    export CURRENT_LINE=$((CURRENT_LINE - WINDOW + OVERLAP))
    echo "CURRENT_LINE=$CURRENT_LINE"
    _constrain_line
    _print
}

# @yaml
# signature: goto <line_number>
goto() {
    if [ $# -gt 1 ]; then
        echo "goto allows only one line number at a time."
        return
    fi

    if [ -z "$CURRENT_FILE" ]; then
        echo "No file open. Use the open command first."
        return
    fi

    if [ -z "$1" ]; then
        echo "Usage: goto <line>"
        return
    fi

    if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo "Usage: goto <line>"
        echo "Error: <line> must be a number"
        return
    fi

    local max_line=$(awk 'END {print NR}' "$CURRENT_FILE")
    if [ $1 -gt $max_line ]; then
        echo "Error: <line> must be less than or equal to $max_line"
        return
    fi

    export CURRENT_LINE=$(( $1 + WINDOW / 2 - WINDOW / 6 ))
    echo "CURRENT_LINE=$CURRENT_LINE"
    _constrain_line
    _print
}

# @yaml
# signature: create <filename>
create() {
    if [ -z "$1" ]; then
        echo "Usage: create <filename>"
        return
    fi

    if [ -e "$1" ]; then
        echo "Error: File '$1' already exists."
        open "$1"
        return
    fi

    printf "\n" > "$1"
    open "$1"
}

# @yaml
# signature: submit
submit() {
    cd "$ROOT"

    if [ -s "/root/test.patch" ]; then
        git apply -R < "/root/test.patch"
    fi

    git add -A
    git diff --cached > model.patch
    echo "<<SUBMISSION||"
    cat model.patch
    echo "||SUBMISSION>>"
}