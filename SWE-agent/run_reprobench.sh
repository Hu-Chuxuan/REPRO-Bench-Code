#!/bin/bash

index=$1
commands_dir=$(realpath config/commands)

mkdir ./environment/$index
mkdir ./environment/$index/work_dir
cp ../REPRO-Bench/$index/paper.pdf ./environment/$index/work_dir/
cp -rf ../REPRO-Bench/$index/replication_package ./environment/$index/work_dir/

echo "Running agent..."
python3 run_reprobench.py --index $index --commands_dir $commands_dir 2>&1 | tee ./environment/$index/output.txt

if [ -f "./environment/$index/work_dir/reproducibility_score.json" ]; then
    cp "./environment/$index/work_dir/reproducibility_score.json" "./environment/$index/"
fi
python3 evaluation.py --index $index

rm -r ./environment/$index/work_dir/
echo "Script completed!"