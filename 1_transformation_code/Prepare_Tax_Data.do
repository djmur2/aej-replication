**********************************************************************
***** Replication code for 
***** The Big Short (Interest): 
***** Closing the Loopholes in the Dividend-Withholding Tax
***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
**********************************************************************


* Note to replicators:
* Set the path below to lead to the folder 0_raw_data


global path_input "/Users/eva/Dropbox/Proj_Taxloop/Submissions/Journal Submissions/AEJ Submission Files/Replication package/0_raw_data/"

global path_output "/Users/eva/Dropbox/Proj_Taxloop/Submissions/Journal Submissions/AEJ Submission Files/Replication package/2_final_data/"


* Import and clean out World Bank exchange rates for the used currencies
import excel "${path_input}ExchangeRates_WB_clean.xlsx", firstrow clear

reshape long Y_, i(CountryName CountryCode IndicatorName IndicatorCode) j(Year)

keep CountryCode Year Y_

rename Y_ exchangerates
rename CountryCode Country

save "${path_input}ExchangeRates_WB_clean.dta", replace


* import the collected tax revenue data
import excel "${path_input}DWT_Revenues_Overview_Sept2022.xlsx", firstrow clear

* merge to the exchange rates
merge 1:1 Country Year using "${path_input}ExchangeRates_WB_clean.dta"
keep if _merge==3
drop _merge

* apply the exchange rates
gen GrossDWT_Mil_USD=(GrossDWT/exchangerates)
gen RefundDWT_Mil_USD=(RefundDWT/exchangerates)
gen NetDWT_Mil_USD=(NetDWT/exchangerates)

keep Country Year GrossDWT_Mil_USD RefundDWT_Mil_USD NetDWT_Mil_USD

save "${path_output}Data_Tax.dta", replace
