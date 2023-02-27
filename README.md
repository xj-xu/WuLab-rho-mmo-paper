# wu-lab-rho-mmo-paper

[![DOI](https://zenodo.org/badge/doi/TC2023paperlink.svg)](http://dx.doi.org/)
**`wu-lab-rho-mmo-paper` is an open-source repository for a collection of MATLAB(R) scripts used for analysis in: Tong et al. (2023) Periodicity, mixed-mode oscillations, and multiple timescales in a phosphoinositide-Rho GTPase network. For further details on the methods of analysis, please refer to the methods section in the manuscript that can be found in the DOI link above.**

Installation
============

1. Clone the git repository by downloading the ZIP file and set up the directory in a convenient location.
2. Add the `/src` directory to your path in MATLAB.
    - The `toRun.m` script will do this by default.
    - The `addpath(desired_directory)` function can also be called from the command window if you choose to store the `/src`  scripts in another desired directory.

Make sure that your MATLAB(R) (version R2022a or higher) installation is up-to-date and includes:

* [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html) version 9.0 or higher
* [Wavelet Toolbox](https://www.mathworks.com/products/wavelet.html) version 6.1 or higher
* [Curve Fitting Toolbox](https://www.mathworks.com/products/curvefitting.html) version 3.7 or higher

Older versions may function similarly, but since the scripts in this repository are tested using the versions outlined above, it is recommended that the user install the latest stable versions.

Usage
=====
Input
------
`wu-lab-rho-mmo-paper` takes in a pre-processed data in the form of a .xlsx spreadsheet. An example dataset `Rho-demo-data.xlsx` is included for demonstration. Briefly, to obtain such a dataset, an image stack is acquired during total internal fluorescence (TIRF) time-lapse imaging of active GTP-bound RhoA pulses as observed via the fluorescently tagged rGBD sensor. A region of interest (ROI) is chosen on the cell - typically a 3x3 $\mu$M square - for quantification of the average ROI fluorescence intensity as a function of time. The example spreadsheet has 4 sheets to store the necessary information.
| time series | time interval | perturbation | meta |
|--|--| --| --|
| Data points of fluorescence intensity averaged over the pixels contained in the ROI | Image acquisition interval in seconds, e.g. one frame acquired every 4 seconds. | Time point for addition of pharmacological perturbations, such as Nocodazole |  Info of date and condition of experiment, location of raw data etc  |

Demonstration
------
  1. Get the file path and name for the dataset you wish to analyze. For the demonstration, `'Rho-demo-data.xlsx'` is kept in the same directory as the `toRun.m` script.
  2. Run `wu-lab-rho-mmo-paper` on `'Rho-demo-data.xlsx'` by entering the following in the command window:
```matlab
toRun('Rho-demo-data.xlsx');
```
 3. A set of figures are generated and saved in a directory named `/0analysis`. 

Output
------
`OS_plot_1c.m`

> plots the time series in one color



More information
================
* For more information about how each function is implemented, please refer to the source code docstrings in  `/src` . 
* Contact [XJ](xj.xu@yale.edu ) if issues with this version of the repository arise.
> All rights and permissions belong to
> [Wu Lab, Yale University](https://medicine.yale.edu/lab/wu/)
> February 26, 2023