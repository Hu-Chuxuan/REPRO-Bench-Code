#!/bin/bash

for index in {91..100}  # Range from 1 to 100
do
    # Run the reproduce_autogpt.sh script with the current index
    ./run_reprobench.sh $index

    # Optionally, you can print the index for tracking
    echo "Ran ./run_reprobench.sh with index: $index"
done