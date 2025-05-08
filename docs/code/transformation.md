# Data Transformation Code

This section documents the Stata code used for data transformation in the replication package.

## Overview

The data transformation process consists of the following steps:

1. **Data Import**: Converting CSV files to Stata format
2. **Data Preparation**: Cleaning and preparing the data
3. **Stock Exchange Selection**: Selecting the appropriate stock exchanges for each country
4. **Exchange Rate Conversion**: Converting financial values to a common currency
5. **Event Window Creation**: Creating windows around ex-dividend dates
6. **Data Appending**: Combining data from multiple countries

## Main Script

The main script that orchestrates the transformation process is `0_alltodos_code.do`.

### Purpose

This script controls the entire data transformation workflow by calling other scripts in the correct order.

### Usage

```stata
do "${path}1_transformation_code/config.do"
do "${path}1_transformation_code/0_alltodos_code.do"
```

### Key Components

```stata
* Data Import
run "${do}/1_import_data.do"

* Data Preparation
local countries "aut bel che deu dnk esp fin fra gbr irl ita nld nor prt swe"
foreach now in `countries' {
    use "${data}/`now'.dta", clear
    do "${do}frag_data_prep_1"
    do "${do}frag_`now'_stock_exchange_selection"
    do "${do}frag_data_prep_2"
    do "${do}frag_`now'_exchange_rate_conversion"
    do "${do}frag_data_prep_3.do"
    save "${data}/dataforanalysis_`now'_1.dta", replace
}

* Data Appending
run "${do}4_appending"
```

## Data Import Script

### File: `1_import_data.do`

This script imports the raw CSV files for each country and converts them to Stata format.

### Key Components

```stata
import delimited "${data}aut.csv", clear
duplicates drop
save "${data}aut.dta", replace

import delimited "${data}bel.csv", clear
duplicates drop
save "${data}bel.dta", replace

// ... and so on for each country
```

## Data Preparation Scripts

### File: `frag_data_prep_1.do`

This script performs the initial data preparation for each country.

### Key Functions

1. **Identifier Creation**: Creates unique identifiers for security-listing pairs
2. **Data Filtering**: Keeps only relevant observations
3. **Date Formatting**: Converts string dates to Stata date format
4. **Ex-Dividend Date Marking**: Identifies ex-dividend dates

### Key Code Snippets

```stata
* Create identifiers
egen id=group(c_isin m_isin m_sedol), missing

* Drop non-matched data
drop if c_gvkey==.

* Create date variables
gen date = date(c_datadate, "YMD")
format %td date
gen year=year(date)
gen month=month(date)
gen day=day(date)

* Mark ex-dividend dates
gen exdivdummy=c_divdgross<.
```

### File: `frag_data_prep_2.do`

This script performs the second stage of data preparation.

### Key Functions

1. **Business Day Identification**: Identifies business days
2. **Trading Activity Marking**: Marks days with trading activity

### Key Code Snippets

```stata
* Define business days
gen trade=0
replace trade=1 if c_cshtrd<.
bys c_exch date: egen stockstraded=total(trade)
gen businessday=0
replace businessday=1 if stockstraded>0

* Drop non-business days
drop if businessday==0
```

### File: `frag_data_prep_3.do`

This script performs the final stage of data preparation.

### Key Functions

1. **Market Cap Calculation**: Calculates market capitalization
2. **Short Interest Calculation**: Calculates stock lending metrics
3. **Event Window Creation**: Creates windows around ex-dividend dates

### Key Code Snippets

```stata
* Calculate market cap
gen price_USD=price_interp*exchange_rate
gen marketcap=sharesoutstanding*price_USD
bys c_isin year: egen yearlymarketcap=mean(marketcap)

* Calculate short interest
gen shortinterest=m_lenderquantityonloan/sharesoutstanding*100

* Create event windows
gen eventwindow=0
foreach i of numlist -15/15{    
    replace eventwindow=1 if c_gvkey==c_gvkey[_n+`i']&/*
                        */bus_day<=bus_dayend[_n+`i']&bus_day>=bus_daybegin[_n+`i'] & eventwindow==0 & exdivdummy[_n+`i']<.
}
```

## Country-Specific Scripts

### Stock Exchange Selection

Each country has a specific script for selecting the appropriate stock exchange.

#### Example: `frag_dnk_stock_exchange_selection.do`

```stata
* Select Danish stock exchange
keep if c_exchg==144 
gen StockExch_country="."
replace StockExch_country="DNK" if c_exchg==144
drop if c_loc!=StockExch_country
```

### Exchange Rate Conversion

Each country has a specific script for currency conversion.

#### Example: `frag_dnk_exchange_rate_conversion.do`

```stata
* Convert Danish currency
replace danishkronedkk=danishkronedkk/usdollar
ipolate danishkronedkk date, gen(DNK_exchange)
gen price_interp=c_prccd
gen exchange_rate=0
replace exchange_rate=DNK_exch if c_exchg==144
```

## Data Appending Script

### File: `4_appending.do`

This script combines the processed data from multiple countries.

### Key Functions

1. **Data Appending**: Combines data from Denmark, Finland, Sweden, and Norway
2. **Country Identification**: Adds country identifiers
3. **Final Data Saving**: Saves the combined dataset

### Key Code Snippets

```stata
clear
append using "${data}dataforanalysis_dnk.dta"
gen idc="DNK"
append using "${data}dataforanalysis_fin.dta"
replace idc="FIN" if idc==""
replace country=2 if idc=="FIN"
append using "${data}dataforanalysis_swe.dta"
replace idc="SWE" if idc==""
replace country=4 if idc=="SWE"
append using "${data}dataforanalysis_nor.dta"
replace idc="NOR" if idc==""
replace country=3 if idc=="NOR"

gen id=c_gvkey
save "${path}2_final_data/dnk_fin_swe_nor.dta",replace
```

## Input and Output Files

### Input Files

- Raw CSV files for each country (`0_raw_data/*.csv`)
- Exchange rate data (`0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.xlsx`)

### Intermediate Files

- Country-specific Stata data files (`2_final_data/*.dta`)
- Processed country data (`2_final_data/dataforanalysis_*.dta`)

### Output Files

- Combined Nordic countries data (`2_final_data/dnk_fin_swe_nor.dta`)