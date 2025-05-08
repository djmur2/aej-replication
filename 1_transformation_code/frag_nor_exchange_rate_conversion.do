
*****************************Country Specific Code***************************************************************
* Beginning with the latter: interpolate the exchange rate for missing dates
replace norwegiankronenok=norwegiankronenok/usdollar
ipolate norwegiankronenok date, gen(NOR_exchange)


* Interpolate stock prices by security (use the epolate option to allow for extrapolation)
* Interpolate stock prices by security (use the epolate option to allow for extrapolation)
*bys isinn: ipolate c_prccd date, gen(price_interp) epolate
gen price_interp=c_prccd

* Generate the relevant exchange rate (SKK for stock exchange 144, DKK for stock exchange 256)
gen exchange_rate=0
replace exchange_rate=NOR_exch if c_exchg==228

sum exchange_rate
****************************************************************************************************************************************
****************************************************************************************************************************************
