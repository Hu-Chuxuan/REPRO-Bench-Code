import argparse
import os
import json
import csv

def evaluate(index):
    directory = f"./environment/{index}"
    reproduce_score_path = directory + "/reproducibility_score.json"
    if os.path.exists(reproduce_score_path):
        # Open the file if it exists
        try:
            with open(reproduce_score_path, 'r') as file:
                data1 = json.load(file)  # Assuming it's a JSON file
            ground_truth_path = f"../ground_truth.json"
            with open(ground_truth_path, 'r') as file:
                data = json.load(file)  
            ground_truth = data[str(index)]
            try:
                result = 1 if int(data1["reproducibility_score"]) == int(ground_truth) else 0
            except:
                result = 0
        except:
            result = 0
    else:
        result = 0

    cost_path = directory + "/costs.json"
    if os.path.exists(cost_path):
        try:
            with open(cost_path, 'r') as file:
                cost_data = json.load(file)
            cost = cost_data[-1] if cost_data else 0
        except:
            cost = 0
    else:
        cost = 0  # Default cost if cost.json doesn't exist

    time_path = directory + "/times.json"
    if os.path.exists(time_path):
        try:
            with open(time_path, 'r') as file:
                time_data = json.load(file)
            time = sum(time_data) if time_data else 0
        except:
            time = 0
    else:
        time = 0  # Default cost if cost.json doesn't exist

    # Append the index, result, and cost to the CSV file
    csv_file_path = "./environment/results.csv"

    with open(csv_file_path, mode='a', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow([index, result, cost, time])
    
    print(f"Appended: index={index}, result={result}, cost={cost}, time={time}")
    return

if __name__ == "__main__":

    # Setup argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('--index', type=int, required=True)

    args = parser.parse_args()

    # Run the main function with parsed arguments
    evaluate(index=args.index)