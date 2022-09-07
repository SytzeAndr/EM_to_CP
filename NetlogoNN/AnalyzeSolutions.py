import os.path
import sys

import numpy as np
from matplotlib import pyplot as plt
import pandas as pd


def main(experiment_path, params_in, params_out, sample_function):
    solutions_csv_path = os.path.join(experiment_path, "filtered_solutions.csv")

    solutions_df = pd.read_csv(solutions_csv_path)
    real_solutions = {}

    def add_real_tag(key_in):
        return f"{key_in}_real"

    # initialize empty arrays
    for k in params_out:
        real_solutions[add_real_tag(k)] = []

    # sample from simulator
    for i, solution in enumerate(solutions_df.iloc):
        real_out = sample_function(solution[params_in])
        for k in params_out:
            real_solutions[add_real_tag(k)].append(real_out[k])

    # append columns to original df
    for k in params_out:
        solutions_df[add_real_tag(k)] = real_solutions[add_real_tag(k)]

    # sort by objective values
    solutions_df.sort_values(by=params_out, inplace=True)

    # plot real vs CP
    colors = ['b', 'r', 'y', 'k', 'm', 'g', 'c', 'gray']
    MSE = []
    for i, k in enumerate(params_out):
        Y1 = solutions_df[k]
        Y2 = solutions_df[add_real_tag(k)]

        MSE.append(np.square(np.subtract(Y1, Y2)))

        X = list(range(1, len(Y1)+1))
        plt.scatter(X, Y1, color=colors[i], marker='o', label=f"{params_out[i]} CP")
        plt.scatter(X, Y2, color=colors[i], marker='+', label=f"{params_out[i]} SIM")

    MSE_mean = np.round(np.mean(MSE), 4)

    # save df and plot
    solutions_df.to_csv(os.path.join(experiment_path, "sim_solutions.csv"))
    # plt.legend()
    plt.subplots_adjust(right=0.5)
    plt.legend(bbox_to_anchor=(1.2, 0.9), ncol=1)
    plt.title(f"{solutions_csv_path}\nMSE={MSE_mean}")
    plt.savefig(os.path.join(experiment_path, "pareto.png"))
    plt.show()


# if __name__ == "__main__":
#     main(
#         experiment_path="cases/Restaurant/dzn_solutions/test1",
#         params_in = ["buy1","buy2"],
#         params_out = ["success_ratio","spoil_ratio"],
#         sample_function=sample_restaurant
#     )


