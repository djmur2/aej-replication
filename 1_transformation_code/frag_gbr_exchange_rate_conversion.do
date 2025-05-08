
*****************************Country Specific Code***************************************************************
* Beginning with the latter: interpolate the exchange rate for missing dates
gen pounddollar=ukpoundgbp/usdollar
ipolate pounddollar date, gen(GBR_exchange)

* Interpolate stock prices by security (use the epolate option to allow for extrapolation)
*bys isinn: ipolate c_prccd date, gen(price_interp) epolate
gen price_interp=c_prccd

* Generate the relevant exchange rate (SKK for stock exchange 144, DKK for stock exchange 256)
gen exchange_rate=0
replace exchange_rate=GBR_exch if c_exchg==226 | c_exchg==194


sum exchange_rate
****************************************************************************************************************************************
****************************************************************************************************************************************
