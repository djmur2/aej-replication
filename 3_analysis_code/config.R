# **********************************************************************
# ***** Configuration file for R replication code
# ***** The Big Short (Interest): 
# ***** Closing the Loopholes in the Dividend-Withholding Tax
# ***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
# **********************************************************************

# Clean environment
rm(list=ls())

# ------------------------------------------------------
# STEP 1: Set the base path to the replication package
# ------------------------------------------------------
# IMPORTANT: Modify this path to match your local setup
# Example for Windows: path_base <- "C:/Users/username/replication_package_aej"
# Example for Mac: path_base <- "/Users/username/replication_package_aej"
# Example for Linux: path_base <- "/home/username/replication_package_aej"

path_base <- "/Users/davidmurphy/Desktop/replication_package_aej"

# ------------------------------------------------------
# STEP 2: Set paths to subdirectories
# ------------------------------------------------------
# These paths should not need to be modified if you maintain the directory structure
path_raw_data <- file.path(path_base, "0_raw_data")
path_code <- file.path(path_base, "1_transformation_code")
path_input <- file.path(path_base, "2_final_data")
path_analysis <- file.path(path_base, "3_analysis_code")
path_output <- file.path(path_base, "4_output")

# ------------------------------------------------------
# STEP 3: Load required packages
# ------------------------------------------------------
required_packages <- c(
  "synthdid",
  "ggplot2",
  "haven",
  "gginnards",
  "stargazer"
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) {
  install.packages(new_packages)
}

# Load all required packages
invisible(lapply(required_packages, library, character.only = TRUE))

# ------------------------------------------------------
# STEP 4: Set seed for reproducibility
# ------------------------------------------------------
set.seed(48476352)

# ------------------------------------------------------
# STEP 5: Display configuration
# ------------------------------------------------------
cat("Configuration loaded successfully.\n")
cat("Base path:", path_base, "\n")
cat("Raw data path:", path_raw_data, "\n")
cat("Code path:", path_code, "\n")
cat("Input data path:", path_input, "\n")
cat("Analysis path:", path_analysis, "\n")
cat("Output path:", path_output, "\n")