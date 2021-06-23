
import sys
sys.path.append("../..")

from NetLogoSimulator import NetLogoSimulator
from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNet, LinearNetTanh, LinearNetSoftmax, LinearNetRelu, LinearNetSigmoid
import torch


if __name__ == "__main__":
    parametersOutTraits = ["mean_strength", "mean_speed", "mean_intelligence"]
    parametersOutDeaths = ["murder-rate", "age-death-rate", "starvation-rate"]
    parametersOutAggression = ["mean_reactive_aggression", "mean_proactive_aggression"]
    parametersOutPop = ["average-population"]

    parametersOutAll = parametersOutTraits + parametersOutDeaths + parametersOutAggression + parametersOutPop
    parametersOutRatio = parametersOutTraits + parametersOutDeaths + parametersOutAggression

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

    # s = NetLogoSimulator(
    #         parametersInRange,
    #         parametersOutAll,
    #         modelDefaultParameters,
    #         r"Fruit Wars.nlogo",
    #         tag="fruit_wars_"
    #     )
    #
    # s.run(randomParametersCount=100000, simulationTicks=6000, cores=8)
    # folder = s.logFolder
    # print(folder)
    testData = "data_out/fruit_wars_210511-234655/data_out.csv"
    folder = "data_out/fruit_wars_merged/"

    max_iters = 10e9
    max_seconds = 14400
    # max_seconds = 4

    layers = 4

    tag_sigmoid = "sigmoid_{}layer".format(layers)
    tag_relu = "relu_{}layer".format(layers)

    # fit ratio
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOutRatio,
        LinearNetSigmoid(
            len(parametersIn), len(parametersOutRatio), hiddenLayers=layers
        ),
        tag=tag_sigmoid
    ).fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        lr=0.0001,
        batch_size=64,
        printTestLabels=True,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOutRatio, cuda=False))

    # fit population
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOutPop,
        LinearNetRelu(
            len(parametersIn), len(parametersOutPop), hiddenLayers=layers
        ),
        tag=tag_relu
    ).fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        lr=0.0001,
        batch_size=64,
        printTestLabels=True,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOutPop, cuda=False))

    def create_mzn_by_tag(tag, paramsOut):
        torch.load(
            folder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + tag + ".pt"
        ).createMiniZincFunctions(
            parametersIn,
            paramsOut,
            "mzn_nn/nn_{}.mzn".format(tag), tag=tag
        )

    create_mzn_by_tag(tag_sigmoid, parametersOutRatio)
    create_mzn_by_tag(tag_relu, parametersOutPop)
