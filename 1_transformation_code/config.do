/*
Configuration file for Stata replication code
The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax
Authors: Elisa Casi, Evelina Gavrilova, David Murphy, Floris Zoutman
*/

// Clear any existing globals
clear all
set more off
version 15

// ------------------------------------------------------
// STEP 1: Set the base path to the replication package
// ------------------------------------------------------
// IMPORTANT: Modify this path to match your local setup
// Example for Windows: global path "C:/Users/username/replication_package_aej/"
// Example for Mac: global path "/Users/username/replication_package_aej/"
// Example for Linux: global path "/home/username/replication_package_aej/"

global path "/Users/davidmurphy/Desktop/replication_package_aej/"

// ------------------------------------------------------
// STEP 2: Set paths to subdirectories
// ------------------------------------------------------
// These paths should not need to be modified if you maintain the directory structure
global data     "${path}0_raw_data/"
global do       "${path}1_transformation_code/"
global outdata  "${path}2_final_data/"
global analysis "${path}3_analysis_code/"
global output   "${path}4_output/"
global ado      "${path}ado/"

// ------------------------------------------------------
// STEP 3: Set other configuration options
// ------------------------------------------------------
// Add required ado files to the search path
adopath + "${ado}"
adopath + "${ado}/d"
adopath + "${ado}/r"
adopath + "${ado}/s"

// Set seed for reproducibility
set seed 525443

// Display configuration
di "Configuration loaded successfully."
di "Base path: ${path}"
di "Data path: ${data}"
di "Code path: ${do}"
di "Output data path: ${outdata}"
di "Analysis path: ${analysis}"
di "Output path: ${output}"
di "Ado path: ${ado}"