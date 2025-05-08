# Data Preprocessing

This document explains the preprocessing steps required to create the country-specific CSV files from the proprietary data sources (Compustat and Markit) before running the transformation code in the replication package.

## Overview

The raw data from Compustat and Markit comes in text files that need to be processed and merged to create the country-specific CSV files used as inputs for the replication code. This preprocessing involves:

1. Ingesting raw text files into a database (e.g., Amazon Athena)
2. Querying and transforming by country
3. Concatenating country-level frames
4. Exporting as CSV files

## Detailed Process

### 1. Ingest Raw Text Files into Athena via External Tables

```python
for source in ["Compustat", "Markit"]:
    # Upload the source's .txt files to S3
    upload_txt_files_to_s3(source, s3_path=f"s3://bucket/raw/{source}/")

    # Define an Athena external table over the uploaded .txt files
    create_athena_table(
        table_name = source.lower() + "_raw", 
        s3_location = f"s3://bucket/raw/{source}/",
        format = "TEXT",
        schema = {...}    # columns as in the .txt files
    )
```

### 2. Query and Transform by Country

```python
results = []
for country_code in LIST_OF_COUNTRIES:
    # Pull Compustat rows for this country
    comp = athena_query(
        f"SELECT * FROM compustat_raw WHERE country_code = '{country_code}'"
    )
    # Prefix all data columns with "c_" (leave country_code untouched)
    comp_prefixed = add_prefix_to_columns(comp, prefix="c_", exclude=["country_code"])

    # Pull Markit rows for this country
    mark = athena_query(
        f"SELECT * FROM markit_raw WHERE country_code = '{country_code}'"
    )
    # Prefix all data columns with "m_"
    mark_prefixed = add_prefix_to_columns(mark, prefix="m_", exclude=["country_code"])

    # Merge the two sources on the country_code key
    merged = merge_datasets(
        left = comp_prefixed, 
        right = mark_prefixed, 
        on = ["country_code"], 
        how = "outer"
    )

    results.append(merged)
```

### 3. Concatenate All Country-Level Frames into One

```python
alltodos = concatenate_dataframes(results, axis=0)
```

### 4. Persist the Result and Export as CSV Files

```python
# Persist the result as an Athena table
create_athena_table_as_select(
    table_name = "alltodos_processed",
    database   = "finance_db",
    query      = "SELECT * FROM UNNEST(ARRAY[alltodos])"  
    # or use a CTAS: 
    # "CREATE TABLE finance_db.alltodos_processed WITH (format = 'PARQUET') AS SELECT * FROM (...)"
)

# Export as CSV files by country
for country_code in LIST_OF_COUNTRIES:
    csv_data = athena_query(
        f"SELECT * FROM alltodos_processed WHERE country_code = '{country_code}'"
    )
    export_to_csv(
        data = csv_data,
        filename = f"0_raw_data/{country_code.lower()}.csv"
    )
```

## Implementation Notes

### Required Data Sources

1. **Compustat Global**: Financial and market data for companies
   - Columns needed: gvkey, isin, datadate, prccd, cshtrd, cshoc, divdgross, exchg, conm, curcddv, fic, loc
   - Filter: European countries in the study period (2010-2019)

2. **Markit Securities Finance**: Stock lending data
   - Columns needed: isin, datadate, lendervalueonloan, lenderquantityonloan, lendablequantity, utilisation, lenderconcentration, borrowerconcentration
   - Filter: Same securities and time period as Compustat data

### Country Codes

The preprocessing should create files for each of these countries:
- `aut.csv`: Austria
- `bel.csv`: Belgium
- `che.csv`: Switzerland
- `deu.csv`: Germany
- `dnk.csv`: Denmark
- `esp.csv`: Spain
- `fin.csv`: Finland
- `fra.csv`: France
- `gbr.csv`: United Kingdom
- `irl.csv`: Ireland
- `isl.csv`: Iceland
- `ita.csv`: Italy
- `lux.csv`: Luxembourg
- `nld.csv`: Netherlands
- `nor.csv`: Norway
- `prt.csv`: Portugal
- `swe.csv`: Sweden

### Column Naming Convention

- Compustat variables should be prefixed with `c_` (e.g., `c_gvkey`, `c_isin`)
- Markit variables should be prefixed with `m_` (e.g., `m_lendervalueonloan`, `m_utilisation`)

### Merging Strategy

The two data sources are merged based on ISIN and date. Since ISINs may appear in multiple exchanges, additional cleaning steps may be required after the initial merge.

## Alternatives to Athena

While Amazon Athena is used in this example, other data processing tools can be used:

- **SQL Databases**: PostgreSQL, MySQL, SQL Server
- **Big Data Tools**: Spark, Hadoop
- **Data Analysis Tools**: Python with pandas, R with data.table

## Output Validation

After creating the country CSV files, validate them to ensure:

1. All required columns are present
2. No data type issues exist
3. The date coverage is complete (2010-2019)
4. The merging of Compustat and Markit data is correct

The validated CSV files should be placed in the `0_raw_data/` directory with the appropriate naming convention before running the transformation code.