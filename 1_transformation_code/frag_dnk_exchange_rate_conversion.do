*****************************Country Specific Code***************************************************************
* Beginning with the latter: interpolate the exchange rate for missing dates
replace danishkronedkk=danishkronedkk/usdollar
ipolate danishkronedkk date, gen(DNK_exchange)


* Interpolate stock prices by security (use the epolate option to allow for extrapolation)
*bys c_isin: ipolate c_prccd date, gen(price_interp) epolate
gen price_interp=c_prccd
* Generate the relevant exchange rate (DKK for stock exchange 144)
gen exchange_rate=0
replace exchange_rate=DNK_exch if c_exchg==144

sum exchange_rate
****************************************************************************************************************************************
****************************************************************************************************************************************
