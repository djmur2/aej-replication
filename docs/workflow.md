# Replication Workflow

This section provides a detailed explanation of the replication workflow, including the steps to reproduce the results in the paper.

## Overview

The replication workflow consists of the following main steps:

1. **Data Preparation**: Import and transform the raw data
2. **Analysis**: Run the main analyses
3. **Output Generation**: Generate tables and figures
4. **Validation**: Validate the outputs against the paper

## Step-by-Step Instructions

### 1. Run the Complete Replication

For convenience, a master script is provided that runs the entire replication process:

```bash
./run_replication.sh
```

This script will:
- Check for required software and data files
- Run the data transformation code
- Run the analysis code
- Generate all tables and figures
- Validate the outputs

### 2. Run Individual Steps

If you prefer to run the steps individually, follow these instructions:

#### 2.1. Data Transformation

```bash
cd 1_transformation_code
stata -b do config.do
stata -b do 0_alltodos_code.do
```

This will:
- Import the raw data from `0_raw_data/`
- Transform the data through various stages
- Save the processed data in `2_final_data/`

#### 2.2. Analysis and Output Generation

```bash
cd 3_analysis_code
stata -b do config.do
stata -b do Table3_TableC2_Table4_TableC1_Figure1.do
Rscript Figure10_Table5_T.R
stata -b do FigureC10.do
```

This will:
- Run the main analyses on the processed data
- Generate tables and figures
- Save the outputs in `4_output/`

#### 2.3. Validation

```bash
cd tests
./run_tests.sh
```

This will:
- Check if all expected output files exist
- Validate the format and content of the outputs
- Report any issues or discrepancies

## Workflow Diagram

Below is a diagram of the complete workflow:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Raw Data    │     │ Transformed │     │ Analysis    │     │ Output      │
│             │     │ Data        │     │ Code        │     │ Files       │
│ 0_raw_data/ │────>│ 2_final_data│────>│ 3_analysis_ │────>│ 4_output/   │
│             │     │             │     │ code/       │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

## Expected Runtime

- **Data Transformation**: ~10-15 minutes
- **Analysis and Output Generation**: ~5-10 minutes
- **Validation**: ~1-2 minutes
- **Total**: ~15-30 minutes

Note: Runtime may vary depending on your system's performance.

## Output Files

After successful replication, you should have the following key output files:

- **Tables**:
  - `4_output/Table3_sumstats.tex`
  - `4_output/Table5.tex`
  - Various other LaTeX tables

- **Figures**:
  - `4_output/Figure10_synthDiD_NetDWT_Revenue_data_sept22.png`
  - `4_output/Novo_Nordisk.png`
  - `4_output/Svenska_Handelsbanken.png`

## Troubleshooting

If you encounter issues during the replication process:

1. **Check Log Files**:
   - Stata generates log files for each script
   - R output may contain error messages

2. **Check Data Files**:
   - Ensure all required data files are present
   - Check file permissions

3. **Check Configuration**:
   - Ensure paths are correctly set in the configuration files

For more detailed troubleshooting, refer to the Troubleshooting section in the Appendix.