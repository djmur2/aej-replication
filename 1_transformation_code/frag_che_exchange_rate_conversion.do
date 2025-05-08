
*****************************Country Specific Code***************************************************************
* Beginning with the latter: interpolate the exchange rate for missing dates
replace swissfrancchf=swissfrancchf/usdollar
ipolate swissfrancchf date, gen(CHE_exchange)

* Interpolate stock prices by security (use the epolate option to allow for extrapolation)
*bys isinn: ipolate c_prccd date, gen(price_interp) epolate
gen price_interp=c_prccd
* Generate the relevant exchange rate 
gen exchange_rate=0
replace exchange_rate=CHE_exchange if c_exchg==151

sum exchange_rate
****************************************************************************************************************************************
****************************************************************************************************************************************
