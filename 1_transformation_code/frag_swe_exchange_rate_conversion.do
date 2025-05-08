**************************************************************************************************************************************

** Now we want to calculate the market-value of different companies. There are several issues: 1. the stock price in Compustat is in local currency, we want USD, 
* 2. the stock prices are sometimes missing, 3. exchange rates (from the IMF) are sometimes missing

*****************************Country Specific Code***************************************************************
* Beginning with the latter: interpolate the exchange rate for missing dates
replace swedishkronasek=swedishkronasek/usdollar
ipolate swedishkronasek date, gen(SWE_exchange)

* Interpolate stock prices by security (use the epolate option to allow for extrapolation)
*bys isinn: ipolate c_prccd date, gen(price_interp) epolate
gen price_interp=c_prccd
* Generate the relevant exchange rate (SKK for stock exchange 144, DKK for stock exchange 256)
gen exchange_rate=0
replace exchange_rate=SWE_exchange if c_exchg==256 
