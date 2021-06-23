import sys
sys.path.append("../..")
from CreateDznFiles import *
import pandas as pd
from matplotlib import pyplot as plt


### (1) define parameters ###

static_params = {
    "timespan": 1,
    "initial_fruit_bushes": [40],
    "initial_foragers": [40],
    "ticks_to_flee": [100],
    "bush_growth_chance": [10],
    "rate_of_mutation": [5.0]
}

dynamic_params = {
    "mean_strength_th": [0.0, 1.0],
    "mean_strength_w": [1, 100],
    "mean_speed_th": [0.0, 1.0],
    "mean_speed_w": [1, 100],
    "mean_intelligence_th": [0.0, 1.0],
    "mean_intelligence_w": [1, 100],
    "murder_rate_th": [0.0, 1.0],
    "murder_rate_w": [1, 100],
    "age_death_rate_th": [0.0, 1.0],
    "age_death_rate_w": [1, 100],
    "starvation_rate_th": [0.0, 1.0],
    "starvation_rate_w": [1, 100],
    "mean_reactive_aggression_th": [0.0, 1.0],
    "mean_reactive_aggression_w": [1, 100],
    "mean_proactive_aggression_th": [0.0, 1.0],
    "mean_proactive_aggression_w": [1, 100],
    "average_population_th": [1, 1000],
    "average_population_w": [1, 300],
}


### (2) create DZN files ###

dzncount = 50
repetitions = 8
simulationTicks = 10000

folder_out = createDznFiles(static_params, dynamic_params, count=dzncount, tag="fruitWars")

print(folder_out)

### (3) solve DZN files and find pareto front ###

# set objectives to minimize agressive behavior
minimizeObj = {
    "mean_strength": True,
    "mean_speed": True,
    "mean_intelligence": False,
    "murder_rate": True,
    "age_death_rate": False,
    "starvation_rate": False,
    "mean_reactive_aggression": False,
    "mean_proactive_aggression": True,
    "average_population": False,
}

observables = ["mean_strength", "mean_speed", "mean_intelligence", "murder_rate", "age_death_rate", "starvation_rate", "mean_reactive_aggression", "mean_proactive_aggression"]
observables_pop = ["average_population"]
observables_with_dash = ["mean_strength", "mean_speed", "mean_intelligence", "murder-rate", "age-death-rate", "starvation-rate", "mean_reactive_aggression", "mean_proactive_aggression"]
observables_with_dash_pop = ["average-population"]
solutionsFile = solveAndFindPareto(
    model_path="mzn_soft/fruit_wars.mzn",
    dzn_folder=folder_out,
    csv_header="collaboration_bonus,max_age,mean_strength,mean_speed,mean_intelligence,murder_rate,age_death_rate,starvation_rate,mean_reactive_aggression,mean_proactive_aggression,average_population\n",
    objectives=observables + observables_pop,
    minimizeObj=minimizeObj
)

### (4) compare results with simulation and plot ###
pdFile = pd.read_csv(solutionsFile)

netlogo_model_path = "Fruit Wars.nlogo"

params_static = {}

params_dynamic = []
expected_outcomes = []

for rowindex, row in pdFile.iterrows():
    observablesToAppend = {
        "mean_strength": row["mean_strength"],
        "mean_speed": row["mean_speed"],
        "mean_intelligence": row["mean_intelligence"],
        "murder-rate": row["murder_rate"],
        "age-death-rate": row["age_death_rate"],
        "starvation-rate": row["starvation_rate"],
        "mean_reactive_aggression": row["mean_reactive_aggression"],
        "mean_proactive_aggression": row["mean_proactive_aggression"],
        "average-population": row["average_population"]
    }
    expected_outcomes.append(observablesToAppend)

    solution = {
        "collaboration-bonus": float(row["collaboration_bonus"]),
        "max-age": int(row["max_age"])
    }

    params_dynamic.append(solution)
    print("\nsolution {}: {}".format(rowindex + 1, solution))
    print("\nexpectation {}: {}".format(rowindex+1, observablesToAppend))

realOut_all, MSE_arr_all = evalParamsOnSimulationMulti(
    netlogo_model_path,
    params_static,
    params_dynamic,
    expected_outcomes,
    simulationTicks=simulationTicks,
    maxSims=None,
    repetitions=repetitions
)

colors = ['b', 'r', 'y', 'k', 'm', 'g', 'c', 'gray']

i = 0

# plot for each observables


def plot_observables(observables, observables_with_dash):
    plt.figure(figsize=(14, 7))

    for i in range(len(observables)):
        # X ~ real value
        Y1 = list(map(lambda x: x[observables_with_dash[i]], realOut_all))
        Y2 = list(map(lambda x: x[observables_with_dash[i]], expected_outcomes))[:len(Y1)]
        # X ~ error wrt NN
        X = []
        for ii in range(len(Y1)):
            X.append(np.square(np.subtract(Y1[ii], Y2[ii])))

        X = list(range(1, len(Y1)+1))
        plt.scatter(X, Y1, color=colors[i], label="{} SIM".format(observables[i]))
        plt.scatter(X, Y2, color=colors[i], marker='+', label="{} CP".format(observables[i]))
        i += 1


    layers = 4
    tag = "{} layered Sigmoid".format(layers)
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

plot_observables(observables, observables_with_dash)
plot_observables(observables_pop, observables_with_dash_pop)
