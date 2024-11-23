_print() {
    # echo "Function _print is called"
    # Ensure CURRENT_FILE is set
    if [ -z "$CURRENT_FILE" ]; then
        echo "No file open. Use the open command first."
        return
    fi

    local total_lines=$(awk 'END {print NR}' "$CURRENT_FILE")
    echo "[File: $(realpath "$CURRENT_FILE") ($total_lines lines total)]"
    
    # Calculate lines_above and lines_below using bash arithmetic
    lines_above=$((CURRENT_LINE - WINDOW / 2))
    lines_above=$((lines_above > 0 ? lines_above : 0))  # Ensure non-negative value

    lines_below=$((total_lines - CURRENT_LINE - WINDOW / 2))
    lines_below=$((lines_below > 0 ? lines_below : 0))  # Ensure non-negative value

    # Show lines above
    if [ $lines_above -gt 0 ]; then
        echo "($lines_above more lines above)"
    fi

    # echo "CURRENT_LINE: $CURRENT_LINE"
    # echo "WINDOW: $WINDOW"
    # echo "lines_above: $lines_above"
    # echo "lines_below: $lines_below"
    
    # Ensure we don't exceed the total number of lines
    start_line=$((CURRENT_LINE - WINDOW / 2))
    start_line=$((start_line > 0 ? start_line : 1))

    end_line=$((CURRENT_LINE + WINDOW / 2))
    end_line=$((end_line > total_lines ? total_lines : end_line))

    # Display the range of lines using awk
    awk "NR >= $start_line && NR <= $end_line" "$CURRENT_FILE"

    # Show lines below
    if [ $lines_below -gt 0 ]; then
        echo "($lines_below more lines below)"
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
# signature: open "<path>" [<line_number>]
# docstring: opens the file at the given path in the editor. If line_number is provided, the window will move to include that line
open() {
    if [ -z "$1" ]; then
        echo "Usage: open \"<file>\""
        return
    fi

    local line_number

    if [ -n "$2" ]; then
        if ! [[ $2 =~ ^[0-9]+$ ]]; then
            echo "Usage: open \"<file>\" [<line_number>]"
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
            local OFFSET=$((WINDOW / 6))
            line_number=$(( $2 + WINDOW / 2 - OFFSET ))
        fi
    else
        line_number=$((WINDOW / 2))
    fi

    if [ -f "$1" ]; then
        export CURRENT_FILE=$(realpath "$1")
        export CURRENT_LINE=$line_number
        echo "CURRENT_LINE=$CURRENT_LINE"
        echo "CURRENT_FILE=$CURRENT_FILE"
        _constrain_line
        _print
    elif [ -d "$1" ]; then
        echo "Error: $1 is a directory. You can only open files. Use cd or ls to navigate directories."
    else
        echo "File $1 not found"
    fi
}

# @yaml
# signature: goto <line_number>
# docstring: moves the window to show <line_number>
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

    local OFFSET=$((WINDOW / 6))
    export CURRENT_LINE=$(( $1 + WINDOW / 2 - OFFSET ))
    echo "CURRENT_LINE=$CURRENT_LINE"
    _constrain_line
    _print
}

# @yaml
# signature: scroll_down
# docstring: moves the window down {WINDOW} lines
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
# docstring: moves the window up {WINDOW} lines
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
# signature: create <filename>
# docstring: creates and opens a new file with the given name
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
# docstring: submits your current code and terminates the session
submit() {
    # cd "$ROOT"

    # if [ -s "/root/test.patch" ]; then
    #     git apply -R < "/root/test.patch"
    # fi

    # git add -A
    # git diff --cached > model.patch
    # echo "<<SUBMISSION||"
    # cat model.patch
    echo "SUBMITTED"
}