# Replication Package: The Big Short (Interest)

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
- `ado/`: Stata library/package directory with all required packages
- `requirements/`: Requirements files for software dependencies

## Data Sources

This replication package uses data from the following sources:

1. **Stock Market Data**: From Compustat and Markit (proprietary)
   - Stock returns, prices, volumes, and company information
   - Stock lending data (short interest, utilization rates, etc.)

2. **Dividend Withholding Tax Revenue Data**: From national tax authorities
   - Located in `0_raw_data/DWT Revenue Data/`

See [DATA_ACQUISITION.md](DATA_ACQUISITION.md) for detailed instructions on obtaining and processing the proprietary data.

## Software Requirements

This replication package uses the following software:

1. **Stata** (version 15 or higher)
   - Required packages are included in the `ado/` directory:
     - `reghdfe`: For fixed-effects regression
     - `did_imputation`/`did_switching`: For difference-in-differences analysis
     - `estout`/`esttab`: For table creation
     - `coefplot`: For coefficient plots
     - `ftools`: For data manipulation
   
   While we include these packages in the `ado/` directory, some dependencies might be missing. If you encounter errors, install the complete packages:
   ```stata
   ssc install reghdfe
   ssc install estout
   ssc install coefplot
   ssc install ftools
   ```
   
2. **R** (version 4.0 or higher)
   - Required packages:
     - `synthdid` (version 0.0.2): For synthetic difference-in-differences analysis
     - `ggplot2` (version 3.4.0): For plotting
     - `haven` (version 2.5.1): For reading Stata files
     - `gginnards` (version 0.1.1): For modifying ggplots
     - `stargazer` (version 5.2.3): For table creation
   
   Install these packages with:
   ```r
   install.packages(c("synthdid", "ggplot2", "haven", "gginnards", "stargazer"))
   ```
   
   To install specific versions:
   ```r
   # Create a vector of package requirements
   pkgs <- c("synthdid==0.0.2", "ggplot2==3.4.0", "haven==2.5.1", 
             "gginnards==0.1.1", "stargazer==5.2.3")
   
   # Parse package names and versions
   pkg_names <- gsub("==.*$", "", pkgs)
   pkg_versions <- gsub("^.*==", "", pkgs)
   
   # Install each package with specific version
   for(i in seq_along(pkg_names)) {
     devtools::install_version(pkg_names[i], version=pkg_versions[i])
   }
   ```

## Replication Workflow

Follow these steps to replicate the results:

### 1. Setup

1. Clone this repository
2. Set the base path in the configuration files:
   - For Stata: Edit `1_transformation_code/config.do`
   - For R: Edit `3_analysis_code/config.R`

### 2. Data Preparation

1. Place the proprietary data files in the `0_raw_data/` directory (see DATA_ACQUISITION.md)
2. Run the data transformation code:
   ```
   cd 1_transformation_code/
   stata -b do 0_alltodos_code.do
   ```

### 3. Analysis

Run the analysis code for tables and figures:
```
cd 3_analysis_code/
stata -b do Table3_TableC2_Table4_TableC1_Figure1.do
Rscript Figure10_Table5_T.R
```

For detailed testing instructions, see [TESTING_GUIDE.md](TESTING_GUIDE.md).

## Documentation Files

- [DATA_ACQUISITION.md](DATA_ACQUISITION.md): Instructions for obtaining and processing proprietary data
- [DATA_CATALOG.md](DATA_CATALOG.md): Catalog of all data files and variables
- [DATA_FLOW.md](DATA_FLOW.md): Data flow diagram and architecture
- [SCRIPT_DEPENDENCIES.md](SCRIPT_DEPENDENCIES.md): Script dependencies and execution order
- [TESTING_GUIDE.md](TESTING_GUIDE.md): Step-by-step guide for testing

## Contact

For questions about this replication package, please contact:

- David Murphy: David.Murphy@nhh.no
- Floris Zoutman: Floris.Zoutman@nhh.no
- Elisa Casi: Elisa.Casi@nhh.no
- Evelina Gavrilova-Zoutman: Evelina.Gavrilova-Zoutman@nhh.no