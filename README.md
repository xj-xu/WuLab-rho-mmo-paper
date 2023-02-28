# wu-lab-rho-mmo-paper

[![DOI](https://zenodo.org/badge/doi/Tong2023paperlink.svg)](http://dx.doi.org/) <br/>
**`wu-lab-rho-mmo-paper` is an open-source repository for a collection of MATLAB(R) scripts used for analysis in: Tong et al. (2023) Periodicity, mixed-mode oscillations, and multiple timescales in a phosphoinositide-Rho GTPase network. For further details on the methods of analysis, please refer to the methods section in the manuscript that can be found in the DOI link above.** <br/>

Written by [XJ Xu](https://github.com/xj-xu).<br/>
Last updated February 28, 2023.

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
`wu-lab-rho-mmo-paper` takes in a pre-processed data in the form of a .xlsx spreadsheet. An example dataset `Rho-demo-data.xlsx` is included for demonstration. Briefly, to obtain such a dataset, an image stack is acquired during total internal fluorescence (TIRF) time-lapse imaging of active GTP-bound RhoA pulses as observed via the fluorescently tagged rGBD sensor. A region of interest (ROI) is chosen on the cell - typically a 3x3 &mu;M square - for quantification of the average ROI fluorescence intensity as a function of time. The example spreadsheet has 4 sheets to store the necessary information and each column in the respective sheets correspond to a given ROI (or cell).
| time series | time interval | perturbation | meta |
|--|--| --| --|
| Data points of fluorescence intensity averaged over the pixels contained in the ROI | Image acquisition interval in seconds, e.g. one frame acquired every 4 seconds. | Image stack frame number for addition of pharmacological perturbations, such as Nocodazole. |  Info of date and condition of experiment, location of raw data etc  |

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
`OS_plot_1c.m` &rarr; plots the raw time series in one color. <br/>
![Rho-demo-data xlsx_1_plot_1c_raw](https://user-images.githubusercontent.com/33842377/221711043-b4c2473d-0141-4f4c-9a9f-0e297de8d258.png)

`OS_plot_1c_3d.m` &rarr; traces the peak amplitutde $I, I+n, I+2n$. <br/>
![Rho-demo-data xlsx_1_1c_3d](https://user-images.githubusercontent.com/33842377/221984463-7c972a18-40a1-4081-91cf-f1d7cbf4d496.png)

`OS_poincare_v4.m` &rarr; plots the peaks; period return map; and period of peaks over time, which is useful for identifying period doubling events. <br/>
![Rho-demo-data xlsx_1_p2p__](https://user-images.githubusercontent.com/33842377/221711369-da72219b-0f61-4ba8-b19f-aaf07ff8330b.png)

`OS_wavelet_v3_yPeriod.m` &rarr; performs a 1-D continuous wavlet transform on the oscillatory Rho signal $x(t)$ <br/>

$$ W(t,s) \equiv \int_{-\infty}^\infty \frac{1}{s} \psi^*\left(\frac{u-t}{s}\right) x(u) du$$

where $\psi(t)$ is the analyzing function - wavelet; $s$ is the scale so $1/s$ effectively serve as the normalization factor in place of the typical $1/\sqrt{s}$ seen in Fourier transforms. The analytic Morse wavelet is utilized and is given by the following generalized form in frequency $\omega$ domain. <br/>

$$ \Psi_{\beta,\gamma}(\omega) = U(\omega) a_{\beta,\gamma} \omega^\beta e^{-\omega^\gamma} $$

where $U$ is the Heaviside step function; $a$ is a normalization constant; while $\beta$ and $\gamma$ are the 'decay' and symmetry parameters respectively. The sampling frequency is set by the experimental image acquisition interval. The power spectrum of oscillation period is plotted alongside the same oscillation trace. <br/>
![Rho-demo-data xlsx_1_wavelet](https://user-images.githubusercontent.com/33842377/221984199-98a97417-a08f-4d71-aba6-a60478e30f03.png)

`OS_Xcorr_v3.m` &rarr; computes the cross-correlation of two input signals. In the demo case, as a single input is given, the auto-correlation is effectively computed to show the presence of periodicity and its duration. <br/>
![Rho-demo-data xlsx_1_Xcorr_](https://user-images.githubusercontent.com/33842377/222005955-05a211a5-f672-4643-b131-aa3f05222176.png)

`OS_fft.m` &rarr; fast Fourier transform <br/>
![Rho-demo-data xlsx_1_fft](https://user-images.githubusercontent.com/33842377/222009245-422d61e4-1a4c-4f34-ac94-d54f5d27a899.png)


More information
================
* For more information about how each function is implemented, please refer to the source code docstrings in  `/src` . 
* Contact [XJ](xj.xu@yale.edu) if issues with this version of the repository arise.
> All rights and permissions belong to <br/>
> [Wu Lab, Yale University](https://medicine.yale.edu/lab/wu/) <br/>
> February 26, 2023
