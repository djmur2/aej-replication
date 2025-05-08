*! version 2.46.0 07jan2022
program ftools, rclass
	gettoken subcommand 0 : 0, parse(" ,")
	local subcommand `subcommand'
	if ("`subcommand'" == substr("compile", 1, max(2, strlen("`subcommand'")))) {
		compile_mata `0'
	}
	else if ("`subcommand'" == substr("version", 1, max(2, strlen("`subcommand'")))) {
		version_info `0'
	}
	else {
		di as error "Incorrect subcommand: ftools {compile|version}"
		error 197
	}
end


program compile_mata
	mata: mata mlib create lftools, dir("`c(sysdir_plus)'l") replace
	mata: mata mlib add lftools Vector.mata
	mata: mata mlib add lftools Factor.mata
	mata: mata mlib add lftools HashMap.mata
	mata: mata mlib add lftools Bimap.mata
	mata: mata mlib add lftools fcmp.mata
	mata: mata mlib add lftools ftools.mata
	mata: mata mlib add lftools ftools_common.mata
	mata: mata mlib add lftools ftools_hash.mata
	mata: mata mlib add lftools ftools_main.mata
	mata: mata mlib add lftools ftools_plugin.mata
	mata: mata mlib index
end


program version_info, rclass
	syntax [, Verbose]
	local 0 version
	cap mata: `0'
	if ("`verbose'" != "") {
		mata: mata desc lftools
		mata: mata which Vector
		mata: mata which Factor
		mata: mata which HashMap
		mata: mata which Bimap
		mata: mata which fcmp
		mata: mata which ftools
		mata: mata which ftools_common
		mata: mata which ftools_hash
		mata: mata which ftools_main
		mata: mata which ftools_plugin
	}
end


// The functions below are the ones used with the statistical programs
// ---------------------------------------------------------------------
program define _assert_2, rclass
	cap assert `0'
	if c(rc) {
		di as error "assertion failed: `0'"
		exit c(rc)
	}
end


program define _get_varlabel, rclass
	local lbl : var label `0'
	return local label "`lbl'"
end


program define _get_valueformat, rclass
	local fmt : format `0'
	return local format "`fmt'"
end


program define _get_generic_levels, rclass
	syntax varlist(min=1) [if] [in] [, /*
		*/ method(string asis) /*
		*/ dict_info(string) /*
		*/ MAP_Function(string) /*
		*/ POOLfactor(string) /*
		*/ Verbose]
	marksample touse, novarlist
	if ("`method'" == "") local method hash1

	if ("`dict_info'" != "") {
		cap confirm file "`dict_info'"
		if _rc {
			di as error "error: dict_info `dict_info' does not exist"
			exit 601
		}
		tempname dict_fh
		local loaded_dict 1
		file open `dict_fh' using "`dict_info'", read
	}
	else {
		local loaded_dict 0
	}

	tempname levels counts map_info
	local num_vars : word count `varlist'

	mata: F = factor("`varlist'", "`touse'", "`method'", /*
		*/ "`map_function'", "`poolfactor'", /*
		*/ `loaded_dict', "`dict_fh'", /*
		*/ ("`verbose'" != ""))
	mata: `levels' = asarray_keys(F.keys)
	mata: `counts' = asarray_get_values(F.counts)
	mata: `map_info' = F.save_map_info()
	if (`loaded_dict') file close `dict_fh'

	return matrix levels = `levels'
	return matrix counts = `counts'
	return matrix map_info = `map_info'
	return scalar num_levels = rowsof(`levels')
	return scalar num_vars = `num_vars'
end


program define _get_levels, rclass
	_get_generic_levels `0', method(hash1) verbose
	return add
end


