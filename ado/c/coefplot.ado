*! version 1.8.5  21jul2021  Ben Jann

program coefplot
    version 11.0
    
    // replay
    if replay() {
        if "`e(cmd)'"!="coefplot" error 301
        ky display as text "(Coefficient plot)"
        exit
    }
    
    // syntax
    local version : di "version " string(_caller()) ", missing:"
    _parse comma lhs 0 : 0
    _coefplot_parsesubcmd `lhs'  // returns cmdname vlist wlist flist
    local subcmd `"`cmdname'"'
    if `"`wlist'"'!="" local 0 `"`wlist', `flist', `0'"'
    else if `"`flist'"'!="" local 0 `"`flist', `0'"'
    local vlist `"`subcmd'"' `"`vlist'"'
    mata: st_local("vlist", _coefplot_invtokens(st_local("vlist")))
    local 0 `", `0'"'
    
    // parse options
    syntax [, ///
        at(string asis) ///
        CI1OPT(string) CI2OPT(string) CI3OPT(string) ///
        ///
        rename(string asis) ///
        COEFlabels(string asis) ///
        flatten ///
        GRoups(string asis) ///
        ///
        format(string) RECast(passthru) ///
        nooffsets POSTHZomit HORizontal VERTical NONE ///
        BYcoefs BYOPts(string) ///
        /// 
        xline(string) yline(string) ///
        grid(string) GRID2(string) NOGrid ///
        OGRid(string) OGRID2(string) ///
        ///
        addplot(string) ///
        plot(string asis) ///
        headings(string asis) ///
        SUBTitles(string) ///
        ///
        COLors(string) ///
        MSymbols(string) ///
        MYSYMbols(string) ///
        MColors(string) ///
        MYCOlors(string) ///
        MLWidths(string) ///
        MYMLWidths(string) ///
        MLStyles(string) ///
        MYMLStyles(string) ///
        MYSIzes(string) ///
        MLABPosition(string) MLABANGle(string) MLABGap(string) ///
        MYLABPosition(string) MYLABANGle(string) MYLABGap(string) ///
        CSymbols(string) ///
        CColors(string) ///
        CLWidths(string) ///
        CLStyles(string) ///
        CISYMbols(string) ///
        CICOlors(string) ///
        CILWidths(string) ///
        CILStyles(string) ///
        MYLAbels(string) ///
        MLAbels(string asis) ///
        CILabels(string asis) ///
        NORMALize(string) ///
        LWidth(string) LColor(string) LStyle(string) ///
        LPPERcent(string) LPHPercent(string) ///
        ///
        Xlabel(string asis) Xtick(string asis) XOPTion(string) ///
        Ylabel(string asis) Ytick(string asis) YOPTion(string) ///
        noLABels SUBOPts(string) LEGend(string) noci NOPSTuff ///
        TItle(string) SUBtitle(string) note(string) ///
        * ]
    
    // coefplot_options
    if `"`recast'"'!="" {
        tokenize `"`recast'"', parse(" ,")
        if `"`1'"'=="recast" {
            if `"`2'"'=="(" {
                local p 2
                while (`"`2'"'=="(" & `"`3'"'!="") {
                    local ++p
                    if `"`3'"'=="(" continue
                    local recast0 `"`recast0'`3' "'
                    mac shift 3
                }
            }
            else if `"`2'"'=="" local recast0
            else {
                capt n syntax [, Recast(str) *]
                if _rc==0 & `"`options'"'=="" local recast0 `"`recast'"'
            }
        }
    }
    if `"`title'"'!="" local r_title `title'
    if `"`subtitle'"'!="" local r_subtitle `subtitle'
    
    // check mlabposition
    if `"`mymlabposition'"'!="" {
        foreach s of local mymlabposition {
            if `"`s'"'!="" {
                if !(`"`s'"'=="n" | `"`s'"'=="e" | `"`s'"'=="w" | `"`s'"'=="s" | ///
                        inrange(`"`s'"',0,12)) {
                    di as err "invalid mlabposition(): '`s'"
                    exit 198
                }
            }
        }
    }
    if `"`mlabposition'"'!="" {
        if !(`"`mlabposition'"'=="n" | `"`mlabposition'"'=="e" | ///
             `"`mlabposition'"'=="w" | `"`mlabposition'"'=="s" | ///
             inrange(`"`mlabposition'"',0,12)) {
            di as err "invalid mlabposition(): '`mlabposition'"
            exit 198
        }
    }
    
    // options for axes
    local opts
    _coefplot_add_opt `opts' xlabel `"`xlabel'"' "'
    _coefplot_add_opt `opts' xtick `"`xtick'"' "'
    _coefplot_add_opt `opts' xscale `"`xoption'"' "'
    _coefplot_add_opt `opts' ylabel `"`ylabel'"' "'
    _coefplot_add_opt `opts' ytick `"`ytick'"' "'
    _coefplot_add_opt `opts' yscale `"`yoption'"' "'
    local 0 `", `subopts'"'
    syntax [, SCHEME(string) xsize(string) ysize(string) ///
        SCALE(string) TEXT(string) save(string asis) name(string) ///
        * ]
    if `"`scale'"'!="" local scale `"yscale(`scale') xscale(`scale')"'
    local opts `"`opts' `scale'"'
    if `"`text'"'!=""  local opts `"`opts' text(`text')"'
    if `"`scheme'"'!="" local opts `"`opts' scheme(`scheme')"'
    if `"`xsize'"'!=""  local opts `"`opts' xsize(`xsize')"'
    if `"`ysize'"'!=""  local opts `"`opts' ysize(`ysize')"'
    if `"`save'"'!=""   local opts `"`opts' saving(`save')"'
    if `"`name'"'!=""   local opts `"`opts' name(`name')"'
    if `"`options'"'!="" local opts `"`opts' `options'"'
    
    // initialize
    tempname by bycats i j k ky r
    tempname cc RES
    mata: `r' = _coefplot_get_returns()
    scalar `i' = 0
    local legend legend(off)
    _get_gropts, graphopts(`opts')
    local xtitle2 `"`s(ytitle)'"' // reverse x/y if horizontal
    local ytitle2 `"`s(xtitle)'"'
    local xtitle
    local ytitle
    if `"`horizontal'"'!="" | `"`vertical'"'=="" {
        local horizontal horizontal
        local xscale xscale(altaxis)
        local yscale yscale(altaxis)
        // Stata's all axis ticks/grid draw a vertical/horizontal line of the entire
        // width/height of the inner plot region even for categorical-axis plots,
        // which looks ugly, so disable them for the x-axis since that's the y-variable
        // in the horizontal case.
        local xgrid
        local xtick
    }
    else {
        local horizontal
        local xscale
        local yscale
        local ygrid
        local ytick
    }
    _coefplot__strip_missing at `at'
    local at `"`r(value)'"'
    if `"`posthz'"'=="" local posthz posthz
    else                local posthz
    
    // prepare ciopts
    forv h = 1/3 {
        local ciopts2 `"`ciopts2' ci`h'opt(`ci`h'opt')"'
    }
    
    // collect results
    local p 0
    foreach v of local vlist {
        local ++p
        mata: `r' = _coefplot_parse_input(`v')
        local v  `"`r'"'
        mata: `r' = _coefplot_get_plot(`v', `=`i''+("`bycoefs'"!=""), "`at'", ///
            "`noci'"!="", "`nooffsets'"!="", ///
            "`rename'", "`coeflabels'", ///
            (`"`horizontal'"'!=""), "`posthz'"!="", "`format'", ///
            "`nopostuff'"!="")
        _parse comma input1 input2 : r(input)  // returns input1 and input2
        _coefplot_parseparse `p' `"`input1'"'
        if `"`bylabels'"'=="" & `"`bycoefs'"'!="" {
            local bylabels `"`_bylabels'"'
        }
        local nplots `"`_nplot'"'
        mata: `r' = _coefplot_join(`=`cc'+1')  // join plot options and at()
        local nplot = r(k)
        if `=`cc'+1' {
            mata: `r' = _coefplot_get_plotpos(`=`i''+1, "`groups'", ///
                "`bycoefs'"!="")
            scalar `k' = r(k)
            scalar `j' = r(j)
            mata: `r' = _coefplot_inject_subgr_bycats(`RES', `=`i'+1', `=`j'')
            mata: `r' = _coefplot_collect_bylabels(`by')
            mata: `r' = _coefplot_compare_cats(`by', `bycats')
            scalar `i' = `j'
            if "`bycoefs'"!="" {
                forv jj = 1/`=r(n)' {
                    local bylabels0 `"`bylabels0'`"`=r(l`jj')'"' "'
                }
            }
        }
        scalar `cc' = `cc' + 1
    }
    mata: `r' = _coefplot_add_eq_info((`"`bycoefs'"'!=""))
    if "`bycoefs'"!="" {
        mata: `r' = _coefplot_get_bylabels(`by')
        if `"`bylabels'"'=="" {
            forv jj = 1/`=r(n)' {
                local bylabels `"`bylabels'`"`=r(l`jj')'"' "'
            }
        }
    }
    
    // headings and subtitles
    if `"`headings'"'!="" {
        mata: `r' = _coefplot_parse_headings(st_local("headings"))
    }
    if `"`subtitles'"'!="" {
        mata: `r' = _coefplot_parse_subtitles(st_local("subtitles"))
    }
    
    // plot options
    if `"`plot'"'!="" local plot `", `plot'"'
    if "`nopsuff'"=="" {
        local pstuff p
    }
    mata: `r' = _coefplot_get_model_style(`RES')
    forv jj = 1/`=`i'' {
        if r(p`jj') { // p`jj': nplot (models per subgraph)
            if "`noci'`ciopts2'"=="" {
                if `"`horizontal'"'!="" {
                    if `"`ogrid'"'!="" {
                        local ogrid0 `"`ogrid'"'
                        if `"`ogrid2'"'!="" {
                            local ogrid1 `"`ogrid2'"'
                        }
                        else {
                            local ogrid1 `"`ogrid0'"'
                        }
                        _coefplot_add_opt opts`jj' ///
                            `"`horizontal'"' yline(`"`ogrid0'"', `ogrid1') "'
                    }
                    else if "`nogrid'"=="" {
                        if `"`grid'"'!="" {
                            local grid0 `"`grid'"'
                            if `"`grid2'"'!="" {
                                local grid1 `"`grid2'"'
                            }
                            else {
                                local grid1 `"`grid0'"'
                            }
                        }
                        else {
                            if "`labels'"!="" local grid0 none
                            else              local grid0 .
                            local grid1 `"lstyle(grid) lcolor(gs12)"'
                        }
                        _coefplot_add_opt opts`jj' ///
                            `"`horizontal'"' yline(`"`grid0'"', `grid1') "'
                    }
                }
                else {
                    if `"`ogrid'"'!="" {
                        local ogrid0 `"`ogrid'"'
                        if `"`ogrid2'"'!="" {
                            local ogrid1 `"`ogrid2'"'
                        }
                        else {
                            local ogrid1 `"`ogrid0'"'
                        }
                        _coefplot_add_opt opts`jj' ///
                            `"`horizontal'"' xline(`"`ogrid0'"', `ogrid1') "'
                    }
                    else if "`nogrid'"=="" {
                        if `"`grid'"'!="" {
                            local grid0 `"`grid'"'
                            if `"`grid2'"'!="" {
                                local grid1 `"`grid2'"'
                            }
                            else {
                                local grid1 `"`grid0'"'
                            }
                        }
                        else {
                            if "`labels'"!="" local grid0 none
                            else              local grid0 .
                            local grid1 `"lstyle(grid) lcolor(gs12)"'
                        }
                        _coefplot_add_opt opts`jj' ///
                            `"`horizontal'"' xline(`"`grid0'"', `grid1') "'
                    }
                }
            }
            scalar `ky' = 0
            forv kk = 1/`=r(p`jj')' {
                if r(g`jj'_`kk') { // ngroup (coefficients per model)
                    scalar `ky' = `ky' + 1
                    if `"`pstuff'"'!="" {
                        local pstuff0 p`=`ky''
                    }
                    mata: `r' = _coefplot_get_opts("`pstuff0'", ///
                        "`normalize'", `jj', `kk', `i')
                    local myplot`jj'_`kk' `"connected `r(p1)' `r(p2)' `r(p3)' `r(p4)' `r(p5)'"'
                }
            }
        }
    }
    if `"`r_title'"'!="" {
        local title title(`"`r_title'"')
    }
    local title0 title(,`"bexpand bcolor(none) size(0)"')
    if `"`r_subtitle'"'!="" {
        local subtitle subtitle(`"`r_subtitle'"')
    }
    
    // yxline()
    local 0 `", `xline'"'
    syntax [, *]
    if `"`options'"'!="" {
        local 0 `", xline(`options')"'
        syntax [, LWidth(passthru) LPattern(passthru) LColor(passthru) ///
            LAlign(passthru) * ]
        if `"`lwidth'`lpattern'`lcolor'`lalign'"'!="" {
            local xlineopts `"xline(, `lwidth' `lpattern' `lcolor' `lalign')"'
        }
    }
    local 0 `", `yline'"'
    syntax [, *]
    if `"`options'"'!="" {
        local 0 `", yline(`options')"'
        syntax [, LWidth(passthru) LPattern(passthru) LColor(passthru) ///
            LAlign(passthru) * ]
        if `"`lwidth'`lpattern'`lcolor'`lalign'"'!="" {
            local ylineopts `"yline(, `lwidth' `lpattern' `lcolor' `lalign')"'
        }
    }
    if `"`horizontal'"'!="" {
        if `"`yline'"'!="" {
            local xline xline(`yline')
            local yline
        }
        if `"`xline'"'!="" {
            local yline yline(`xline')
            local xline
        }
        local xline `"`xline' `ylineopts'"'
        local yline `"`yline' `xlineopts'"'
    }
    else {
        if `"`yline'"'!="" {
            local yline yline(`yline')
        }
        if `"`xline'"'!="" {
            local xline xline(`xline')
        }
        local xline `"`xline' `xlineopts'"'
        local yline `"`yline' `ylineopts'"'
    }
    
    // get xlabels (and number of eqs)
    mata: `r' = _coefplot_get_labels("`horizontal'"!="", "`bycoefs'"!="")
    
    // set labels/legends
    if "`labels'" != "nolabels" & "`flatten'" == "" {
        if `"`horizontal'"'!="" {
            local ylabel2 ylabel(,nogrid)
            if r(eq)>1 {
                local neq = r(eq)
                local xsca
                forv i = 1/`neq' {
                    if `"`r(eqlab`i')'"'!="" {
                        _coefplot_add_opt xsca `"altxaxis(`i', "'
                        _coefplot_add_opt xsca `"axis("'
                        _coefplot_add_opt xsca ///
                            `"title(`"`r(eqlab`i')'"') "'
                        _coefplot_add_opt xsca `"labcolor(black)) "'
                    }
                    else _coefplot_add_opt xsca `"altxaxis(`i') "'
                }
                local xscale `"`xscale' `xsca'"'
            }
        }
        else {
            local xlabel2 xlabel(,nogrid)
            if r(eq)>1 {
                local neq = r(eq)
                local ysca
                forv i = 1/`neq' {
                    if `"`r(eqlab`i')'"'!="" {
                        _coefplot_add_opt ysca `"altyaxis(`i', "'
                        _coefplot_add_opt ysca `"axis("'
                        _coefplot_add_opt ysca ///
                            `"title(`"`r(eqlab`i')'"') "'
                        _coefplot_add_opt ysca `"labcolor(black)) "'
                    }
                    else _coefplot_add_opt ysca `"altyaxis(`i') "'
                }
                local yscale `"`yscale' `ysca'"'
            }
        }
        local xla xlabels(`r(xlabels)')
        local yla ylabels(`r(ylabels)')
    }
    else {
        local nolabels nolabels
    }
    if "`bycoefs'"!="" {
        if `"`bylabels'"'!="" & `"`bylabels0'"'!="" {
            mata: `r' = _coefplot_merge_bylabels(`by', ("`bylabels'"), ("`bylabels0'"))
        }
        else if `"`bylabels0'"'!="" {
            local bylabels `"`bylabels0'"'
        }
        local bycmd by(, `byopts')
        if `"`bylabels'"'!="" {
            local bylegend legend(`r(legend)')
        }
        else {
            local bylegend legend(off)
        }
    }
    if `"`legend'"' == "legend(off)" & "`nplots'" != "" & "`nolabels'" == "" {
        mata: `r' = _coefplot_get_plotlabels(`RES', "`bycoefs'"=="")
        if r(legendnum) {
            local legend legend(`r(legend)')
        }
    }
    
    // graph
    if "`none'"!="" exit
    local gropts `title' `title0' `subtitle' `note' `xline' `yline' ///
        `legend' `bylegend' `xlabel2' `ylabel2' `xla' `yla' ///
        `xscale' `yscale' `xtick' `ytick' `opts' `bycmd'
    if `"`addplot'"'!="" {
        local addplot `"|| `addplot' ||"'
    }
    local plotcmds
    local axtitle
    forv jj = 1/`=`i'' {
        if r(p`jj') { // p`jj': nplot (models per subgraph)
            local rcmds
            scalar `ky' = 0
            forv kk = 1/`=r(p`jj')' {
                if r(g`jj'_`kk') { // ngroup (coefficients per model)
                    scalar `ky' = `ky' + 1
                    local rcmds `"`rcmds' || `myplot`jj'_`kk'' `plot' || "'
                }
            }
            if `"`rcmds'"'!="" {
                local plotcmds `"`plotcmds' `rcmds' `opts`jj'' ||"'
            }
        }
    }
    if "`horizontal'"!="" {
        if `"`xtitle2'"'!="" & `"`xtitle'"'=="" {
            local axtitle ytitle(`"`xtitle2'"')
        }
        if `"`xtitle'"'!="" {
            local axtitle ytitle(`"`xtitle'"')
        }
        if `"`ytitle2'"'!="" & `"`ytitle'"'=="" {
            local axtitle `axtitle' xtitle(`"`ytitle2'"')
        }
        if `"`ytitle'"'!="" {
            local axtitle `axtitle' xtitle(`"`ytitle'"')
        }
    }
    else {
        if `"`xtitle2'"'!="" & `"`xtitle'"'=="" {
            local axtitle xtitle(`"`xtitle2'"')
        }
        if `"`xtitle'"'!="" {
            local axtitle xtitle(`"`xtitle'"')
        }
        if `"`ytitle2'"'!="" & `"`ytitle'"'=="" {
            local axtitle `axtitle' ytitle(`"`ytitle2'"')
        }
        if `"`ytitle'"'!="" {
            local axtitle `axtitle' ytitle(`"`ytitle'"')
        }
    }
    version 11: twoway `plotcmds' `addplot', ///
        `axtitle' `gropts'
    
    // return e-returns
    eret clear
    eret local cmdline `"coefplot `0'"'
    eret local cmd "coefplot"
end

program _coefplot_parsesubcmd
    eret parse, first: `0'
    local cmdname `"`s(first)'"'
    if `"`cmdname'"'=="matrix" {  // matrix(...)
        eret parse, between("(", ")") second: `0'
        eret parse, extract: `"`s(between)'"'
        local vlist `"`s(rec0)'"'
        local 0 `"`s(second)'"'
        eret parse, second(, ",", "{", "}"): `0'
        local wlist `"`s(rest)'"'
        local 0 `"`s(second)'"'
    }
    else {                      // model
        local 0: subinstr local 0 `"`cmdname'"' ""
        eret parse, second(, ",", "{", "}"): `0'
        local wlist `"`s(rest)'"'
        local 0 `"`s(second)'"'
        local vlist "`cmdname'"
    }
    eret parse, first("," "[", "]"): `"`0'"'
    c_local cmdname `"`cmdname'"'
    c_local vlist `"`vlist'"'
    c_local wlist `"`wlist'"'
    c_local flist `"`s(first)'"'
end

program _coefplot_parseparse // recusively collect values and options from multiple plots
    args p input
    if `"`input'"'=="" exit
    eret parse, first(","): `"`input'"'
    capt confirm integer number `p'
    if _rc local pl "_`p'"
    else   local pl "`p'"
    local _nplot1`pl': copy local _nplot`pl'
    local _bylabels1`pl': copy local _bylabels`pl'
    if `"`_nplot1`pl''"'=="" {
        local _nplot1`pl' 1
        local _nplot`pl' 1
        c_local _nplot `_nplot`pl''  // global return
        c_local _bylabels `"`_bylabels`pl''"'
    }
    local input `"`s(first)'"'
    if substr(`"`input'"',1,1)=="(" {
        eret parse, between("(", ")"): `"`input'"'
        eret parse, extract(1): `"`s(between)'"'
        local par0: copy local s(rec0)
        eret parse, extract: `"`par0'"'
        local p0: copy local s(rec0)
    }
    else {
        local p0 1
    }
    capt confirm integer number `p0'
    if _rc {
        di as err "invalid plot specification"
        exit 198
    }
    forv j = 1/`p0' {
        local _nplot`pl' = `_nplot`pl'' + 1
        local _p`_nplot`pl''`pl' `p'
        local _bylabels`pl' `"`_bylabels`pl''`"`s(rec`j')'"' "'
    }
    eret parse, first("," "[", "]"): `"`s(rest)'"'
    _coefplot_parseparse `=`p'+1' `"`s(first)'"'
end

program _coefplot__strip_missing, rclass
    args name value
    if trim(`"`value'"')=="" { // `name' specified without argument
        return local value `"`name'()"'
        exit
    }
    // check whether value is a name
    local c1 = substr(`"`value'"',1,1)
    if !inrange(`"`c1'"',"a","z") & !inrange(`"`c1'"',"A","Z") {
        return local value `"`name'(`value')"'
        exit
    }
    // check whether value can be interpreted as name(...)
    gettoken tok rest : value, parse("(")
    if `"`rest'"'=="" {  // value is a name without (...)
        return local value `"`name'(`value')"'
        exit
    }
    // value is of the form name(...) or name(... or ...)
    // => check whether name can be interpreted as an option name
    // => if so, `name' is missing and `value' belongs to next option
    local c = substr(`"`tok'"', 1, 1)
    if (inrange(`"`c'"', "a", "z") | inrange(`"`c'"', "A", "Z")) {
        // check whether name(...) exists
        capture confirm names `tok'
        if (_rc==0) {
            return local value `"`name'() `value'"'
            exit
        }
    }
    return local value `"`name'(`value')"'
end

program _coefplot_add_opt // adds/replaces options
    args name value opt
    if `"`value'"'=="" exit
    local hasyaxis = strpos(`"`value'"', "yaxis(")
    local hasxaxis = strpos(`"`value'"', "xaxis(")
    if !`hasyaxis' & !`hasxaxis' & `"`opt'"'=="" local opt axis(1)
    c_local `name' `"``name'' `value'`opt'"'
end

mata:
struct CoefPlot_element {
    real scalar  j                     // subgraph
    real scalar  k                     // plot
    real scalar  eq                    // equation number
    real scalar  i                     // outcome equation index
    real scalar  mlpos                 // options for marker label position
    string scalar    label             // coefficient/heading label
    string scalar    eqlabel           // equation label
    real scalar      plabel            // nonzero = include in key
    real scalar      at                // position on x-axis
    real scalar      b                 // (transformed) coefficient
    real scalar      se                // (transformed) standard error
    real scalar      ci                // ci level
    real scalar      aux               // auxiliary data
    string scalar    by                // bygroup
    string scalar    plot              // plotgroup (style)
    string scalar    mlbl              // marker label
    string scalar    ciplbl            // ci plot marker label
    struct CoefPlot_style scalar   style // style
}
struct CoefPlot_style {
    string scalar    msymbol
    string scalar    mcolor
    string scalar    mlabcolor
    string scalar    mlabposition
    string scalar    mlabgap
    string scalar    mlabangle
    string scalar    mlabsize
    string scalar    mlabstyle
    string scalar    msize
    string scalar    msangle
    string scalar    mfcolor
    string scalar    mlcolor
    string scalar    mlwidth
    string scalar    mlalign
    string scalar    mlstyle
    string scalar    csymbol
    string scalar    ccolor
    string scalar    clcolor
    string scalar    clwidth
    string scalar    clstyle
    string scalar    clalign
    string scalar    clpattern
    string scalar    cinsidecolor
    string scalar    cisizecolor
    string scalar    clsizecolor
    string scalar    clcintypeolor
}
struct CoefPlot_ci {
    real scalar      level
    real scalar      n
    real rowvector   l
    real rowvector   u
}

struct CoefPlot_subgr {
    real scalar      j              // subgraph
    string scalar    grid           // grid options
    string scalar    yline          // yline options
}

struct CoefPlot_plotregion {
    real scalar      i
    real scalar      j
    string scalar    at
    string scalar    x
    string scalar    xlab
    string scalar    axis
    string scalar    plot
    string scalar    opts
}

struct CoefPlot_model {
    string rowvector at
    string rowvector eqs
    string rowvector sns
    string rowvector atwl
    string rowvector auxs
    string rowvector pstyles
    string rowvector mlabels
    string scalar    prefix
    string matrix    cis
    string matrix    bs
    string matrix    ses
    string matrix    ts
    string matrix    dfs
    string matrix    pvals
    string matrix    auxmat
    real scalar      mlpos
    real scalar      nokey
    real colvector   nobs
    string rowvector eqlabels
    string rowvector cats
    string rowvector bysarr
    string rowvector ps          // plot index (style)
    string rowvector posarr      // positions for headings
    real matrix      pos         // positions for headings matrix
    pragma unset     cis
    pragma unset     bs
    pragma unset     ses
    pragma unset     ts
    pragma unset     dfs
    pragma unset     pvals
    pragma unset     auxmat
}

struct CoefPlot_info {
    struct CoefPlot_model scalar model
    real scalar      eqnow
    real scalar      nowpos
    real scalar      nowat
    real rowvector   atn
    struct CoefPlot_element scalar element
}

struct CoefPlot_models {
    real scalar      n
    real scalar      subview
    struct CoefPlot_model vector    model
}

struct CoefPlot_struct {
    real scalar      k
    real scalar      n
    real scalar      nby
    real scalar      nxlab
    real scalar      neq
    string matrix    results
    string rowvector pstyles
    string rowvector coeflabels   // merged coefficients labels
    string rowvector bylabels     // bylabels across plots
    string rowvector byvector
    string matrix    xlab         // coefficients labels by plot
    string matrix    eqlab        // equations labels by plot
    real matrix      eq           // equation numbers by plot
    struct CoefPlot_subgr vector  s
    struct CoefPlot_ci vector     ci
    struct CoefPlot_plotregion scalar plotregion
    string scalar    iname
}

// returns
void _coefplot_return_add_r_err(string scalar msg,| string scalar rc)
{
    if (rc=="") rc = "198"
    st_local("r_err_toadd", msg)
    st_local("r_rc", rc)
    st_local("r_return_local", "r_err")
    st_local("r_err", msg)
}

string scalar _coefplot_get_returns()
{
    if (st_local("r_return_local")!="") {
        if (st_local("r_return_local")=="r_err") {
            printf("{error:%s}\n", st_local("r_err_toadd"))
            exit(strtoreal(st_local("r_rc")))
        }
        return(st_local(st_local("r_return_local")))
    }
    return("")
}

string scalar _coefplot_parse_input(string scalar v)
{
    if (v=="") return("")
    if (substr(v, 1, 1)!="(") return(v)
    v = strtrim(substr(v, 2, strlen(v)-2))
    return(v)
}

// parsing routines
string rowvector _coefplot_invtokens(string scalar s, |real scalar noreturn)
{
    return(tokens(s))
}

// collections
string scalar _coefplot_merge_bylabels(pointer scalar by,
    string rowvector from,
    string rowvector from0)
{
    fxs = (from:!="")
    if (any(fxs)) {
        if (rows((*by))>=cols(from)) (*by)[|1,1 \ 1,cols(from)|] = from'
    }
    fxs = (from0:!="")
    if (any(fxs)) {
        if (rows((*by))>=cols(from0)) (*by)[|1,1 \ 1,cols(from0)|] = from0'
    }
    
    // Get distinct legend labels
    n = min((rows((*by)), cols(from)))
    ky_i = J(1, n, 0)
    ky_v = J(1, n, "")
    for (i=1; i<=n; i++) {
        if ((*by)[i,1]=="") continue
        ky_i[i] = i
        ky_v[i] = (*by)[i,1]
    }
    s = select((1::n), ky_i:!=0)
    if (length(s)==0) return("")
    ky_i = ky_i[s]
    ky_v = ky_v[s]
    
    // Generate legend string
    legend = "order("
    for (i=1; i<=length(ky_i); i++) {
        legend = legend + strofreal(ky_i[i])
        if (i<length(ky_i)) legend = legend + " "
    }
    legend = legend + ") label("
    for (i=1; i<=length(ky_i); i++) {
        legend = legend + strofreal(ky_i[i]) + `" "`ky_v[i]'"' + " "
    }
    legend = legend + ")"
    st_local("r(legend)", legend)
    return("r(legend)")
}

// plot and model
string scalar _coefplot_join(real scalar ci)
{
    return(ci)
}

string scalar _coefplot_collect_bylabels(pointer scalar by)
{
    if (st_global("r(k)")!="") {
        n = strtoreal(st_global("r(k)"))
        *by = J(n, 1, "")
        for (i=1; i<=n; i++) {
            if (st_global("r(l"+strofreal(i)+")")!="") {
                (*by)[i,1] = st_global("r(l"+strofreal(i)+")")
            }
        }
    }
    return("")
}
mata mlib add lftools coefplot.mata
end