import sys
sys.path.append("../..")
from CreateDznFiles import *
import pandas as pd
from matplotlib import pyplot as plt
import restaurant_sim as rs
import restaurant_generate_simdata as rgs
import numpy as np


### (1) define parameters ###

static_params = {}

dynamic_params = {
    "spoil_ratio_th": [0.0, 1.0],
    "succes_ratio_th": [0.0, 1.0],
    "spoil_ratio_w": [1, 100],
    "succes_ratio_w": [1, 100]
}

### (2) create DZN files ###

dzncount = 300
repetitions = 50
simulationTicks = 200

folder_out = createDznFiles(static_params, dynamic_params, count=dzncount, tag="restaurant")

print(folder_out)

### (3) solve DZN files and find pareto front ###

# set objectives to minimize agressive behavior
minimizeObj = {
    "spoil_ratio": True,
    "succes_ratio": False
}

solutionsFile = solveAndFindPareto(
    model_path="mzn_soft/restaurant.mzn",
    dzn_folder=folder_out,
    csv_header="buy1,buy2,spoil_ratio,succes_ratio\n",
    objectives=["spoil_ratio", "succes_ratio"],
    minimizeObj=minimizeObj
)

### (4) compare results with simulation and plot ###
pdFile = pd.read_csv(solutionsFile)

proposed_actions = []
expected_outcomes = []

for rowindex, row in pdFile.iterrows():
    proposed_action = {
        "buy1": int(row["buy1"]),
        "buy2": int(row["buy2"])
    }

    expected_outcome = {
        "spoil_ratio": float(row["spoil_ratio"]),
        "succes_ratio": float(row["succes_ratio"])
    }

    proposed_actions.append(proposed_action)
    expected_outcomes.append(expected_outcome)

    print("\nproposed_action {}: {}".format(rowindex + 1, proposed_action))
    print("\nexpected_outcome {}: {}".format(rowindex + 1, expected_outcome))


def get_real_outcome(parameters_in):
    buying_strategy = [parameters_in["buy1"], parameters_in["buy2"]]
    spoil_ratios = []
    succes_ratios = []
    for _ in range(repetitions):
        succes_ratio, spoil_ratio = rgs.run_single_def(buying_strategy)
        spoil_ratios.append(spoil_ratio)
        succes_ratios.append(succes_ratio)
    return {
        "spoil_ratio": np.mean(spoil_ratios),
        "succes_ratio": np.mean(succes_ratios)
    }


simulation_outcomes = [get_real_outcome(x) for x in proposed_actions]
colors = ['b', 'r', 'y', 'k', 'm', 'g', 'c', 'gray']

i = 0
# plot for each observables

observables = list(minimizeObj.keys())
layers = 1
tag = "{} layered Sigmoid".format(layers)

def plot_observables(observables):
    plt.figure(figsize=(14, 7))

    for i in range(len(observables)):
        # X ~ real value
        Y1 = list(map(lambda x: x[observables[i]], simulation_outcomes))
        Y2 = list(map(lambda x: x[observables[i]], expected_outcomes))[:len(Y1)]

        X = list(range(1, len(Y1)+1))
        plt.scatter(X, Y1, color=colors[i], label="{} SIM".format(observables[i]))
        plt.scatter(X, Y2, color=colors[i], marker='+', label="{} CP".format(observables[i]))
        i += 1

    plt.title("pareto front, simulation vs CP, {}\n{}".format(tag, folder_out))
    plt.ylabel("value (SIM or CP)")
    # plt.xlabel("MSE")
    plt.xlabel("solution index")
    plt.grid()
    # plt.legend()
    plt.legend(bbox_to_anchor=(1.2, 0.9), ncol=1)
    # plt.legend()
    plt.subplots_adjust(right=0.5)
    plt.savefig("plots/{}.png".format(tag))
    plt.show()


def plot_pareto():
    X = [e["buy1"] for e in proposed_actions]
    Y = [e["buy2"] for e in proposed_actions]
    for i in range(len(X)):
        plt.scatter(X, Y)
    plt.title("restaurant approximated pareto front, {}\n {}".format(tag, folder_out))
    plt.xlabel("buy1")
    plt.ylabel("buy2")
    plt.grid()
    plt.savefig("plots/{}_pareto.png".format(tag))
    plt.show()


plot_observables(observables)
plot_pareto()
