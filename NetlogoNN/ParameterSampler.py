
import numpy as np
from abc import ABC, abstractmethod
from scipy.stats import qmc


class ParameterSampler(ABC):
    def __init__(self, simulation_parameters_in_range):
        self.simulation_parameters_in_range = simulation_parameters_in_range

    @abstractmethod
    def get_sequence(self, amount, dimensions):
        """
        Obtains a sequence of length 'amount', where each sample has dimension 'dimensions'.
        The first 'start_index' samples are skipped, as these are assumed to have been already generated
        """
        pass

    def create_parameter_combinations(self, amount):
        dimensions = len(self.simulation_parameters_in_range)
        sequence = self.get_sequence(amount, dimensions)
        assert (len(sequence) == amount)
        parameter_names = self.simulation_parameters_in_range.keys()
        result = [self.scale_sequence_with_parameters(sample, parameter_names) for sample in sequence]
        return result

    def scale_sequence_with_parameters(self, sample, parameter_names):
        parameter_combination = {}
        for i, parameter_name in enumerate(parameter_names):
            parameter_range = self.simulation_parameters_in_range[parameter_name]
            if len(parameter_range) == 1:
                # parameter is fixed
                parameter_combination[parameter_name] = parameter_range[0]
            else:
                # scale range wrt value of sobol sample
                if type(parameter_range[0]) == str or len(parameter_range) > 2:
                    def add_quation_if_string(x):
                        if type(x) == str:
                            return f"\"{x}\""
                        return x
                    # discrete categorical values if the type is string or the range has 2 or more entries
                    parameter_combination[parameter_name] = add_quation_if_string(parameter_range[
                        int(np.round(len(parameter_range) * sample[i])) - 1
                    ])
                else:
                    # numerical value
                    parameter_combination[parameter_name] = parameter_range[0] + sample[i] * (
                            parameter_range[1] - parameter_range[0])

                    if type(parameter_range[0]) == int:
                        # rounding procedure if the parameter is an int
                        parameter_combination[parameter_name] = int(np.round(parameter_combination[parameter_name]))
        return parameter_combination


class ParameterSamplerUniform(ParameterSampler):
    def get_sequence(self, amount, dimensions):
        # sequence is random
        return np.random.uniform(size=[amount, dimensions])


class ParameterSamplerSobol(ParameterSampler):
    def get_sequence(self, amount, dimensions):
        # exponent to determine the max length of the sequence (to generate a sobol sequence of length 2^exponent)
        exponent = int(np.ceil(np.log2(amount)))

        # define the entire sobol sequence
        sampler_sobol = qmc.Sobol(d=dimensions, scramble=False)
        sobol_sequence_all = sampler_sobol.random_base2(m=exponent)

        # take subset of the sequence which we are about to sample, such that 'amount' samples are generated
        sobol_sequence_subset = sobol_sequence_all[:amount]
        return sobol_sequence_subset


class ParameterSamplerHalton(ParameterSampler):
    def get_sequence(self, amount, dimensions):
        sampler = qmc.Halton(d=dimensions, scramble=False)
        sequence_all = sampler.random(n=amount)
        sequence_subset = sequence_all[:amount]
        return sequence_subset

