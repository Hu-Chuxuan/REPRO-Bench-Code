# @yaml
# signature: |-
#   edit
#   <replacement_text>
#   end_of_edit
# docstring: replaces *all* of the text between the START CURSOR and the END CURSOR with the replacement_text. The replacement text is terminated by a line with only end_of_edit on it. All of the <replacement_text> will be entered, so make sure your indentation is formatted properly. To enter text at the beginning of the file, set START CURSOR and END CURSOR to 0. Use set_cursors to move the cursors around. Python files will be checked for syntax errors after the edit.
# end_name: end_of_edit
# arguments:
#   replacement_text:
#     type: string
#     description: the text to replace the current selection with
#     required: true
edit() {
    if [ -z "$CURRENT_FILE" ]; then
        echo 'No file open. Use the `open` command first.'
        return
    fi

    local start_line=$((START_CURSOR - 1))
    start_line=$((start_line < 0 ? 0 : start_line))
    local end_line=$((END_CURSOR))
    end_line=$((end_line < 0 ? 0 : end_line))

    local replacement_text="$1"
    if [ -z "$replacement_text" ]; then
        echo "Error: replacement_text cannot be empty"
        return
    fi

    local replacement=()
    while IFS= read -r line; do
        replacement+=("$line")
    done <<< "$replacement_text"

    local num_lines=${#replacement[@]}

    # Create a backup of the current file in the current working directory
    cp "$CURRENT_FILE" "$(basename "$CURRENT_FILE")_backup"

    # Read the file line by line into an array (portable replacement for mapfile)
    lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done < "$CURRENT_FILE"

    # Replace lines between START_CURSOR and END_CURSOR with replacement text
    local new_lines=("${lines[@]:0:$start_line}" "${replacement[@]}" "${lines[@]:$((end_line))}")

    # Write the new content back into the original file
    printf "%s\n" "${new_lines[@]}" >| "$CURRENT_FILE"

    # Run linter for Python files
    if [[ $CURRENT_FILE == *.py ]]; then
        lint_output=$(flake8 --isolated --select=F821,F822,F831,E111,E112,E113,E999,E902 "$CURRENT_FILE" 2>&1)
    else
        lint_output=""
    fi

    # Check if there are any linter errors
    if [ -z "$lint_output" ]; then
        # Update START and END cursors based on the number of lines edited
        export END_CURSOR=$((num_lines == 0 ? START_CURSOR : START_CURSOR + num_lines - 1))
        export START_CURSOR=$START_CURSOR
        echo "END_CURSOR=$END_CURSOR"
        echo "START_CURSOR=$START_CURSOR"
        _print
        echo "File updated successfully. Please review the changes to ensure everything is correct."
    else
        # Display syntax errors and revert changes
        echo "Your proposed edit has introduced new syntax error(s). Please read the following error(s):"
        echo "$lint_output"

        # Restore the original file content
        cp "$(basename "$CURRENT_FILE")_backup" "$CURRENT_FILE"
        echo "Changes reverted. Please correct your edit and try again."

        # Display the original code before the failed edit
        export CURRENT_LINE=$(( ((end_line - start_line) / 2) + start_line ))
        export WINDOW=$((end_line - start_line + 10))
        echo "This is the original code before your edit:"
        _constrain_line
        _print
    fi

    # Clean up: remove the backup file
    rm -f "$(basename "$CURRENT_FILE")_backup"
}