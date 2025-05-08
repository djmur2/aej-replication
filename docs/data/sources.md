# Data Sources

This section describes the data sources used in the replication package.

## Overview

The replication package uses data from the following sources:

1. **Stock Market Data**: From Compustat and Markit
2. **Dividend Withholding Tax Revenue Data**: From national tax authorities
3. **Exchange Rate Data**: From the World Bank

## Stock Market Data

### Compustat Global

Compustat Global is a comprehensive database of financial, statistical, and market information on global companies.

#### Provider
- S&P Global Market Intelligence

#### Coverage
- European publicly traded companies
- Period: 2010-2019

#### Key Variables
- `c_gvkey`: Global company identifier
- `c_isin`: International Securities Identification Number
- `c_datadate`: Date of observation
- `c_prccd`: Stock price in local currency
- `c_cshtrd`: Shares traded
- `c_cshoc`: Shares outstanding
- `c_divdgross`: Gross dividend amount
- `c_exchg`: Stock exchange code
- `c_fic`: Country of incorporation
- `c_loc`: Country of headquarters

#### Access Requirements
- Subscription to Compustat Global
- Typically accessed through institutional subscriptions
- [S&P Global Market Intelligence website](https://www.spglobal.com/marketintelligence/en/)

### Markit Securities Finance

Markit Securities Finance provides data on securities lending activities.

#### Provider
- IHS Markit (now part of S&P Global)

#### Coverage
- European publicly traded companies
- Period: 2010-2019

#### Key Variables
- `m_lendervalueonloan`: Value of shares on loan
- `m_lenderquantityonloan`: Quantity of shares on loan
- `m_lendablequantity`: Quantity of shares available for lending
- `m_utilisation`: Utilization rate (percentage of available shares that are on loan)
- `m_lenderconcentration`: Lender concentration (measure of how concentrated the lenders are)
- `m_borrowerconcentration`: Borrower concentration (measure of how concentrated the borrowers are)

#### Access Requirements
- Subscription to IHS Markit Securities Finance
- Typically accessed through institutional subscriptions
- [IHS Markit Securities Finance website](https://ihsmarkit.com/products/securities-finance.html)

## Dividend Withholding Tax Revenue Data

This data includes information on dividend withholding tax revenues for Nordic countries.

#### Provider
- National tax authorities of Denmark, Finland, Norway, and Sweden

#### Coverage
- Denmark, Finland, Norway, Sweden
- Period: 2010-2019

#### Key Variables
- `Country`: Country code
- `Year`: Year of observation
- `GrossDWT`: Gross dividend withholding tax revenue
- `RefundDWT`: Refunded dividend withholding tax
- `NetDWT`: Net dividend withholding tax revenue

#### Access
- Data provided in the replication package
- Original data collected from national tax authorities
- File: `0_raw_data/DWT Revenue Data/DWT_Revenues_Overview_Sept2022.xlsx`

## Exchange Rate Data

This data includes exchange rates for converting local currencies to USD.

#### Provider
- World Bank

#### Coverage
- European countries
- Period: 2010-2019

#### Key Variables
- `CountryCode`: Country code
- `Year`: Year of observation
- `exchangerates`: Exchange rate (local currency units per USD)

#### Access
- Data provided in the replication package
- Original data from World Bank Open Data
- Files: 
  - `0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.xlsx`
  - `0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.dta`

## Accessing Proprietary Data

### Compustat and Markit Data

To replicate the results using the full dataset, researchers need to:

1. **Obtain access** to Compustat Global and Markit Securities Finance
2. **Extract data** for the following countries:
   - Austria (aut)
   - Belgium (bel)
   - Switzerland (che)
   - Germany (deu)
   - Denmark (dnk)
   - Spain (esp)
   - Finland (fin)
   - France (fra)
   - United Kingdom (gbr)
   - Ireland (irl)
   - Iceland (isl)
   - Italy (ita)
   - Luxembourg (lux)
   - Netherlands (nld)
   - Norway (nor)
   - Portugal (prt)
   - Sweden (swe)
   
3. **Merge the data** from both sources, matching on ISIN and date
4. **Save the files** in CSV format with the following naming convention:
   - `0_raw_data/[country_code].csv` (e.g., `0_raw_data/dnk.csv`)

### Data Structure

The country CSV files should have the following structure:

- One row per security-day observation
- Variables from Compustat prefixed with `c_`
- Variables from Markit prefixed with `m_`
- Both ISIN (`c_isin` and `m_isin`) and date (`c_datadate` and `m_datadate`) included for matching

For detailed information on data acquisition, see the README file in the `data/` directory.