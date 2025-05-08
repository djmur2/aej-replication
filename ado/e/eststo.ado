*! version 3.32 07jan2022 Ben Jann
*! wrapper for _estimates store

program eststo
    version 8.2
    local local local
    local replay = replay()
    if `replay' | `"`0'"'=="" {
        if `replay' & `"`e(cmd)'"'!="`e(eststo_cmd)'" & `"`e(eststo_cmd)'"'!="" {
            di as txt "(`e(eststo_cmd)')" _c
        }
        exit
    }
    
    syntax [anything] [, noCopy Add Refresh ESample Title(string asis) noClear * ]
    if "`clear'"=="" {
        local clear clear
    }
    
    // check if nocopy or add => model is scalar
    if "`nocopy'`add'"!="" {
        capt confirm name `anything'
        if _rc {
            di as err "invalid model name"
            exit 198
        }
        
        gettoken subcmd wstuff : options, parse(" ,")
        if `"`subcmd'"'=="dir" {
            model_dir `anything'
            exit
        }
        
        if "`nocopy'"!="" exit
        
        gettoken subcmd wstuff : options, parse(" ,")
        if `"`subcmd'"'!=":" exit
        gettoken colon wstuff : wstuff, parse(" :")
        if `"`colon'"'!=":" {
            di as err "invalid subcommand"
            exit 198
        }
        
        gettoken yvar xvars: wstuff, parse(" ,")
        if `"`yvar'"'==`","' {
            di as err "missing yvar as first argument"
            exit 198
        }
        
        gettoken rest: xvars, parse(" ,")
        if `"`rest'"'==`","' {
            local xvars
            local colon ,
        }
        else {
            gettoken colon rest: rest, parse(" ,")
            if `"`colon'"'!=`","' {
                local rest `colon' `rest'
                local colon
            }
        }
        
        capt confirm name `yvar'
        if _rc {
            di as err "invalid yvar"
            exit 198
        }
        
        foreach var of local xvars {
            capt confirm name `var'
            if _rc {
                di as err "invalid xvar"
                exit 198
            }
        }
        
        _eststo_internal_nocopy `anything' : `yvar' `xvars' `colon' `rest'
        exit
    }
    
    
    // check if model: command
    gettoken subcmd wstuff : anything, parse(" :")
    if `"`subcmd'"'==":" {
        di as err "invalid subcommand"
        exit 198
    }
    
    gettoken colon wstuff : wstuff, parse(" :")
    if `"`colon'"'==":" {
        _eststo_internal_not `subcmd' : `wstuff'
        exit
    }
    
    // standard syntax: eststo model: cmd
    gettoken subcmd wstuff : anything, parse(" :")
    if `"`wstuff'"'!="" {
        gettoken colon wstuff : wstuff, parse(" :")
        if `"`colon'"'==":" {
            _eststo_internal `subcmd' `clear' `options' : `wstuff'
            exit
        }
    }
    
    // syntax: eststo
    if `"`anything'"'=="" {
        _eststo_internal, `clear' `options'
        exit
    }
    else {
        if "`refresh'"!="" {
            if "`esample'"!="" {
                local refresh esample
            }
            capt estimates refresh `anything'
            if _rc {
                di as error `"unable to refresh `anything'; use "{stata eststo `anything', replace}""'
                exit _rc
            }
        }
        
        // syntax: eststo name
        if "`add'"!="" {
            _eststo_internal_add `anything', `clear' `options'
            exit
        }
        else {
            _eststo_internal `anything', `clear' `options'
            exit
        }
    }
end



program _eststo_internal
    gettoken namelist 0 : 0 , parse(" :")
    gettoken colon    0 : 0 , parse(":")
    local options `0'
    
    if "`colon'"==":" {
        gettoken command 0 : 0 , parse(":")
        if `"`command'"'=="." {
            local command
        }
        else if `:length local command' {
            capt confirm name `namelist'
            if _rc {
                di as err "invalid model name"
                exit 198
            }
        }
    }
    else {
        local options `colon' `options'
        local command ""
    }
    
    syntax [, esample title(string asis) prefix(name) * ]
    
    if `"`prefix'"'!="" {
        local name `prefix'`namelist'
    }
    else {
        local name `namelist'
    }
    
    if `"`command'"'!="" {
        version 8.2: `command' `options'
        local rc = _rc
        if `rc' {
            exit `rc'
        }
        if e(sample)==. {
            tempname touse
            gen byte `touse' = 1 /* legacy */
            estimates local sample `touse'
        }
        if "`esample'"=="" {
            tempname esample
            qui gen byte `esample' = e(sample)
            est local sample `esample'
        }
    }
    
    if "`esample'"!="" {
        est local sample 1
    }
    
    if `"`title'"'!="" {
        est local title `"`title'"'
    }
    
    if `"`name'"'!="" {
        capt est store `name'
        if _rc {
            di as err "model `name' already exists, use replace option or eststo clear"
            exit 110
        }
        est local eststo_cmd = "`e(cmd)'"
    }
