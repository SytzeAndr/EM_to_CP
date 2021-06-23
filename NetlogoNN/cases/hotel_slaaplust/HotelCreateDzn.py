import sys
sys.path.append("../..")
from CreateDznFiles import *
import pandas as pd
from matplotlib import pyplot as plt


### (1) define parameters ###

duration_def = 10

static_params = {
    "timespan": 1,
    "t1_dur_raw": [duration_def],
    "t2_dur_raw": [duration_def],
    "t3_dur_raw": [duration_def],
    "t4_dur_raw": [duration_def],
    "t5_dur_raw": [duration_def],
    "t6_dur_raw": [duration_def],
    "t1_max_relative_change": 0.5,
    "t2_max_relative_change": 0.5,
    "t3_max_relative_change": 0.5,
    "t1_w": 0.5,
    "t2_w": 0.5,
    "t3_w": 0.5,
    "p_incoming_t1": [0.6],
    "p_incoming_t3": [0.4],
    "p_showup": [0.9],
    "spread_factor": [0.8],
    "receptionists_amount": [45],
    "satisfied_max_quetime": [10],
    "checkin_max_quetime": [15],
    "reservation_max_quetime": [15],
    "noshow_max_time": [100],
    "time_between_t1_and_t3": [500],
    "stay_duration": [100],
    "spread_horizon": [2000]
}

dynamic_params = {
    "low_t1_loss_th": [0.0, 0.5],
    "low_t1_loss_w": [1, 100],
    "low_t2_loss_th": [0.0, 0.5],
    "low_t2_loss_w": [1, 100],
    "low_t3_loss_th": [0.0, 0.5],
    "low_t3_loss_w": [1, 100],
    "low_unsatisfied_th": [0.0, 0.5],
    "low_unsatisfied_w": [1, 100],
}

### (2) create DZN files ###

layers = 4
dzncount = 10
repetitions = 10

folder_out = createDznFiles(static_params, dynamic_params, count=dzncount, tag="hotel")
# folder_out = "dzn_solutions/hotel210506-143613/"
# folder_out = "dzn_solutions/hotelMany_1/"

print(folder_out)

### (3) solve DZN files and find pareto front ###
observables = ["t1_loss", "t2_loss", "t3_loss", "unsatisfied_rate"]


solutionsFile = solveAndFindPareto(model_path="mzn_soft_durations/hotel_soft_durations.mzn",
               dzn_folder=folder_out,
               csv_header="low_t1_loss_th,low_t1_loss_w,low_t2_loss_th,low_t2_loss_w,"
                    "low_t3_loss_th,low_t3_loss_w,low_unsatisfied_th,low_unsatisfied_w,"
                    "t1_change_a,t2_change_a,t3_change_a,t1_loss,t2_loss,t3_loss,unsatisfied_rate\n",
                objectives=observables)


### (4) compare results with simulation and plot ###

pdFile = pd.read_csv(solutionsFile)

netlogo_model_path = "Hotel_slaaplust.nlogo"

params_static = {
    "p_incoming_t1": static_params["p_incoming_t1"][0],
    "p_incoming_t3": static_params["p_incoming_t3"][0],
    "p_showup": static_params["p_showup"][0],
    "spread_factor": static_params["spread_factor"][0],
    "receptionists_amount": static_params["receptionists_amount"][0],
    "satisfied_max_quetime":  static_params["satisfied_max_quetime"][0],
    "checkin_max_quetime": static_params["checkin_max_quetime"][0],
    "reservation_max_quetime": static_params["reservation_max_quetime"][0],
    "noshow_max_time": static_params["noshow_max_time"][0],
    "time_between_t1_and_t3": static_params["time_between_t1_and_t3"][0],
    "stay_duration": static_params["stay_duration"][0],
    "spread_horizon": static_params["spread_horizon"][0]
}

params_dynamic = []
expected_outcomes = []

t1_losses = pdFile["t1_loss"]


for rowindex, row in pdFile.iterrows():
    observablesToAppend = {}
    for field in observables:
        observablesToAppend[field] = row[field]
    expected_outcomes.append(observablesToAppend)

    t1_w = static_params["t1_w"]
    t2_w = static_params["t2_w"]
    t3_w = static_params["t3_w"]
    t1_change_a = float(row["t1_change_a"])
    t2_change_a = float(row["t2_change_a"])
    t3_change_a = float(row["t3_change_a"])

    t1_increased = int(t1_change_a > 0)
    t1_change_b = -1 * t1_change_a * (t1_w * t1_increased + (1 / t1_w) * (1 - t1_increased))

    t2_increased = int(t2_change_a > 0)
    t2_change_b = -1 * t2_change_a * (t2_w * t2_increased + (1 / t2_w) * (1 - t2_increased))

    t3_increased = int(t3_change_a > 0)
    t3_change_b = -1 * t3_change_a * (t3_w * t3_increased + (1 / t3_w) * (1 - t3_increased))

    durations = {
        "t1_duration": duration_def + t1_change_a + t2_change_a,
        "t2_duration": duration_def,
        "t3_duration": duration_def + t1_change_b + t3_change_a,
        "t4_duration": duration_def + t3_change_b,
        "t5_duration": duration_def,
        "t6_duration": duration_def + t2_change_b,
    }

    params_dynamic.append(durations)
    print("\nsolution {}: {}".format(rowindex+1, durations))
    print("\nexpectation {}: {}".format(rowindex+1, observablesToAppend))
realOut_all, MSE_arr_all = evalParamsOnSimulationMulti(
    netlogo_model_path,
    params_static,
    params_dynamic,
    expected_outcomes,
    simulationTicks=20000,
    maxSims=None,
    repetitions=repetitions)

# plot for each observable

colors = ['b', 'r', 'y', 'k']
i = 0

for observable in observables:
    # X ~ real value
    Y1 = list(map(lambda x: x[observable], realOut_all))
    Y2 = list(map(lambda x: x[observable], expected_outcomes))[:len(Y1)]
    # X ~ error wrt NN
    X = []
    for ii in range(len(Y1)):
        X.append(np.square(np.subtract(Y1[ii], Y2[ii])))

    X = list(range(1, len(Y1)+1))
    plt.scatter(X, Y1, color=colors[i], label="{} SIM".format(observable))
    plt.scatter(X, Y2, color=colors[i], marker='+', label="{} CP".format(observable))
    i += 1


tag = "{} layered Sigmoid".format(layers)
plt.title("pareto front, simulation vs CP, {}\n{}".format(tag, folder_out))
plt.ylabel("value (SIM or CP)")
# plt.xlabel("MSE")
plt.xlabel("solution index")
# plt.grid()
plt.legend()

plt.legend(bbox_to_anchor=(1.0, -0.15), ncol=3)
plt.subplots_adjust(bottom=0.3)
plt.savefig("plots/{}.png".format(tag))
plt.show()
