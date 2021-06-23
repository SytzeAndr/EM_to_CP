# Applying Constraint Programming To Enterprise Modelling

This repository contains supplementary code regarding my Master Thesis in Computer Science at the [Algorithmics Group](https://www.tudelft.nl/ewi/over-de-faculteit/afdelingen/software-technology/algorithmics/) ([Software Technology Department](https://www.tudelft.nl/ewi/over-de-faculteit/afdelingen/software-technology), [EEMCS](https://www.tudelft.nl/ewi), [TU Delft](https://www.tudelft.nl/)) under supervision of [Dr. Neil Yorke-Smith](https://homepage.tudelft.nl/0p6y8/), to be defended the 3th of July 2021. 
The thesis can be read [here](TODO_ADD_LINK), and should be referred to for more details. 
The thesis focuses on how constraint programming (CP) can be applied to enterprise modelling (EM).
The experiments are based on how enterprise models can be "solved" through CP.

The CP language used is [MiniZinc](https://www.minizinc.org/). [MiniBrass](http://isse-augsburg.github.io/minibrass/), an extension to MiniZinc, was used to implement soft constraints. For solving instances regarding a neural network embedding (cases from NetlogoNN), I recommend using [JaCoP](https://github.com/radsz/jacop) as solver.
Python was used for writing experimental scripts. Simulation models were made in [NetLogo](https://ccl.northwestern.edu/netlogo/). A combination of [PyTorch](https://pytorch.org/) with [CUDA](https://developer.nvidia.com/cuda-python) was used to design and train Neural Networks.

Feel free to use any code here for experiments, however, if you do so, please cite [my thesis](TODO_ADD_LINK).

### Content

This repository is divided into three categories.

1. Petri-nets. Here, petri net models based on enterprise models are solved through MiniZinc.
2. Netlogo simulation + Neural network. Here, neural networks are trained on NetLogo simulation models. Then, these neural networks are embedded into MiniZinc, and used to find solutions to it in a multi objective sense.
3. Other experiments. Here, a simple supply chain of a pizza restaurant, as well as a hospital case (FHCC) that was based on a DEMO model, are formulated as a CP model. These experiments are not dicussed in the thesis.

### Abstract

Enterprise Modelling (EM) is the process of producing models, which in turn can be used to support understanding, analysis, (re)design, reasoning, control and learning about various aspects of an enterprise. Various EM techniques and languages exist, and are often supported by computational tools, in particular simulation. The goal of this thesis is to study the effects and advantages of applying constraint programming (CP) to EM. To the best of my knowledge, no previous study has explicitly combined EM and CP. On the topic of applying CP to EM, this thesis explains where it can be applied, as well as its requirements and advantages. This thesis explains a possible approach where a neural network, trained on a simulation model that represents an enterprise model, is embedded into a constraint program. This approach was supported with experiments, that showed it is possible to embed typical business objectives in a constraint program and find solutions to it in a multi-objective context. The main conclusion is that due to CP being a declarative programming technique, business constraints and goals can be effectively modelled into a constraint program, making the approach understandable and intuitive for business analysts to use. This thesis argues alternative approaches to apply CP to EM can also be realised. Some of these, as well as improvements over the proposed method, are also discussed.