end

program _eststo_internal_nocopy
    gettoken namelist 0 : 0, parse(" :")
    gettoken colon    0 : 0, parse(":")
    
    capt confirm name `namelist'
    if _rc {
        di as err "invalid model name"
        exit 198
    }
    
    // get input
    capt _eststo_parse_nocopy, `0'
    if _rc {
        di as error "nocopy: invalid syntax"
        exit 198
    }
    
    // drop model if it exists
    capt estimates drop `namelist'
    
    // create new model
    tempname b
    mat `b' = `r(b)'
    mat colnames `b' = `r(colnames)'
    mat rownames `b' = `r(rownames)'
    
    estimates post `b'
    
    // add scalars
    local j = 1
    local enames: subinstr local r(scalars) "," " ", all
    foreach e in `enames' {
        est scalar `e' = `r(s`j++')'
    }
    
    // add macros
    local j = 1
    local enames: subinstr local r(macros) "," " ", all
    foreach e in `enames' {
        est local `e' `"`r(m`j++')'"'
    }
    
    // post
    est local cmd "eststo"
    est local eststo_cmd "eststo"
    est local predict ""
    est store `namelist'
end

program _eststo_internal_not
    version 8
    gettoken namelist 0 : 0 , parse(" :")
    gettoken colon    0 : 0 , parse(":")
    gettoken command  0 : 0 , parse(":")
    `command' `0'
end

