version 15
set more off

* Import and save data for each countries separately
**Country list: AT BE CH DE DK ES FI FR GB IE IS IT LU NL NO PT SE 

import delimited "${data}aut.csv", clear
duplicates drop
save "${data}aut.dta", replace

import delimited "${data}bel.csv", clear
duplicates drop
save "${data}bel.dta", replace

import delimited "${data}che.csv", clear
duplicates drop
save "${data}che.dta", replace

import delimited "${data}deu.csv", clear
duplicates drop
save "${data}deu.dta", replace

import delimited "${data}dnk.csv", clear
duplicates drop
save "${data}dnk.dta", replace

import delimited "${data}esp.csv", clear
duplicates drop
save "${data}esp.dta", replace

import delimited "${data}fin.csv", clear
duplicates drop
save "${data}fin.dta", replace

import delimited "${data}fra.csv", clear
duplicates drop
save "${data}fra.dta", replace

import delimited "${data}gbr.csv", clear
duplicates drop
save "${data}gbr.dta", replace

import delimited "${data}irl.csv", clear
duplicates drop
save "${data}irl.dta", replace

import delimited "${data}isl.csv", clear
duplicates drop
save "${data}isl.dta", replace

import delimited "${data}ita.csv", clear
duplicates drop
save "${data}ita.dta", replace

import delimited "${data}lux.csv", clear
duplicates drop
save "${data}lux.dta", replace

import delimited "${data}nld.csv", clear
duplicates drop
save "${data}nld.dta", replace

import delimited "${data}nor.csv", clear
duplicates drop
save "${data}nor.dta", replace

import delimited "${data}prt.csv", clear
duplicates drop
save "${data}prt.dta", replace

import delimited "${data}swe.csv", clear
duplicates drop
save "${data}swe.dta", replace


