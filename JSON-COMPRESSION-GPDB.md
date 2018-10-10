# JSON Data Compression in Pivotal Greenplum Database

General information for Table and Data compression on Greenplum Database is available on [Greenplum Database Administration Guide](https://gpdb.docs.pivotal.io/latest/admin_guide/ddl/ddl-storage.html).

The experiment described below, focuses on checking the compression capabilities available in Pivotal Greenplum Database in relation with JSON data types.

# Experiment Definition

## Scope

- Pivotal Greenplum Database v5.11.2 Sandbox OVA
- 2GB RAM
- 2 CPU Cores
- 1x Master Segment, no Master Standby configured
- 2x Primary Segments, no Mirror Segments configured
- `gp_vmem_protect_limit`= 8192MB
- `max_statement_mem`= 200MB
- `statement_mem`= 125MB

## Goals

- Demonstrate the use of compression algorithms available at both OSS and Commercial (Pivotal) Greenplum Database versions for JSON data.
- Demonstrate the different compression ratios achieved using different compression algorithms and parameter values.
- Share the data and the process with the community, so others can replicate and run the same tests for themselves

## Anti-goals

- Collect or present any loading and querying performance statistics or metrics related to the different compression algorithms and parameter values used in this test.
 

## Targeted Outcomes

- Identify Best Practises on compressing JSON data on Greenplum Database
- Share learnings with the Greenplum Database community

## Experiment Process

### 1. Create test JSON data

For generating our input JSON data, we made use of the [Mockaroo](https://www.mocharoo.com) application; Mockaroo's Free plans are limited to 200 requests per day and can generate up to 1,000 rows of realistic test data per request. For our tests, we generated a total of 50K rows with the following format (check [Mockaroo Documentation](https://www.mockaroo.com/api/docs) for more information on the supported types):

###### Table 1. Test JSON data specification

| Field Name | Type |
| :---       | :--- |
| id         | _Row Number_ |
| first_name | _First Name_ |
| last_name  | _Last Name_  |
| email      | _Email Address_ |
| ip_address | _IP Address v4_ |

Each of the rows generated, follows a format similar to:

```json
{"id":14480, "first_name":"Starlin", "last_name":"Franseco", "email":"sfransecodb@nasa.gov", "gender":"Female", "ip_address":"103.141.21.92"}
```

The full generated dataset is available [here](https://github.com/cantzakas/gp-json/blob/master/data/MOCK_DATA.json).

### 2. Prepare data tables

Different data table were then created for each of the baseline (no compression) and the different compression algorithms and parameters used. In total, the following tables were created:

###### Table 2. Test data tables specification

| Table Name      | Storage Model | Table Orientation | Definition |
| :---            | :---          | :---              | :---       |
| json\_standard  | Append-Optimized | Row | The original/baseline, non-compressed table |
| json\_zlib1     | Append-Optimized | Row | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 1     |
| json\_zlib5     | Append-Optimized | Row | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 5     |
| json\_zlib9     | Append-Optimized | Row | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 9     |
| json\_quicklz   | Append-Optimized | Row | COMPRESSTYPE =`QUICKLZ`                     |
| json\_rle1      | Append-Optimized | Row | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 1 |
| json\_rle2      | Append-Optimized | Row | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 2 |
| json\_rle3      | Append-Optimized | Row | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 3 |
| json\_rle4      | Append-Optimized | Row | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 4 |
| json\_zlib1\_blocksize8K | Append-Optimized | Column | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 1, BLOCKSIZE = 8192 |
| json\_zlib1\_blocksize16K | Append-Optimized | Column | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 1, BLOCKSIZE = 16384 |
| json\_zlib1\_blocksize32K | Append-Optimized | Column | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 1, BLOCKSIZE = 32768 |
| json\_quicklz\_blocksize8K | Append-Optimized | Column | COMPRESSTYPE =`QUICKLZ`, BLOCKSIZE = 8192 |
| json\_quicklz\_blocksize16K | Append-Optimized | Column | COMPRESSTYPE =`QUICKLZ`, BLOCKSIZE = 16384 |
| json\_quicklz\_blocksize32K | Append-Optimized | Column | COMPRESSTYPE =`QUICKLZ`, BLOCKSIZE = 32768 |
| json\_rle4\_blocksize8K | Append-Optimized | Column | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 4, BLOCKSIZE = 8192 |
| json\_rle4\_blocksize16K | Append-Optimized | Column | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 4, BLOCKSIZE = 16384 |
| json\_rle4\_blocksize32K | Append-Optimized | Column | COMPRESSTYPE =`RLE_TYPE`, COMPRESSLEVEL = 4, BLOCKSIZE = 32768 |

Each of these tables were created with exactly one column, named `col1` which was of data type `JSON` and the data were `DISTRIBUTED RANDOMLY` across the availabel Greenplum database segments. For example, the baseline, non-compressed table definition is:

```sql
CREATE TABLE json_standard (
	col1 JSON)
WITH (appendonly = TRUE)
DISTRIBUTED RANDOMLY;
```

The complete set of SQL commands for creating the tables (DDL scripts) above is available as a single SQL script [here](https://github.com/cantzakas/gp-json/blob/master/sql/CREATE_TABLE.sql).

### 3. Load JSON data into tables

Loading the generated JSON data into the tables, was done in two steps:

- First, we used Greenplum/PostgreSQL `COPY` command to bulk load data into the baseline, **json_standard**, table, using the script available [here](https://github.com/cantzakas/gp-json/blob/master/sql/COPY_DATA.sql).
- Then, we incrementally loaded each of the remaining **json_\*** tables, using the scripts available [here](https://github.com/cantzakas/gp-json/blob/master/sql/INSERT_DATA.sql). 

  | **Note**: |
  | :--- |
  | In order to create `JSON` data type columns of variable `BLOCKSIZE`, we created arrays of JSON data; each array, was grouping together JSON rows based on the result of modulo of JSON id by {300, 150, 75}. i.e. |
  
  ```sql
  INSERT INTO json_quicklz_blocksize32K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%75 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;
  ```

### 4. Run & collect compression ratio results

To collect compression ration results for each of the tables created, we used Greenplum `get_ao_compression_ratio()`function, which is described in detail on [Greenplum Database Administration Guide](https://gpdb.docs.pivotal.io/latest/admin_guide/ddl/ddl-storage.html#topic41).

The complete SQL script used to run and collect compression ratio results is available [here](https://github.com/cantzakas/gp-json/blob/master/sql/FINAL_REPORT.sql).

## Results

The final results of the experiment, are shown here:

###### Table 3. Experiment final results table

| Compression Ratio | Table              |
| ---:              | :----              |
| 4.30 : 1 | json\_rle4\_blocksize32K    |
| 4.11 : 1 | json\_rle4\_blocksize16K    |
| 3.86 : 1 | json\_rle4\_blocksize8K     |
| 3.78 : 1 | json\_zlib1\_blocksize32K   |
| 3.69 : 1 | json\_zlib1\_blocksize16K   |
| 3.66 : 1 | json\_rle4                  |
| 3.56 : 1 | json\_rle3                  |
| 3.52 : 1 | json\_zlib1\_blocksize8K    |
| 3.48 : 1 | json\_zlib9                 |
| 3.41 : 1 | json\_zlib5                 |
| 3.20 : 1 | json\_rle2                  |
| 3.11 : 1 | json\_quicklz\_blocksize32K |
| 3.07 : 1 | json\_zlib1                 |
| 2.97 : 1 | json\_quicklz\_blocksize16K |
| 2.73 : 1 | json\_quicklz\_blocksize8K  |
| 2.62 : 1 | json\_quicklz               |
| 1.00 : 1 | json\_standard              |
| 1.00 : 1 | json\_rle1                  |

## Remarks and observations

_finalize write-up; major observation is compression rate can vary from 2x-4x, depends on JSON size (number of bytes) and appropriate setting for `BLOCKSIZE` parameter. For future, GPDB 6.x, we may be able to do even more when `JSONB` would be available (first introduced into PostgreSQL 9.4)_

- Compression ratios achieved can vary depending on the algorith used, i.e. from ~2.6x and ~3x using "standard" `QUICKLZ` and `ZLIB` algorithms up to ~4.3x using a "tuned" version of `RLE_TYPE` algorithm (COMPRESSLEVEL = 4, BLOCKSIZE = 32768) vs. the baseline table.
- For all different combinations of `COMPRESSLEVEL`&`BLOCKSIZE` values, the `RLE_TYPE` algorithm achieves better compression ratios vs. the `ZLIB` algorithm and both better compression ratios vs. the `QUICKLZ` algorithm.
- For tables in which JSON data size "matches" the defined `BLOCKSIZE` value, i.e. `BLOCKSIZE=8K, DATASIZE~=8K`, `BLOCKSIZE=16K, DATASIZE~=16K` or `BLOCKSIZE=32K, DATASIZE~=32K`, all 3 algorithms achieve better compression ratios vs. tables in which the JSON data size is significantly smaller than defined the `BLOCKSIZE` value, i.e. `BLOCKSIZE=8K, DATASIZE<1K`. Actually, the bigger the `BLOCKSIZE` defined, the better compression ratio is achieved.

  ###### Table 4. Comparison of Compression Ratios Achieved Results

  | **COMPRESS TYPE** | **BLOCKSIZE=32K<BR>DATASIZE=1K** | **BLOCKSIZE=8K<BR>DATASIZE=8K** | **BLOCKSIZE=16K<BR>DATASIZE=16K** | **BLOCKSIZE=32K<BR>DATASIZE=32K** | 
  | ---:              | ---: | ---: | ---: | ---: |
  | QUICKLZ           | 2.62 | 2.73 | 2.97 | 3.11 |
  | ZLIB 1            | 3.07 | 3.52 | 3.69 | 3.78 |
  | RLE 4             | 3.66 | 3.86 | 4.11 | 4.30 |
  
- At the time this experiment took place (October 2018), the latest version of Greenplum Database (v5.11.2) only supports the `JSON` data types of variable unlimited length with a total size of 1 byte + JSON size. This is due to the Greenplum Database which is based on PostgreSQL v8.3. 

  As of PostgreSQL 9.4 there are two available JSON data types: `JSON` and `JSONB`. They accept almost identical sets of values as input but their major practical difference is one of efficiency. The `JSON` data type stores an exact copy of the input text, which processing functions must reparse on each execution, while `JSONB` data is stored in a decomposed binary format that makes it slightly slower to input due to added conversion overhead, but significantly faster to process, since no reparsing is needed. Further experiments on compressing JSON data should be performed when the next major version (6.x) of Greenplum Database is released (Greenplum Database v6.x is expected to be based on PostgreSQL v9.4 or later).
