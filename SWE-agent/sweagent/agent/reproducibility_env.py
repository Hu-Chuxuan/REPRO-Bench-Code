import os
import re
import subprocess

def command_exec(text, working_directory, env, commands_dir):
    # TODO: environment setups
    # subprocess.call(command, shell=True)
    print(text)
    res = ""
    command_pattern = r'```(.*?)```'
    match = re.search(command_pattern, text, re.DOTALL)
    if match:
        command = match.group(1).strip() 
        print(command)
        parts = command.split()

        if parts[0] == 'cd':
            # Handle the 'cd' command
            if len(parts) == 1 or parts[1] == '~':
                # If 'cd' is called without an argument, it defaults to the home directory
                new_directory = os.path.expanduser("~")
            elif parts[1] == '-':
                # If 'cd -' is called, go back to the previous directory (could store last dir)
                new_directory = working_directory
            else:
                # Otherwise, update the working directory to the specified path
                new_directory = os.path.join(working_directory, parts[1])

            # Normalize the path (removing redundant slashes, etc.)
            new_directory = os.path.abspath(new_directory)

            if os.path.exists(new_directory) and os.path.isdir(new_directory):
                # Return the updated directory
                return "", new_directory, env
            else:
                return f"No such file or directory: {new_directory}", working_directory, env

        
        # if venv_path:
        #     # For Linux/macOS
        #     activate_command = f"source {venv_path}/bin/activate &&"
        #     command = activate_command + " " + command
        # command = "stata-se -b do /Users/chuxuanhu/Documents/reproducibility/code/env_tests/test_script.do"
        # source_commands = ["open", "goto", "scroll_down", "scroll_up", "create", "submit", "search_dir", "search_file", "find_file", "edit"]
        # if any(keyword in command for keyword in source_commands):
        cursors_defaults = os.path.join(commands_dir, 'cursors_defaults.sh')
        cursors_edit_linting = os.path.join(commands_dir, 'cursors_edit_linting.sh')
        defaults = os.path.join(commands_dir, 'defaults.sh')
        edit_linting = os.path.join(commands_dir, 'edit_linting.sh')
        search = os.path.join(commands_dir, 'search.sh')

        command = f"""
        source {cursors_defaults} &&
        source {cursors_edit_linting} &&
        source {defaults} &&
        source {edit_linting} &&
        source {search} &&
        {command}
        """
        bash_command = f"bash -c '{command}'"
        # else:
        #     bash_command = f"{command}"
        result = subprocess.run(bash_command, cwd=working_directory, shell=True, capture_output=True, text=True, env=env)
        for line in result.stdout.splitlines():
            if "=" in line:
                key, value = line.split("=", 1)
                env[key] = value

        output = result.stdout
        res += output
        error_output = result.stderr
        if error_output:
            res += error_output
    else:
        res += "No command found."
    return res, working_directory, env