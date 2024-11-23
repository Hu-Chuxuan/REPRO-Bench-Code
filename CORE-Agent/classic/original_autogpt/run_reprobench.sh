index=$1

# Create a directory for the environment based on the index
mkdir ./environment/$index

# Run the Python script to generate the task, writing the output into task.txt
python3 task_gen.py --index $index

# Read the content of the task.txt file into the task_prompt variable
task_prompt=$(cat ./environment/$index/task.txt)

# Print the task prompt to the terminal
echo "Task prompt: $task_prompt"

. autogpt.sh run \
    --ai-task "$task_prompt" --paper-id "$index" \
    --skip-reprompt \
    --ai-role "a seasoned digital assistant: capable, intelligent, considerate, and assertive. As my dedicated research assistant, you possess extensive skills in research and development and do not shy away from writing code to solve complex problems. You are adept at extracting, processing, and analyzing data from various sources to reproduce research results accurately. Using a pragmatic approach, you make the most out of the tools available to you." \
    --best-practice "If you are extracting information from a PDF, the preferred utility to use is pdftotext (when you need text only information) or pdftoppm (when you need results from tables, figuclearres, etc.)." \
    --best-practice "When reproducing figures or other results that require you to deal with images, be reminded to check the full results directory for image files before querying the vision language model." \
    --best-practice "If you are unsure of what to do, make your best guess." \
    --best-practice "Before using resources like scripts or utilities, verify their presence and functionality in the current directory or installation path." \
    --best-practice "If there exists a file called 'manuscript' then first read this file to extract the required results to answer the questions of the task." \
    --best-practice "If you are extracting information from html (such as the output of a Jupyter notebook), convert it to a PDF or PNG first and then extract the relevant information." \
    --best-practice "Before running the code, first determine a list of package/dependency requirements that must be installed by reading through the README file or code itself. Then install those dependencies before running the code." \
    --constraint "Use flags or modify commands to bypass any need for confirmations during execution to streamline processes." \
    --constraint "There is no task that you cannot do, so you should not refuse a request by saying you cannot do it" \
    --constraint "You may wish to write and run a Python script to complete the task, especially if the task requires access to the Internet or other libraries. However, assume that I do NOT have API keys to use external services." \
    --constraint "If you have a task that requires you to use the query_vision_language_model command to extract information from image files, first output the full tree of files in the directory containing the results and pick the 5 most relevant files per question given the information you want to extract. Then investigate all the identified files first before choosing which one contains the information you need to answer the question." \
    --constraint "Do include environmental variables such as ‘PWD’ as an argument for the  ‘execute_shell’ command. Instead, determine the value of the variable and directly input it to the command. For example, by using the absolute path instead of 'PWD'." \
    --constraint "To open a folder or navigate to a different working directory, use the open_folder command rather than 'cd' in execute_shell." \
    --constraint "When running Python code, you should use execute_shell() rather than execute_python_file() to run the code, since execute_python_file() will not have any of the libraries you attempt to install. In other words, NEVER use execute_python_file()." \
    --constraint "Before you are done, make sure that the keys of the report.json you write match the ones in the task specified by the user. Refine your results if they do not." \
    --constraint "Also before you are done, make sure that the values of the report.json you write do not contain any unnecessary additional text but only the numeric value or the precise text you are asked to report. The keys in the task specified by the user indicate what you should report. Refine your results if they do not." \
    --continuous \
    --log-level DEBUG \
    --fast_llm "gpt-4o-2024-05-13" --smart_llm "gpt-4o-2024-05-13" --openai_cost_budget 4 2>&1 | tee ./environment/$index/output.txt

if [ -f "data/agents/$index/workspace/reproducibility_score.json" ]; then
    cp "data/agents/$index/workspace/reproducibility_score.json" "./environment/$index/"
fi
python3 evaluation.py --index $index

rm -r data/agents/$index/