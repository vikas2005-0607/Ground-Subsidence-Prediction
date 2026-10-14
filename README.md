# Ground Subsidence Prediction Using the Influence Function Method

**MATLAB-Based Modelling | Mining Engineering | Ground Deformation Analysis**

## Overview

This project focuses on predicting ground subsidence caused by underground mining using an influence-function-based modelling approach. Developed in MATLAB, it estimates surface deformation over a predefined mining panel and provides visualizations to help analyze the spatial distribution of subsidence.

The project includes a standalone MATLAB implementation and a generalized model with a graphical user interface (GUI), enabling users to configure model parameters, visualize predicted deformation, export results, and compare predictions against observed data.

## Objectives

- Estimate ground subsidence over a mining panel using an influence-function approach.
- Analyze the spatial distribution of predicted surface deformation.
- Visualize results through 3D surfaces and 2D contour plots.
- Calculate additional ground-deformation parameters using the generalized model.
- Provide a GUI for simulation, visualization, data export, and model validation.

## Project Structure

| File | Description |
|---|---|
| `matlab_proj.m` | Standalone script that performs subsidence calculations for predefined mining-panel parameters and generates 3D and 2D plots. |
| `point_to_line.m` | Helper function that calculates the perpendicular distance between a point and a line in 2D or 3D coordinates. |
| `subsidence_model.m` | Generalized model that calculates subsidence and additional deformation parameters, including horizontal displacement, slope, and strain. |
| `subsidenceGUI.m` | Graphical user interface for configuring simulations, viewing plots, exporting CSV data, and validating predictions against observed measurements. |
| `Subsidence_Influence_Function.pdf` | Supporting reference document for the project. |

## Methodology

The modelling workflow follows these main steps:

1. **Parameter definition:** Specify mining depth, panel dimensions, draw angle, and other model parameters.
2. **Panel geometry:** Define the mining-panel boundaries and construct a grid of surface observation points.
3. **Influence-function calculation:** Sample influence points using concentric rings and angular divisions to estimate their contributions to subsidence.
4. **Boundary correction:** Use geometric distances to account for the influence of mining-panel boundaries.
5. **Deformation estimation:** Calculate subsidence and, in the generalized model, additional ground-deformation parameters.
6. **Visualization and validation:** Generate graphical outputs, export numerical results, and compare model predictions with observed data when available.

## Key Features

- MATLAB-based numerical modelling.
- 3D subsidence surface visualization.
- 2D subsidence contour mapping.
- GUI-based parameter configuration and simulation.
- Horizontal displacement, slope, and strain analysis in the generalized model.
- CSV export of calculated results.
- Model validation using RMSE, MAE, and R² when observed data are supplied.

## How to Run

### Option 1: Run the GUI

1. Clone or download this repository.
2. Open MATLAB.
3. Set the repository folder as the current working directory.
4. Ensure all required `.m` files are in the same folder.
5. Run the following command:

```matlab
subsidenceGUI
```

6. Enter the required parameters and run the simulation.

### Option 2: Run the Standalone Script

Run:

```matlab
matlab_proj
```

This executes the original calculation workflow and generates the corresponding 3D subsidence surface and 2D contour plot.

**Note:** `matlab_proj.m` and `subsidence_model.m` are separate implementations. Their outputs may differ because of differences in their calculation and boundary-correction approaches.

## Technologies Used

- **MATLAB** — Numerical computation, modelling, and visualization.
- **Influence Function Method** — Estimation of mining-induced ground subsidence.
- **Numerical Analysis** — Evaluation of deformation across a surface grid.
- **Data Visualization** — 3D surfaces, contour plots, and displacement visualizations.

## Model Validation

The GUI supports comparison of predicted subsidence against observed measurements using:

- **RMSE:** Root Mean Square Error.
- **MAE:** Mean Absolute Error.
- **R²:** Coefficient of determination.

These metrics can help evaluate model performance when suitable observed data are available. Their values depend on the supplied data and the model configuration.

## Applications

The project can support academic study and preliminary analysis of:

- Mining-induced ground subsidence.
- Surface deformation over underground mining panels.
- Spatial patterns of subsidence and related deformation.
- Numerical modelling methods in mining engineering.

## Limitations

- Predictions depend on the selected model parameters and assumptions.
- The standalone and generalized implementations may produce different results.
- Reliable validation requires suitable field measurements or reference data.
- Results should not be treated as certified engineering predictions without independent verification and calibration.

## Future Improvements

- Calibration against field-measured subsidence data.
- Sensitivity analysis for important model parameters.
- Comparison with alternative subsidence prediction methods.
- Improved graphical reporting and automated result summaries.

## Author

**Vikas Modanwal**  
B.Tech. — Mining Engineering  
Indian Institute of Technology (Indian School of Mines), Dhanbad
results to engineering decisions.*
