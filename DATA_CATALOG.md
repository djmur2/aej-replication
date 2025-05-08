# Data Catalog

This document catalogs all data files used in the replication package for "The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax".

## Raw Data Files

### Country-Specific Stock Market Data (Proprietary)

These files contain stock market data from Compustat and Markit for different European countries. They are proprietary and must be obtained by researchers with appropriate licenses.

| Filename | Description | Source | Variables |
|----------|-------------|--------|-----------|
| `0_raw_data/aut.csv` | Austria stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/bel.csv` | Belgium stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/che.csv` | Switzerland stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/deu.csv` | Germany stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/dnk.csv` | Denmark stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/esp.csv` | Spain stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/fin.csv` | Finland stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/fra.csv` | France stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/gbr.csv` | United Kingdom stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/irl.csv` | Ireland stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/isl.csv` | Iceland stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/ita.csv` | Italy stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/lux.csv` | Luxembourg stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/nld.csv` | Netherlands stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/nor.csv` | Norway stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/prt.csv` | Portugal stock market data | Compustat, Markit | Stock prices, volumes, lending data |
| `0_raw_data/swe.csv` | Sweden stock market data | Compustat, Markit | Stock prices, volumes, lending data |

### Dividend Withholding Tax Revenue Data

| Filename | Description | Source | Variables |
|----------|-------------|--------|-----------|
| `0_raw_data/DWT Revenue Data/DWT_Revenues_Overview_Sept2022.xlsx` | Dividend withholding tax revenue data | National tax authorities | Country, Year, GrossDWT, RefundDWT, NetDWT |
| `0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.xlsx` | Exchange rate data | World Bank | Country, Year, Exchange rates |
| `0_raw_data/DWT Revenue Data/ExchangeRates_WB_clean.dta` | Exchange rate data (Stata format) | World Bank | Country, Year, Exchange rates |

## Intermediate Data Files

These files are created during the data transformation process:

| Filename | Description | Created By | Used By |
|----------|-------------|------------|---------|
| `2_final_data/aut.dta` | Austria data (Stata format) | `1_import_data.do` | `frag_data_prep_*.do` |
| `2_final_data/bel.dta` | Belgium data (Stata format) | `1_import_data.do` | `frag_data_prep_*.do` |
| ... | ... | ... | ... |
| `2_final_data/swe.dta` | Sweden data (Stata format) | `1_import_data.do` | `frag_data_prep_*.do` |
| `2_final_data/dataforanalysis_dnk.dta` | Processed Denmark data | `frag_*_*.do` | `4_appending.do` |
| `2_final_data/dataforanalysis_fin.dta` | Processed Finland data | `frag_*_*.do` | `4_appending.do` |
| `2_final_data/dataforanalysis_nor.dta` | Processed Norway data | `frag_*_*.do` | `4_appending.do` |
| `2_final_data/dataforanalysis_swe.dta` | Processed Sweden data | `frag_*_*.do` | `4_appending.do` |
| `2_final_data/dnk_fin_swe_nor.dta` | Combined Nordic countries data | `4_appending.do` | `Table3_TableC2_Table4_TableC1_Figure1.do` |
| `2_final_data/Data_Tax.dta` | Processed tax revenue data | `Preparing_DWTRevenueData.do` | `Figure10_Table5_T.R` |
| `2_final_data/capx_treatment_yearly.dta` | Investment data | `Table3_TableC2_Table4_TableC1_Figure1.do` | `Table3_TableC2_Table4_TableC1_Figure1.do` |
| `2_final_data/Data_WelfareAnalysis_Sept2022.dta` | Welfare analysis data | `Preparing_DWTRevenueData.do` | Analysis code |

## Output Files

These files are the final results of the analysis:

| Filename | Description | Created By | Contents |
|----------|-------------|------------|----------|
| `4_output/Figure10_synthDiD_NetDWT_Revenue_data_sept22.png` | Figure 10 in the paper | `Figure10_Table5_T.R` | Synthetic DiD plot |
| `4_output/Table5.tex` | Table 5 in the paper | `Figure10_Table5_T.R` | Synthetic DiD results |
| `4_output/Table3_sumstats.tex` | Table 3 in the paper | `Table3_TableC2_Table4_TableC1_Figure1.do` | Summary statistics |
| `4_output/Table3_sumstats_obs.tex` | Observations for Table 3 | `Table3_TableC2_Table4_TableC1_Figure1.do` | Observation counts |
| `4_output/TableA_sumstats_appendix.tex` | Appendix Table C2 | `Table3_TableC2_Table4_TableC1_Figure1.do` | Extended statistics |
| `4_output/Novo_Nordisk.png` | Figure 1A in the paper | `Table3_TableC2_Table4_TableC1_Figure1.do` | Novo Nordisk case study |
| `4_output/Svenska_Handelsbanken.png` | Figure 1B in the paper | `Table3_TableC2_Table4_TableC1_Figure1.do` | Svenska Handelsbanken case study |
| `4_output/dnk_dwt_revenue.png` | Denmark revenue plot | Analysis code | DWT revenue for Denmark |
| `4_output/fin_dwt_revenue.png` | Finland revenue plot | Analysis code | DWT revenue for Finland |
| `4_output/nor_dwt_revenue.png` | Norway revenue plot | Analysis code | DWT revenue for Norway |
| `4_output/swe_dwt_revenue.png` | Sweden revenue plot | Analysis code | DWT revenue for Sweden |

## Variable Descriptions

### Stock Market Data Variables

| Variable | Description | Units |
|----------|-------------|-------|
| `c_gvkey` | Compustat Global Company Key | ID |
| `c_isin` | International Securities Identification Number | ID |
| `c_prccd` | Price in local currency | Currency |
| `c_cshtrd` | Shares traded | Count |
| `c_cshoc` | Shares outstanding | Count |
| `c_divdgross` | Dividend amount (gross) | Currency |
| `m_lendervalueonloan` | Value of shares on loan | Currency |
| `m_lenderquantityonloan` | Quantity of shares on loan | Count |
| `m_lendablequantity` | Quantity of shares available for lending | Count |
| `m_utilisation` | Utilization rate | Percent |
| `m_lenderconcentration` | Lender concentration | Index |
| `m_borrowerconcentration` | Borrower concentration | Index |
| `windowcount` | Days relative to ex-dividend date | Days |
| `shortinterest` | Stock lending as percentage of shares outstanding | Percent |

### Tax Revenue Data Variables

| Variable | Description | Units |
|----------|-------------|-------|
| `Country` | Country code | ISO code |
| `Year` | Year | Year |
| `GrossDWT` | Gross dividend withholding tax revenue | Currency |
| `RefundDWT` | Refunded dividend withholding tax | Currency |
| `NetDWT` | Net dividend withholding tax revenue | Currency |
| `NetDWT_Mil_USD` | Net dividend withholding tax revenue in millions USD | USD |