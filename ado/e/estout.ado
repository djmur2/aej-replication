*! version 3.32 07jan2022 Ben Jann
*! wrapper for estout

program estout
    version 11
    local version : di "version " string(_caller()) ":"
    `version' _estout `0'
end

program _estout, rclass
    version 11
    local caller: di int(_caller())

    // syntax
    gettoken eq 0 : 0, parse("=")
    if `"`eq'"' == "=" {
        local 0 `", using("'`0'`")"'
    }
    syntax [anything] [using] [ , * ]
    if `:length local anything' {
        if `"`using'"'=="" confirm name `anything'
        else {
            _est_unhold `anything'
            capture confirm name `anything'
            local rc = _rc
            _est_hold `anything'
            if `rc' {
                di as error "invalid syntax"
                exit 198
            }
        }
    }
    if `"`anything'"'!="" {
        if `"`using'"'!="" {
            tempname hcurrent
            _return hold `hcurrent'
            capt {
                _est_unhold `anything'
                estimates dir `anything'
                local models "`r(names)'"
                _est_hold `anything'
            }
            _return restore `hcurrent'
            if _rc {
                tempname models
                forv i=1/100 {
                    capt confirm name `anything'`i'
                    if _rc continue
                    capt confirm new var `anything'`i'
                    if _rc continue
                    unab vn: `anything'`i'
                    if `"`vn'"'=="" continue
                    if `"`vn'"'!="`anything'`i'" continue
                    local `models' ``models'' `anything'`i'
                }
                local models ``models''
            }
            else {
                foreach name of local models {
                    if index("`name'",":")==0 continue
                    tempname hold
                    _est_unhold `name'
                    _est_hold `name' `hold'
                    local tmpmodels `"`tmpmodels'`hold' "'
                }
            }
            local 0 `", `options'"'
            syntax [, notable replace append * ]
            local options `options'
            if `"`notable'"'!="" local options `"notable `options'"'
            if `"`replace'"'!="" local options `"replace `options'"'
            if `"`append'"'!=""  local options `"append `options'"'
            foreach name of local models {
                capt {
                    qui eststo model: `anything' `name'
                    estadd local source: `"`name'"'
                    estout model `using' , equation(1) `options'
                }
                if _rc {
                    di as error "invalid syntax"
                    exit 198
                }
                local options: subinstr local options "replace" "append", word
            }
            foreach name in `tmpmodels' {
                capt est drop model
                _est_unhold `name'
            }
            exit
        }
        else {
            local 0 `"`anything', `options'"'
        }
    }
    if `"`using'"'!="" local using `" `using'"'

    // helper options (undocumented)
    syntax [namelist(min=1 max=1000 id="model names")] [using] [,    ///
        UHold                     ///
        SHold                     ///
        noRETURN                  ///
        MATA(name)                ///
        ]
    if "`uhold'"!="" {
        _est_unhold `namelist'
        exit
    }
    if "`shold'"!="" {
        _est_hold `namelist'
        exit
    }

    // prepare
    capt mata mata drop ___ESTOUT___()
    if `"`mata'"'!="" {
        capt confirm matrix `mata'
        if _rc == 0 {
            mata ___ESTOUT___ = st_matrix("`mata'")
        }
        else {
            mata ___ESTOUT___ = `mata'
        }
    }

    // delegate to esttab (... but not if mataeq is specd.)
    if `caller'>8 {
        local 0 `", `options'"'
        gettoken comma 0 : 0, parse(",")
        gettoken asis  0 : 0, parse(", ")
        gettoken comma 0 : 0, parse(",")
        ///syntax [using] [, CELLS(string asis) MATA(name) asis * ]
        syntax [, CELLS(string asis) MATaeq(string asis) * ]
        if `"`mataeq'"'=="" {
            estout2 `namelist'`using', `options'
            if "`return'"=="" {
                return add
            }
            exit
        }
    }

    // get stats table from estout
    local statsholdok = (_caller()>=9)
    local r_nooutput = 0
    local r_table
    if `statsholdok'==0 {
        tempname statsholdcur
        if "`namelist'"=="" error 301
        quietly _eststo `statsholdcur' : estout `namelist'`using', ///
            `options' noisily noreturn
        local r_nooutput = (`r(nooutput)'==1)
        local r_table    `"`r(table)'"'
        estimates drop `statsholdcur'
    }
    else {
        tempname statsholdcur
        _return hold `statsholdcur'
        if "`namelist'"=="" {
            capt noisily estout `using', `options'
            if _rc exit _rc
        }
        else {
            quietly _eststo_internal_not _statsholdname : ///
                estout `namelist'`using', `options' noisily noreturn
        }
        local r_nooutput = (`r(nooutput)'==1)
        local r_table    `"`r(table)'"'
        _return restore `statsholdcur'
    }
    if "`return'"!="" exit
    // return results
    if "`r(scalars)'"!="" {
        local r_scalars_list : subinstr local r(scalars) "," " ", all
        foreach r_scalarname of local r_scalars_list {
            return scalar `r_scalarname' = `r(`r_scalarname')'
        }
    }
    if "`r(macros)'"!="" {
        local r_macros_list : subinstr local r(macros) "," " ", all
        foreach r_macroname of local r_macros_list {
            return local `r_macroname' `"`r(`r_macroname')'"'
        }
    }
    return local scalars `"`r(scalars)'"'
    return local macros `"`r(macros)'"'
    return scalar nooutput = `r_nooutput'
    return local table    `r_table'
end

program _eststo_internal_not
    version 8
    gettoken namelist 0 : 0 , parse(" :")
    gettoken colon    0 : 0 , parse(":")
    gettoken command  0 : 0 , parse(":")
    `command' `0'
end

// delegate to esttab
program estout2, rclass
    version 11
    _return drop *(*)
    
    // syntax
    syntax [namelist] [using/] [, drop(passthru) keep(passthru) ///
        order(passthru) indicate(passthru) COEFLAbels(passthru) ///
        TRansform(passthru) EQuations(passthru) ///
        CELLS(string asis) eform FOrmat(passthru) ///
        notar replace append type NOIsily * ]

    // defaults
    if `"`cells'"'=="" local cells "b se"
    
    // translation
    local esttab_opts
    if !inlist("`noisily'","",",") local esttab_opts `esttab_opts' noisily
    if !inlist("`replace'","",",") local esttab_opts `esttab_opts' replace
    if !inlist("`append'","",",")  local esttab_opts `esttab_opts' append
    if !inlist("`type'","",",")    local esttab_opts `esttab_opts' type
    if !inlist("`eform'","",",")   local esttab_opts `esttab_opts' eform
    
    local badopts wide noabbrev modelwidth(passthru) varwidth(passthru) ///
        begin(passthru) delimiter(passthru) end(passthru) ///
        prehead(passthru) posthead(passthru) ///
        prefoot(passthru) postfoot(passthru) ///
        stats(passthru) stardrop starkeep mlabels(passthru) ///
        collabels(passthru) note(passthru) title(passthru) ///
        nogaps page_dif(passthru) page(passthru) ///
        smcltags(passthru) nonumbers showstars

    local 0 ", `options'"
    syntax [, `badopts' nodepvars ///
        nonumbers2(passthru) noSTArs2(passthru) /// preserve legacy
        plain TABle Fragment ///
        * ]
    
    if !inlist("`nodepvars'","",",") local esttab_opts `esttab_opts' nodepvar
    if !inlist("`table'","",",")     local esttab_opts `esttab_opts' fragment
    if !inlist("`fragment'","",",")  local esttab_opts `esttab_opts' fragment
    if !inlist("`nonumbers2'","",",") {
        gettoken junk nonumbers2: nonumbers2, parse("(")
        local esttab_opts `esttab_opts' nonumbers(`nonumbers2'
    }
    if !inlist("`nostars2'","",",") {
        gettoken junk nostars2: nostars2, parse("(")
        local esttab_opts `esttab_opts' nostars(`nostars2'
    }
    
    // open tex? => tex
    if (strpos(`"`using'"', ".tex")>0) {
        if "`plain'"=="" local esttab_opts `esttab_opts' tex
    }
    
    // call esttab
    capt findfile esttab.ado
    if _rc {
        di as err "esttab is required; type {stata ssc install estout}"
        exit 199
    }
    
    esttab `namelist' `using', drop(`drop') keep(`keep') ///
        order(`order') indicate(`indicate') ///
        transform(`transform') equations(`equations') ///
        wrap cells(`cells') format(`format') coef(`coeflabels') ///
        `esttab_opts' `options'
    return add
end