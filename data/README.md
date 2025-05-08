# Data Sources and Acquisition

This document provides detailed information on how to obtain the data required for replication.

## Overview of Data Sources

The replication package relies on the following data sources:

1. **Stock Market Data** from Compustat and Markit
2. **Dividend Withholding Tax Revenue Data** from national tax authorities
3. **Exchange Rate Data** from the World Bank

## Proprietary Data

### Compustat Global

Compustat Global is a database provided by S&P Global Market Intelligence that contains financial, statistical, and market information on global companies.

**How to obtain:**
1. Institutional access is typically required
2. Visit [S&P Global Market Intelligence](https://www.spglobal.com/marketintelligence/en/)
3. Request access to Compustat Global
4. Extract data for the following European countries: Austria, Belgium, Switzerland, Germany, Denmark, Spain, Finland, France, United Kingdom, Ireland, Iceland, Italy, Luxembourg, Netherlands, Norway, Portugal, and Sweden
5. Use the following variables:
   - gvkey (Global Company Key)
   - isin (International Securities Identification Number)
   - prccd (Price)
   - cshtrd (Shares Traded)
   - cshoc (Shares Outstanding)
   - divdgross (Dividend Amount)
   - exchg (Stock Exchange Code)
   - conm (Company Name)
   - curcddv (Currency Code for Dividends)
   - fic (Country of Incorporation)
   - loc (Country of Headquarters)

### Markit Securities Finance

Markit Securities Finance (now part of IHS Markit) provides data on securities lending and borrowing.

**How to obtain:**
1. Institutional access is required
2. Visit [IHS Markit Securities Finance](https://ihsmarkit.com/products/securities-finance.html)
3. Request access to their securities lending data
4. Extract data for the same European countries as Compustat
5. Use the following variables:
   - lendervalueonloan (Value of Shares on Loan)
   - lenderquantityonloan (Quantity of Shares on Loan)
   - lendablequantity (Quantity of Shares Available for Lending)
   - utilisation (Utilization Rate)
   - lenderconcentration (Lender Concentration)
   - borrowerconcentration (Borrower Concentration)

## Public Data

### World Bank Exchange Rates

Exchange rate data is provided in the package as `0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.xlsx`.

If you need to update this data:
1. Visit the [World Bank Open Data](https://data.worldbank.org/)
2. Search for "Official exchange rate (LCU per US$, period average)"
3. Download data for the European countries in the study
4. Process the data to match the format in `ExchangeRates_WB_clean.xlsx`

### Dividend Withholding Tax Revenue

Tax revenue data is provided in the package as `0_raw_data/DWT Revenue Data/DWT_Revenues_Overview_Sept2022.xlsx`.

This data was collected from national tax authorities. If you need to update or verify this data:
1. Contact the tax authorities of Denmark, Finland, Norway, and Sweden
2. Request data on dividend withholding tax revenues, including:
   - Gross revenue
   - Refunds
   - Net revenue

## Data Preparation

After obtaining the raw data, follow these steps to prepare it for analysis:

1. Save the country-specific data files in CSV format in the `0_raw_data/` directory
2. Name the files according to their ISO 3166-1 alpha-3 country codes (lowercase), e.g., `dnk.csv` for Denmark
3. Ensure the data files contain the variables listed above from both Compustat and Markit
4. Run the data transformation code as described in the main README.md file

## Data Structure

The expected structure of the country-specific CSV files is:

- One row per security-day observation
- Columns for both Compustat (prefixed with `c_`) and Markit (prefixed with `m_`) variables
- Date format: YYYY-MM-DD

See `DATA_CATALOG.md` for detailed descriptions of all variables and files.