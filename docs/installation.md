# Installation and Setup

This section provides detailed instructions on how to set up the replication environment and install the necessary software.

## System Requirements

The replication package requires the following software:

1. **Stata** (version 15 or higher)
2. **R** (version 4.0 or higher)
3. **Bash** shell (for running scripts)
4. **Python** (version 3.8 or higher, optional, for running Sphinx documentation)

## Stata Setup

1. **Install Stata**
   - The replication code was tested with Stata 15
   - Make sure Stata is in your system PATH

2. **Install Required Packages**
   - The required Stata packages are included in the `ado/` directory
   - No additional installation is needed as the package uses local copies

3. **Verify Installation**
   - Run the following command to verify Stata is properly installed:
   ```bash
   stata -b -e -q do "verify_stata.do"
   ```

## R Setup

1. **Install R**
   - Download and install R from [CRAN](https://cran.r-project.org/)
   - Make sure R is in your system PATH

2. **Install Required Packages**
   - Run the following command to install the required R packages:
   ```R
   install.packages(readLines("requirements/r_requirements.txt"))
   ```
   - Alternatively, you can install them manually:
   ```R
   install.packages(c("synthdid", "ggplot2", "haven", "gginnards", "stargazer"))
   ```

3. **Verify Installation**
   - Run the following command to verify R is properly installed:
   ```bash
   Rscript "verify_r.R"
   ```

## Data Setup

1. **Obtain Proprietary Data**
   - Follow the instructions in `data/README.md` to obtain the required data files
   - Place the data files in the `0_raw_data/` directory with the correct naming convention

2. **Verify Data Files**
   - Run the data verification script:
   ```bash
   ./verify_data.sh
   ```

## Configuration

1. **Set Paths**
   - Edit the configuration files to set the correct paths for your system:
     - For Stata: `1_transformation_code/config.do`
     - For R: `3_analysis_code/config.R`

2. **Example Configurations**

   For Stata (`config.do`):
   ```stata
   global path "/path/to/replication_package_aej/"
   ```

   For R (`config.R`):
   ```R
   path_base <- "/path/to/replication_package_aej"
   ```

## Sphinx Documentation (Optional)

If you want to build the Sphinx documentation:

1. **Install Required Python Packages**
   ```bash
   pip install -r docs/requirements.txt
   ```

2. **Build the Documentation**
   ```bash
   cd docs
   make html
   ```

3. **View the Documentation**
   - Open `docs/_build/html/index.html` in your web browser

## Troubleshooting

If you encounter issues during installation:

1. **Check Software Versions**
   - Make sure you have the required versions of Stata and R

2. **Check Path Configuration**
   - Ensure the paths in the configuration files are correct

3. **Check Required Packages**
   - Make sure all required packages are installed

4. **Check Data Files**
   - Ensure all required data files are in the correct locations

For more detailed troubleshooting, refer to the Troubleshooting section in the Appendix.