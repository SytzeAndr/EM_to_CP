import pandas as pd

import petri_dzn_generator
import os
import time
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from multiprocessing import Process, Manager


isSoft = False
if isSoft:
    file_out = "petri_data_soft.dzn"
    command = "minizinc -m petri_net_firing_multiconstraint.mzn -d petri_data_soft.dzn"
else:
    file_out = "petri_data.dzn"
    command = "minizinc -m petri_net.mzn -d petri_data.dzn"


def petri_test(layerSize, nodeAvg, return_dict):
    petriNet, nodeCount, transCount = petri_dzn_generator.generateRandomPetri(
        layers=layerSize, nodeAvg=nodeAvg, transAvg=nodeAvg, variance_scale=2, flowMax=1, isSoft=isSoft)
    petriNet.create_dzn(file_out)
    return_dict["nodeCounts"] = nodeCount
    return_dict["transCounts"] = transCount
    # petriNet.printStats()
    t = time.time()
    os.system(command)
    elapsed = time.time() - t
    print("runtime: {}".format(elapsed))
    return_dict["durations"] = elapsed


if __name__ == "__main__":
    layers = list(range(1, 11))
    nodes = [3]
    reps = 20

    durations = []
    nodeCounts = []
    transCounts = []
    timeoutRatios = []

    TIMEOUT = 60

    def run():
        for layerSize in layers:
            timeoutRatio = []
            for nodeAvg in nodes:
                for r in range(reps):
                    return_dict = Manager().dict()
                    p = Process(target=petri_test, args=(layerSize, nodeAvg, return_dict))
                    p.start()
                    p.join(timeout=TIMEOUT)
                    nodeCounts.append(return_dict["nodeCounts"])
                    transCounts.append(return_dict["transCounts"])
                    if p.exitcode is None:
                        print("timeout for {}, {}".format(layerSize, nodeAvg))
                        durations.append(TIMEOUT)
                        # timeouts.append({"layersize": layerSize, "nodeAvg": nodeAvg})
                        timeoutRatio.append(1)
                        os.system("Taskkill /IM fzn-gecode.exe /F")
                    else:
                        durations.append(return_dict["durations"])
                        timeoutRatio.append(0)
                    p.terminate()
            timeoutRatios.append(np.mean(timeoutRatio))


    fileWrite_dur = "petri_results_dur.csv"
    fileWrite_to = "petri_results_to.csv"

    read = True

    if read:
        data_duration = pd.read_csv(fileWrite_dur)
        data_timeout = pd.read_csv(fileWrite_to)
    else:
        run()
        data_duration = pd.DataFrame({
            "durations": durations,
            "nodeCounts": nodeCounts,
            "transCounts": transCounts,
        })
        data_timeout = pd.DataFrame({
            "layers": layers,
            "timeoutRatio": timeoutRatios
        })

        print("durations: {}".format(durations))
        print("nodecounts: {}".format(nodeCounts))
        print("layers: {}".format(timeoutRatios))
        print("timeoutRatios: {}".format(timeoutRatios))

        data_duration.to_csv(fileWrite_dur)
        data_timeout.to_csv(fileWrite_to)

    sns.lineplot(data=data_timeout, x="layers", y="timeoutRatio")
    plt.suptitle("Petri net scalability test - layers")
    plt.tight_layout()
    plt.grid()
    plt.show()
