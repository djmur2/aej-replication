#!/bin/bash
# Master script to run the entire replication process
# The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax

# Set base path - modify this to match your local setup
BASE_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "$BASE_PATH"

echo "======================================================================"
echo "Running replication package for 'The Big Short (Interest)'"
echo "Authors: Elisa Casi, Evelina Gavrilova, David Murphy, Floris Zoutman"
echo "======================================================================"
echo "Base path: $BASE_PATH"
echo ""

# Check for required software
echo "Checking required software..."
command -v stata >/dev/null 2>&1 || { echo "Error: Stata is required but not found. Please install Stata and ensure it's in your PATH."; exit 1; }
command -v Rscript >/dev/null 2>&1 || { echo "Error: R is required but not found. Please install R and ensure it's in your PATH."; exit 1; }

# Check for required data files
echo "Checking required data files..."
COUNTRY_CODES=("aut" "bel" "che" "deu" "dnk" "esp" "fin" "fra" "gbr" "irl" "isl" "ita" "lux" "nld" "nor" "prt" "swe")
MISSING_FILES=()

for code in "${COUNTRY_CODES[@]}"; do
  if [ ! -f "$BASE_PATH/0_raw_data/$code.csv" ]; then
    MISSING_FILES+=("$code.csv")
  fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  echo "Warning: The following raw data files are missing:"
  for file in "${MISSING_FILES[@]}"; do
    echo "  - 0_raw_data/$file"
  done
  echo ""
  echo "These files contain proprietary data from Compustat and Markit."
  echo "Please refer to the README.md for instructions on obtaining these files."
  
  read -p "Do you want to continue anyway? [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Replication aborted."
    exit 1
  fi
fi

# Create output directories if they don't exist
echo "Setting up directories..."
mkdir -p "$BASE_PATH/2_final_data"
mkdir -p "$BASE_PATH/4_output"

# Step 1: Run data transformation code
echo ""
echo "======================================================================"
echo "Step 1: Running data transformation code (Stata)"
echo "======================================================================"
cd "$BASE_PATH/1_transformation_code"
stata -b do config.do
stata -b do 0_alltodos_code.do

# Check if the transformation was successful
if [ ! -f "$BASE_PATH/2_final_data/dnk_fin_swe_nor.dta" ]; then
  echo "Warning: The transformation did not produce the expected output file."
  echo "This may be due to missing raw data files."
  
  read -p "Do you want to continue anyway? [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Replication aborted."
    exit 1
  fi
fi

# Step 2: Run analysis code
echo ""
echo "======================================================================"
echo "Step 2: Running analysis code (Stata and R)"
echo "======================================================================"
cd "$BASE_PATH/3_analysis_code"

echo "Running Table3_TableC2_Table4_TableC1_Figure1.do..."
stata -b do Table3_TableC2_Table4_TableC1_Figure1.do

echo "Running Figure10_Table5_T.R..."
Rscript Figure10_Table5_T.R

echo "Running Preparing_DWTRevenueData.do..."
stata -b do Preparing_DWTRevenueData.do

echo "Running FigureC10.do..."
stata -b do FigureC10.do

# Step 3: Validate outputs
echo ""
echo "======================================================================"
echo "Step 3: Validating outputs"
echo "======================================================================"
cd "$BASE_PATH"

# Check if key output files exist
OUTPUT_FILES=(
  "4_output/Figure10_synthDiD_NetDWT_Revenue_data_sept22.png"
  "4_output/Table5.tex"
  "4_output/Table3_sumstats.tex"
  "4_output/Novo_Nordisk.png"
  "4_output/Svenska_Handelsbanken.png"
)

MISSING_OUTPUTS=()
for file in "${OUTPUT_FILES[@]}"; do
  if [ ! -f "$BASE_PATH/$file" ]; then
    MISSING_OUTPUTS+=("$file")
  fi
done

if [ ${#MISSING_OUTPUTS[@]} -gt 0 ]; then
  echo "Warning: The following output files were not generated:"
  for file in "${MISSING_OUTPUTS[@]}"; do
    echo "  - $file"
  done
  echo "This may indicate issues with the replication process."
else
  echo "All expected output files were generated successfully."
fi

echo ""
echo "======================================================================"
echo "Replication completed"
echo "======================================================================"
echo "Output files are available in the 4_output/ directory."
echo "Please refer to the README.md for a description of each output file."