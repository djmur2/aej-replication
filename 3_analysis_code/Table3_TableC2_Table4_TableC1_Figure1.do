**********************************************************************
***** Replication code for 
***** The Big Short (Interest): 
***** Closing the Loopholes in the Dividend-Withholding Tax
***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
**********************************************************************
version 15
set more off


* Note to replicators:
* Set the path below to lead to the folder with replication package

global path "/Users/eva/Dropbox/Proj_Taxloop/Submissions/Journal Submissions/AEJ Submission Files/Replication package/"	
global data		"${path}2_final_data/"

global output	"${path}4_output/"
clear all 


set seed 525443

use  "${data}dnk_fin_swe_nor.dta",clear

***generating the id


* Business calendar used for the sum stats on stock returns
* for Denmark, Danske Bank
bys id (date): gen bus_day=_n if c_isin=="DK0010274414"
bys id (date): replace bus_day=_n if c_isin=="FI0009002943" // Raisio
bys id (date): replace bus_day=_n if c_isin=="NO0010345853" // Aker
bys id (date): replace bus_day=_n if c_isin=="SE0007100599" // Svenska Handelsbanken
bys idc date: egen tmp=min(bus_day) 
replace bus_day=tmp
drop tmp


gen bus_day_po=bus_day+1
* c_split is stock split from the compustat data
replace c_split=1 if c_split==.

****************************************
* 3 * Summary stats for all variables
* starts with the loaded dataset
* then goes into preserve/restore where different data are loaded 
* and the sumstats are calculated
****************************************



****************************************
* TABLE 3 * SUMMARY STATISTICS - SHORT VERSION
****************************************


* Denmark Reform history
* Issue noticed on 28 August 2015
* Dividend season finished around September 2016,t his seems to be amonth with no dividends
* Showing summary statistics for before vs after levaing out the inbetween period because lack of space on the table
gen after=date>td("17mar2016")
gen before=date<td("06aug2015")

label define reform 0 "Before" 1 "After"
label values after reform

label define c 1 "DNK" 2 "FIN" 3 "NOR" 4 "SWE"
label values country c

gen lfactor=.
replace lfactor=9 if windowcount==0
replace lfactor=1 if windowcount<20&country==1&before==1 & windowcount>12
replace lfactor=2 if windowcount<20&country==1&after==1 & windowcount>12
replace lfactor=3 if windowcount<20&country==2&before==1 & windowcount>12
replace lfactor=4 if windowcount<20&country==2&after==1 & windowcount>12
replace lfactor=5 if windowcount<20&country==3&before==1 & windowcount>12
replace lfactor=6 if windowcount<20&country==3&after==1 & windowcount>12
replace lfactor=7 if windowcount<20&country==4&before==1 & windowcount>12
replace lfactor=8 if windowcount<20&country==4&after==1 & windowcount>12

label define lfac 1 "Before DNK" 2 "After DNK" 3 "Before FIN" 4 "After FIN" 5 "Before NOR" 6 "After NOR" 7 "Before SWE" 8 "After SWE" 9 "Outside of Event Window"
label values lfactor lfac


lab var shortinterest "Stocks on Loan"
lab var m_utilisation "Utilisation"
lab var tvbypf "Turnover"
lab var lqbypf "Stocks Available for Lending"
lab var m_lenderconcentration "Lender Concentration"
lab var m_borrowerconcentration "Borrower Concentration"
lab var div_yield "Dividend Yield"


generate y = uniform()+3

eststo clear

bys lfactor: eststo: qui regress y shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration  [aweight=yearlymarketcap], nocons 

estadd summ: *
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles nonumber noobs noline 
filefilter  "${output}temp.tex" "${output}Table3_sumstats.tex" , from("[1em]") to("") replace

esttab using "${output}temp.tex", drop(shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration )  nostar nonote replace frag nomtitles nonumber noline 
filefilter  "${output}temp.tex" "${output}temp1.tex" , from("[1em]") to("") replace
filefilter  "${output}temp1.tex" "${output}Table3_sumstats_obs.tex" , from("/BS(N/BS)") to("Observations $[-3,+3]$") replace
* the command above has stopped working, pazienza

** extract number of events for the sum stat table
tab lfactor if windowcount==16

* Generating the overall number of observations
gen lfactor2=.
replace lfactor2=9 if windowcount==0
replace lfactor2=1 if windowcount!=0&country==1&before==1 
replace lfactor2=2 if windowcount!=0&country==1&after==1 
replace lfactor2=3 if windowcount!=0&country==2&before==1
replace lfactor2=4 if windowcount!=0&country==2&after==1 
replace lfactor2=5 if windowcount!=0&country==3&before==1
replace lfactor2=6 if windowcount!=0&country==3&after==1 
replace lfactor2=7 if windowcount!=0&country==4&before==1
replace lfactor2=8 if windowcount!=0&country==4&after==1 
eststo clear

bys lfactor2: eststo: qui regress y shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration [aweight=yearlymarketcap], nocons 

