#!/bin/bash
# Test runner script for the replication package
# The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax

# Set base path
BASE_PATH="$(cd "$(dirname "$0")/.." && pwd)"
TEST_PATH="$BASE_PATH/tests"
cd "$TEST_PATH"

echo "======================================================================"
echo "Running validation tests for 'The Big Short (Interest)'"
echo "======================================================================"
echo "Base path: $BASE_PATH"
echo "Test path: $TEST_PATH"
echo ""

# Check for required software
echo "Checking required software..."
command -v Rscript >/dev/null 2>&1 || { echo "Error: R is required but not found. Please install R and ensure it's in your PATH."; exit 1; }

# Test R dependencies
echo "Checking R dependencies..."
Rscript -e "if(!require('testthat')) install.packages('testthat', repos='https://cran.rstudio.com/')"
Rscript -e "if(!require('png')) install.packages('png', repos='https://cran.rstudio.com/')"

# Run validation script
echo ""
echo "Running validation tests..."
Rscript validate_outputs.R

# Check if output directory structure is correct
echo ""
echo "Checking directory structure..."
for dir in "0_raw_data" "1_transformation_code" "2_final_data" "3_analysis_code" "4_output" "ado"; do
  if [ -d "$BASE_PATH/$dir" ]; then
    echo "✓ Directory exists: $dir"
  else
    echo "✗ Directory missing: $dir"
  fi
done

# Check for required scripts
echo ""
echo "Checking for required scripts..."
REQUIRED_SCRIPTS=(
  "1_transformation_code/0_alltodos_code.do"
  "1_transformation_code/1_import_data.do"
  "1_transformation_code/4_appending.do"
  "3_analysis_code/Figure10_Table5_T.R"
  "3_analysis_code/Table3_TableC2_Table4_TableC1_Figure1.do"
  "3_analysis_code/Preparing_DWTRevenueData.do"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ -f "$BASE_PATH/$script" ]; then
    echo "✓ Script exists: $script"
  else
    echo "✗ Script missing: $script"
  fi
done

echo ""
echo "======================================================================"
echo "Validation tests completed"
echo "======================================================================"