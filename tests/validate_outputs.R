# **********************************************************************
# ***** Validation script for replication outputs
# ***** The Big Short (Interest): 
# ***** Closing the Loopholes in the Dividend-Withholding Tax
# **********************************************************************

# This script validates the outputs of the replication package by comparing
# them with expected values and formats.

# Load libraries
library(png)
library(testthat)
library(tools)

# Set base path
base_path <- file.path("..")
output_path <- file.path(base_path, "4_output")

# Function to check if a file exists
check_file_exists <- function(file_path) {
  test_that(paste("File exists:", file_path), {
    expect_true(file.exists(file_path))
  })
}

# Function to check if a LaTeX file contains expected content
check_latex_content <- function(file_path, expected_pattern) {
  test_that(paste("LaTeX file contains expected content:", file_path), {
    content <- readLines(file_path, warn = FALSE)
    content <- paste(content, collapse = "\n")
    expect_match(content, expected_pattern)
  })
}

# Function to check if a PNG file has expected dimensions
check_png_dimensions <- function(file_path, expected_width, expected_height) {
  test_that(paste("PNG has expected dimensions:", file_path), {
    img <- png::readPNG(file_path)
    dimensions <- dim(img)
    expect_equal(dimensions[2], expected_width)
    expect_equal(dimensions[1], expected_height)
  })
}

# Check if output files exist
cat("Checking if output files exist...\n")
check_file_exists(file.path(output_path, "Figure10_synthDiD_NetDWT_Revenue_data_sept22.png"))
check_file_exists(file.path(output_path, "Table5.tex"))
check_file_exists(file.path(output_path, "Table3_sumstats.tex"))
check_file_exists(file.path(output_path, "Novo_Nordisk.png"))
check_file_exists(file.path(output_path, "Svenska_Handelsbanken.png"))

# Check LaTeX file content
cat("Checking LaTeX file content...\n")
check_latex_content(file.path(output_path, "Table5.tex"), "SDiD Denmark")
check_latex_content(file.path(output_path, "Table3_sumstats.tex"), "Utilisation")

# Check PNG dimensions (if files exist)
cat("Checking PNG dimensions...\n")
if (file.exists(file.path(output_path, "Figure10_synthDiD_NetDWT_Revenue_data_sept22.png"))) {
  check_png_dimensions(file.path(output_path, "Figure10_synthDiD_NetDWT_Revenue_data_sept22.png"), 1600, 1200)
}

# Summary
cat("\nValidation completed.\n")
cat("If all tests passed, the replication outputs match the expected format.\n")
cat("Note: This script only checks the format of outputs, not the exact values.\n")
cat("For detailed validation of numerical results, please refer to the paper.\n")