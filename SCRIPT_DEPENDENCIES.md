# Script Dependencies

This document outlines the dependencies between scripts in the replication package for "The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax".

## Overall Workflow

```
1. Data Import → 2. Data Transformation → 3. Data Analysis → 4. Output Generation
```

## Detailed Script Dependencies

```mermaid
graph TD
    %% Main workflow
    START[Start] --> CONFIG_DO[config.do]
    CONFIG_DO --> ALLTODOS[0_alltodos_code.do]
    
    %% Data Import
    ALLTODOS --> IMPORT[1_import_data.do]
    IMPORT --> |Creates country.dta files| DATA_PREP[Country-specific data preparation]
    
    %% Data Transformation
    DATA_PREP --> |For each country| FRAG1[frag_data_prep_1.do]
    FRAG1 --> |For each country| STOCKEX[frag_country_stock_exchange_selection.do]
    STOCKEX --> |For each country| FRAG2[frag_data_prep_2.do]
    FRAG2 --> |For each country| EXCHRATE[frag_country_exchange_rate_conversion.do]
    EXCHRATE --> |For each country| FRAG3[frag_data_prep_3.do]
    FRAG3 --> |Creates dataforanalysis_country.dta| APPEND[4_appending.do]
    
    %% Final Data
    APPEND --> |Creates dnk_fin_swe_nor.dta| FINAL_DATA[2_final_data/]
    
    %% Tax Revenue Data Preparation
    CONFIG_R[config.R] --> PREP_DWT[Preparing_DWTRevenueData.do]
    PREP_DWT --> |Creates Data_Tax.dta| FINAL_DATA
    
    %% Analysis
    FINAL_DATA --> TABLE3[Table3_TableC2_Table4_TableC1_Figure1.do]
    FINAL_DATA --> FIGURE10[Figure10_Table5_T.R]
    FINAL_DATA --> FIGUREC10[FigureC10.do]
    
    %% Output
    TABLE3 --> OUTPUT[4_output/]
    FIGURE10 --> OUTPUT
    FIGUREC10 --> OUTPUT
    
    %% Legend
    classDef stata fill:#f96,stroke:#333,stroke-width:2px;
    classDef r fill:#9cf,stroke:#333,stroke-width:2px;
    classDef data fill:#9f9,stroke:#333,stroke-width:2px;
    
    class ALLTODOS,IMPORT,FRAG1,STOCKEX,FRAG2,EXCHRATE,FRAG3,APPEND,TABLE3,PREP_DWT,FIGUREC10 stata;
    class FIGURE10,CONFIG_R r;
    class FINAL_DATA,OUTPUT data;
```

## Script Execution Order

1. **Configuration**
   - `1_transformation_code/config.do` (Stata)
   - `3_analysis_code/config.R` (R)

2. **Data Import and Transformation**
   - `1_transformation_code/0_alltodos_code.do` (Stata)
     - Calls `1_import_data.do`
     - For each country, runs:
       - `frag_data_prep_1.do`
       - `frag_[country]_stock_exchange_selection.do`
       - `frag_data_prep_2.do`
       - `frag_[country]_exchange_rate_conversion.do`
       - `frag_data_prep_3.do`
     - Calls `4_appending.do`

3. **Tax Data Preparation**
   - `3_analysis_code/Preparing_DWTRevenueData.do` (Stata)

4. **Analysis and Output Generation**
   - `3_analysis_code/Table3_TableC2_Table4_TableC1_Figure1.do` (Stata)
   - `3_analysis_code/Figure10_Table5_T.R` (R)
   - `3_analysis_code/FigureC10.do` (Stata)

## Data Flow

1. **Raw Data Sources**
   - Country-specific CSV files from Compustat and Markit (`0_raw_data/*.csv`)
   - Dividend withholding tax revenue data (`0_raw_data/DWT Revenue Data/*.xlsx`)
   - Exchange rate data (`0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.xlsx`)

2. **Intermediate Data**
   - Country-specific Stata data files (`2_final_data/*.dta`)
   - Combined Nordic countries data (`2_final_data/dnk_fin_swe_nor.dta`)
   - Tax revenue data (`2_final_data/Data_Tax.dta`)

3. **Output Files**
   - Tables (LaTeX format, `4_output/*.tex`)
   - Figures (PNG format, `4_output/*.png`)