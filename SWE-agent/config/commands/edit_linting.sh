# @yaml
# signature: |-
#   edit <start_line>:<end_line> "<replacement_text>"
# docstring: replaces lines <start_line> through <end_line> (inclusive) with the given text in the open file. The replacement text should be provided as a string, with newlines preserved automatically. Python files will be checked for syntax errors after the edit. If the system detects a syntax error, the edit will not be executed. Simply try to edit the file again, but make sure to read the error message and modify the edit command you issue accordingly.
# end_name: end_of_edit
# arguments:
#   start_line:
#     type: integer
#     description: the line number to start the edit at
#     required: true
#   end_line:
#     type: integer
#     description: the line number to end the edit at (inclusive)
#     required: true
#   replacement_text:
#     type: string
#     description: the text to replace the current selection with, including any newline characters (multiline text will be handled automatically)
#     required: true
edit() {
    if [ -z "$CURRENT_FILE" ]; then
        echo 'No file open. Use the `open` command first.'
        return
    fi

    # Extract start_line and end_line from the first argument
    local start_line=$(echo "$1" | cut -d: -f1)
    local end_line=$(echo "$1" | cut -d: -f2)

    # Validate input
    if [ -z "$start_line" ] || [ -z "$end_line" ]; then
        echo "Usage: edit <start_line>:<end_line> <replacement_text>"
        return
    fi

    local re='^[0-9]+$'
    if ! [[ $start_line =~ $re ]]; then
        echo "Error: start_line must be a number"
        return
    fi
    if ! [[ $end_line =~ $re ]]; then
        echo "Error: end_line must be a number"
        return
    fi

    # Handle replacement_text
    local replacement_text="$2"
    if [ -z "$replacement_text" ]; then
        echo "Error: replacement_text cannot be empty"
        return
    fi

    # Adjust for 0-based indexing
    local start_line=$((start_line - 1))

    # Backup current file
    cp "$CURRENT_FILE" "$(basename "$CURRENT_FILE")_backup"

    # Read the file into a temporary file for processing
    temp_file=$(mktemp)
    awk -v start="$start_line" -v end="$end_line" -v replacement="$replacement_text" '
    NR < start+1 { print $0 }
    NR == start+1 { print replacement }
    NR > end { print $0 }
    ' "$CURRENT_FILE" > "$temp_file"

    # Move the modified file back
    mv "$temp_file" "$CURRENT_FILE"

    # Clean up backup if all is well
    rm -f "$(basename "$CURRENT_FILE")_backup"

    echo "File updated successfully."
}