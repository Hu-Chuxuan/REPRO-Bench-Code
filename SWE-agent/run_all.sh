#!/bin/bash
mkdir ./environment
for index in {1..112}
do
    ./run_reprobench.sh $index
    echo "Ran ./run_reprobench.sh with index: $index"
done