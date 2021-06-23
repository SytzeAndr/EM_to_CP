import sys
sys.path.append("../..")

from NetLogoSimulator import NetLogoSimulator
from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNet, LinearNetTanh, LinearNetSoftmax, LinearNetRelu, LinearNetSigmoid, LinearNetTanhRelu
import torch


def main():
        parametersOutRatio = ["t1_loss", "t2_loss", "t3_loss", "unsatisfied_rate"]
        parametersOutRaw = ["mean_no_show_times", "var_no_show_times"]

        parametersOut = parametersOutRatio + parametersOutRaw

        parametersInRange = {
                "receptionists_amount": [1, 500],
                "p_incoming_t1": [0.0, 1.0],
                "p_incoming_t3": [0.0, 1.0],
                "p_showup": [0.0, 1.0],
                "spread_factor": [0.1, 0.9],
                "satisfied_max_quetime": [10], #[1, 30],
                "checkin_max_quetime": [15], #[1, 30],
                "reservation_max_quetime": [15], #[1, 30],
                "noshow_max_time": [100], #[1, 10000],
                "t1_duration": [1, 100],
                "t2_duration": [1, 100],
                "t3_duration": [1, 100],
                "t4_duration": [1, 100],
                "t5_duration": [1, 100],
                "t6_duration": [1, 100],
                "spread_horizon": [2000], #[1, 3600],
                "stay_duration": [100], #[1, 1000],
                "time_between_t1_and_t3": [500], #[1, 1000],
            }

        parametersIn = list(parametersInRange.keys())

        modelDefaultParameters = {
                "room_price": 10,
                "no_show_fine": 5,
            }

        # s = NetLogoSimulator(
        #         parametersInRange,
        #         parametersOut,
        #         modelDefaultParameters,
        #         r"Hotel_slaaplust.nlogo"
        #     )

        # s.run(
        # randomParametersCount=100000, simulationTicks=10000, cores=8)
        # folder = s.logFolder

        folder = "data_out/3losses_merged/"

        testData = "data_out/3losses_merged/test.csv"
        print(folder)


        max_iters = 10e9
        printLabels = True

        layers = 2
        fitterRatio = NetLogoDataFitterNN(
                folder,
                parametersIn,
                parametersOutRatio,
                LinearNetSigmoid(len(parametersIn), len(parametersOutRatio), hiddenLayers=layers),
                tag="_ratio")

        fitterRatio.fit(
                max_iters=max_iters,
                max_seconds=28800,
                datasetTest=DatasetCSV(testData, parametersIn, parametersOutRatio, cuda=False),
                lr=0.0001,
                batch_size=64,
                printTestLabels=printLabels)

        modelpathRatio = folder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + "_ratio.pt"
        modelRatio = torch.load(modelpathRatio)
        # minizincOutRatio = folder+"nn_Sigmoid_{}layer.mzn".format(layers)
        minizincOutRatio = "mzn_nn/nn_Sigmoid_2layer.mzn".format(layers)
        modelRatio.createMiniZincFunctions(parametersIn, parametersOutRatio, minizincOutRatio, tag="_ratio")


        # fitterRaw = NetLogoDataFitterNN(
        #         folder,
        #         parametersIn,
        #         parametersOutRaw,
        #         LinearNetRelu(len(parametersIn), len(parametersOutRaw)),
        #         tag="_raw")
        # fitterRaw.fit(
        #         max_iters=max_iters,
        #         datasetTest=DatasetCSV(testData, parametersIn, parametersOutRaw, cuda=False),
        #         lr=0.0001,
        #         batch_size=128,
        #         printTestLabels=printLabels)
        #
        # modelpathRaw = folder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + "_raw.pt"
        # modelRaw = torch.load(modelpathRaw)
        # # minizincOutRaw = folder+"nn_out_raw.mzn"
        # minizincOutRaw = "nn_raw_1layer.mzn"
        # modelRaw.createMiniZincFunctions(parametersIn, parametersOutRaw, minizincOutRaw, tag="_raw")

        # parametersEval = torch.tensor([99, 0.8, 0.8, 0.8, 0.9, 5, 10, 10, 10, 10, 10, 10, 10, 10])
        # model.eval()
        # print(model(parametersEval).tolist())

if __name__ == "__main__":
        main()
