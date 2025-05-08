******************Country Specific Part******************************************************************************************************
**from compustat, check number of companies per each country on each stock exchange and keep the highest ones)
keep if c_exchg==171 | c_exchg==212 | c_exchg==154 | c_exchg==165
**We want to identify the country where the stock exchange is to drop afterwards companies listed in one country but HQ in another
gen StockExch_country="."
replace StockExch_country="DEU" if c_exchg==171 | c_exchg==212 | c_exchg==154 | c_exchg==165

drop if c_loc!=StockExch_country
**************************************************************************************************************************************
**************************************************************************************************************************************
