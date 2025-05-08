global path "C:\Users\S14961\Dropbox\LOOPHOLES\Data\WHT Dividend Revenues\Analysis\Data DWT\"

import excel "${path}ExchangeRates_WB_clean.xlsx", firstrow clear

reshape long Y_, i(CountryName CountryCode IndicatorName IndicatorCode) j(Year)

keep CountryCode Year Y_

rename Y_ exchangerates
rename CountryCode Country

save "${path}ExchangeRates_WB_clean.dta", replace


import excel "${path}DWT_Revenues_Overview_Sept2022.xlsx", firstrow clear


merge 1:1 Country Year using "${path}ExchangeRates_WB_clean.dta"
keep if _merge==3
drop _merge


gen GrossDWT_total=GrossDWT if Country!="DNK"
replace GrossDWT_total=GrossDWT*1000000 if Country=="DNK"

gen RefundDWT_total=RefundDWT if Country!="DNK"
replace RefundDWT_total=RefundDWT*1000000 if Country=="DNK"

gen NetDWT_total=NetDWT if Country!="DNK"
replace NetDWT_total=NetDWT*1000000 if Country=="DNK"


gen GrossDWT_Mil_USD=(GrossDWT_total/exchangerates)/1000000
gen RefundDWT_Mil_USD=(RefundDWT_total/exchangerates)/1000000
gen NetDWT_Mil_USD=(NetDWT_total/exchangerates)/1000000

keep Country Year GrossDWT_Mil_USD RefundDWT_Mil_USD NetDWT_Mil_USD

save "${path}Data_WelfareAnalysis_Sept2022.dta", replace
