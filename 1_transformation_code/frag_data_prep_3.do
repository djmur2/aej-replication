* Now we have the stock price in USD as follows
gen price_USD=price_interp*exchange_rate
* Now interpolate shares outstanding for missings
*bys c_isin: ipolate c_cshoc date, gen(sharesoutstanding) epolate
gen sharesoutstanding=c_cshoc
* calculate the daily market valuation by the price with the shares outstanding
gen marketcap=sharesoutstanding*price_USD
* Generate monthly market cap
bys c_isin year: egen yearlymarketcap=mean(marketcap)
* Generate marketcap by isin
bys c_isin: egen avgmarketcap=mean(yearlymarketcap)
/* Rank securities by marketcap
preserve
keep avgmarketcap c_exch isinn
duplicates drop
bys c_exch: egen rankmarketcap=rank(-avgmarketcap)
drop avgmarketcap
save tmp.dta, replace
restore
merge m:1 c_exch isinn using tmp.dta, nogen
sort isin date
*/
* Generate a measure of stocks on loan divided by marketcap shares outstanding
gen shortinterest=m_lenderquantityonloan/sharesoutstanding*100
sum shortinterest, d

bys c_gvkey: gen tmp=_N
egen tmp2=max(tmp)
bys c_gvkey (date): gen bus_day=_n if tmp==tmp2
bys date: egen tmp3=min(bus_day)
replace bus_day=tmp3


drop tmp*


sort c_gvkey date
* Generate a counter for each dividend event (on the ex-div date)
egen eventcounter=group(c_gvkey date) if exdivdummy==1
* Now we create the estimation window. We will consider a 15-day window around the exdivdate and label a variable from -15 to plus 15 for each dividend event.
* Eventwindow is a variable that will (after the loop) equal 1 for all days in the event window.


gen eventwindow=0

gen bus_dayevent=bus_day if exdivdummy==1
gen bus_daybegin=bus_dayevent-15
gen bus_dayend=bus_dayevent+15


foreach i of numlist -15/15{	
replace eventwindow=1 if c_gvkey==c_gvkey[_n+`i']&/*
						*/bus_day<=bus_dayend[_n+`i']&bus_day>=bus_daybegin[_n+`i'] & eventwindow==0 & exdivdummy[_n+`i']<.

replace eventcounter=eventcounter[_n+`i'] if c_gvkey==c_gvkey[_n+`i']&/*
						*/bus_day<=bus_dayend[_n+`i']&bus_day>=bus_daybegin[_n+`i'] & eventcounter==. & exdivdummy[_n+`i']<.

}
drop bus_daybegin bus_dayend bus_day bus_dayevent

drop if eventwindow==1 & shortinterest==.


* And expand the windowcount (this can be done outside of a loop, because Stata updates over _n-1).
sort c_isin date
bys eventcounter (date): gen windowcount=_n if eventwindow==1
* Find the maximum value for a windowcount. This should be 31.
bys eventcounter: egen tmp=total(eventwindow) if eventwindow==1
sort c_isin date
* If the maximum is less than 31 we do not fully observe the event. Drop these observations
drop if tmp<31
*then drop the companies for which we oserve no events at all 
bys c_isin: egen tmp2=total(exdivdummy)
drop if tmp2==0
drop tmp tmp2

replace windowcount=0 if windowcount==.
qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Clean_Events
matrix drop=[drop\tmp]
matlist drop

**** Convert dividends in whatever currency into USD
* Check for SKK issuing dividends in DKK: tab2 c_exchg c_curcddv
gen div_USD=c_divdgross*exchange_rate
replace div_USD=c_divdgross if c_curcddv=="USD"
*replace div_USD=. if c_curcddv=="EUR"
*gen div_yield_=div_USD/price_USD
*bys c_isin eventcounter: egen div_yield=min(div_yield_)

*drop if eventcounter<. & div_yield==.

* Create a group variable for country of headquarter and country of incorporation if both are equal 
egen country=group(c_fic c_loc) if c_fic==c_loc, label

* Drop if the country of incorporation is different from the headquarter country
drop if country==.
qui distinct id if short<.
local id=r(ndistinct)
qui distinct c_gvkey if short<.
local gvkey=r(ndistinct)
qui count if short<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Incorporation_equals_Headquarers
matrix drop=[drop\tmp]
matlist drop



*creating a DRIP dummy based on whether sharesoutstanding increases during event_window

replace yearlymarketcap=0 if yearlymarketcap <0
gen difference = c_cshoc - c_cshoc[_n-1]
gen drip_dummy=0
replace drip_dummy=1 if difference>0 & eventwindow==1
bys eventcounter: egen tmp=max( drip_dummy)
replace drip_dummy=tmp
drop tmp


**Add quartiling and variable creation
capt drop tmp
set scheme s1color
sort c_isin date
* generate new vars - STOCK MARKET VOLUME RELATIVE TO NUMBER OF SHARES
gen tvbypf=(c_cshtrd/sharesoutstanding)*100

*SHARES AVAILABLE FOR LENDING AS FRACTION OF PUBLIC FLOAT
gen lqbypf=(m_lendablequantity/sharesoutstanding)*100


reghdfe shortinterest ib0.windowcount ib0.windowcount#c.drip_dummy [aweight=yearlymarketcap], abs(year#c_gvkey) vce(cl c_gvkey) nocons keepsingletons
* drop observations for which there is no short interest observed
* these are mainly out of the event window
keep if e(sample)
qui distinct id if short<.
local id=r(ndistinct)
qui distinct c_gvkey if short<.
local gvkey=r(ndistinct)
qui count if short<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Missing_Short_Interest
matrix drop=[drop\tmp]
matlist drop


bys c_gvkey: egen meanmarketcap = mean(yearlymarketcap) 

gen quartile_marketcap=.
qui sum meanmarketcap, d
qui replace quartile_marketcap=1 if meanmarketcap<r(p25)
qui replace quartile_marketcap=2 if meanmarketcap<r(p50)&quartile_marketcap==.
qui replace quartile_marketcap=3 if meanmarketcap<r(p75)&quartile_marketcap==.
qui replace quartile_marketcap=4 if meanmarketcap<.&quartile_marketcap==.



bys c_isin year: egen tmp=sum(div_USD)
bys c_isin year: egen tmp2=mean(price_USD)
gen div_yield_yearly=tmp/tmp2
drop tmp tmp2

bys id: egen meandivyield = mean(div_yield_yearly)
gen quartile_div_yield=.
sum meandivyield, d
replace quartile_div_yield=1 if meandivyield<r(p25)
replace quartile_div_yield=2 if meandivyield<r(p50)&quartile_div_yield==.
replace quartile_div_yield=3 if meandivyield<r(p75)&quartile_div_yield==.
replace quartile_div_yield=4 if meandivyield<.&quartile_div_yield==.
destring, replace

drop id
compress
