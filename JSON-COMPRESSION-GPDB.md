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

For generating our input JSON data, we made use of the [Mockaroo](https://www.mocharoo.com) application; Mockaroo's Free plans are limited to 200 requests per day and can generate up to 1,000 rows of realistic test data per request. For our tests, we generated a total of 15K rows with the following format (check [Mockaroo Documentation](https://www.mockaroo.com/api/docs) for more information on the supported types):

###### Table 1. Test JSON data specification

| Field Name | Type |
| :---       | :--- |
| id         | _Row Number_ |
| first_name | _First Name_ |
| last_name  | _Last Name_  |
| email      | _Email Address_ |
| ip_address | _IP Address v4_ |

Each of the 15K rows generated, looked similar to:

```
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
| json\_zlib1     | Append-Optimized | Row | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 5     |
| json\_zlib1     | Append-Optimized | Row | COMPRESSTYPE =`ZLIB`, COMPRESSLEVEL = 9     |
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
		SELECT col1::text, ((col1->>'id')::int)%75 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;
  ```

### 4. Run & collect compression ratio results

To collect compression ration results for each of the tables created, we used Greenplum `get_ao_compression_ratio()`function, which is described in detail on [Greenplum Database Administration Guide](https://gpdb.docs.pivotal.io/latest/admin_guide/ddl/ddl-storage.html#topic41). The complete SQL script used to run and collect compression ratio results is available [here](https://github.com/cantzakas/gp-json/blob/master/sql/FINAL_REPORT.sql).

## Results

The final results of the experiment, are shown here:

###### Table 3. Experiment final results table

| Compression Ratio | Table              |
| ---:     | :----                       |
| 4.33 : 1 | json\_rle4\_blocksize32K    |
| 4.14 : 1 | json\_rle4\_blocksize16K    |
| 3.85 : 1 | json\_rle4\_blocksize8K     |
| 3.81 : 1 | json\_zlib1\_blocksize32K   |
| 3.72 : 1 | json\_zlib1\_blocksize16K   |
| 3.66 : 1 | json\_rle4                  |
| 3.57 : 1 | json\_rle3                  |
| 3.52 : 1 | json\_zlib1\_blocksize8K    |
| 3.48 : 1 | json\_zlib9                 |
| 3.41 : 1 | json\_zlib5                 |
| 3.2 : 1  | json\_rle2                  |
| 3.11 : 1 | json\_quicklz\_blocksize32K |
| 3.07 : 1 | json\_zlib1                 |
| 2.97 : 1 | json\_quicklz\_blocksize16K |
| 2.73 : 1 | json\_quicklz\_blocksize8K  |
| 2.61 : 1 | json\_quicklz               |
| 1 : 1    | json\_standard              |
| 1 : 1    | json\_rle1                  |

## Remarks and observations

_finalize write-up; major observation is compression rate can vary from 2x-4x, depends on JSON size (number of bytes) and appropriate setting for `BLOCKSIZE` parameter. For future, GPDB 6.x, we may be able to do even more when `JSONB` would be available (first introduced into PostgreSQL 9.4)_
