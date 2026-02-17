from Timer import Timer
import pandas as pd
# from NetLogoSimulator import NetLogoSimulator
from matplotlib import pyplot as plt

from sklearn.metrics import mean_squared_error, mean_absolute_percentage_error

import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
from torch.utils.data import Dataset, DataLoader


class NetLogoDataFitterNN():

    # filename for outputting model parameters that fit the simulated data (used for feeding the CP model)
    FILENAME_PARAM_OUT = "model_out"

    # FILENAME_DATA_OUT = NetLogoSimulator.FILENAME_DATA_OUT
    FILENAME_DATA_OUT = "data_out.csv"

    # HEADER_PARAM_OUT = "parameterOut"

    def __init__(self, dataFolder, parametersIn, parametersOut, net, tag="", data_filename=FILENAME_DATA_OUT):
        self.dataFolder = dataFolder
        self.data_filename = data_filename
        self.parametersIn = parametersIn
        self.parametersOut = parametersOut
        self.dataset = DatasetCSV(self.getDataFilename(), parametersIn, parametersOut, cuda=True)
        self.net = net
        self.tag = tag

    def getModelFilename(self):
        return self.dataFolder + NetLogoDataFitterNN.FILENAME_PARAM_OUT + self.tag + ".pt"

    def getDataFilename(self):
        return self.dataFolder + self.data_filename

    def fit(self, max_iters=10e7, max_seconds=None, lr=0.001, datasetTest=None, printTestLabels=False, batch_size=64):

        self.net.cuda()
        dataloader = DataLoader(self.dataset, batch_size=batch_size, shuffle=True)

        # fit NN on the data
        max_epochs = int(np.round(max_iters / len(self.dataset)))

        criterion = nn.MSELoss()
        optimizer = optim.AdamW(self.net.parameters(), lr=lr)
        # optimizer = optim.Adagrad(self.net.parameters())
        # optimizer = optim.RMSprop(self.net.parameters())

        timer = Timer()
        for e in range(max_epochs):
            if max_seconds is not None and timer.elapsed_seconds() >= max_seconds:
                break
            for features, labels in dataloader:
                print("\rtraining{}: {}%\telapsed: {}".format(self.tag, np.round(e * 100/max_epochs, 2), timer.elapsed()), end="")
                output = self.net(features)
                loss = criterion(output, labels)
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()
        print("\n")
        # save model
        self.net.eval()
        torch.save(self.net, self.getModelFilename())

        # if there is a datasetTest, provide metrics
        if datasetTest is not None:
            self.net.cpu()
            foundLabels = []
            trueLabels = []
            for x, y in datasetTest:
                foundLabels.append(self.net(x).data.numpy())
                trueLabels.append(y.data.numpy())
            toPrint = ""
            MSE = mean_squared_error(trueLabels, foundLabels)
            toPrint += "MSE{}: {}\n".format(self.tag, MSE)
            toPrint += "MAPE{}: {}\n".format(self.tag, mean_absolute_percentage_error(trueLabels, foundLabels))
            if printTestLabels:
                toPrint += "truelabel\tnetlabel\n"
                for key, truelabel in enumerate(trueLabels):
                    toPrint += "{}\t{}\n".format(truelabel, foundLabels[key])
            print(toPrint)
            return MSE


class DatasetCSV(Dataset):
    def __init__(self, filename, x_params, y_params, cuda=True):
        pdFile = pd.read_csv(filename)
        x = pdFile[x_params].values
        y = pdFile[y_params].values
        if cuda:
            self.X_train = torch.tensor(x, dtype=torch.float32).cuda()
            self.Y_train = torch.tensor(y, dtype=torch.float32).cuda()
        else:
            self.X_train = torch.tensor(x, dtype=torch.float32)
            self.Y_train = torch.tensor(y, dtype=torch.float32)

    def __len__(self):
        return len(self.Y_train)

    def __getitem__(self, idx):
        return self.X_train[idx], self.Y_train[idx]
