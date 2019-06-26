# STS_SB
Stability Basins for Sit-to-Stand

This repository contains MATLAB code for generating the results found in the paper *cite paper here*

To use this code, first download the Sit-to-Stand dataset here: *add link to dataset*.

Then, download CORA 2018: https://tumcps.github.io/CORA/

The function run_all.m will run through the full pipeline and generate results.
We recommend calling `run_all('parallel')` to utilize MATLAB's parfor toolbox and expedite the process.

Once finished, call `display_results` to display the accuracy of each of the tested SB methods onscreen.
Alternatively, `display_results('presaved')` will display the presaved results included in this repository.
