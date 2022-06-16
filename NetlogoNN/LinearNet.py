import torch
import torch.nn as nn
import numpy as np


p_dropout_def = 0.1


class LinearNet(nn.Module):
    def __init__(self, n_in, n_out, hiddenLayers, hiddenLayerSize=None, p_dropout=p_dropout_def,
                 tanh=False, softmax=False, relu=False, sigmoid=False, taylor_simple=False, pow2_activation=False,
                 double_relu=False):
        super(LinearNet, self).__init__()

        self.hiddenLayers = hiddenLayers

        # hiddenlayersize = sqrt(n_in * n_out) + 4
        self.hiddenLayerSize = int(np.round(np.sqrt(np.multiply(n_in, n_out))) + 4) if hiddenLayerSize is None \
            else hiddenLayerSize

        self.dropout = nn.Dropout(p=p_dropout)
        self.tanh = tanh
        self.softmax = softmax
        self.relu = relu
        self.sigmoid = sigmoid
        self.taylor_simple = taylor_simple
        self.pow2_activation = pow2_activation
        self.double_relu = double_relu

        layerList = []
        for i in range(hiddenLayers):
            layerList.append(
                nn.Linear(
                    in_features=n_in if i == 0 else self.hiddenLayerSize,
                    out_features=self.hiddenLayerSize)
            )

        layerList.append(nn.Linear(in_features=self.hiddenLayerSize, out_features=n_out))
        self.layers = nn.ModuleList(layerList)

    def forward(self, x):
        for index, layer in enumerate(self.layers):
            x = layer(x)
            if index != len(self.layers) - 1:
                x = torch.relu(x)
            if index == 0:
                x = self.dropout(x)

        if self.tanh:
            x = torch.tanh(x)
        if self.softmax:
            x = torch.softmax(x, dim=0)
        if self.relu:
            x = torch.relu(x)
        if self.sigmoid:
            x = torch.sigmoid(x)
        if self.taylor_simple:
            x = torch.div(1 ,torch.add(1, torch.relu(x)))
        if self.pow2_activation:
            x = torch.div(1, torch.add(1, torch.pow(x, 2)))
        if self.double_relu:
            # todo: implement in createMinizincFunctions
            x = torch.clamp(x, 0, 1)
        return x

    def createMiniZincFunctions(self, paramsIn, paramsOut, fileout, tag=""):
        # netlogo variables tend to use invalid minizinc signs. We replace them by underscores or remove them
        def remove_invalid_mzn_chars(parameterFields):
            # first char can't be a number
            parameterFields = ["v" + el if el[0].isnumeric() else el for el in parameterFields]
            parameterFields = [el.replace("-", "_") for el in parameterFields]
            parameterFields = [el.replace(".", "_") for el in parameterFields]
            parameterFields = [el.replace(",", "_") for el in parameterFields]
            parameterFields = [el.replace("(", "") for el in parameterFields]
            parameterFields = [el.replace(")", "") for el in parameterFields]
            parameterFields = [el.replace("%", "") for el in parameterFields]
            return parameterFields

        paramsIn = remove_invalid_mzn_chars(paramsIn)
        paramsOut = remove_invalid_mzn_chars(paramsOut)

        stringOut = "% auto generated file, representing a neural network\n"
        stringOut += "% features in: {}\n% features out: {}\n% layerCount: {}\n% layerWidth: {}\n\n".format(
            paramsIn, paramsOut, self.hiddenLayers, self.hiddenLayerSize
        )

        stringOut += "% use these to access output parameters\n"

        for paramOut in paramsOut:
            varRange = "0.0..1.0" if self.tanh else "float"

            stringOut += "array[Time] of var {varRange}: {paramOut};\n".format(varRange=varRange, paramOut=paramOut)

        stringOut += "\n\n"

        def hiddenLayerRepresentation(linearLayer, inputs, i, relu=False):
            nodeNames = []
            nodeConstraints = ""
            for f1_node in range(linearLayer.out_features):
                # define variable name of the node
                nodeName = "n_{layer}_{node}".format(layer=i, node=f1_node) + tag
                nodeConstraints += "array[Time] of var float: {nodeName};\n".format(nodeName=nodeName)

                # define variable value considering no relu
                nodeNoMax = ""
                for ii, paramIn in enumerate(inputs):
                    if ii != 0:
                        nodeNoMax += " + "
                    nodeNoMax += "{A} * {paramIn}[t]".format(A=float(linearLayer.weight[f1_node, ii]), paramIn=paramIn)
                nodeNoMax = "({nodeRep} + {bias})".format(nodeRep=nodeNoMax, bias=float(linearLayer.bias[f1_node]))
                if relu:
                    nodeRep = "max({nodeNoMax}, 0)".format(nodeNoMax=nodeNoMax)
                else:
                    nodeRep = nodeNoMax

                # add node constraint
                nodeConstraints += "constraint forall(t in Time) ({nodeName}[t] = {nodeRep});\n".format(nodeName=nodeName, nodeRep=nodeRep)

                nodeNames.append(nodeName)
            return nodeConstraints, nodeNames

        stringOut += "% Node constraints\n"

        nodeNames = paramsIn
        for i, layer in enumerate(self.layers):
            stringOut += "% Layer {}\n".format(i)
            # do relu if not at last layer
            relu = i != len(self.layers) - 1

            nodeConstraints, nodeNames = hiddenLayerRepresentation(layer, nodeNames, i, relu)
            stringOut += nodeConstraints

        stringOut += "% Add activation function\n"
        if self.tanh:
            # behavior for tanh
            for i, paramOut in enumerate(paramsOut):
                # out values equal tanh put around the last nodes in nodeNames
                if self.relu:
                    stringOut += "constraint forall(t in Time) ({paramOut}[t] = max(tanh({lastNode}[t]), 0));\n".format(
                    paramOut=paramOut, lastNode=nodeNames[i])
                else:
                    stringOut += "constraint forall(t in Time) ({paramOut}[t] = tanh({lastNode}[t]));\n".format(
                    paramOut=paramOut, lastNode=nodeNames[i])
        elif self.sigmoid:
            # behavior for sigmoid
            # sigmoid(x) = 1 / (1 + exp(-x))
            for i, paramOut in enumerate(paramsOut):
                stringOut += "constraint forall(t in Time) ({paramOut}[t] * (1 + exp(-{lastNode}[t])) = 1.0);\n".format(
                    paramOut=paramOut, lastNode=nodeNames[i])
        elif self.softmax:
            # behavior for softmax
            # softmax(x_i) = exp(x_i) / sum([exp(x_j) | x_j in X])
            softmaxSumVarName = "expsum"+tag
            stringOut += "array[Time] of var 0.0..infinity: {softmaxSumVarName};\n".format(softmaxSumVarName=softmaxSumVarName)
            sumRep = ""
            for i, paramOut in enumerate(paramsOut):
                # define sum
                if i != 0:
                    sumRep += " + "
                sumRep += "{paramOut}[t]".format(paramOut=paramOut)

                stringOut += "constraint forall(t in Time) " \
                             "({paramOut}[t] * {softmaxSumVarName}[t] = exp({lastNode}[t]));\n".format(
                                paramOut=paramOut, softmaxSumVarName=softmaxSumVarName, lastNode=nodeNames[i])

            stringOut += "constraint forall(t in Time) ({softmaxSumVarName}[t] = {sumRep});\n".format(
                softmaxSumVarName=softmaxSumVarName, sumRep=sumRep)

        elif self.relu:
            # behavior for relu
            for i, paramOut in enumerate(paramsOut):
                # relu(x) = max(x,0)
                stringOut += "constraint forall(t in Time) ({paramOut}[t] = max({lastNode}[t], 0));\n".format(
                    paramOut=paramOut, lastNode=nodeNames[i])

        elif self.taylor_simple:
            # simple 1 layered taylor approximation of 1 / (1 + exp(-x))
            for i, paramOut in enumerate(paramsOut):
                stringOut += f"constraint forall(t in Time) ({paramOut}[t] = 1 / (1 + max({nodeNames[i]}[t], 0)));\n"

        elif self.pow2_activation:
            # simple 1 activation that uses 1 / (1 + x^2)
            for i, paramOut in enumerate(paramsOut):
                stringOut += f"constraint forall(t in Time) ({paramOut}[t] = 1 / (1 + ({nodeNames[i]}[t] * {nodeNames[i]}[t]));\n"

        else:
            for i, paramOut in enumerate(paramsOut):
                stringOut += "constraint forall(t in Time) ({paramOut}[t] = {lastNode}[t]);\n".format(
                    paramOut=paramOut, lastNode=nodeNames[i])

        with open(fileout, "w") as file:
            file.write(stringOut)
        print("Minizinc NN Out: {}".format(fileout))


class LinearNetTanh(LinearNet):
    # outputs between -1 and 1
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, tanh=True)


class LinearNetSigmoid(LinearNet):
    # outputs between 0 and 1
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, sigmoid=True)


class LinearNetSoftmax(LinearNet):
    # outputs sum to 1
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, softmax=True)


class LinearNetRelu(LinearNet):
    # all outputs >= 0
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, relu=True)


class LinearNetTanhRelu(LinearNet):
    # outputs between 0 and 1
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, tanh=True, relu=True)


class LinearNetTaylorSimple(LinearNet):
    # outputs between 0 and 1
    # f(x) = 1 / (1 + max(0,x))
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, taylor_simple=True)


class LinearNetPow2(LinearNet):
    # outputs between 0 and 1
    # f(x) = 1 / (1 + x^2)
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, pow2_activation=True)


class LinearDoubleRelu(LinearNet):
    # outputs between 0 and 1
    # f(x) = min(1, max(x, 0))
    def __init__(self, n_in, n_out, hiddenLayers=3, hiddenLayerSize=None, p_dropout=p_dropout_def):
        super().__init__(n_in, n_out, hiddenLayers, hiddenLayerSize, p_dropout, double_relu=True)
