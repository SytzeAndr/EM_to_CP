import json
import os
import sys
import pandas as pd
import matplotlib.pyplot as plt
import multiprocessing

sys.path.append("../..")
from WeightSampler import sample_montgomery_sequence

# from EM_to_CP.NetlogoNN.WeightSampler import sample_montgomery_sequence


def dict_to_dzn_string(dict_in):
    result = ""

    for key, value in dict_in.items():
        result += f"{key} = [{','.join([str(v) for v in value])}]\n"

    return result


def create_dzn(num_objectives, num_composites, path):
    # sample weights
    weights = sample_montgomery_sequence(d=num_objectives, n=num_composites)
    for i, w in enumerate(weights):
        dzn_dict = {'weights': w}
        dzn_string = dict_to_dzn_string(dzn_dict)
        with open(os.path.join(path, f"{i}.dzn"), 'w') as file:
            file.write(dzn_string)


# def create_restaurant_dzn(num_composites, dzn_folder):
#     create_dzn(num_objectives=2, num_composites=num_composites, path=dzn_folder)


def solve_dzn(problem_mzn, weights_dzn, csv_out, total_dzn_count):
    # run and write to tempfile
    tempfile = f"{weights_dzn}_temp"
    command = f"minizinc {problem_mzn} {weights_dzn} --solver jacop -o {tempfile}"
    os.system(command)

    # read tempfile and write to csv
    with open(tempfile) as f:
        row_read = f.readline()
        dict_read = json.loads(row_read)
        row_to_write = ",".join([str(value) for _, value in dict_read.items()]) + "\n"
        with open(csv_out, 'a') as f:
            f.write(row_to_write)
    os.remove(tempfile)
    with open(csv_out, 'r') as f:
        solved_i = len(f.readlines()) - 1
        print(f"solving... {solved_i} / {total_dzn_count}", end="\r")


def filter_solutions(df_in):
    df_out = df_in.drop_duplicates()
    return df_out


def plot_solutions(all_solutions, filtered_solutions):
    # scatterplot dataframe
    filtered_solutions.plot(kind='scatter', x='spoil_ratio', y='success_ratio')
    plt.title(f"n={len(all_solutions)}, unique={len(filtered_solutions)}")
    figure_out = "out.png"
    plt.savefig(figure_out)
    print(f"plot saved to {figure_out}")


def main(num_composites, experiment_path, mzn_path, params_in, objectives):
    if not os.path.isdir(experiment_path):
        os.makedirs(experiment_path)

    dzn_path = os.path.join(experiment_path, "dzn")
    if not os.path.isdir(dzn_path):
        os.makedirs(dzn_path)

    # create dzn files
    create_dzn(
        num_objectives=len(objectives),
        num_composites=num_composites,
        path=dzn_path
    )

    # create csv output
    csv_out = os.path.join(experiment_path, "all_solutions.csv")
    with open(csv_out, 'w') as file:
        header = ",".join(params_in + objectives) + "\n"
        file.write(header)

    # solve each file
    dzn_files = [f for f in os.listdir(dzn_path) if f.endswith('.dzn')]

    processes = []

    for i, weights_dzn in enumerate(dzn_files):
        p = multiprocessing.Process(
            target=solve_dzn,
            args=(
                mzn_path,
                os.path.join(dzn_path, weights_dzn),
                csv_out,
                len(dzn_files)
            )
        )
        processes.append(p)
        p.start()

    for p in processes:
        p.join()

    # visualize
    all_solutions = pd.read_csv(csv_out)
    filtered_solutions = filter_solutions(all_solutions)
    filtered_solutions.to_csv(os.path.join(experiment_path, "filtered_solutions.csv"))


if __name__ == "__main__":
    main(
        num_composites=30,
        experiment_path="cases/Restaurant/dzn_solutions/test2",
        mzn_path="cases/Restaurant/mzn_wgt/restaurant.mzn",
        params_in=["buy1", "buy2"],
        objectives=["success_ratio","spoil_ratio"]
    )