program _eststo_internal_add
    gettoken namelist 0 : 0, parse(" ,")
    
    tempname curr
    quietly estimates store `curr'
    
    syntax [, title(string asis) replace prefix(name) * ]
    
    if `"`prefix'"'!="" {
        local name `prefix'`namelist'
    }
    else {
        local name `namelist'
    }
    
    if "`replace'"!="" {
        capt estimates drop `name'
    }
    
    capt confirm new name `name'
    if _rc {
        di as err "model `name' already exists, use replace option or eststo clear"
        exit 110
    }
    
    if `"`title'"'!="" {
        est local title `"`title'"'
    }
    est local eststo_cmd = "`e(cmd)'"
    est store `name'
    quietly estimates restore `curr'
    estimates drop `curr'
end

/* parse nocopy syntax */
program _eststo_parse_nocopy, rclass
    syntax anything(equalok) [, scalar(namelist) local(namelist) ]
    
    // get depvar names
    gettoken depvar : anything
    unab depvar: `depvar'
    confirm numeric variable `depvar'
    
    // get indepvar names
    gettoken depvar anything2: anything
    local anything = trim("`anything2'")
    if "`anything'"!="" & "`anything'"!="," {
        unab indepvars: `anything'
        confirm numeric variable `indepvars'
    }
    else {
        local indepvars
    }
    
    // any extra options?
    local colon
    if "`anything'"!="" {
        local len = length("`anything'")
        if substr("`anything'", `len', 1)=="," {
            local colon ","
        }
    }
    
    // get scalars
    local snames
    local svals
    tokenize `scalar'
    while "`1'"!="" {
        gettoken val 0 : 0, parse(", ")
        if "`val'"=="," {
            continue
        }
        else {
            capt confirm number `val'
            if _rc {
                di as error "nocopy: `1' must be a number"
                exit 198
            }
            else {
                local snames `snames' `1'
                local svals `svals' `val'
            }
            mac shift
        }
    }
    
    // get locals
    local lnames
    local lvals
    tokenize `local'
    while "`1'"!="" {
        gettoken val 0 : 0, parse(`"""')
        if trim("`val'")=="" {
            continue
        }
        else {
            if substr("`val'", 1, 1)=="," {
                local val = substr("`val'", 2, .)
            }
            if substr("`val'", 1, 1)==`"""' {
                gettoken val : val, parse(`"""')
                local val = substr("`val'", 2, .)
                gettoken val rest: val, parse(`"""')
                local val
                local j = 1
                local tmp: word `j' of `rest'
                while "`tmp'"!="" {
                    if "`tmp'"==`"""' {
                        continue 2
                    }
                    local val `val' `tmp'
                    local ++j
                    local tmp: word `j' of `rest'
                }
                di as err "nocopy: invalid local format"
                exit 198
            }
            local lvals `"`lvals'"`val'""'
            local lnames `lnames' `1'
            mac shift
        }
    }
    
    // depvar
    tempname b
    qui sum `depvar'
    mat `b' = r(mean)
    
    // indepvars
    local i = 1
    foreach var of local indepvars {
        qui sum `var'
        mat `b' = `b', r(mean)
    }
    mat rownames `b' = y1
    
    local cols "`depvar'"
    foreach var of local indepvars {
        local cols `"`cols' `var'"'
    }
    mat colnames `b' = `cols'
    
    // return b and info
    return local b = "`b'"
    return local colnames = "`cols'"
    return local rownames = "y1"
    
    // return scalar info
    local j = 1
    foreach var of local snames {
        local s: word `j++' of `svals'
        return local s`j' = `s'
    }
    return local scalars `snames'
    
    // return local info
    local j = 1
    foreach var of local lnames {
        local m: word `j++' of `lvals'
        return local m`j' `"`m'"'
    }
    return local macros `lnames'
end


/* estimates dir for eststo */
program model_dir
    args name
    
    if regexm("`name'", ":") {
        tempname e
        _est hold `e'
        capt _eststo_est_expand `name', esopts("")
        if _rc {
            di as error "no model files found"
            exit 198
        }
        local names `r(names)'
        _est unhold `e'
    }
    else {
        local names `name'
    }
    
    foreach name of local names {
        if regexm("`name'", ":") {
            di as txt "File: `name'"
            capt scalar dir `name':*
            if _rc {
                di as err "invalid file"
                exit 198
            }
            capt scalar list `name':*
            capt mat dir `name':*
            capt mat list `name':*
        }
        else {
            di as txt "Model: `name'"
            qui est dir `name'
            if _rc {
                di as err "model `name' not found"
                exit 198
            }
            
            est query `name'
        }
    }
end

/* extended est_expand */
program _eststo_est_expand, rclass
    args name , options
    tempname e
    _est hold `e'
    
    capt n est_expand `"`name'"', `options'
    if _rc {
        if substr("`name'", 1, 1)==":" | c(os)!="Windows" {
            di as error "no model files found"
            exit 198
        }
        
        tempname names
        forv i=1/100 {
            capt confirm name `name'`i'
            if _rc continue
            capt confirm new var `name'`i'
            if _rc continue
            unab vn: `name'`i'
            if `"`vn'"'=="" continue
            if `"`vn'"'!="`name'`i'" continue
            local `names' ``names'' `name'`i'
        }
        local names: list clean names
    }
    else {
        local names `r(names)'
    }
    
    if `"`names'"'=="" {
        di as error "no model files found"
        exit 111
    }
    
    _est unhold `e'
    return local names `names'
end
mata mlib add lftools eststo.mata
end