program define _get_clean_levels, rclass
	_get_levels `0'
	return add
end


program define _tab, rclass
	cap syntax varlist(min=1 max=1) [if] [in], [sort ascii MISSing]
	if (c(rc) == 1) error 1
	if c(rc) {
		if c(rc) == 2000 {
			di as err "nothing to tabulate"
			exit 2000
		}
		else {
			local line {err}unrecognized syntax, problem parsing around:{reset}
			noi DispErr `line' `"`0'"' 
			exit 198
		}
	}
	marksample touse, strok
	local varname : copy local varlist
	local hash1 hash1

	// Store variable label
	return local label
	_get_varlabel `varname'
	return local label = r(label)

	// Convert numerical vars to strings
	cap confirm numeric variable `varname'
	local is_numeric = (c(rc)==0)
	if `is_numeric' {
		tempvar copy
		local format_str : format `varname'
		local format_str : subinstr local format_str "%" "", all
		local format_str : subinstr local format_str "s" "", all
		local format_str : subinstr local format_str "t" "", all
		local format_str : subinstr local format_str "-" "", all
		local format_str : subinstr local format_str "," "", all
		// Is the format string empty? (e.g. %s)
		if (!regexm("`format_str'", "[0-9]+(\.[0-9]+)?")) {
			local as_str as string
		}
		// Check if it's an integer
		else if (!regexm("`format_str'", "\.")) {
			local as_str : subinstr local format_str "g" "", all
			local as_str : subinstr local as_str "f" "", all
			local as_str : subinstr local as_str "e" "", all
			local as_str : subinstr local as_str "c" "", all
			local as_str "as string(`as_str')"
		}
		else {
			local as_str as string
		}
		
		qui gen strL `copy' = `as_str' `varname' if `touse'
		local varname `copy'
	}
	
	// Run the main routine
	_get_generic_levels `varname' if `touse', method(`hash1') /*
		*/ `verbose' `sort'
	
	// Decode if value:label map
	cap confirm matrix r(levels)
	if _rc {
		di as err "(nothing to tabulate)"
		exit 999
	}
	tempname levels counts
	matrix `levels' = r(levels)
	local num_levels = r(num_levels)
	matrix `counts' = r(counts)

	local ret_missing
	
	// Don't sort missing unless explicitly requested
	if (`is_numeric' & "`missing'" == "") {
		mata: fix_missing_order(`levels', `counts')
	}
	else if ("`missing'" != "") {
		local ret_missing = "missing"
	}

	return local missing = `ret_missing'
	return scalar N = sum(`counts')
	return matrix levels = `levels'
	return matrix counts = `counts'
	return scalar num_levels = rowsof(`levels')
	return local varname `varlist'
	return local var = "`varlist'"
end


capture program define DispErr, rclass
	return local message `"`0'"'
	dis `return(message)'
end


// ---------------------------------------------------------------------
// Mata section
// ---------------------------------------------------------------------

mata:
class Factor {
	// Public variables
	// ----------------
	// F.counts - asarray(i, count)
	// F.keys   - asarray(i, .) and asarray(key, i)
	// F.levels - vector of keys

	// Basic keys
	// ----------
	real scalar num_levels
	real scalar num_obs
	real scalar max_strL
	real scalar max_width
	real scalar ktype
	real scalar vtype
	real scalar pooled
	real scalar verbose
	real scalar sorted
	real scalar save_keys
	real vector index
	real vector counts
	real vector levels
	struct Vector vector scalar map
	struct Vector vector scalar values
	struct Vector vector scalar val_levels
	string rowvector varlist
	string scalar method
	real scalar drop_index
	string scalar touse
	string scalar msg_prefix
	
	// Integer keys
	// ------------
	real scalar int_keys
	real scalar min_val
	real scalar max_val
	class HashMap scalar hashes

	// String keys
	// -----------
	real scalar has_strL
	string vector str_levels
	
	// Numeric keys
	// ------------
	real vector num_levels
	
	// BiMap class
	// -----------
	class BiMap scalar bimap
	real vector map_keys
	real vector map_values
	string scalar map_fcn
	real scalar map_initialized
	
	// External data
	// ------------
	real scalar dict_loaded
	pointer scalar dict_fh
	
	// Methods
	void new()
	real scalar is_injective()
	real vector invert()
	void init_keys()
	void check_inputs()
	real scalar get_method()
	real scalar pool()
	void init_bimap()
	void finalize_bimap()
	real vector save_map_info()
	real vector get_sorted_levels()
	real vector order()
}


void Factor::new() {
	ktype = 0
	vtype = 0
	num_levels = .
	num_obs = .
	max_strL = 0
	max_width = 0
	index = J(0, 1, .)
	counts = J(0, 1, .)
	levels = J(0, 1, .)
	method = ""
	varlist = J(1, 0, "")
	sorted = 0
	save_keys = 1
	pooled = 0
	verbose = 0
	has_strL = 0
	drop_index = 0
	touse = ""
	msg_prefix = "__" // "ftools>" // used by _get_levels, not by other functions
	
	// Integer keys
	int_keys = 0
	min_val = .
	max_val = .
	
	// Map function
	map_fcn = ""
	map_initialized = 0
	
	// External data
	dict_loaded = 0
	dict_fh = NULL
}


real vector Factor::save_map_info() {
	real vector ans
	if (map_initialized == 0) return(J(0, 1, .))
	ans = (bimap.N \ rows(bimap.keys) \ rows(bimap.values))
	return(ans)
}


real scalar Factor::is_injective() {
	if (map_initialized == 0) return(1)
	return(rows(bimap.values) == rows(bimap.keys))
}


real vector Factor::invert() {
	"IMPLEMENT ME!"
	assert(0)
}


real vector Factor::get_sorted_levels() {
	// Create a levels vector sorted by frequency
	real vector idx
	if (num_levels==0) return (J(0, 1, .))
	//  asarray_keys won't work b/c it returns the keys in arbitrary order
	idx = order(counts, 1)
	if (num_levels > 0 & num_levels < rows(idx)) {
		idx = idx[|rows(idx) - num_levels + 1 \ rows(idx)|]
	}
	if (ktype == 3) {
		return(str_levels[idx])
	}
	else {
		return(levels[idx])
	}
}


real vector Factor::order() {
	real vector ans
	real scalar i
	ans = J(num_obs, 1, .)
	if (length(index) == 0) return (ans)
	for (i = 1; i <= num_levels; i++) {
		if (counts[i] > 0) ans[selectindex(index :== i)] = J(counts[i], 1, i)
	}
	return(ans)
}


void Factor::init_keys() {
	// TODO: make this generic
	"IMPLEMENT ME!"
	assert(0)
}


void Factor::check_inputs() {
	if (num_levels == 0) return
	if (ktype == 3) {
		assert(length(str_levels) == num_levels)
	}
	else {
		assert(length(levels) == num_levels)
	}
	assert(length(counts) == num_levels)
}


void Factor::init_bimap() {
	// Initialize BiMap
	struct Vector vector scalar new_args
	bimap.num_keys = 0
	bimap.num_values = 0
	bimap.N = 0
	bimap.ktype = 0
	bimap.vtype = 0
	
	if (map_fcn == "") return
	
	if (map_fcn == "identity") {
		vector.init()
		vector.type = vtype
		vector.data = values.data
		vector.count = values.count
		map.init()
		map.type = 115
		map.count = values.count
		map.data = J(values.count, 1, "error")
		bimap.keys = map
		bimap.values = values
		bimap.N = values.count
		bimap.ktype = 1
		bimap.vtype = vtype
		bimap.is_identity = 1
		map_initialized = 1
	}
	else {
		assert(0) // TODO: "implement me!"
	}
}


void Factor::finalize_bimap() {
	if (map_initialized == 0) return
}


real scalar Factor::get_method() {
	real scalar idx
	string matrix methods
	
	methods = ("hash0", "128", /*
		*/   "hash1", "4", /*
		*/   "hash2", "0", /*
		*/   "hash3", "121", /*
		*/   "bimap", "4")
	
	idx = selectindex(methods[., 1] :== method)
	if (length(idx) == 0) return(4)
	return(strtoreal(methods[idx, 2]))
}


real scalar Factor::pool() {
	pooled = 1
	return(1)
}


// Need this for -areg, absorb()-
// Note that asarray_keys and asarray_get_values are included here too (below)
end



void version() {
	printf("ftools version: 2.46.0 07jan2022\n")
}


void fix_missing_order(matrix levels, matrix counts)
{
	real scalar last, i, num_missing
	real scalar has_strL
	
	has_strL = 0
	if (eltype(levels)!=4) {
		has_strL = sum(rowmissing(levels))
		if (has_strL > 0) has_strL = 1
	}

	if (has_strL == 0 & eltype(levels) != 4) {
		num_missing = sum(rowmissing(levels))
		if (num_missing > 0) {
			last = rows(levels)
			i = last - num_missing + 1
			if (i <= last & rows(counts) == rows(levels)) {
				// Sort the missings at the end
				levels[|i, 1 \ last, cols(levels)|] = J(num_missing, cols(levels), .)
				counts[|i, 1 \ last, cols(counts)|] = counts[selectindex(rowmissing(levels)), .]
			}
		}
	}
}


pointer (real matrix) scalar asarray_keys(transmorphic matrix arr_A)
{
	real scalar len, i
	real vector ans, indices
	
	ans = J(0, 1, .)
	indices = asarray_first(arr_A) \ asarray_next(arr_A)
	
	for (i = 1; i <= length(indices); i++) {
		ans = ans \ indices[i]
	}
	return(&ans)
}


pointer (real matrix) scalar asarray_get_values(transmorphic matrix arr_A)
{
	real scalar len, i
	real vector ans, indices
	
	ans = J(0, 1, .)
	indices = asarray_first(arr_A) \ asarray_next(arr_A)
	
	for (i = 1; i <= length(indices); i++) {
		ans = ans \ asarray(arr_A, indices[i])
	}
	return(&ans)
}


real vector asarray_get_values_num(transmorphic matrix arr_A) {
	real vector ans, indices
	real scalar i
	
	ans = J(0, 1, .)
	indices = asarray_first(arr_A) \ asarray_next(arr_A)
	
	for (i = 1; i <= length(indices); i++) {
		ans = ans \ asarray(arr_A, indices[i])
	}
	return(ans)
}


pointer factor(string matrix varlist,
			 string scalar touse,
			 string scalar method,
			 string scalar map_fcn,
			 string scalar poolfactor,
			 | real scalar dict_loaded,
			 string scalar dict_fh,
			 real scalar verbose)
{
	class Factor scalar F
	
	if (args() < 5) poolfactor = ""
	if (args() < 6) dict_loaded = 0
	if (args() < 7) dict_fh = ""
	if (args() < 8) verbose = 0
	
	F.num_levels = .
	F.method = method
	F.verbose = verbose
	F.varlist = tokens(varlist)
	F.touse = touse
	F.map_fcn = map_fcn
	F.pooled = (poolfactor != "")
	F.dict_loaded = dict_loaded
	
	if (F.dict_loaded) F.dict_fh = &dict_fh
	assert_msg(F.get_method() != ., sprintf("Method %s not implemented", method))
	
	// Return pointer to a factor variable
	return(&F)
}
mata mlib add lftools ftools.mata
mata mlib add lftools ftools_hash.mata
mata mlib add lftools ftools_main.mata


class HashMap {
	real scalar num_levels
	real scalar num_obs
	real scalar vtype
	real scalar pooled
	real scalar verbose
	real vector index
	real vector keys
	real vector values
	transmorphic matrix dict
	string matrix varlist
	string scalar touse
	void new()
}


void HashMap::new() {
	dict = asarray_create("real")
	num_levels = .
	num_obs = .
	vtype = 0
	index = J(0, 1, .)
	keys = J(0, 1, .)
	varlist = J(1, 0, "")
	pooled = 0
	verbose = 0
	touse = ""
}


// Vectors
struct Vector {
	real scalar type // based on eltype() plus 100 for string
	real scalar count
	real vector data
	string vector data_str
}


void vector::init() {
	type = 0
	count = 0
	data = J(0, 1, .)
	data_str = J(0, 1, "")
}


void vector::add(| real scalar value, string scalar value_str) {
	if (args() < 1) value = .
	if (args() < 2) value_str = ""
	
	if (type == 0) {
		if (value != .) {
			type = eltype(value)
		}
		else if (value_str != "") {
			type = 115 // strL
		}
		else {
			assert(0) // uninitialized type
		}
	}
	
	if (type <= 100) {
		// Numeric
		data = data \ value
	}
	else {
		// String
		data_str = data_str \ value_str
	}
	count = count + 1
}


// Factor BiMap class (for bijections)
class BiMap {
	real scalar ktype // Based on eltype() plus 100 for string
	real scalar vtype // Based on eltype() plus 100 for string
	real scalar num_keys
	real scalar num_values
	real scalar N
	real scalar is_sorted
	real scalar is_identity // Flag for when values is a subset of keys
	struct Vector vector scalar keys
	struct Vector vector scalar values
	void new()
}


void BiMap::new() {
	num_keys = 0
	num_values = 0
	N = 0
	ktype = 0
	vtype = 0
	is_sorted = 0
	is_identity = 0
}


// Assert

void assert_msg(real scalar condition, string scalar msg) {
	if (!condition) {
		printf("{txt}%s\n", msg)
		_error(123)
	}
}
end