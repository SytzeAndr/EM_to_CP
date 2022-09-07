
import sys
import os
sys.path.append("../..")

from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNetSigmoid, LinearNetTaylorSimple, LinearNetPow2, LinearDoubleRelu
import numpy as np
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import pandas as pd
import torch


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

def get_parameters_in():
    parametersInRange = {
        "Fact": [1, 3],
        "Distr1": [1, 10],  # need scaling
        "Distr2": [1, 40],  # need scaling
        "Clients_N": [1, 1500],  # need scaling
        "Demand_W": [1, 15],
        "HC": [0.01, 0.1],
        "Lt0": [4],  # [0, 7], # fix?
        "Lt1": [4],  # [0, 7], # fix?
        "SS_%": [0.85],  # [0.5, 0.95], # fix?
        "DS_D": [0, 15],
        "K": [200],  # fix?
        "MA": [500],
        "Customers_Strategy": ["1-DailyPurchase", "2-PeriodicallyPurchase", "3-Random"],
        "Inventory_Policy": ["1-(s,Q)", "2-(s,S)", "3-(R,S)", "4-Random"],
    }

    # create list of parameters after encoded
    paramInKeysRaw = np.array(list(parametersInRange.keys()))
    paramInKeysRaw = paramInKeysRaw[paramInKeysRaw != "Customers_Strategy"]
    paramInKeysRaw = list(paramInKeysRaw[paramInKeysRaw != "Inventory_Policy"])
    parametersIn = paramInKeysRaw + parametersInRange["Customers_Strategy"] + parametersInRange["Inventory_Policy"]

    return parametersIn

def get_parameters_out():
    return [
        "lost_ratio_sales_ret",
        "lost_ratio_sales_dis",
        "lost_ratio_sales_fac",
        # "stock_customer_MA_mean_relative",
        # "stock_distributor_MA_mean_relative",
        # "stock_retailer_MA_mean_relative",
        # "stock_factory_MA_mean_relative"
    ]

def trainNeuralNetworkSupplyChain(
        trainingDataPath, tag, max_iters=10e8, max_seconds=300,
        hiddenLayers=2, layerSize=None,
        modelContructor=LinearNetSigmoid,
        testDataPath="data_out/Supply_Chain_all/data_out_enc.csv",
        printTestLabels=False
):
    parametersIn = get_parameters_in()
    parametersOut = get_parameters_out()

    # tag_full = f"Supply_Chain_{tag}"
    tag_full = create_full_tag(tag)

    # folder = "data_out/Supply_Chain_all/"
    # testfolder = "data_out/Supply_Chain_test/"
    print(trainingDataPath)

    dataToCategorical(
        os.path.join(trainingDataPath, "data_out.csv"),
        os.path.join(trainingDataPath, "data_out_enc.csv"),
        ["Customers_Strategy", "Inventory_Policy"],
        [["1-DailyPurchase", "2-PeriodicallyPurchase", "3-Random"], ["1-(s,Q)", "2-(s,S)", "3-(R,S)", "4-Random"]]
    )

    # testData = testfolder + "data_out_enc.csv"
    # testData = "data_out/Supply_Chain_all/data_out_enc.csv"

    # fit NN
    NetLogoDataFitterNN(
        trainingDataPath,
        parametersIn,
        parametersOut,
        modelContructor(len(parametersIn), len(parametersOut), hiddenLayers=hiddenLayers, hiddenLayerSize=layerSize),
        tag=tag_full,
        data_filename="data_out_enc.csv"
    ).fit(
        max_iters=max_iters,
        max_seconds=max_seconds,
        lr=0.0001,
        datasetTest=DatasetCSV(testDataPath, parametersIn, parametersOut, cuda=False),
        printTestLabels=printTestLabels
    )


def create_mzn_by_tag(model_path_in, mzn_path_out, parametersIn, paramsOut):
    torch.load(
        model_path_in
    ).createMiniZincFunctions(
        parametersIn,
        paramsOut,
        mzn_path_out
    )


def create_full_tag(tag):
    return f"Supply_Chain_{tag}"


if __name__ == "__main__":
    tag = "halton"
    folder = f"data_out/supply_chain_{tag}_v3/"
    printTestLabels = False
    max_seconds = 300
    testDataPath = "data_out/Supply_Chain_all/data_out_enc.csv"
    activation = "sigmoid"
    hiddenLayers = 3
    tag_suffix = tag + f"_{activation}_{hiddenLayers}layer"
    print(activation)
    # trainNeuralNetworkSupplyChain(
    #     folder, tag_suffix, max_seconds=max_seconds, modelContructor=LinearNetSigmoid,
    #     hiddenLayers=hiddenLayers,
    #     testDataPath=testDataPath, printTestLabels=printTestLabels
    # )
    # print("pow2")
    # trainNeuralNetworkSupplyChain(
    #     folder, tag_suffix+"_pow2", max_seconds=max_seconds, modelContructor=LinearNetPow2,
    #     testDataPath=testDataPath, printTestLabels=printTestLabels
    # )
    # print("LinearDoubleRelu")
    # trainNeuralNetworkSupplyChain(
    #     folder, tag_suffix+"_doubleRelu", max_seconds=max_seconds, modelContructor=LinearDoubleRelu,
    #     testDataPath=testDataPath, printTestLabels=printTestLabels
    # )
    # print("taylor")
    # trainNeuralNetworkSupplyChain(
    #     folder, tag_suffix+"_taylor", max_seconds=max_seconds, modelContructor=LinearNetTaylorSimple,
    #     testDataPath=testDataPath, printTestLabels=printTestLabels
    # )
    create_mzn_by_tag(
        model_path_in=os.path.join(folder, f"{NetLogoDataFitterNN.FILENAME_PARAM_OUT}{create_full_tag(tag_suffix)}.pt"),
        mzn_path_out=os.path.join("mzn_nn", create_full_tag(tag_suffix) + "_3obj" + ".mzn"),
        parametersIn=get_parameters_in(),
        paramsOut=get_parameters_out()
    )

