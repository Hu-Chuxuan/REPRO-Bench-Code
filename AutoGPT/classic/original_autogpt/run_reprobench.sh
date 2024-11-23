index=$1

# Create a directory for the environment based on the index
mkdir ./environment/$index

# Run the Python script to generate the task, writing the output into task.txt
python3 task_gen.py --index $index

# Read the content of the task.txt file into the task_prompt variable
task_prompt=$(cat ./environment/$index/task.txt)

# Print the task prompt to the terminal
echo "Task prompt: $task_prompt"

# . autogpt.sh run --ai-task "$task_prompt" --ai-name $cap_subdir --skip-reprompt --continuous --log-level DEBUG --vlm "gpt-4o-2024-05-13" --fast_llm "gpt-4o-2024-05-13" --smart_llm "gpt-4o-2024-05-13" --openai_cost_budget 4
. autogpt.sh run --ai-task "$task_prompt" --paper-id "$index" --skip-reprompt --continuous --log-level DEBUG --fast_llm "gpt-4o-2024-05-13" --smart_llm "gpt-4o-2024-05-13" --openai_cost_budget 4 2>&1 | tee ./environment/$index/output.txt

if [ -f "data/agents/$index/workspace/reproducibility_score.json" ]; then
    cp "data/agents/$index/workspace/reproducibility_score.json" "./environment/$index/"
fi
python3 evaluation.py --index $index

rm -r data/agents/$index/
