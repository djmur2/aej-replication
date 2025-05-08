*! version 2.1.0  14jul2021  Ben Jann
*! wrapper for estout

program esttab
    version 11
    local version: di "version " string(_caller()) ":"
    `version' _esttab `0'
end

program _esttab, rclass
    version 11
    
    // init
    tempname hcurrent estspec every
    
    // preserve estout options
    if replay() {
        local esopts "`e(cmdline)'"
        gettoken colon esopts: esopts, parse(":")
        if "`colon'"==":" {
            local esopts `esopts'
        }
        else if `:length local colon' {
            local esopts
        }
    }
    
    // syntax 1
    syntax [anything] [using/] [, STYLE(passthru) STYle2(string asis) /*
        */ NUMLABel PAGe(passthru) EXTRALines(passthru) LABels(string asis) /*
        */ TItle(passthru) NOTEs(passthru) ONEcell *]
    
    // additional syntax checking for onecell: only allowed with csv or tab delimiters
    if "`onecell'"!="" {
        _return hold `hcurrent'
        estout_detect_args, `options'
        if "`r(delimiter)'"=="&" & "`r(begin)'"!="\begin{tabular}" {
            di as error "onecell not allowed with the current selection of options"
            exit 198
        }
        _return restore `hcurrent'
    }

    // prehead, posthead, prefoot, postfoot using style
    if "`style'"!="" local style2 `"`style2'`style'"'
    _esttab_style `"`style2'"'
    local prehead    `"`r(prehead)'"'
    local posthead   `"`r(posthead)'"'
    local prefoot    `"`r(prefoot)'"'
    local postfoot   `"`r(postfoot)'"'
    local mlabels    `"`r(mlabels)'"'
    local collabels  `"`r(collabels)'"'
    local leaveout   `"`r(leaveout)'"'
    local extracols  `"`r(extracols)'"'
    local autonumber = `r(autonumber)'
    
    // stats, layout
    local stats      `"`r(stats)'"'
    local statslayout    `"`r(statslayout)'"'
    if inlist(`"`r(statspush)'"', "t", "true", "yes") local statspush statspush
    
    // starlevels, stardetach
    local starlevels `"`r(starlevels)'"'
    if inlist(`"`r(stardetach)'"', "t", "true", "yes") local stardetach stardetach
    
    // labels
    if `"`labels'"'!="" {
        local varlabels `"`labels'"'
    }
    else {
        local varlabels `"`r(varlabels)'"'
    }
    
    // wrap: default is wrap in fixed format
    _return hold `hcurrent'
    estout_detect_args, `options'
    local wrap wrap
    if "`r(smcl)'"!="" {
        if "`r(fixed)'"!="" {
            local wrap `wrap'(100)
        }
    }
    else if "`r(html)'"!="" {
        local wrap
    }
    else {
        if "`r(varwidth)'`r(modelwidth)'"=="" {
            if  "`r(tab)'"!="" | "`r(csv)'"!="" | "`r(scsv)'"!="" | ///
                "`r(rtf)'"!="" | "`r(tex)'"!="" | "`r(booktabs)'"!="" | ///
                "`r(html)'"!="" | "`r(fixed)'"!="" {
                local wrap
            }
        }
    }
    _return restore `hcurrent'
    
    // eqlabels etc.
    local eqlabels   `"`r(eqlabels)'"'
    local mgroups    `"`r(mgroups)'"'
    local numbers    = "`numlabel'"!="" | `autonumber'
    
    // process extralines
    if "`extralines'"!="" {
        _return hold `hcurrent'
        _parse comma lhs rhs : extralines
        local n = 0
        local extralines
        while `"`lhs'"'!="" {
            estout_detect_args, args(`lhs')
            local extralines `"`extralines' extralines(`++n',`r(args)')"'
            _parse comma lhs rhs : rhs
        }
        _return restore `hcurrent'
    }
    if "`page'"!="" {
        _parse comma lhs rhs : page
        _esttab_every every: `lhs'
        local page `"page(`=scalar(`every')'`rhs')"'
    }
    
    // syntax 2
    syntax [anything] [using/] [, CELLLABels(passthru) /*
        */ noTItle noBOttom noHEADer noFOOTer noLEGend /*
        */ PREHead(passthru) POSTHead(passthru) PREFOot(passthru) POSTFOot(passthru) /*
        */ VARLABels(passthru) REFcat(passthru) MLabels(passthru) /*
        */ EQLabels(passthru) COLLabels(passthru) MGRoups(passthru) DROPmg DROPlevels /*
        */ WRAP VARWIDTH(passthru) MODELWidth(passthru) ONEcell /*
        */ SUBstitute(passthru) esopts(string) dmargin(numlist) margin(numlist) *]
    if "`varwidth'"!="" local nomargin dmargin(0)
    if "`margin'`dmargin'"!="" {
        if "`dmargin'"!="" {
            local nomargin dmargin(`dmargin')
        }
        else {
            local nomargin margin(`margin')
        }
    }
    
    // onecell stuff
    if "`onecell'"!="" {
        local esopts `"`esopts' cells(onecell) noeqlines nodiscrete interaction("  ")"'
    }
    
    // prehead
    if `"`prehead'"'!="" & "`prehead'"=="" {
        local options `"prehead(`prehead') `options'"'
    }
    if "`title'"=="" & "`header'"=="" {
        if `"`posthead'"'!="" & "`posthead'"=="" {
            local options `"posthead(`posthead') `options'"'
        }
    }
    // prefoot
    if `"`prefoot'"'!="" & "`prefoot'"=="" {
        local options `"prefoot(`prefoot') `options'"'
    }
    // bottom/footer
    if "`bottom'"=="" & "`footer'"=="" {
        if `"`postfoot'"'!="" & "`postfoot'"=="" {
            local options `"postfoot(`postfoot') `options'"'
        }
    }
    
    // labels
    if `"`varlabels'"'!="" & "`varlabels'"=="" {
        local options `"varlabels(`varlabels') `options'"'
    }
    if `"`eqlabels'"'!="" & "`eqlabels'"=="" {
        if "`droplevels'"=="" {
            local options `"eqlabels(`eqlabels') `options'"'
        }
    }
    if `"`mgroups'"'!="" & "`mgroups'"=="" {
        if "`dropmg'"=="" {
            local options `"mgroups(`mgroups') `options'"'
        }
    }
    if `"`mlabels'"'!="" & "`mlabels'"=="" {
        local options `"mlabels(`mlabels') `options'"'
    }
    if `"`collabels'"'!="" & "`collabels'"=="" & "`celllabels'"=="" {
        local options `"collabels(`collabels') `options'"'
    }
    
    // wrap
    if "`wrap'"!="" {
        local options `"wrap `options'"'
    }
    
    // starlevels, stardetach
    if `"`starlevels'"'!="" {
        local options `"starlevels(`starlevels') `options'"'
    }
    if "`stardetach'"!="" {
        local options `"stardetach `options'"'
    }
    
    // stats, statslayout
    if "`legend'"=="" {
        if `"`stats'"'!="" {
            local options `"stats(`stats') `options'"'
        }
        if `"`statslayout'"'!="" {
            local options `"statslayout(`statslayout') `options'"'
        }
        if "`statspush'"!="" {
            local options `"statspush `options'"'
        }
    }
    
    // leaveout, extracols
    if `"`leaveout'"'!="" {
        local options `"leaveout(`leaveout') `options'"'
    }
    if `"`extracols'"'!="" {
        local options `"extracols(`extracols') `options'"'
    }
    
    if `numbers' {
        _return hold `hcurrent'
        _estout_detect_groups `anything', esopts(`esopts' `options')
        local max `r(max)'
        _esttab_row `anything', esopts(`esopts' `options')
        local anyrow = "`r(anyrow)'"!=""
        _return restore `hcurrent'
        if `max'>`=_N' | `anyrow' {
            if "`esopts'"=="" {
                if "`eqmatch'" == "" local esopts "eqmatch"
            }
            local options `"numbers `options'"'
        }
    }
    
    // compile command: estout.ado
    capt findfile estout.ado
    if _rc {
        di as err "estout is required; type {stata ssc install estout}"
        exit 199
    }
    
    estout `anything' `using', `nomargin' `extralines' `page' `esopts' `options'
    return add
end

program _esttab_style, rclass
    version 11
    
    syntax [anything] [, *]
    if "`anything'"=="" exit
    
    gettoken style : anything
    gettoken style2: anything, q
    while (`"`style2'"'!="') {
        local style "`style' `style2'"
        macro shift anything
        gettoken style2: anything, q
    }
    gettoken style_basic style: style
    
    // default style
    if `"`style_basic'"'=="default" | `"`style_basic'"'=="smcl" {
        if `"`style'"'=="" {
            local style `"`style_basic'"'
        }
        else {
            local style "default `style'"
        }
    }
    
    // style: "default"
    foreach i of local style {
        if      "`i'"=="default" {
            return local prehead
            return local posthead
            return local prefoot
            return local postfoot
            return local mlabels "Model"
            return local collabels "tab"
            return local leaveout
            return local extracols
            return local varlabels
            return local eqlabels
            return local mgroups
            return local autonumber 0
            return local stats "r2 r2_a"
            return local statslayout
            return local statspush "false"
            return local starlevels "* 0.05 ** 0.01 *** 0.001"
            return local stardetach "false"
        }
        // style: "smcl"
        else if "`i'"=="smcl" {
            return local mlabels "Model"
            return local collabels "tab"
        }
        // style: "tab"
        else if "`i'"=="tab" {
            return local mlabels "Model"
            return local collabels "tab"
            return local postfoot
        }
        // style: "tab2"
        else if "`i'"=="tab2" {
            return local mlabels
            return local collabels "nonames"
        }
        // style: "fixed"
        else if "`i'"=="fixed" {
            return local mlabels "Model"
            return local collabels "tab"
            return local postfoot
        }
        // style: "main"
        else if "`i'"=="main" {
            return local stats
        }
        // style: "plain"
        else if "`i'"=="plain" {
            return local mlabels "noname"
            return local collabels "nonames"
            return local stats
        }
        // style: "tex"
        else if "`i'"=="tex" {
            return local prehead "\begin{tabular}{l*{@M}{c}}" _n "\hline\hline"
            return local posthead "\hline"
            return local prefoot "\hline"
            return local postfoot "\hline\hline" _n "\end{tabular}"
            return local mlabels "&"
            return local collabels "&"
        }
        // style: "booktabs"
        else if "`i'"=="booktabs" {
            return local prehead "\begin{tabular}{l*{@M}{c}}" _n "\toprule"
            return local posthead "\midrule"
            return local prefoot "\midrule"
            return local postfoot "\bottomrule" _n "\end{tabular}"
            return local mlabels "&"
            return local collabels "&"
        }
        // style: "htm" or "html"
        else if "`i'"=="htm" | "`i'"=="html" {
            return local prehead "<table border=1>" _n "<tr>" _n "<td> </td>"
            return local posthead "</tr>"
            return local prefoot
            return local postfoot "</tr>" _n "</table>"
            return local mlabels "<td align=center>"
            return local collabels "<td align=center>"
        }
        // style: "rtf"
        else if "`i'"=="rtf" {
            return local prehead /* 
             */ "{\rtf1\ansi\deff0 {\fonttbl{\f0\fnil Times New Roman;}}" _n /*
             */ "\paperw15840\paperh12240\margl1440\margr1440\margt1440\margb1440\landscape" _n /*
             */ "\plain\f0\fs24 {\pard\qc\li0\fi0\ri0\rin0 " _n /*
             */ "\fs32 @title \par" _n /*
             */ " \par}" _n /*
             */ "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw15\brdrs" _n /*
             */ "\cellx816\clbrdrt\brdrw15\brdrs"
            return local posthead "\row" _n /*
             */ "{\trowd\trgaph108\trleft-108\cellx816"
            return local prefoot "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw15\brdrs" _n /*
             */ "\cellx816\clbrdrb\brdrw15\brdrs"
            return local postfoot "\row}" _n /*
             */ "@notes" _n /*
             */ "}"
            return local mlabels "\cell"
            return local collabels "\cell"
        }
        // style: "fragments"
        else if "`i'"=="fragments" {
            return local prehead
            return local posthead
            return local prefoot
            return local postfoot
            return local mlabels "noname"
            return local collabels "nonames"
        }
        // style: "empty"
        else if "`i'"=="empty" {
            return local prehead
            return local posthead
            return local prefoot
            return local postfoot
            return local mlabels
            return local collabels "nonames"
        }
        // style: "csv"
        else if "`i'"=="csv" {
            return local collabels ","
            return local mlabels ","
        }
        // style: "scsv"
        else if "`i'"=="scsv" {
            return local collabels ";"
            return local mlabels ";"
        }
        // style: "custom"
        else if "`i'"=="custom" {
            return local collabels "`options'"
            return local mlabels "`options'"
        }
        // style: all
        
        // style: "starlevels"
        else if substr("`i'",1,10)=="starlevels" {
            gettoken lhs rhs: i, parse("(")
            if `"`rhs'"'!="" {
                gettoken tmp rhs: rhs, parse(")")
                return local starlevels `"`tmp'"'
            }
        }
        // style: "stardetach"
        else if "`i'"=="stardetach" {
            return local stardetach "true"
        }
        // style: "nostardetach"
        else if "`i'"=="nostardetach" {
            return local stardetach "false"
        }
        // style: "statspush"
        else if "`i'"=="statspush" {
            return local statspush "true"
        }
        // style: "nostatspush"
        else if "`i'"=="nostatspush" {
            return local statspush "false"
        }
        // style: "cells"
        else if substr("`i'",1,5)=="cells" {
            gettoken lhs rhs: i, parse("(")
            if `"`rhs'"'=="" {
                return local stats "r2 r2_a"
            }
            else {
                gettoken tmp rhs: rhs, parse(")")
                if `"`tmp'"'=="stats" {
                    return local stats "r2 r2_a"
                }
                else if `"`tmp'"'=="main" {
                    return local stats
                }
                else {
                    return local stats `"`tmp'"'
                }
            }
        }
        // style: "statslayout"
        else if substr("`i'",1,11)=="statslayout" {
            gettoken lhs rhs: i, parse("(")
            if `"`rhs'"'!="" {
                gettoken tmp rhs: rhs, parse(")")
                return local statslayout `"`tmp'"'
            }
        }
        // style: "numbers"
        else if "`i'"=="numbers" {
            return local autonumber 1
        }
        // style: "nonumbers"
        else if "`i'"=="nonumbers" {
            return local autonumber 0
        }
        // style: "extracols"
        else if substr("`i'",1,9)=="extracols" {
            gettoken lhs rhs: i, parse("(")
            if `"`rhs'"'!="" {
                gettoken tmp rhs: rhs, parse(")")
                return local extracols `"`tmp'"'
            }
        }
        // style: "leaveout"
        else if substr("`i'",1,8)=="leaveout" {
            gettoken lhs rhs: i, parse("(")
            if `"`rhs'"'!="" {
                gettoken tmp rhs: rhs, parse(")")
                return local leaveout `"`tmp'"'
            }
        }
        // style: other
        else if strpos("`i'", "(")!=0 {
            gettoken name tmp : i, parse("(")
            gettoken tmp args : tmp, parse("(")
            gettoken args tmp : args, parse(")")
            
            return local `name' `"`args'"'
        }
    }
