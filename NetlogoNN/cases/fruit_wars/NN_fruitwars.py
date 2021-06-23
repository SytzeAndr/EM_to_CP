
import sys
sys.path.append("../..")

from NetLogoSimulator import NetLogoSimulator
from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNet, LinearNetTanh, LinearNetSoftmax, LinearNetRelu
import torch


if __name__ == "__main__":
    parametersOutTraits = ["mean_strength", "mean_speed", "mean_intelligence"]
    parametersOutDeaths = ["murder-rate", "age-death-rate", "starvation-rate"]
    parametersOutAggression = ["mean_reactive_aggression", "mean_proactive_aggression"]
    parametersOutPop = ["average-population"]

    parametersOutAll = parametersOutTraits + parametersOutDeaths + parametersOutAggression + parametersOutPop

    parametersInRange = {
            "initial-fruit-bushes": [1, 40],
            "initial-foragers": [1, 100],
            "ticks-to-flee": [1, 100],
            "collaboration-bonus": [0.1, 5.0],
            "bush-growth-chance": [0.1, 100.0],
            "max-age": [1, 500],
            "rate-of-mutation": [0.1, 10.0]
        }

    modelDefaultParameters = {}

    parametersIn = list(parametersInRange.keys())

    s = NetLogoSimulator(
            parametersInRange,
            parametersOutAll,
            modelDefaultParameters,
            r"Fruit Wars.nlogo",
            tag="fruit_wars_"
        )

    s.run(randomParametersCount=100000, simulationTicks=6000, cores=9)
    folder = s.logFolder
    print(folder)
    testData = "data_out/fruit_wars_210408-124609/data_out.csv"
    folder = "data_out/fruit_wars_210408-130120/"

    max_iters = 10e6
    max_seconds = 300

    # fit traits
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOutTraits,
        LinearNetSoftmax(len(parametersIn), len(parametersOutTraits)),
        tag="_traits").fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOutTraits, cuda=False))

    # fit deaths
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOutDeaths,
        LinearNetSoftmax(len(parametersIn), len(parametersOutDeaths)),
        tag="_deaths").fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOutDeaths, cuda=False))

    # fit Aggression
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOutAggression,
        LinearNetSoftmax(len(parametersIn), len(parametersOutAggression)),
        tag="_aggression").fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOutAggression, cuda=False))

    # fit Population
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOutPop,
        LinearNetRelu(len(parametersIn), len(parametersOutPop)),
        tag="_pop").fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOutPop, cuda=False)
    )

    def create_mzn_by_tag(tag, paramsOut):
        torch.load(folder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + tag + ".pt").createMiniZincFunctions(
            parametersIn,
            paramsOut,
            folder+"nn_out{}.mzn".format(tag), tag=tag
        )

    create_mzn_by_tag("_traits", parametersOutTraits)
    create_mzn_by_tag("_deaths", parametersOutDeaths)
    create_mzn_by_tag("_aggression", parametersOutAggression)
    create_mzn_by_tag("_pop", parametersOutPop)
