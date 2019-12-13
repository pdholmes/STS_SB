# STS_SB

> Stability Basins for characterizing stability of sit-to-stand control strategies

> paper: [https://arxiv.org/abs/1908.01876](https://arxiv.org/abs/1908.01876)

> keywords: Sit-to-Stand, Biomechanics, Stability

## Overview

This repository contains MATLAB code for generating and validating Stability Basins (SB) for sit-to-stand (STS).

SBs are a model-based method for determining the set of perturbations that would cause an individual to step, sit, or fall during STS under a given motor control strategy. The SB corresponds to the set of body configurations that do not lead to failure during STS, and characterizes stability throughout the duration of the motion

We conducted a perturbative STS experiment (dataset included in repo) where subjects were pulled by motor-driven cables during STS.
We had subjects perform STS using three different strategies: Natural, Momentum-Transfer, and Quasi-Static.
Subjects sometimes stepped or sat in response to perturbation, as demonstrated in the figure below:

![](https://github.com/pdholmes/STS_SB/blob/master/images/models.png "STS cartoon")

Individualized biomechanical models of STS are constructed for each subject, and kinematic data is translated into trajectories of these models.
Subject and strategy specific input bounds are formed from data.
Then, we use a reachability toolbox called CORA to compute the SB for a given subject and STS strategy.
The SB is the *backwards reachable set* of a standing set, under the model's dynamics and input bounds:

![](https://github.com/pdholmes/STS_SB/blob/master/images/backprop_x.gif "BRS")

Finally, we evaluate the accuracy of SBs by using them to predict whether or not an STS trial will succeed or fail (e.g., the subject will take a step or sit).
These predictions are compared to experimentally observed results.

![](https://github.com/pdholmes/STS_SB/blob/master/images/basin_step.png "SB predicts step will occur")

## Installation
### MATLAB Version
- R2019b
### Clone
- Clone this repo to your local machine using `https://github.com/pdholmes/STS_SB`
### Downloads
- To use this code, first download CORA 2018: https://tumcps.github.io/CORA/
- More information about CORA and how to use it may be found here: https://tumcps.github.io/CORA/data/Cora2018Manual.pdf

- We also recommend using MOSEK (https://www.mosek.com) in place of MATLAB's default linear program solver `linprog`, though this is not necessary.
### Setting Path
- Ensure that CORA (and MOSEK, if downloaded) are on the MATLAB path. For example, use the MATLAB command `addpath(genpath('.../path/to/CORA_2018'));`
## GUI
- To simply view presaved results of the SB evaluation in a table, use `display_results()`.
- A GUI for visualizing the STS trials, the SBs, and their predictions is provided. To run this GUI, use `animateSTS`.
![](https://github.com/pdholmes/STS_SB/blob/master/images/GUI_example.png "GUI for visualizing STS results")
## Generating Results from Scratch
If you would like to run the full pipeline and generate the results from scratch on your own machine:
1) Run `setPaths()`.
2) Use `run_all()`. We recommend calling `run_all('parallel')` to utilize MATLAB's parfor toolbox and expedite the process.
3) Uncomment line 5 in `display_results` and line 5 in `animateSTS` to use your locally generated results instead of the presaved results.
4) Call `display_results` or `animateSTS` to display the accuracy of each of the tested SB methods onscreen.
## Team
- Patrick Holmes (PhD Candidate, Mechanical Engineering, University of Michigan)
- Shannon Danforth (PhD Candidate, Mechanical Engineering, University of Michigan)
- Xiao-Yu Fu (PhD Candidate, Mechanical Engineering, University of Michigan)
- Talia Y. Moore (Assistant Research Scientist, Robotics Institute, University of Michigan)
- Ram Vasudevan (Assistant Professor, Mechanical Engineering and Robotics Institute, University of Michigan)
## License
- Code licensed under [BSD3](https://opensource.org/licenses/BSD-3-Clause)
- STS Data licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