estadd summ: *
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", drop(shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration )  nostar nonote replace frag nomtitles nonumber noline 
filefilter  "${output}temp.tex" "${output}temp2.tex" , from("[1em]") to("") replace
filefilter  "${output}temp2.tex" "${output}Table3_sumstats_obs_all.tex" , from("/BS(N/BS)") to("Observations $[-15,+15]$") replace
drop lfactor2


*****************************************************************
** TABLE C2. Extended summary statistics first table for appendix
*****************************************************************
gen lfactor2=.
replace lfactor2=13 if windowcount==0
replace lfactor2=1 if windowcount<20&country==1&before==1 & windowcount>12
replace lfactor2=2 if windowcount<20&country==1&before==0&after==0 & windowcount>12
replace lfactor2=3 if windowcount<20&country==1&after==1 & windowcount>12
replace lfactor2=4 if windowcount<20&country==2&before==1 & windowcount>12
replace lfactor2=5 if windowcount<20&country==2&before==0&after==0 & windowcount>12
replace lfactor2=6 if windowcount<20&country==2&after==1 & windowcount>12
replace lfactor2=7 if windowcount<20&country==3&before==1 & windowcount>12
replace lfactor2=8 if windowcount<20&country==3&before==0&after==0 & windowcount>12
replace lfactor2=9 if windowcount<20&country==3&after==1 & windowcount>12
replace lfactor2=10 if windowcount<20&country==4&before==1 & windowcount>12
replace lfactor2=11 if windowcount<20&country==4&before==0&after==0 & windowcount>12
replace lfactor2=12 if windowcount<20&country==4&after==1 & windowcount>12

label define lfac2 1 "Before DNK" 2 "Inbetween DNK" 3 "After DNK" 4 "Before FIN" 5 "Inbetween FIN" 6 "After FIN" 7 "Before NOR" 8 "Inbetween NOR" 9 "After NOR" 10 "Before SWE" 11 "Inbetween SWE" 12 "After SWE" 13 "Outside of Event Window"
label values lfactor2 lfac2

eststo clear
bys lfactor2: eststo: qui regress y shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration [aweight=yearlymarketcap], nocons 
estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 
esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline 
filefilter  "${output}temp.tex" "${output}TableA_sumstats_appendix.tex" , from("[1em]") to("") replace
esttab using "${output}temp.tex", drop(shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration)  nostar nonote replace frag nomtitles nonumber noline 
filefilter  "${output}temp.tex" "${output}temp1.tex" , from("[1em]") to("") replace
filefilter  "${output}temp1.tex" "${output}TableA_sumstats_appendix_obs.tex" , from("/BS(N/BS)") to("Observations $[-3,+3]$") replace

* Generating the overall number of observations
gen lfactor3=.
replace lfactor3=13 if windowcount==0
replace lfactor3=1 if windowcount!=0&country==1&before==1 
replace lfactor3=2 if windowcount!=0&country==1&before==0&after==0 
replace lfactor3=3 if windowcount!=0&country==1&after==1 
replace lfactor3=4 if windowcount!=0&country==2&before==1 
replace lfactor3=5 if windowcount!=0&country==2&before==0&after==0 
replace lfactor3=6 if windowcount!=0&country==2&after==1 
replace lfactor3=7 if windowcount!=0&country==3&before==1 
replace lfactor3=8 if windowcount!=0&country==3&before==0&after==0 
replace lfactor3=9 if windowcount!=0&country==3&after==1 
replace lfactor3=10 if windowcount!=0&country==4&before==1 
replace lfactor3=11 if windowcount!=0&country==4&before==0&after==0 
replace lfactor3=12 if windowcount!=0&country==4&after==1 
eststo clear

bys lfactor3: eststo: qui regress y shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration [aweight=yearlymarketcap], nocons 

estadd summ: *
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", drop(shortinterest lqbypf tvbypf m_lenderconcentration m_borrowerconcentration)  nostar nonote replace frag nomtitles nonumber noline 
filefilter  "${output}temp.tex" "${output}temp1.tex" , from("[1em]") to("") replace
filefilter  "${output}temp1.tex" "${output}TableA_sumstats_appendix_obs_all.tex" , from("/BS(N/BS)") to("Observations $[-15,+15]$") replace

** extract number of events for the sum stat table, 
tab lfactor3 if windowcount==16

drop lfactor2 lfactor3


*****************************************************************
** Table 4. Summary statistics Annual Data
*****************************************************************
preserve

*****************************************************************
*Net DWT Revenue
*****************************************************************

use "${data}Data_tax.dta", clear
lab var NetDWT_Mil_USD "Net DWT Revenue"
rename Country country
gen after=Year>=2015
gen lfactor=9
replace lfactor=1 if country=="DNK"&after==0
replace lfactor=2 if country=="DNK"&after==1
replace lfactor=3 if country=="FIN"&after==0
replace lfactor=4 if country=="FIN"&after==1
replace lfactor=5 if country=="NOR"&after==0
replace lfactor=6 if country=="NOR"&after==1
replace lfactor=7 if country=="SWE"&after==0
replace lfactor=8 if country=="SWE"&after==1
*label define lfac 1 "Before DNK" 2 "After DNK" 3 "Before FIN" 4 "After FIN" 5 "Before NOR" 6 "After NOR" 7 "Before SWE" 8 "After SWE" 9 "Outside of Event Window"

