import numpy as np


class PetriNet:
    def __init__(self, flowsTo, flowsFrom, P, T, tMax=None, isSoft=False, pObjective=None):
        self.flowsTo = flowsTo
        self.flowsFrom = flowsFrom
        self.P = P
        self.T = T
        self.tMax = tMax
        # if not soft, pObjective is a single value
        # if soft, pObjective is a list of pairs of (P_name, int)
        self.isSoft = isSoft
        self.pObjective = pObjective


    def printStats(self):
        print("node count: {}".format(len(self.P)))
        print("transaction count: {}".format(len(self.T)))
        print("objective: {}".format(self.pObjective))

    def create_dzn(self, filename):
        """
        Creates a minizinc DZN file given a petri net
        :param file_out:
        :param petri_net:
        :return:
        """

        def DZNmapToCollection(mapping, name, isset=False):
            result = name + " = "
            result += "{" if isset else "["
            list_format = list(mapping)
            for index, el in enumerate(list_format):
                result += el
                if index != len(list_format)-1:
                    result += ", "
            result += "}" if isset else "]"
            result += ";\n"
            return result

        dzn_out = ""

        dzn_out += DZNmapToCollection(map(lambda x: x.name, self.P), "P", True)
        dzn_out += DZNmapToCollection(map(lambda x: x.name, self.T), "T", True)

        dzn_out += DZNmapToCollection(map(lambda x: x.name, self.flowsTo), "F_to", True)
        dzn_out += DZNmapToCollection(map(lambda x: x.el_in, self.flowsTo), "F_to_in")
        dzn_out += DZNmapToCollection(map(lambda x: x.el_out, self.flowsTo), "F_to_out")

        dzn_out += DZNmapToCollection(map(lambda x: x.name, self.flowsFrom), "F_from", True)
        dzn_out += DZNmapToCollection(map(lambda x: x.el_in, self.flowsFrom), "F_from_in")
        dzn_out += DZNmapToCollection(map(lambda x: x.el_out, self.flowsFrom), "F_from_out")

        dzn_out += DZNmapToCollection(map(lambda x: str(x.value), self.flowsTo), "F_to_value")
        dzn_out += DZNmapToCollection(map(lambda x: str(x.value), self.flowsFrom), "F_from_value")
        dzn_out += DZNmapToCollection(map(lambda x: str(x.value), self.P), "P_init")

        dzn_out += "TimeMax = " + str(self.tMax) + ";\n"
        if self.isSoft:
            # the objective is a pair of values
            dzn_out += DZNmapToCollection(map(lambda x: "c"+x[0], self.pObjective), "Objectives", True)
            dzn_out += DZNmapToCollection(map(lambda x: x[0], self.pObjective), "P_objective_name", False)
            dzn_out += DZNmapToCollection(map(lambda x: str(x[1]), self.pObjective), "P_objective_value", False)
        else:
            # the objective is some value to maximize
            dzn_out += "P_objective = " + self.pObjective + ";\n"

        # write to file
        file = open(filename, "wt")
        file.write(dzn_out)
        file.close()


class Element:
    def __init__(self, name):
        self.name = name


class Node(Element):
    def __init__(self, name, value):
        self.value = value
        super().__init__(name)


class Transaction(Element):
    def __init__(self, name):
        super().__init__(name)


class Flow:
    def __init__(self, el_in, el_out, value):
        # el_in and el_out should be strings
        self.el_in = el_in
        self.el_out = el_out
        self.name = el_in+el_out
        self.value = value


