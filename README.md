# Replication Package: The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax

Authors: Elisa Casi, Evelina Gavrilova, David Murphy, and Floris Zoutman

This repository contains the replication package for the paper "The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax" published in the American Economic Journal.

## Overview

This paper studies how closing loopholes in dividend withholding taxation affects financial markets. The study analyzes the effects of a reform in Denmark that reduced opportunities for dividend tax arbitrage, examining patterns in stock lending around ex-dividend dates and the impact on government tax revenue.

## Directory Structure

- `0_raw_data/`: Contains input data files
  - `DWT Revenue Data/`: Dividend withholding tax revenue data
- `1_transformation_code/`: Stata scripts for data transformation
- `2_final_data/`: Directory for transformed data (proprietary, not included)
- `3_analysis_code/`: R and Stata scripts for analysis and figure/table generation
- `4_output/`: Output files including figures, tables, and tex files
- `ado/`: Stata library/package directory (contains required custom Stata packages)
- `requirements/`: Requirements files for software dependencies

## Data Sources

This replication package uses data from the following sources:

1. **Stock Market Data**: From Compustat and Markit (proprietary)
   - Stock returns, prices, volumes, and company information
   - Stock lending data (short interest, utilization rates, etc.)

2. **Dividend Withholding Tax Revenue Data**: From national tax authorities
   - Located in `0_raw_data/DWT Revenue Data/`

### Proprietary Data

Much of the raw data used in this analysis is proprietary. To fully replicate the study, researchers will need to:

1. Obtain access to Compustat and Markit databases
2. Extract country-specific data for the European countries in the study
3. Save these files as country-code CSV files (e.g., `dnk.csv` for Denmark) in the `0_raw_data/` directory

## Software Requirements

This replication package uses the following software:

1. **Stata** (version 15 or higher)
   - Required packages are included in the `ado/` directory
   
2. **R** (version 4.0 or higher)
   - Required packages are listed in `requirements/r_requirements.txt`

3. **Python** (version 3.8 or higher, optional)
   - Required packages are listed in `requirements/python_requirements.txt`

## Replication Workflow

Follow these steps to replicate the results:

### 1. Setup

1. Install required software (Stata, R, Python)
2. Install required packages:
   - R: `install.packages(readLines("requirements/r_requirements.txt"))`
   - Python: `pip install -r requirements/python_requirements.txt`
3. Set the base path in the configuration files:
   - For Stata: Edit `config.do`
   - For R: Edit `config.R`

### 2. Data Preparation

1. Place the proprietary data files in the `0_raw_data/` directory
2. Run the data transformation code:
   ```
   cd 1_transformation_code/
   stata -b do 0_alltodos_code.do
   ```

### 3. Analysis

1. Run the analysis code for tables and figures:
   ```
   cd 3_analysis_code/
   stata -b do Table3_TableC2_Table4_TableC1_Figure1.do
   Rscript Figure10_Table5_T.R
   stata -b do FigureC10.do
   ```

2. Check the results in the `4_output/` directory

## Description of Code Files

### Transformation Code

- `0_alltodos_code.do`: Master script that runs all transformation steps
- `1_import_data.do`: Imports raw CSV data and saves as Stata files
- `4_appending.do`: Combines data from multiple countries
- `frag_*_*.do`: Country-specific transformation fragments

### Analysis Code

- `Table3_TableC2_Table4_TableC1_Figure1.do`: Creates main tables and figures
- `Figure10_Table5_T.R`: Creates Figure 10 and Table 5 using synthetic difference-in-differences
- `FigureC10.do`: Creates Figure C10 in the appendix
- `Preparing_DWTRevenueData.do`: Prepares dividend withholding tax revenue data

## Test Scripts

To validate the replication, run:
```
cd tests/
./run_tests.sh
```

This will check that all outputs match expected results.

## Contact

For questions about this replication package, please contact the authors:

- David Murphy: [email]
- Floris Zoutman: [email]
- Elisa Casi: [email]
- Evelina Gavrilova: [email]

## License

This code is provided under [LICENSE]. The data is subject to the terms and conditions of the data providers.