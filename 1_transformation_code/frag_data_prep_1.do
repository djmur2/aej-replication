* Identifier for a security-listing pair
egen id=group(c_isin m_isin m_sedol), missing
** Throughout the code when we are dropping observations we keep track of in the Matrix drop
* which is formed with this little snippet of code here
* Nr of distinct security-listing pairs for which we observe our main dependent variable
qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
* Distinct nr of companies
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
* Number of observations
qui count if m_lendervalueonloan<.
local obs=r(N)
* Store the results in a matrix
matrix drop=[`obs', `id', `gvkey']
matrix colnames drop=Observations Securities Companies
matrix rownames drop=Initial

*In this data, "m_" denotes variables that come from markit, "c_" denotes vars from compustat
* We have kept all of compustat, even if markit has missings-> we use compustat date and isin.
* Drop the data that is not matched on compustat
drop if c_gvkey==.
qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=In_Compustat
matrix drop=[drop\tmp]

* Drop one of the two dates and isin variables (they are the same)
drop m_datadate m_isin
* Create a Stata date variable out of the string date variable
gen date = date(c_datadate, "YMD")
format %td date
* Split the dates into year, months, days day of the week
gen year=year(date)
gen month=month(date)
gen day=day(date)
gen dow=dow(date)
* The Markit data is not really complete before 2010 so drop it.
drop if year<2010 | year>2019
qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=After_2010
matrix drop=[drop\tmp]


* Transform isin into a numeric value.  
*encode c_isin, gen(isinnumeric)
* Find the minimum dividend payment by isin
bys c_isin: egen tmp=min(c_divdgross)
* Drop those that never pay a dividend
drop if tmp==.
drop tmp

qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Paying_Dividend
matrix drop=[drop\tmp]
matlist drop

* The next command will drop one additional observation (with lendervalueonloan), and ensure that isin and sedol jointly identify a security (isin) and a listing (sedol) 
duplicates drop date c_isin m_sedol, force
* Calculate mean_lendable value
bys c_gvkey c_isin m_sedol: egen meanlendervalueonloan=mean(m_lendervalueonloan)
* Drop securities for whom the meanlendablevalue is never observed (no relevant data from Markit)
drop if meanlendervalueonloan==.
qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Lendable_Value_Observed
matrix drop=[drop\tmp]
matlist drop
* Per company gvkey there can be several isin (security), which have sometimes have muliple listings. 
*we select the securities*listing with maximum lendervalue on loan
* in this way we reduce the multiple listings to one per security
bys c_isin: egen maxlendervalueonloan=max(meanlendervalueonloan)
keep if maxlendervalueonloan==meanlendervalueonloan

* here we keep the security by company with the highest marketcap

gen tempmarketcap=c_cshoc*c_prccd
bys c_gvkey c_isin m_sedol: egen totmarketcap=mean(tempmarketcap)
drop tempmarketcap

bys c_gvkey: egen maxmarketcap=max(totmarketcap)
keep if totmarketcap==maxmarketcap
drop maxmarketcap

qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Primary_Listing
matrix drop=[drop\tmp]
matlist drop
* Clean up the workspace
drop meanlendervalueonloan maxlendervalueonloan totmarketcap

*** First we mark the ex-dividend summy
*** It seems like compustat records on the ex div date the different dates related to a
*** dividend disubursement
gen exdivdummy=c_divdgross<.

* Balance the panel with a tsfill instruction. This is very handy since we are working with different exchanges that potentially have different business days
*xtset c_gvkey date
*tsfill
* Assign an exchange to the new empty observations
*bys c_gvkey (c_exchg): replace c_exchg=c_exchg[1]

