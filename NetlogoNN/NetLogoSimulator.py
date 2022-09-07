import os
import sys

import pyNetLogo



# from EM_to_CP.NetlogoNN.Timer import Timer
# from EM_to_CP.NetlogoNN.parameters import load_parameter

from Timer import Timer
from parameters import load_parameter


import time
from pyNetLogo.core import NetLogoException
from datetime import datetime

import multiprocessing as mp

from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
from sys import platform


class NetLogoSimulator:
    # filename for outputting simulation data
    FILENAME_DATA_OUT = "data_out.csv"
    FILENAME_INDICES_PERFORMED = "indices_performed.txt"

    # main folder where data is stored
    FOLDERNAME_DATA_OUT = "data_out/"

    def __init__(
            self,
            simulationParameterInRange,
            simulationParameterOut,
            modelDefaultParameters,
            modelFilename,
            parameter_sampler_constructor,
            tag=""
    ):
        self.simulationParameterOut = simulationParameterOut
        self.modelDefaultParameters = modelDefaultParameters
        self.modelFilename = modelFilename
        self.parameter_sampler = parameter_sampler_constructor(simulationParameterInRange)
        self.tag = tag

    def get_start_index(self):
        # based on the number of data rows present in the data file
        return len(pd.read_csv(self.getDataOutFilename()))

    def mark_index_performed(self, index):
        with open(self.getIndicesPerformedFilename(), 'a') as file:
            file.write(f"{index}\n")

    def get_indices_performed(self):
        with open(self.getIndicesPerformedFilename(), 'r') as file:
            res = [int(line.rstrip()) for line in file]
            print(f"indices performed: {res}")
            return res
            # return file.readLines()

    def run(self, randomParametersCount=1000, simulationTicks=10000, num_workers=None, timeoutRestartTime=None, log_folder=None):
        # create folder to store sim data
        if log_folder is None:
            dateTimeObj = datetime.now()
            timestampStr = dateTimeObj.strftime("%y%m%d-%H%M%S")
            self.logFolder = NetLogoSimulator.FOLDERNAME_DATA_OUT + self.tag + timestampStr + "/"
        else:
            self.logFolder = log_folder

        if not os.path.exists(self.logFolder):
            os.makedirs(self.logFolder)

        filename = self.getDataOutFilename()

        if not os.path.exists(filename):
            # create new csv file
            with open(filename, "w") as file:
                file.write(",".join(list(
                    self.parameter_sampler.simulation_parameters_in_range.keys()) + self.simulationParameterOut) + "\n"
                           )

        if not os.path.exists(self.getIndicesPerformedFilename()):
            # create file if non-existent
            open(self.getIndicesPerformedFilename(), 'w')

        processList = []

        # define number of cores, but leave one free
        if num_workers is None:
            num_workers = mp.cpu_count() - 1

        # start_index_start = self.get_start_index()

        # define parameter combinations to evaluate
        all_parameter_combinations = self.parameter_sampler.create_parameter_combinations(
            amount=randomParametersCount
        )

        def fill_process_list():
            # clear all processes
            processList.clear()

            # retrieve what processes have been performed
            performed_indices = self.get_indices_performed()

            to_perform_indices = [
                i for i in range(randomParametersCount)
                if i not in performed_indices
            ]

            # distribute to_perform_indices among cpu's
            indices_per_core = [[] for _ in range(num_workers)]
            for key_i, value_i in enumerate(to_perform_indices):
                worker_to_assign_to = np.mod(key_i, num_workers)
                indices_per_core[worker_to_assign_to] += [value_i]

            print(f"indices_per_core:{indices_per_core}")

            # create java environment per cpu
            for i in range(num_workers):
                # input_params_this_core = all_parameter_combinations[indices_per_core[i]]
                input_params_this_core = [all_parameter_combinations[int(ii)] for ii in indices_per_core[i]]
                parameter_indices = indices_per_core[i]
                p = mp.Process(
                    target=self.simulate,
                    args=(input_params_this_core, simulationTicks, filename, parameter_indices),
                    name=str(i)
                )
                processList.append(p)
                p.start()

        fill_process_list()

        with Timer("simulation"):
            # endless sim runs with restarts every timeoutRestart seconds
            start = time.time()
            while timeoutRestartTime is not None:
                # if sims have been performed, break
                if len(self.get_indices_performed()) >= randomParametersCount:
                    print("done simulating")
                    for p in processList:
                        p.terminate()
                    return

                while time.time() - start <= timeoutRestartTime:
                    # check every 10 seconds
                    time.sleep(10)
                else:
                    print("timed out, restart all processes")
                    start = time.time()
                    for p in processList:
                        p.terminate()
                    fill_process_list()
            else:
                # do normal joining of processes
                for process in processList:
                    process.join()

    def simulate(self, parameter_combinations, simulation_ticks, filename, parameter_indices):
        # load model
        print("start simulation...")
        # print(f"file:{__file__}")
        netlogo = pyNetLogo.NetLogoLink(
            gui=False,
            netlogo_home=load_parameter("netlogo_home"),
            netlogo_version=load_parameter("netlogo_version"),
            jvm_home=load_parameter("jvm_home")
        )  # , netlogo_version="6.1")
        netlogo.load_model(self.modelFilename)

        # setup default parameters
        NetLogoSimulator.setModelParameters(netlogo, self.modelDefaultParameters)

        for i, parameter_combination in enumerate(parameter_combinations):
            # create parameters and set to model
            NetLogoSimulator.setModelParameters(netlogo, parameter_combination)

            try:
                # run simulation
                netlogo.command('setup')
                netlogo.repeat_command('go', simulation_ticks)

                toWrite = ""
                # write parameters used
                toWrite += ",".join(list(map(lambda x: str(x), parameter_combination.values())))
                # write observed values
                for paramaterOutField in self.simulationParameterOut:
                    toWrite += "," + str(netlogo.report(paramaterOutField))

                # open file for appending lines
                with open(filename, "a") as file:
                    file.write(toWrite)
                    file.write("\n")
                self.mark_index_performed(parameter_indices[i])
                print("{}_{}: {}".format(mp.current_process().name, i, toWrite))

            except Exception:
                print("error occured, do not write results to file")

        netlogo.kill_workspace()

    def getDataOutFilename(self):
        return os.path.join(self.logFolder, NetLogoSimulator.FILENAME_DATA_OUT)

    def getIndicesPerformedFilename(self):
        return os.path.join(self.logFolder, self.FILENAME_INDICES_PERFORMED)

    @staticmethod
    def setModelParameters(netlogoModel, parameters):
        for key, value in parameters.items():
            command = "set {} {}".format(key, value)
            # print(command)
            netlogoModel.command(command)

    @staticmethod
    def allCombinations(arrayOfArrays):
        # source: https://www.geeksforgeeks.org/combinations-from-n-arrays-picking-one-element-from-each-array/
        n = len(arrayOfArrays)
        indices = [0 for i in range(n)]
        out = []
        while True:
            comb = []
            for i in range(n):
                comb.append(arrayOfArrays[i][indices[i]])
            out.append(comb)

            next = n - 1
            while (next >= 0 and
                   (indices[next] + 1 >= len(arrayOfArrays[next]))):
                next -= 1

            if next < 0:
                return out
            indices[next] += 1

            for i in range(next + 1, n):
                indices[i] = 0
