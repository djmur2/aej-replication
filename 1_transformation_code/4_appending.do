**********************************************************************
***** Replication code for 
***** The Big Short (Interest): 
***** Closing the Loopholes in the Dividend-Withholding Tax
***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
**********************************************************************


* This file is called in 1_alltodos_code


****************************************
* 1 * Appending the three Scandinavian countries
****************************************
clear
append using "${data}dataforanalysis_dnk.dta"
* Create a new country identifier
gen idc="DNK"
append using "${data}dataforanalysis_fin.dta"
replace idc="FIN" if idc==""
replace country=2 if idc=="FIN"
append using "${data}dataforanalysis_swe.dta"
replace idc="SWE" if idc==""
replace country=4 if idc=="SWE"
append using "${data}dataforanalysis_nor.dta"
replace idc="NOR" if idc==""
replace country=3 if idc=="NOR"


****************************************
* 2 * Data Prep
****************************************

capt drop tmp
set scheme s1color
sort c_gvkey date

gen id=c_gvkey

save "${path}2_final_data/dnk_fin_swe_nor.dta",replace


