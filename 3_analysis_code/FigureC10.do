**********************************************************************
***** Replication code for 
***** The Big Short (Interest): 
***** Closing the Loopholes in the Dividend-Withholding Tax
***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
**********************************************************************


* Note to replicators:
* Set the path below to lead to the replication folder


global path "/Users/eva/Dropbox/Proj_Taxloop/Submissions/Journal Submissions/AEJ Submission Files/Replication package/"	

global data		"${path}2_final_data/"
global output	"${path}4_output/"
clear all 

****************************************
* 1 * Create Figure C10 Net DWT Revenues and Refunds
****************************************

use  "${data}Data_Tax.dta",clear
*
gen percentagerefund=Refund/Gross

sort Year
set scheme s1color
twoway line NetDWT Year  if Country=="DNK", ytitle("Net DWT USD") lcolor(blue) /*
*/ lwidth(1) ylabel(0 500 1000 1500 2000 2500 3000 3500)|| /*
*/line percentagerefund Year if Country=="DNK", lwidth(1, axis(2)) /*
*/ylabel(0 0.2 0.4 0.6 0.8 1.0, axis(2)) lwidth(1) yaxis(2) ytitle("Percentage Refund", axis(2)) 
graph export "${output}FigureC10_dnk_dwt_revenue.png", replace

twoway line NetDWT Year  if Country=="FIN", ytitle("Net DWT USD") lcolor(blue) lwidth(1) ylabel(0 500 1000 1500 2000 2500 3000 3500)|| line percentagerefund Year if Country=="FIN", ylabel(0 0.2 0.4 0.6 0.8 1.0, axis(2)) lwidth(1) yaxis(2) ytitle("Percentage Refund", axis(2))
graph export "${output}FigureC10_fin_dwt_revenue.png", replace

twoway line NetDWT Year  if Country=="NOR", ytitle("Net DWT USD") lcolor(blue) lwidth(1) ylabel(0 500 1000 1500 2000 2500 3000 3500)|| line percentagerefund Year if Country=="NOR", ylabel(0 0.2 0.4 0.6 0.8 1.0, axis(2)) lwidth(1) yaxis(2) ytitle("Percentage Refund", axis(2))
graph export "${output}FigureC10_nor_dwt_revenue.png", replace

twoway line NetDWT Year  if Country=="SWE", ytitle("Net DWT USD") lcolor(blue) lwidth(1) ylabel(0 500 1000 1500 2000 2500 3000 3500)|| line percentagerefund Year if Country=="SWE", ylabel(0 0.2 0.4 0.6 0.8 1.0, axis(2)) lwidth(1) yaxis(2) ytitle("Percentage Refund", axis(2))
graph export "${output}FigureC10_swe_dwt_revenue.png", replace
