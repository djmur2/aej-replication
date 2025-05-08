# Replication Package Plan for "The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax"

This document outlines the plan for creating a fully reproducible replication package for the AEJ paper.

## 1. Current Structure Analysis

The codebase is organized as follows:

- **0_raw_data/**: Contains input data files (some proprietary data files are missing)
  - DWT Revenue Data/: Contains dividend withholding tax revenue data
- **1_transformation_code/**: Stata scripts for data transformation
  - Country-specific transformation fragments
  - Data preparation scripts
- **2_final_data/**: Directory for transformed data (currently empty/ignored as it contains proprietary data)
- **3_analysis_code/**: R and Stata scripts for analysis and figure/table generation
- **4_output/**: Output files including figures, tables, and tex files
- **ado/**: Stata library/package directory

## 2. Identified Issues

1. **Missing Raw Data**:
   - Country-specific CSV files (aut.csv, bel.csv, etc.) are referenced but not included
   - These appear to be outputs from proprietary databases (Compustat, Markit)

2. **Workflow Documentation**:
   - No clear documentation of the execution order of scripts
   - Path variables are hardcoded with user-specific paths
   - No documentation on required software versions and dependencies

3. **Code Structure**:
   - Multiple fragments across files with unclear documentation
   - Hardcoded file paths that need to be adjusted by replicators

4. **Reproducibility Testing**:
   - No test scripts to validate the reproducibility of the workflow

## 3. Refactoring Plan

### 3.1 Documentation Improvements

1. **Create a comprehensive README.md**:
   - Overview of the paper and replication package
   - Description of data sources and their acquisition (including proprietary data)
   - Detailed workflow for running the replication code
   - Software requirements and versions

2. **Create a data catalog file**:
   - List all input data files, their sources, and how to obtain them
   - Document all intermediate and output data files

3. **Create a script dependency diagram**:
   - Visual representation of the execution order of scripts

### 3.2 Code Refactoring

1. **Fix path handling**:
   - Replace hardcoded paths with relative paths
   - Create a config.do file for Stata to set global paths
   - Create a config.R file for R to set global paths

2. **Standardize entry points**:
   - Create a master script for running the entire replication process
   - Ensure all scripts can run independently with appropriate documentation

3. **Add code documentation**:
   - Add clear comments to all scripts
   - Document the purpose of each fragment file
   - Add section headers to guide the reader

### 3.3 Dependency Management

1. **Create requirements files**:
   - requirements.txt for Python dependencies
   - renv.lock for R dependencies
   - stata.requirements.txt listing required Stata packages

2. **Version pinning**:
   - Pin all dependencies to specific versions
   - Document the specific versions of Stata, R, and Python used

### 3.4 Reproducibility Testing

1. **Create test scripts**:
   - Scripts to validate the outputs against expected results
   - Checks for each step of the workflow

2. **Create a validation report**:
   - Document any differences between the original and reproduced results
   - Explain any expected discrepancies

## 4. Implementation Steps

1. **Documentation Creation**:
   - Write the main README.md file
   - Create the data catalog
   - Document the workflow and script dependencies

2. **Code Refactoring**:
   - Create configuration files
   - Update path handling in all scripts
   - Standardize code structure

3. **Dependency Management**:
   - Document all required packages and versions
   - Create setup scripts

4. **Testing**:
   - Develop testing scripts
   - Validate the entire workflow

## 5. Deliverables

1. **Documentation**:
   - Main README.md
   - Data catalog
   - Workflow documentation
   - Script dependency diagram

2. **Code**:
   - Refactored scripts with improved documentation
   - Configuration files
   - Master scripts for running the workflow

3. **Dependency Management**:
   - Requirements files for all platforms
   - Setup scripts

4. **Testing**:
   - Test scripts
   - Validation report

## 6. Notes on Proprietary Data

This replication package relies on proprietary data from Compustat and Markit. Researchers wishing to replicate the results will need to:

1. Obtain licenses for these data providers
2. Follow the documented procedures to extract the required data
3. Place the data files in the specified locations

All code for processing this data is provided, but the raw data files themselves cannot be included due to licensing restrictions.