generate y = uniform()+3

eststo clear

bys lfactor: eststo: qui regress y NetDWT_Mil_USD, nocons 

estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline 
filefilter  "${output}temp.tex" "${output}Table4_line1.tex" , from("[1em]") to("") replace


*****************************************************************
* Investment Rate and Div Yield
*****************************************************************

*this dataset is created in 8_appending_capx_new_plots
use "${data}capx_treatment_yearly.dta", clear


replace after=year>=2015
gen lfactor=.
replace lfactor=1 if country==1&after==0
replace lfactor=2 if country==1&after==1
replace lfactor=3 if country==2&after==0
replace lfactor=4 if country==2&after==1
replace lfactor=5 if country==3&after==0
replace lfactor=6 if country==3&after==1
replace lfactor=7 if country==4&after==0
replace lfactor=8 if country==4&after==1
*label define lfac 1 "Before DNK" 2 "After DNK" 3 "Before FIN" 4 "After FIN" 5 "Before NOR" 6 "After NOR" 7 "Before SWE" 8 "After SWE" 9 "Outside of Event Window"
lab var relativecapx "Investment Rate"
lab var div_yield_yearly "Dividend Yield"

generate y = uniform()+3



eststo clear

bys lfactor: eststo: qui regress y relativecapx [aweight=meanmarketcap], nocons 

estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline 
filefilter  "${output}temp.tex" "${output}Table4_line2.tex" , from("[1em]") to("") replace


eststo clear

bys lfactor: eststo: qui regress y div_yield_yearly [aweight=meanmarketcap], nocons 

estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline 
filefilter  "${output}temp.tex" "${output}Table4_line3.tex" , from("[1em]") to("") replace
restore

*****************************************************************
** Table C1. Summary statistics Annual Data by Treatment intensity
*****************************************************************
preserve

use "${data}capx_treatment_yearly.dta", clear

eststo clear

bys lfactor: eststo: qui regress y relativecapx div_yield_yearly if treatmentintensity==1 [aweight=meanmarketcap], nocons 

estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline 
filefilter  "${output}temp.tex" "${output}TableC1_high_treatment.tex" , from("[1em]") to("") replace


eststo clear

bys lfactor: eststo: qui regress y relativecapx div_yield_yearly if treatmentintensity==0 [aweight=meanmarketcap], nocons 

estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline 
filefilter  "${output}temp.tex" "${output}TableC1_low_treatment.tex" , from("[1em]") to("") replace



*Number of obs in Table notes 
bys treatmentintensity: sum lfactor


restore

*****************************************************************
* Stock Return - TBA
*****************************************************************
sort id date
replace div_USD=0 if div_USD==.
gen rit = (price_USD + div_USD - price_USD[_n-1]/c_split) / (price_USD[_n-1]/c_split) if id==id[_n-1] & bus_day==bus_day_po[_n-1]
lab var rit "Stock Market Return"

eststo clear

replace lfactor=. if lfactor==9
bys lfactor: eststo: qui regress y rit [aweight=yearlymarketcap], nocons

estadd summ: *
* weight by market value later on?
esttab, main(mean) aux(sd) label nodepvar nostar nonote 

esttab using "${output}/temp.tex", main(mean) aux(sd) label nodepvar nostar nonote replace frag nomtitles noobs nonumber noline
filefilter  "${output}temp.tex" "${output}Table3_sumstat_return.tex" , from("[1em]") to("") replace

drop lfactor y


****************************************
* 3.2 * Case Study plots
****************************************

****************************************
* 3.2.1 * Figure 1A: Novo Nordisk
****************************************

set scheme s1color

gen tmp=date*exdivdummy
replace tmp=. if tmp==0
sort date
* Same plot for Novo Nordisk
levelsof tmp if c_isin=="DK0060534915", local(dates)
twoway line shortinterest date if c_isin=="DK0060534915", xline(`dates', lpattern(dash) lcolor(black)) ytitle("Stocks on Loan") xtitle("") ylabel(0(2)10)
graph export "${output}Novo_Nordisk.png", replace
drop tmp

****************************************
* 3.2.2 * Figure 1B. Svenska Handelsbanken
****************************************

gen tmp=date*exdivdummy
replace tmp=. if tmp==0
* Find the ex-dividend dates of the largest bank in Sweden: Svenska Handelsbanken"
levelsof tmp if c_isin=="SE0007100599" , local(dates)
twoway line shortinterest date if c_isin=="SE0007100599", xline(`dates', lpattern(dash) lcolor(black)) ytitle("Stocks on Loan") xtitle("") ylabel(0(2)10)
graph export "${output}Svenska_Handelsbanken.png", replace
drop tmp



