
import sys

import sklearn.preprocessing

sys.path.append("../..")

from NetLogoSimulatorUniform import NetLogoSimulatorUniform
from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNet, LinearNetTanh, LinearNetSoftmax, LinearNetRelu, LinearNetSigmoid
import torch
import numpy as np
import pandas as pd


class SupplyChainSimulator(NetLogoSimulatorUniform):
    # custom sampling for the supply chain

    def sampleParameterCombination(self):
        parameterCombination = {}

        # some fields have a relative upper bound
        specialNames = ["Fact", "Distr1", "Distr2", "Clients_N", "Demand_W", "DS_D"]

        parameterCombination["Fact"] = np.random.randint(
            self.simulationParameterInRange["Fact"][0], self.simulationParameterInRange["Fact"][1])

        parameterCombination["Distr1"] = np.random.randint(
            self.simulationParameterInRange["Distr1"][0], parameterCombination["Fact"] * 6)

        parameterCombination["Distr2"] = np.random.randint(
            self.simulationParameterInRange["Distr2"][0], parameterCombination["Distr1"] * 4)

        parameterCombination["Clients_N"] = np.random.randint(
            self.simulationParameterInRange["Clients_N"][0], parameterCombination["Distr2"] * 50)

        parameterCombination["Demand_W"] = np.random.randint(
            self.simulationParameterInRange["Demand_W"][0], self.simulationParameterInRange["Demand_W"][1])

        parameterCombination["DS_D"] = np.random.randint(
            self.simulationParameterInRange["DS_D"][0], np.ceil(parameterCombination["Demand_W"] / 2))

        # else do normal behavior
        for parametername, parameterrange in self.simulationParameterInRange.items():
            if parametername not in specialNames:
                if len(parameterrange) == 1:
                    parameterCombination[parametername] = parameterrange[0]
                elif type(parameterrange[0]) == int:
                    parameterCombination[parametername] = np.random.randint(parameterrange[0], parameterrange[1])
                elif type(parameterrange[0]) == str:
                    parameterCombination[parametername] = "\"{}\"".format(np.random.choice(parameterrange))
                else:
                    # the parameter is a float
                    parameterCombination[parametername] = np.random.uniform(parameterrange[0], parameterrange[1])
        return parameterCombination


def dataToCategorical(path_in, path_out, categorical_headers, categorical_options):
    csv_in = pd.read_csv(path_in)

    csv_out = pd.DataFrame()
    for index, row in csv_in.iterrows():
        rowOut = {}
        for key, value in row.items():
            if key not in categorical_headers:
                rowOut[key] = value
            else:
                for cat_i in range(len(categorical_headers)):
                    if categorical_headers[cat_i] == key:
                        for cat_opt in categorical_options[cat_i]:
                            if cat_opt == value:
                                rowOut[cat_opt] = 1
                            else:
                                rowOut[cat_opt] = 0
        csv_out = csv_out.append(rowOut, ignore_index=True)
    csv_out.to_csv(path_out)


if __name__ == "__main__":
    parametersOut = [
        "lost_ratio_sales_ret",
        "lost_ratio_sales_dis",
        "lost_ratio_sales_fac",
        "stock_customer_MA_mean_relative",
        "stock_distributor_MA_mean_relative",
        "stock_retailer_MA_mean_relative",
        "stock_factory_MA_mean_relative"
    ]

    parametersInRange = {
            "Fact": [1, 3],
            "Distr1": [1, 10], # need scaling
            "Distr2": [1, 40], # need scaling
            "Clients_N": [1, 1500], # need scaling
            "Demand_W": [1, 15],
            "HC": [0.01, 0.1],
            "Lt0": [4], # [0, 7], # fix?
            "Lt1": [4], # [0, 7], # fix?
            "SS_%": [0.85], #[0.5, 0.95], # fix?
            "DS_D": [0, 15],
            "K": [200], # fix?
            "MA": [500],
            "Customers_Strategy": ["1-DailyPurchase", "2-PeriodicallyPurchase", "3-Random"],
            "Inventory_Policy": ["1-(s,Q)", "2-(s,S)", "3-(R,S)", "4-Random"],
    }

    modelDefaultParameters = {}

    # create list of parameters after encoded
    paramInKeysRaw = np.array(list(parametersInRange.keys()))
    paramInKeysRaw = paramInKeysRaw[paramInKeysRaw != "Customers_Strategy"]
    paramInKeysRaw = list(paramInKeysRaw[paramInKeysRaw != "Inventory_Policy"])
    parametersIn = paramInKeysRaw + parametersInRange["Customers_Strategy"] + parametersInRange["Inventory_Policy"]

    tag = "Supply_Chain"

    # s = SupplyChainSimulator(
    #         parametersInRange,
    #         parametersOut,
    #         modelDefaultParameters,
    #         r"Supply_Chain.nlogo",
    #         tag=tag
    #     )
    # s.run(randomParametersCount=10000, simulationTicks=3000, cores=6, timeoutRestartTime=1800)
    # folder = s.logFolder

    folder = "data_out/Supply_Chain_all/"
    testfolder = "data_out/Supply_Chain_test/"
    print(folder)

    dataToCategorical(
        folder + "data_out.csv",
        folder + "data_out_enc.csv",
        ["Customers_Strategy", "Inventory_Policy"],
        [["1-DailyPurchase", "2-PeriodicallyPurchase", "3-Random"], ["1-(s,Q)", "2-(s,S)", "3-(R,S)", "4-Random"]]
    )

    dataToCategorical(
        testfolder + "data_out.csv",
        testfolder + "data_out_enc.csv",
        ["Customers_Strategy", "Inventory_Policy"],
        [["1-DailyPurchase", "2-PeriodicallyPurchase", "3-Random"], ["1-(s,Q)", "2-(s,S)", "3-(R,S)", "4-Random"]]
    )

    testData = testfolder + "data_out_enc.csv"
    # testData = folder + "data_out_enc.csv"

    max_iters = 10e8
    max_seconds = 7200

    # fit NN
    NetLogoDataFitterNN(
        folder,
        parametersIn,
        parametersOut,
        LinearNetSigmoid(len(parametersIn), len(parametersOut), hiddenLayers=4),
        tag=tag,
        data_filename="data_out_enc.csv"
    ).fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        lr=0.0001,
        datasetTest=DatasetCSV(testData, parametersIn, parametersOut, cuda=False))


    def create_mzn_by_tag(tag, paramsOut):
        torch.load(folder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + tag + ".pt").createMiniZincFunctions(
            parametersIn,
            paramsOut,
            "mzn_nn/nn_out_sigmoid_4layer.mzn", tag=tag
        )

    create_mzn_by_tag(tag, parametersOut)

