import os
import random
import pyNetLogo
import numpy as np
from datetime import datetime
import pandas as pd
from WeightSampler import sample_montgomery_sequence


def createDznFiles(static_params, dynamic_params, count, tag, folder_out=None):
    timestampStr = datetime.now().strftime("%y%m%d-%H%M%S")

    if folder_out is None:
        folder_out = "dzn_solutions/" + tag + timestampStr + "/"

    folder_out_sols = folder_out + "dzn/"

    if not os.path.exists(folder_out_sols):
        os.makedirs(folder_out_sols)

    weight_sequence = sample_montgomery_sequence(d=len(dynamic_params.items()), n=count)

    for i in range(count):
        fileout = folder_out_sols + tag + "_" + str(i) + ".dzn"
        with open(fileout, "w") as file:
            file.write("%%% static parameters %%%\n")
            for key, value in static_params.items():
                file.write("{} = {};\n".format(key, str(value)))
            file.write("%%% dynamic parameters %%%\n")
            for key, value in dynamic_params.items():
                lb = value[0]
                ub = value[1]
                isint = type(value[0]) == int

                file.write("{} = {};\n".format(key,
                                               str(random.randint(value[0], value[1])) if type(value[0]) == int
                                               else str(random.uniform(value[0], value[1]))
                                               ))
    return folder_out


def solveDznFolder(model_path, dzn_folder, csv_header, csv_out="all_solutions.csv"):
    dzn_folder_sols = dzn_folder + "dzn/"
    files = os.listdir(dzn_folder_sols)

    csv_out = dzn_folder + csv_out

    with open(csv_out, "w") as csv_out_file:
        csv_out_file.write(csv_header)
        ii = 0
        for filename in files:
            if ".dzn" in filename and not ("_temp" in filename):
                print("\rsolving... {}%".format(str(np.round(100 * (ii+1)/len(files), 3))), end="")
                ii += 1

                dzn_path = dzn_folder_sols+filename
                output_file_temp = dzn_path+"_temp"
                command = "minizinc {model_path} {dzn_path} --solver jacop -o {file_out}".format(
                    model_path=model_path, dzn_path=dzn_path, file_out=output_file_temp)
                os.system(command)
                with open(output_file_temp, "r") as solution_file:
                    solution = solution_file.readline()
                    csv_out_file.write(solution)
                os.remove(output_file_temp)
    return csv_out


def solveAndFindPareto(model_path, dzn_folder, csv_header, objectives, minimizeObj=None):
    allSolutionsPath = solveDznFolder(model_path, dzn_folder, csv_header)
    return paretoSolutions(allSolutionsPath, objectives, dzn_folder, minimizeObj)


def paretoSolutions(all_solutions_path, objectives, dzn_folder, minimizeObj=None, fileOut="paretoSolutions.csv"):
    pdFile = pd.read_csv(all_solutions_path)
    res = pd.DataFrame()

    fileOut = dzn_folder + fileOut

    if minimizeObj is None:
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
            res = res.append(row2)

    res.to_csv(fileOut)

    return fileOut


def evalParamsOnSimulationMulti(netlogo_model_path, params_static, params_dynamic, expectedOutcomes, simulationTicks=10000, maxSims=None, repetitions=3, gui=False):
    # load model
    print("\rloading netlogo model...", end="")
    netlogo = pyNetLogo.NetLogoLink(gui=gui)
    netlogo.load_model(netlogo_model_path)

    # set static params
    for key, value in params_static.items():
        netlogo.command("set {} {}".format(key, value))

    MSE_arr_all = []
    realOut_all = []

    if maxSims is None:
        maxSims = len(expectedOutcomes)

    for i in range(maxSims):
        MSE_arr, realOut = evalParamsOnSimulationSingle(
            netlogo, params_dynamic[i], expectedOutcomes[i], simulationTicks, repetitions)
        MSE_arr_all.append(list(MSE_arr.values()))
        realOut_all.append(realOut)
        print("\rsimulating.. {} of {}".format(i+1, maxSims), end="")

    print("\nMSE_mean: {}".format(np.mean(MSE_arr_all)))
    netlogo.kill_workspace()
    return realOut_all, MSE_arr_all


def evalParamsOnSimulationSingle(netlogo, params, expectedOutcomes, simulationTicks, repetitions):
    realOut = {}
    MSE_arr = {}

    for key, value in expectedOutcomes.items():
        realOut[key] = []
        MSE_arr[key] = []

    for i in range(repetitions):
        # setup instance specific params
        for key, value in params.items():
            netlogo.command("set {} {}".format(key, value))

        # run netlogo model
        netlogo.command('setup')
        netlogo.repeat_command('go', simulationTicks)

        # compare with expected value
        for key, value in expectedOutcomes.items():
            observed = float(netlogo.report(key))
            realOut[key].append(observed)
            MSE_arr[key].append(np.square(observed - expectedOutcomes[key]))

    for key, value in expectedOutcomes.items():
        realOut[key] = np.mean(realOut[key])
        MSE_arr[key] = np.mean(MSE_arr[key])

    return MSE_arr, realOut

