import multiprocessing
import os.path
import sys

import numpy as np
from matplotlib import pyplot as plt
import pandas as pd


def main(experiment_path, params_in, params_out, sample_function, minimizeObj=None):
    solutions_csv_path = os.path.join(experiment_path, "filtered_solutions.csv")

    solutions_df = pd.read_csv(solutions_csv_path)
    real_solutions = {}

    def add_real_tag(key_in):
        return f"{key_in}_real"

    # initialize empty arrays
    for k in params_out:
        real_solutions[add_real_tag(k)] = []

    # sample from simulator
    # todo: parallelize simulation calls. Code below is not working properly
    # num_workers = multiprocessing.cpu_count() - 1
    # with multiprocessing.Pool(num_workers) as pool:
    #     inputs = [solution[params_in] for _, solution in enumerate(solutions_df.iloc)]
    #     # get results
    #     results = pool.map(sample_function, inputs)
    #     # append solutions results
    #     for solution in results:
    #         for k in params_out:
    #             real_solutions[add_real_tag(k)].append(solution)

    for i, solution in enumerate(solutions_df.iloc):
        real_out = sample_function(solution[params_in])
        for k in params_out:
            real_solutions[add_real_tag(k)].append(real_out[k])

    # append columns to original df
    for k in params_out:
        solutions_df[add_real_tag(k)] = real_solutions[add_real_tag(k)]

    # sort columns by name such that each <X>_real column is next to its corresponding <X> column
    solutions_df = solutions_df.reindex(sorted(solutions_df.columns), axis=1)

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

    MSE_mean = np.mean(MSE)

    # compute pareto optimality ratio
    all_solutions_path = os.path.join(experiment_path, "all_solutions.csv")
    num_composites = len(pd.read_csv(all_solutions_path))
    num_filtered = len(solutions_df)

    # save sim df
    sim_solutions_path = os.path.join(experiment_path, "sim_solutions.csv")
    solutions_df.to_csv(
        sim_solutions_path,
        # index_label=False
    )

    # find pareto from simulation solutions
    pareto_solutions = getParetoSolutionsDf(
        all_solutions_path=sim_solutions_path,
        objectives=[add_real_tag(s) for s in params_out],
        minimizeObj=minimizeObj
    )
    num_pareto = len(pareto_solutions)

    pareto_solutions.to_csv(
        os.path.join(experiment_path, "pareto_solutions.csv"),
        # index_label=False
    )

    # save metrics to a log
    with open(os.path.join(experiment_path, "log.out"), 'w') as f:
        def write_property(key, value):
            f.write(f"{key}={value}\n")
        write_property("path", experiment_path)
        write_property("MSE", MSE_mean)
        write_property("num_composites", num_composites)
        write_property("num_filtered", num_filtered)
        write_property("num_pareto", num_pareto)
        write_property("pareto_ratio", num_pareto / num_composites)
        write_property("pareto_ratio_filtered", num_pareto / num_filtered)

    # plt.legend()
    plt.subplots_adjust(right=0.5)
    plt.legend(bbox_to_anchor=(1.2, 0.9), ncol=1)
    plt.title(f"{solutions_csv_path}\nMSE={MSE_mean}")
    plt.savefig(os.path.join(experiment_path, "pareto.png"))
    plt.show()


def getParetoSolutionsDf(all_solutions_path, objectives, minimizeObj=None):
    pdFile = pd.read_csv(all_solutions_path)
    res = pd.DataFrame()

    if minimizeObj is None:
        # by default, minimize all objectives
        minimizeObj = {}
        for obj in objectives:
            minimizeObj[obj] = True

    def dominates(row1, row2):
        # returns true if row2 is dominated by row1
        for objective in objectives:
            if minimizeObj[objective] and row2[objective] < row1[objective]:
                return False
            if (not minimizeObj[objective]) and row2[objective] > row1[objective]:
                return False
        return True

    for i, row2 in pdFile.iterrows():
        hasDominatingPoint = False
        for ii, row1 in res.iterrows():
            if dominates(row1, row2):
                hasDominatingPoint = True
            if dominates(row2, row1):
                # drop row1 if it is dominated
                res.drop(ii, inplace=True)
                hasDominatingPoint = False
        if not hasDominatingPoint:
            # see: https://stackoverflow.com/questions/70837397/good-alternative-to-pandas-append-method-now-that-it-is-being-deprecated
            res = pd.concat([res, pd.DataFrame.from_records([row2])])

    return res

