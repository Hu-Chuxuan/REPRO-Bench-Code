import argparse

def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def text_gen(index):
    directory = f"../../../REPRO-Bench/{index}"
    should_reproduce_path = directory + "/should_reproduce.txt"
    with open(should_reproduce_path, 'r') as file:
        reproduction_list = [line.strip() for line in file.readlines() if len(line.strip()) > 0]
    print(reproduction_list)
    
    with open('./environment/task_template.txt', 'r') as file:
        task_template = file.read()
    
    task_text = task_template.format(figures=[item for item in reproduction_list if item.startswith('Figure')], 
                                     tables=[item for item in reproduction_list if item.startswith('Table')],
                                     claims=[item for item in reproduction_list if item.startswith('Claim')]
                                     )
    with open(f"./environment/{index}/task.txt", 'w') as file:
        file.write(task_text)
    return

if __name__ == "__main__":

    # Setup argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('--index', type=int, required=True)

    args = parser.parse_args()

    # Run the main function with parsed arguments
    text_gen(index=args.index)