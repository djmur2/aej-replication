# Testing Guide for Replication Package

This guide provides step-by-step instructions for testing the replication package, including handling custom Stata packages and proprietary data considerations.

## Prerequisites

- Stata (version 15 or higher)
- R (version 4.0 or higher)

## Testing Workflow

### Step 1: Clone the Repository

```bash
mkdir ~/replication_test
cd ~/replication_test
git clone https://github.com/djmur2/aej-replication.git
cd aej-replication
```

### Step 2: Configure Paths

1. Edit the Stata configuration file:
   ```bash
   nano 1_transformation_code/config.do
   ```
   Update the `global path` variable to your clone location.

2. Edit the R configuration file:
   ```bash
   nano 3_analysis_code/config.R
   ```
   Update the `path_base` variable to your clone location.

### Step 3: Prepare Test Data

1. Create the required directories:
   ```bash
   mkdir -p 0_raw_data
   mkdir -p "0_raw_data/DWT Revenue Data"
   mkdir -p 2_final_data
   mkdir -p 4_output
   ```

2. Place test data in the appropriate locations:
   - Country CSV files in `0_raw_data/` (see DATA_ACQUISITION.md)
   - Revenue data in `0_raw_data/DWT Revenue Data/`

3. For minimal testing, you can use a single country:
   ```bash
   # Example for testing with only Denmark data
   cp /path/to/dnk.csv 0_raw_data/
   ```

### Step 4: Check Custom Stata Package Setup

Our package includes custom Stata ado files, which are automatically found thanks to the configuration in `config.do`:

```bash
# View the custom did_switching.ado file
cat ado/d/did_switching.ado
```

The `config.do` file adds these to Stata's search path:
```stata
adopath + "${ado}"
adopath + "${ado}/d"
adopath + "${ado}/r"
adopath + "${ado}/s"
```

This ensures that when scripts call these packages, they use our exact versions.

### Step 5: Run the Replication

For a full test:
```bash
./run_replication.sh
```

For step-by-step testing:
```bash
# Test data transformation
cd 1_transformation_code
stata -b do config.do
stata -b do 0_alltodos_code.do

# Test analysis code
cd ../3_analysis_code
stata -b do config.do
stata -b do Table3_TableC2_Table4_TableC1_Figure1.do
Rscript Figure10_Table5_T.R
```

### Step 6: Verify Outputs

```bash
# Check output files
ls -la 4_output/

# Run validation tests
cd ../tests
./run_tests.sh
```

## Testing Without Proprietary Data

If you don't have access to the proprietary data:

1. Create minimal test data with the same structure as described in DATA_ACQUISITION.md
2. Run only specific parts of the code that don't depend on the full dataset
3. Focus on validating code structure and documentation

## Testing the Documentation

```bash
# Review the Markdown documentation
less README.md
less DATA_ACQUISITION.md
less SCRIPT_DEPENDENCIES.md

# Build the Sphinx documentation (if Python/Sphinx installed)
cd docs
pip install -r requirements.txt
make html
# View docs/_build/html/index.html in a browser
```

## Troubleshooting Common Issues

### Missing Data Files
- Check that all required CSV files exist in `0_raw_data/`
- Check that DWT revenue data exists in `0_raw_data/DWT Revenue Data/`

### Stata Package Issues
- Make sure `config.do` is executed before any other Stata script
- Check that the custom packages in `ado/` are being used

### Path Issues
- Ensure all paths in configuration files use the correct format for your OS
- For Windows, use double backslashes or forward slashes in paths

### R Package Issues
- If R packages are missing, install them using:
  ```R
  install.packages(c("synthdid", "ggplot2", "haven", "gginnards", "stargazer"))
  ```