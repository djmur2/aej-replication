# Intermediate Datasets

This document describes the key intermediate datasets used in the replication package, including those where the creation process might not be explicitly shown in the main code files.

## Overview

Throughout the data transformation and analysis process, several intermediate datasets are created. Some of these datasets are created by explicitly documented scripts, while others might be created through processes not directly shown in the main code files.

## Key Intermediate Datasets

### Investment Data: `capx_treatment_yearly.dta`

This dataset contains yearly investment rates and is used in the analysis for Table 4 and Table C1.

#### Content and Structure

The dataset contains the following key variables:
- `country`: Country identifier (1=DNK, 2=FIN, 3=NOR, 4=SWE)
- `year`: Year of observation
- `relativecapx`: Investment rate (capital expenditure relative to total assets)
- `div_yield_yearly`: Dividend yield (annual)
- `meanmarketcap`: Average market capitalization
- `after`: Indicator for post-reform period (year>=2015)
- `treatmentintensity`: Indicator for high treatment intensity

#### Creation Process

While not explicitly shown in the main scripts, this dataset is likely created through the following process:

1. **Data Source**: Compustat Global data on capital expenditures (capx) and total assets
2. **Aggregation**: Yearly aggregation of company-level data
3. **Calculation**: 
   - `relativecapx` = capital expenditure / total assets
   - `div_yield_yearly` = annual dividends / stock price
   - `meanmarketcap` = average of daily market capitalization values
4. **Treatment Variables**:
   - `after` = 1 if year >= 2015, 0 otherwise
   - `treatmentintensity` = 1 for companies with high dividend yield, 0 otherwise

#### Usage

This dataset is used in:
- `Table3_TableC2_Table4_TableC1_Figure1.do` for analysis of investment rates and dividend yields
- It's specifically used to produce Tables 4 and C1 in the paper

### Combined Nordic Countries Data: `dnk_fin_swe_nor.dta`

This dataset combines processed data from Denmark, Finland, Sweden, and Norway.

#### Content and Structure

The dataset contains daily stock lending data for companies in the four Nordic countries, including:
- `country`: Country identifier (1=DNK, 2=FIN, 3=NOR, 4=SWE)
- `idc`: Country code string ("DNK", "FIN", "NOR", "SWE")
- `date`: Date of observation
- `shortinterest`: Stock lending as percentage of shares outstanding
- `id`: Company identifier
- `c_isin`: International Securities Identification Number
- `windowcount`: Days relative to ex-dividend date (-15 to +15)
- `yearlymarketcap`: Yearly average market capitalization
- Various other stock lending and company variables

#### Creation Process

This dataset is created by the `4_appending.do` script, which:
1. Loads the processed country data files (`dataforanalysis_*.dta`)
2. Appends them into a single dataset
3. Adds country identifiers and creates a common company ID

#### Usage

This dataset is used in:
- `Table3_TableC2_Table4_TableC1_Figure1.do` for analysis of stock lending around ex-dividend dates
- `FigureC10.do` for additional analysis

### Tax Revenue Data: `Data_Tax.dta`

This dataset contains dividend withholding tax revenue data.

#### Content and Structure

The dataset contains yearly tax revenue data for Nordic countries, including:
- `Country`: Country code ("DNK", "FIN", "NOR", "SWE")
- `Year`: Year of observation
- `GrossDWT_Mil_USD`: Gross dividend withholding tax revenue in millions USD
- `RefundDWT_Mil_USD`: Refunded dividend withholding tax in millions USD
- `NetDWT_Mil_USD`: Net dividend withholding tax revenue in millions USD

#### Creation Process

This dataset is created by the `Preparing_DWTRevenueData.do` script, which:
1. Loads the raw tax revenue data (`DWT_Revenues_Overview_Sept2022.xlsx`)
2. Loads exchange rate data (`ExchangeRates_WB_clean.xlsx`)
3. Merges the two datasets
4. Converts tax revenue values to USD
5. Creates variables for gross, refund, and net revenue

#### Usage

This dataset is used in:
- `Figure10_Table5_T.R` for synthetic difference-in-differences analysis of tax revenue

## Other Intermediate Datasets

### Country-Specific Raw Data: `*.dta`

These files are created by `1_import_data.do` and contain the raw data for each country converted to Stata format.

### Processed Country Data: `dataforanalysis_*.dta`

These files are created by the country-specific transformation scripts and contain the processed data for each country, including stock lending metrics and event windows around ex-dividend dates.

### Data for Short Interest Analysis: `country_shortinterest_*.dta`

These files are created for analysis of short interest by country (mentioned in `0_alltodos_code.do` but may not be used in the final analysis).

## Missing or Undocumented Datasets

Some datasets used in the analysis code may not have clear documentation on their creation:

1. **Data_WelfareAnalysis_Sept2022.dta**: Created by `Preparing_DWTRevenueData.do` but its relationship to `Data_Tax.dta` is not clearly documented

2. **country-specific files for Figure 1 case studies**: The selection process for the specific companies used in the case studies (Novo Nordisk and Svenska Handelsbanken) could be better documented

## Documentation Improvements

To enhance reproducibility, the following improvements to dataset documentation are recommended:

1. **Create explicit data dictionaries** for each intermediate dataset
2. **Add comments in code** explaining calculation methodologies
3. **Include validation checks** to ensure data integrity
4. **Document the exact process** for creating `capx_treatment_yearly.dta` and other datasets that may be created outside the main scripts