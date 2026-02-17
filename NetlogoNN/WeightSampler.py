import numpy as np
from scipy.stats import qmc


def sample_montgomery_sequence(n, d):
    """
    Special thanks to Aaron Montgomery.
    see: https://math.stackexchange.com/questions/4521470/quasi-monte-carlo-sampling-with-a-summation-constraint
    """
    num_samples_extended = np.math.factorial(d - 1) * n

    sampler = qmc.Halton(d=d - 1, scramble=False)
    sequence_halton = sampler.random(num_samples_extended)

    sequence_sums = [sum(x) for x in sequence_halton]
    last_dimension = np.subtract(1, sequence_sums)

    new_sequence = list(zip(sequence_halton, last_dimension))
    new_sequence = [np.append(x[0], x[1]) for x in new_sequence if x[1] >= 0][:n]

    return new_sequence

