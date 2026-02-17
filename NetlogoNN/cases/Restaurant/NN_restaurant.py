import sys
sys.path.append("../..")

from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNet, LinearNetTanh, LinearNetSoftmax, LinearNetRelu, LinearNetSigmoid, LinearNetTanhRelu, LinearNetPow2
import torch
from restaurant_generate_simdata import main as generate_sim_data_main


def main():
        # optional: generate training data
        # generate_sim_data_main(repetitions=10000, csv_out="train.csv")

        parametersInRange = {
                "buy1": [0, 10],
                "buy2": [0, 10]
            }

        parametersIn = list(parametersInRange.keys())
        parametersOut = ["success_ratio", "spoil_ratio"]


        folder = "simdata/"
        testData = "simdata/test.csv"

        print(folder)

        max_iters = 10e9
        printLabels = True

        layers = 4

        # net_in = LinearNetPow2(len(parametersIn), len(parametersOut), hiddenLayers=layers)
        net_in = LinearNetSigmoid(len(parametersIn), len(parametersOut), hiddenLayers=layers)
        # net_in = torch.load("simdata/model_out_3layer.pt")

        dofit = True
        if dofit:
                fitterRatio = NetLogoDataFitterNN(
                        folder,
                        parametersIn,
                        parametersOut,
                        net_in,
                        data_filename="train.csv",
                        tag="_{}layer".format(layers))

                fitterRatio.fit(
                        max_iters=max_iters,
                        max_seconds=3600,
                        datasetTest=DatasetCSV(testData, parametersIn, parametersOut, cuda=False),
                        lr=0.00001,
                        batch_size=64,
                        printTestLabels=printLabels)

        torch_model_path = folder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + "_{}layer.pt".format(layers)
        nn_model = torch.load(torch_model_path)

        minizinc_out_path = "mzn_nn/nn_Sigmoid_{}layer.mzn".format(layers)
        nn_model.createMiniZincFunctions(
                parametersIn, parametersOut, minizinc_out_path, tag="_{}layer".format(layers))


if __name__ == "__main__":
        main()