def generateRandomPetri(layers=3, nodeAvg=2, transAvg=2, variance_scale=1, flowMax = 4, isSoft=False):
    """
    generates a random petri net
    :param layers:
    :param nodeAvg:
    :param transAvg:
    :param variance_scale:
    :return:
    """
    variance_Nodes = nodeAvg * variance_scale
    variance_Trans = transAvg * variance_scale

    # flows to a T
    flowsTo = set()
    # flows from a T
    flowsFrom = set()

    P = set()
    T = set()

    # always have at least one transaction and node per layer
    nodes_per_layer = np.maximum(np.round(np.random.normal(nodeAvg, variance_Nodes, size=layers+1)), 1).astype(int)
    trans_per_layer = np.maximum(np.round(np.random.normal(transAvg, variance_Trans, size=layers)), 1).astype(int)

    nodeCount = np.sum(nodes_per_layer)
    transCount = np.sum(trans_per_layer)

    nodeIndex = 0
    transIndex = 0

    pObjective = None

    # make random connections for each layer
    for layer in range(layers):
        # nodes nodeIndex to nodeIndex + nodeLayer
        nodeLayer = nodes_per_layer[layer]
        # nodes nodeIndex + nodeLayer + 1 to nodeIndex + nodeLayer + nodeLayerNext
        nodeLayerNext = nodes_per_layer[layer+1]
        # transactions transIndex to transIndex + transLayer
        transLayer = trans_per_layer[layer]

        def create_flows(names_in, names_out, flow_vector, reverse=False):
            result = set()

            if not reverse:
                # index ~ flow in, value ~ flow out
                for el_in, el_out in enumerate(flow_vector):
                    new_flow = Flow(names_in[el_in], names_out[el_out], np.random.randint(1, flowMax+1))
                    result.add(new_flow)
            else:
                # index ~ flow out, value ~ flow in
                for el_out, el_in in enumerate(flow_vector):
                    new_flow = Flow(names_in[el_in], names_out[el_out], np.random.randint(1, flowMax+1))
                    result.add(new_flow)
            return result

        # define names of the elements
        namesNodeIn = list(map(lambda x: "p"+str(x), range(nodeIndex, nodeIndex + nodeLayer)))
        namesNodeOut = list(map(lambda x: "p"+str(x), range(nodeIndex + nodeLayer, nodeIndex + nodeLayer + nodeLayerNext)))
        namesTrans = list(map(lambda x: "t"+str(x), range(transIndex, transIndex + transLayer)))

        def flowsByNames(Nin, Nout, namesIn, namesOut):
            # create flows based on the amount of IN and OUT elements,
            # such that each element is connected to at least one flow
            if Nin >= Nout:
                # if we have more IN than OUT, create a flow for every IN such that every OUT is at least covered once
                # first put 0..OUT into a 1 x IN vector
                v = np.zeros(shape=Nin, dtype=int)
                for vi in range(Nin):
                    if vi <= Nout-1:
                        # to make sure that we cover 0..out at least once
                        v[vi] = vi
                    else:
                        # random connections for the remainder
                        v[vi] = np.random.randint(0, Nout)
                # shuffle v
                np.random.shuffle(v)
                # create flows based on v
                return create_flows(names_in=namesIn, names_out=namesOut, flow_vector=v)
            else:
                # if we have more OUT than IN, create a flow for every OUT such that every IN is at least covered once
                # first put 0..IN into a 1 x OUT vector
                v = np.zeros(shape=Nout, dtype=int)
                for vi in range(Nout):
                    if vi <= Nin-1:
                        # to make sure that we cover 0..out at least once
                        v[vi] = vi
                    else:
                        # random connections for the remainder
                        v[vi] = np.random.randint(0, Nin)
                # shuffle v
                np.random.shuffle(v)
                # create flows based on v
                return create_flows(names_in=namesIn, names_out=namesOut, flow_vector=v, reverse=True)

        # add flows to
        flowsTo.update(flowsByNames(Nin=nodeLayer, Nout=transLayer, namesIn=namesNodeIn, namesOut=namesTrans))
        # add flows from
        flowsFrom.update(flowsByNames(Nin=transLayer, Nout=nodeLayerNext, namesIn=namesTrans, namesOut=namesNodeOut))

        # add new P and T objects corresponding to this layer
        Pval = 1 if layer == 0 else 0
        P.update(set(map(lambda x: Node(x, Pval), namesNodeIn)))

        if layer == layers-1:
            # do not skip the last layer of P if we are at the last layer
            P.update(set(map(lambda x: Node(x, 0), namesNodeOut)))
            if isSoft:
                pObjective = list()
                for obj_name in namesNodeOut:
                    # objVal is set at random, but can also be set to 1 or something else
                    objVal = np.random.randint(1, flowMax+1)
                    # objVal = 1
                    pObjective.append((obj_name, objVal))
            else:
                # pick a random objective from the set
                pObjective = np.random.choice(namesNodeOut)

        T.update(set(map(lambda x: Transaction(x), namesTrans)))

        # increment nodeIndex and transIndex
        nodeIndex += nodeLayer
        transIndex += transLayer

    return PetriNet(flowsTo=flowsTo, flowsFrom=flowsFrom, P=P, T=T, tMax=layers*3, pObjective=pObjective, isSoft=isSoft), nodeCount, transCount

