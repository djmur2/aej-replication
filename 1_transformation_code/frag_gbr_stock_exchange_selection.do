******************Country Specific Part******************************************************************************************************
**from compustat, check number of companies per each country on each stock exchange and keep the highest ones)
keep if c_exchg==226 | c_exchg==194
**We want to identify the country where the stock exchange is to drop afterwards companies listed in one country but HQ in another
gen StockExch_country="."
replace StockExch_country="GBR" if c_exchg==226 | c_exchg==194

drop if c_loc!=StockExch_country
**************************************************************************************************************************************
**************************************************************************************************************************************
