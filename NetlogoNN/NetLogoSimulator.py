import os
import pyNetLogo
from Timer import Timer
import time
from pyNetLogo.core import NetLogoException
from datetime import datetime

import multiprocessing as mp

from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
from scipy.optimize import curve_fit


class NetLogoSimulator():

    # filename for outputting simulation data
    FILENAME_DATA_OUT = "data_out.csv"

    # main folder where data is stored
    FOLDERNAME_DATA_OUT = "data_out/"

    def __init__(self, simulationParameterInRange, simulationParameterOut, modelDefaultParameters, modelFilename, tag=""):
        self.simulationParameterInRange = simulationParameterInRange
        self.simulationParameterOut = simulationParameterOut
        self.modelDefaultParameters = modelDefaultParameters
        self.modelFilename = modelFilename
        self.tag = tag

    def run(self, randomParametersCount=1000, simulationTicks=10000, cores=None, timeoutRestartTime=None):
        # create folder where we store data corresponding to this run
        dateTimeObj = datetime.now()
        timestampStr = dateTimeObj.strftime("%y%m%d-%H%M%S")

        self.logFolder = NetLogoSimulator.FOLDERNAME_DATA_OUT + self.tag + timestampStr + "/"
        if not os.path.exists(self.logFolder):
            os.makedirs(self.logFolder)
        # create file and write header
        filename = self.getDataOutFilename()

        with open(filename, "w") as file:
            file.write(",".join(list(self.simulationParameterInRange.keys()) + self.simulationParameterOut) + "\n")

        processList = []

        def fillProcessList(cores):
            # create java environment per cpu
            processList.clear()
            if cores is None:
                cores = mp.cpu_count()
            sims_per_core = int(np.ceil(randomParametersCount / cores))
            sims_assigned = 0
            for i in range(cores):
                if sims_assigned + sims_per_core > randomParametersCount:
                    sims_per_core = randomParametersCount - sims_assigned
                sims_assigned += sims_per_core
                # do simulation
                process = mp.Process(target=self.simulate,
                                     args=(sims_per_core, simulationTicks, filename), name=str(i))
                processList.append(process)
                process.start()

        fillProcessList(cores)
        with Timer("simulation"):
            # endless sim runs with restarts every timeoutRestart seconds
            start = time.time()
            while timeoutRestartTime is not None:
                while time.time() - start <= timeoutRestartTime:
                    # check every 10 seconds
                    time.sleep(10)
                else:
                    print("timed out, restart all processes")
                    start = time.time()
                    for p in processList:
                        p.terminate()
                    fillProcessList(cores)

            else:
                # do normal joining of processes
                for process in processList:
                    process.join()

    def sampleParameterCombination(self):
        parameterCombination = {}
        for parametername, parameterrange in self.simulationParameterInRange.items():
            if len(parameterrange) == 1:
                parameterCombination[parametername] = parameterrange[0]
            elif type(parameterrange[0]) == int:
                # the parameter is an int
                parameterCombination[parametername] = np.random.randint(parameterrange[0], parameterrange[1])
            else:
                # the parameter is a float
                parameterCombination[parametername] = np.random.uniform(parameterrange[0], parameterrange[1])
        return parameterCombination

    def simulate(self, randomParametersCount, simulationTicks, filename):
        # load model
        netlogo = pyNetLogo.NetLogoLink(gui=False)  # , netlogo_version="6.1")
        netlogo.load_model(self.modelFilename)
        # setup default parameters
        NetLogoSimulator.setModelParameters(netlogo, self.modelDefaultParameters)

        for i in range(randomParametersCount):
            # create parameters and set to model
            parameterCombination = self.sampleParameterCombination()
            NetLogoSimulator.setModelParameters(netlogo, parameterCombination)

            try:
                # run simulation
                netlogo.command('setup')
                netlogo.repeat_command('go', simulationTicks)

                toWrite = ""
                # write parameters used
                toWrite += ",".join(list(map(lambda x: str(x), parameterCombination.values())))
                # write observed values
                for paramaterOutField in self.simulationParameterOut:
                    toWrite += "," + str(netlogo.report(paramaterOutField))

                # open file for appending lines
                with open(filename, "a") as file:
                    file.write(toWrite)
                    file.write("\n")
                print("{}_{}: {}".format(mp.current_process().name, i, toWrite))

            except Exception:
                print("error occured, do not write results to file")

        netlogo.kill_workspace()

    def getDataOutFilename(self):
        return self.logFolder + NetLogoSimulator.FILENAME_DATA_OUT

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
