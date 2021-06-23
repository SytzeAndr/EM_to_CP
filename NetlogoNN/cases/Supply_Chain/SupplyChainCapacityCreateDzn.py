import sys
sys.path.append("../..")
from CreateDznFiles import *
import pandas as pd
from matplotlib import pyplot as plt


### (1) define parameters ###

static_params = {
    "timespan": 1,
    "Clients_N": [500],
    "Demand_W": [20],
    "Lt0": [4],
    "Lt1": [4],
    "SS_": [0.85],
    "DS_D": [6],
    "K": [200],
    "MA": [500],
    "HC": [0.05]
}

dynamic_params = {
    "lost_ratio_sales_ret_th": [0.0, 0.001],
    "lost_ratio_sales_ret_w": [1, 100],
    "lost_ratio_sales_dis_th": [0.0, 0.001],
    "lost_ratio_sales_dis_w": [1, 100],
    "lost_ratio_sales_fac_th": [0.0, 0.001],
    "lost_ratio_sales_fac_w": [1, 100],
    "stock_customer_MA_mean_relative_th": [0.0, 1.0],
    "stock_customer_MA_mean_relative_w": [1, 100],
    "stock_distributor_MA_mean_relative_th": [0.0, 1.0],
    "stock_distributor_MA_mean_relative_w": [1, 100],
    "stock_retailer_MA_mean_relative_th": [0.0, 1.0],
    "stock_retailer_MA_mean_relative_w": [1, 100],
    "stock_factory_MA_mean_relative_th": [0.0, 1.0],
    "stock_factory_MA_mean_relative_w": [1, 100],
}


### (2) create DZN files ###

dzncount = 20
repetitions = 2
simulationTicks = 3000

folder_out = createDznFiles(static_params, dynamic_params, count=dzncount, tag="Supply_Chain")

print(folder_out)

### (3) solve DZN files and find pareto front ###

# set objectives to minimize agressive behavior
minimizeObj = {
    "lost_ratio_sales_ret": True,
    "lost_ratio_sales_dis": True,
    "lost_ratio_sales_fac": True,
    "stock_customer_MA_mean_relative": False,
    "stock_distributor_MA_mean_relative": False,
    "stock_retailer_MA_mean_relative": False,
    "stock_factory_MA_mean_relative": True,
}

observables = [
    "lost_ratio_sales_ret", "lost_ratio_sales_dis", "lost_ratio_sales_fac",
    "stock_customer_MA_mean_relative", "stock_distributor_MA_mean_relative",
    "stock_retailer_MA_mean_relative", "stock_factory_MA_mean_relative"]

solutionsFile = solveAndFindPareto(
    model_path="mzn_soft_capacity/supply_chain.mzn",
    dzn_folder=folder_out,
    csv_header="Fact,Distr1,Distr2,"
               "v1_DailyPurchase,v2_PeriodicallyPurchase,v3_Random,"
               "v1_s_Q,v2_s_S,v3_R_S,v4_Random,"
               "lost_ratio_sales_ret,lost_ratio_sales_dis,lost_ratio_sales_fac,"
               "stock_customer_MA_mean_relative,stock_distributor_MA_mean_relative,"
               "stock_retailer_MA_mean_relative,stock_factory_MA_mean_relative\n",
    objectives=observables,
    minimizeObj=minimizeObj
)

### (4) compare results with simulation and plot ###
pdFile = pd.read_csv(solutionsFile)

netlogo_model_path = "Supply_Chain.nlogo"

params_static_sim = {}

for key in static_params.keys():
    if key == "SS_":
        params_static_sim["SS_%"] = static_params[key][0]
    elif key != "timespan":
        params_static_sim[key] = static_params[key][0]

params_dynamic = []
expected_outcomes = []

for rowindex, row in pdFile.iterrows():
    observablesToAppend = {}
    for observable in observables:
        observablesToAppend[observable] = row[observable]
    expected_outcomes.append(observablesToAppend)

    solution = {
        "Fact": int(row["Fact"]),
        "Distr1": int(row["Distr1"]),
        "Distr2": int(row["Distr2"]),
        "Customers_Strategy": "\"{}\"".format(
            "1-DailyPurchase" if row["v1_DailyPurchase"] == "1"
            else ("2-PeriodicallyPurchase" if row["v2_PeriodicallyPurchase"] == "1"
                  else "3-Random")),
        "Inventory_Policy": "\"{}\"".format(
            "1-(s,Q)" if row["v1_s_Q"] == "1"
            else ("2-(s,S)" if row["v2_s_S"] == "1"
                  else ("3-(R,S)" if row["v3_R_S"] == "1" else "4-Random")))
    }

    params_dynamic.append(solution)
    print("\nsolution {}: {}".format(rowindex + 1, solution))
    print("\nexpectation {}: {}".format(rowindex+1, observablesToAppend))

# run simulation
realOut_all, MSE_arr_all = evalParamsOnSimulationMulti(
    netlogo_model_path,
    params_static_sim,
    params_dynamic,
    expected_outcomes,
    simulationTicks=simulationTicks,
    maxSims=None,
    repetitions=repetitions
)

colors = ['b', 'r', 'y', 'k', 'm', 'g', 'c', 'gray']


def plotObservables(observables, tag):
    # plot CP vs simulation values
    plt.figure(figsize=(10, 5))

    for i in range(len(observables)):
        # X ~ real value
        Y1 = list(map(lambda x: x[observables[i]], realOut_all))
        Y2 = list(map(lambda x: x[observables[i]], expected_outcomes))[:len(Y1)]
        # X ~ error wrt NN
        X = []
        for ii in range(len(Y1)):
            X.append(np.square(np.subtract(Y1[ii], Y2[ii])))

        X = list(range(1, len(Y1)+1))
        plt.scatter(X, Y1, color=colors[i], label="{} SIM".format(observables[i]))
        plt.scatter(X, Y2, color=colors[i], marker='+', label="{} CP".format(observables[i]))

    # layers = 4
    tag = "{} supply chain capacity".format(tag)
    plt.title("pareto front, simulation vs CP, {}\n{}".format(tag, folder_out))
    plt.ylabel("value (SIM or CP)")
    # plt.xlabel("MSE")
    plt.xlabel("solution index")
    plt.grid()
    # plt.legend()
    plt.legend(bbox_to_anchor=(1.2, 0.9), ncol=1)
    # plt.legend()
    plt.subplots_adjust(right=0.5)
    plt.show()
    plt.savefig("plots/{}.png".format(tag))

observablesLost = [
    "lost_ratio_sales_ret", "lost_ratio_sales_dis", "lost_ratio_sales_fac"]

observablesStock = [
    "stock_customer_MA_mean_relative", "stock_distributor_MA_mean_relative",
    "stock_retailer_MA_mean_relative", "stock_factory_MA_mean_relative"]

plotObservables(observablesLost, "lost_rates")
plotObservables(observablesStock, "stock_relative")
