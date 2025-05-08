*********************************************************************
***** Replication code for 
***** The Big Short (Interest): 
***** Closing the Loopholes in the Dividend-Withholding Tax
***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
*********************************************************************

* Load configuration
do "${path}1_transformation_code/config.do"



****************************************
* 1 * Data Import, save as .dta
****************************************
run "${do}/0_import_data.do"

****************************************
* 2 * Data Preparation
****************************************

version 15
set more off
local countries "aut bel che deu dnk esp fin fra gbr irl ita nld nor prt swe"

foreach now in `countries' {
use "${data}/`now'.dta", clear
di "step: chunk 1"
do "${do}frag_data_prep_1"
di "step: select the stock exchanges"
do "${do}frag_`now'_stock_exchange_selection"
di "step: chunk 2"
do "${do}frag_data_prep_2"
di "step: fix the currency conversion"
do "${do}frag_`now'_exchange_rate_conversion"
di "step: last chunk"
do "${do}frag_data_prep_3.do"
save "${data}/dataforanalysis_`now'_1.dta", replace
}



****************************************
* 4 * Main analysis on the 3 Scandinavian countries
****************************************


run "${do}4_appending"



The part below has to be moved to a later point
****************************************
* 3 * Extracting regression coefficients for maps, code continues in R
****************************************
****************************************
*  * Short Interest
****************************************

local countries "aut bel che deu dnk esp fin fra gbr irl ita nld nor prt swe"
foreach now in `countries' {
use "${data}dataforanalysis_`now'.dta", clear
replace windowcount=0 if windowcount==.
rename shortinterest depvar
do "${do}frag_map_input.do"
save "${data}country_shortinterest_`now'_1.dta", replace
}




****************************************
*   * THE END
****************************************

