#!/bin/bash
for index in {1..112}
do
    ./reproduce_reprobench.sh $index
    echo "Ran ./reproduce_reprobench.sh with index: $index"
done