end

program _estout_detect_groups, rclass
    args anything, esopts
    local max = 0
    tempname matsave hcurrent
    _return hold `hcurrent'
    foreach est of local anything {
        if "`est'"=="." continue
        capt est_expand `"`est'"', esopts(`esopts')
        if _rc continue
        
        foreach m of local r(names) {
            qui estout `m' using /dev/null, noisily /*
                */ equation(default=1) noobs /*
                */ drop(_cons) /*
                */ stardetach /* one delimiter between b and t */
                qui estimates store `matsave'
                
                local vlist
                capt mat list e(b)
                if _rc==0 {
                    local n = colsof(e(b))
                    local curr = `n'
                    if `n'>`max' {
                        local max = `n'
                    }
                }
                else {
                    mat rownames e(stats) = ""
                    capture estimates drop `est'
                }
                if "`matsave'"!="" {
                    quietly estimates restore `matsave'
                    capture estimates drop `matsave'
                }
        }
    }
    return scalar max = `max'
    _return restore `hcurrent'
end

program _esttab_row, rclass
    args anything, esopts
    
    local anyrow
    tempname hcurrent
    _return hold `hcurrent'
    foreach est of local anything {
        if "`est'"=="." continue
        capt est_expand `"`est'"', esopts(`esopts')
        if _rc continue
        
        foreach m of local r(names) {
            capt confirm matrix r(row)
            if _rc==0 {
                if r(row)>0 {
                    local anyrow row
                }
            }
        }
    }
    return local anyrow `anyrow'
    _return restore `hcurrent'
end

program _esttab_every, rclass
    args names :  anything
    if `:length local anything'==0 exit
    tempname `names'
    scalar ``names'' = 1
    if strpos(`"`anything'"', "even") {
        scalar ``names'' = 2
    }
    else if strpos(`"`anything'"', "odd") {
        scalar ``names'' = 2
        local anythinge = "`anything'"
        local anything
        forv i = 1/`: word count `anythinge' ' {
            local w: word `i' of `anythinge'
            if "`w'"=="odd" {
                local anything `anything' 1
            }
            else {
                local anything `anything' `w'
            }
        }
    }
    else {
        capt confirm number `anything'
        if _rc==0 {
            scalar ``names'' = `anything'
            exit
        }
    }
    local w: word 1 of `anything'
    capt confirm integer number `w'
    if _rc==0 & `w'>0 {
        scalar ``names'' = `w'
    }
end
mata mlib add lftools esttab.mata
end