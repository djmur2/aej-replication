# Data Acquisition Process

This document details the specific process for acquiring and preprocessing the proprietary data needed for replication.

## Overview

To replicate this study, researchers need access to:

1. **Compustat Global**: Financial and stock market data
2. **Markit Securities Finance**: Stock lending data

These proprietary datasets need to be processed into country-specific CSV files before running the replication code.

## Detailed Acquisition Process

The following pseudocode outlines the process we used to prepare the country-specific CSV files from the raw proprietary data sources:

```python
# 1. Ingest raw .txt files into Athena via external tables
for source in ["Compustat", "Markit"]:
    # upload the source's .txt files to S3
    upload_txt_files_to_s3(source, s3_path="s3://bucket/raw/{source}/")

    # define an Athena external table over the uploaded .txt files
    create_athena_table(
        table_name = source.lower() + "_raw", 
        s3_location = "s3://bucket/raw/{source}/",
        format = "TEXT",
        schema = {...}    # columns as in the .txt files
    )

# 2. Query and transform by country
results = []
for country_code in LIST_OF_COUNTRIES:
    # pull Compustat rows for this country
    comp = athena_query(
        "SELECT * FROM compustat_raw WHERE country_code = '{country_code}'"
    )
    # prefix all data columns with "c_" (leave country_code untouched)
    comp_prefixed = add_prefix_to_columns(comp, prefix="c_", exclude=["country_code"])

    # pull Markit rows for this country
    mark = athena_query(
        "SELECT * FROM markit_raw WHERE country_code = '{country_code}'"
    )
    # prefix all data columns with "m_"
    mark_prefixed = add_prefix_to_columns(mark, prefix="m_", exclude=["country_code"])

    # merge the two sources on the country_code key
    merged = merge_datasets(
        left = comp_prefixed, 
        right = mark_prefixed, 
        on = ["country_code"], 
        how = "outer"
    )

    results.append(merged)

# 3. Concatenate all country-level frames into one
alltodos = concatenate_dataframes(results, axis=0)

# 4. Persist the result as an Athena table
create_athena_table_as_select(
    table_name = "alltodos_processed",
    database   = "finance_db",
    query      = "SELECT * FROM UNNEST(ARRAY[alltodos])"  
    # or use a CTAS: 
    # "CREATE TABLE finance_db.alltodos_processed WITH (format = 'PARQUET') AS SELECT * FROM (...)"
)

# 5. Export to CSV files by country
for country_code in LIST_OF_COUNTRIES:
    country_data = athena_query(
        f"SELECT * FROM alltodos_processed WHERE country_code = '{country_code}'"
    )
    export_to_csv(
        data = country_data,
        filename = f"0_raw_data/{country_code.lower()}.csv"
    )
```

## Required Data Elements

### From Compustat Global

The following variables are needed from Compustat, with the prefix `c_`:

- `c_gvkey`: Global company identifier
- `c_isin`: International Securities Identification Number
- `c_datadate`: Date of observation
- `c_prccd`: Stock price in local currency
- `c_cshtrd`: Shares traded
- `c_cshoc`: Shares outstanding
- `c_divdgross`: Gross dividend amount
- `c_exchg`: Stock exchange code
- `c_conm`: Company name
- `c_curcddv`: Currency code for dividends
- `c_fic`: Country of incorporation
- `c_loc`: Country of headquarters

### From Markit Securities Finance

The following variables are needed from Markit, with the prefix `m_`:

- `m_isin`: International Securities Identification Number
- `m_datadate`: Date of observation
- `m_lendervalueonloan`: Value of shares on loan
- `m_lenderquantityonloan`: Quantity of shares on loan
- `m_lendablequantity`: Quantity of shares available for lending
- `m_utilisation`: Utilization rate
- `m_lenderconcentration`: Lender concentration
- `m_borrowerconcentration`: Borrower concentration

## Country Codes

The preprocessing should create CSV files for each of these countries:

| CSV Filename | Country         |
|-------------|-----------------|
| `aut.csv`   | Austria         |
| `bel.csv`   | Belgium         |
| `che.csv`   | Switzerland     |
| `deu.csv`   | Germany         |
| `dnk.csv`   | Denmark         |
| `esp.csv`   | Spain           |
| `fin.csv`   | Finland         |
| `fra.csv`   | France          |
| `gbr.csv`   | United Kingdom  |
| `irl.csv`   | Ireland         |
| `isl.csv`   | Iceland         |
| `ita.csv`   | Italy           |
| `lux.csv`   | Luxembourg      |
| `nld.csv`   | Netherlands     |
| `nor.csv`   | Norway          |
| `prt.csv`   | Portugal        |
| `swe.csv`   | Sweden          |

## Alternative Implementation

If you don't have access to AWS Athena, you can implement a similar process using:

- **Python with pandas**: For smaller datasets
- **R with data.table**: For medium-sized datasets 
- **Spark**: For very large datasets

Regardless of the technology used, the key steps remain the same:
1. Load the raw data from both sources
2. Filter by country
3. Add the appropriate prefixes to column names
4. Merge the datasets by ISIN and date
5. Save as country-specific CSV files

## Placement of Output Files

The processed CSV files should be placed in the `0_raw_data/` directory of the replication package before running the transformation code. The files are then processed by `1_import_data.do` at the beginning of the replication workflow.