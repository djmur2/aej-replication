qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=StockExchange
matrix drop=[drop\tmp]
matlist drop
* Also a company name. Note: company name is a string so the missing values go on top so here we take the last observation rather than the first.
*bys c_isin (c_conm): replace c_conm=c_conm[_N]
* And gvkey
*bys c_isin (c_gvkey): replace c_gvkey=c_gvkey[1]
* replace the recorddatedummy to 0 when its missing (do it after the tsfill)
*replace recorddatedummy=0 if recorddatedummy==.
* Now we define a business day. We use the following definition: a business day is a day on which, on a given stock exchange, at least one stock is traded
* Dummy for when a stock is traded
gen trade=0
replace trade=1 if c_cshtrd<.
* By exchange and day find the number of stocks traded
bys c_exch date: egen stockstraded=total(trade)
gen businessday=0
replace businessday=1 if stockstraded>0
drop stockstraded
* We now drop the non-businessday with the exception if the recorddate is somehow recorded on a non-business day.
drop if businessday==0 //& recorddatedummy==0
*tab2 businessday exdivdummy
* Now drop all non-businessdays: note the ex-div dummy never equals 1 on non-business days
*drop if businessday==0
qui distinct id if m_lendervalueonloan<.
local id=r(ndistinct)
qui distinct c_gvkey if m_lendervalueonloan<.
local gvkey=r(ndistinct)
qui count if m_lendervalueonloan<.
local obs=r(N)
matrix tmp=[`obs', `id', `gvkey']
matrix rownames tmp=Business_Days
matrix drop=[drop\tmp]
matlist drop
