# Flexible Enterprise Optimization With Constraint Programming

This repository contains experimental code for applying constraint programming to enterprise simulation. More details can be read [here](http://resolver.tudelft.nl/uuid:7d67baa1-6e28-407a-9cab-9cd67e592d8e). The experiments are based on how enterprise models can be "solved" through CP.

The CP language used is [MiniZinc](https://www.minizinc.org/). [MiniBrass](http://isse-augsburg.github.io/minibrass/), an extension to MiniZinc, was used to implement soft constraints. For solving instances regarding a neural network embedding (cases from NetlogoNN), I recommend using [JaCoP](https://github.com/radsz/jacop) as solver.
Python was used for writing experimental scripts. Simulation models were made in [NetLogo](https://ccl.northwestern.edu/netlogo/). A combination of [PyTorch](https://pytorch.org/) with [CUDA](https://developer.nvidia.com/cuda-python) was used to design and train Neural Networks.

Code is free to use for further experimenting, however, if you do so, please cite [my thesis](http://resolver.tudelft.nl/uuid:7d67baa1-6e28-407a-9cab-9cd67e592d8e).
```
@article{2021_Andringa_,
	author = {Andringa, S.P.E},
	title = {Applying Constraint Programming To Enterprise Modelling},
	publisher = {Delft University of Technology},
	year = {2021}
}
```


### Content

This repository is divided into three categories.

1. Petri-nets. Here, petri net models based on enterprise models are solved through MiniZinc.
2. Netlogo simulation + Neural network. Here, neural networks are trained on NetLogo simulation models. Then, these neural networks are embedded into MiniZinc, and used to find solutions to it in a multi objective sense.
3. Other experiments. Here, a simple supply chain of a pizza restaurant, as well as a hospital case (FHCC) that was based on a DEMO model, are formulated as a CP model. These experiments are not dicussed in the thesis.

### Abstract

Simulation-optimization is often used in enterprise decision-making processes, both operational and tactical. This paper shows how an intuitive mapping from descriptive problem to optimization model can be realized with Constraint Programming (CP).  It shows how a CP model can be constructed given a simulation model and a set of business goals.  The approach is to train a neural network (NN) on simulation model inputs and outputs, and embed the NN into the CP model together with a set of soft constraints that represent business goals.  We study this novel simulation-optimization approach through a set of experiments, finding that it is flexible to changing multiple objectives simultaneously, allows an intuitive mapping from business goals expressed in natural language to a formal model suitable for state-of-the-art optimization solvers, and is realizable for diverse managerial problems.
