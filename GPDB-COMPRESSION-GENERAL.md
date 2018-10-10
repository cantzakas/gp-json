## Greenplum Database Tables and Compression

Greenplum Database is built for advanced Data Warehouse and Analytic workloads at scale. Both Open Source and the Commercial (Pivotal) Release of Greenplum Database provide a number of table types and compression options that the architect can employ to store data in the most efficient way possible.

While some newer database offerings only provide the column-oriented option, Greenplum Database provides both row-oriented and column-oriented table types, which means the data architect can select the table storage method that best suits the related data storage requirement. In addition, unlike other products , Greenplum Database offers multiple ways to logically partition table data, either by range or by a list of values, with the ability to create multi-level partitions of a single table to optimize data storage and query access. The flexibility and power of Greenplum Database goes one step further, where each partition of a single table can utilize its own storage method (row vs. column orientation) and compression type (`ZLIB` with various levels, column oriented `RLE`, as an example). 

Internally, information can be stored using the traditional PostgreSQL HEAP model, ideally suited for tables with ongoing changes to the data (inserts, updates, deletes)or the append-optimized table model is ideally suited for data that is loaded in large batches and is rarely, if ever, updated or deleted after the initial commit to the table. This model also offers the widest range of storage methods: row and column oriented, with a number of compression options to be applied at the row level, as well as on individual columns within a table. For the greatest flexibility in data storage, data architects can combine an append-optimized, column-oriented design with a variety of data compression methods on a per-column basis, for each column in the table definition.

## Using Compression (Append-Optimized Tables Only)

There are two types of in-database compression available in the Greenplum Database for append-optimized tables:

- Table-level compression is applied to an entire table.
- Column-level compression is applied to a specific column. You can apply different column-level compression algorithms to different columns.

The following table summarizes the available compression algorithms:

###### Table 1. Compression Algorithms for Append-Optimized Tables

| Table Orientation | Available Compression Types | Supported Algorithms |
| :---------------- | :-------------------------- | :------------------- |
| Row               | Table                       | `ZLIB` and `QUICKLZ `     |
| Column            | Column and Table            | `RLE_TYPE`, `ZLIB `, and `QUICKLZ` |

When choosing a compression type and level for append-optimized tables, consider these factors:

- **CPU usage**. Your segment systems must have the available CPU power to compress and uncompress the data.
- **Compression ratio/disk size**. Minimizing disk size is one factor, but also consider the time and CPU capacity required to compress and scan data. Find the optimal settings for efficiently compressing data without causing excessively long compression times or slow scan rates.
- **Speed of compression**. QuickLZ compression generally uses less CPU capacity and compresses data faster at a lower compression ratio than zlib. zlib provides higher compression ratios at lower speeds.   
  For example, at compression level 1 (`compresslevel=1`), `QUICKLZ` and `ZLIB` have comparable compression ratios, though at different speeds. Using `ZLIB` with `compresslevel=6` can significantly increase the compression ratio compared to QuickLZ, though with lower compression speed.
- **Speed of decompression/scan rate**. Performance with compressed append-optimized tables depends on hardware, query tuning settings, and other factors. Perform comparison testing to determine the actual performance in your environment.
  
  | **Note**: |
  | :--- |
  | Do not create compressed append-optimized tables on file systems that use compression. If the file system on which your segment data directory resides is a compressed file system, your append-optimized table must not use compression. |
  
  Performance with compressed append-optimized tables depends on hardware, query tuning settings, and other factors. You should perform comparison testing to determine the actual performance in your environment.
  
  | **Note**: |
  | :--- |
  | `QUICKLZ` compression level can only be set to level 1; no other options are available. Compression level with `ZLIB` can be set at values from 1 - 9. Compression level with `RLE` can be set at values from 1 - 4. An `ENCODING` clause specifies compression type and level for individual columns. When an `ENCODING` clause conflicts with a `WITH` clause, the `ENCODING `clause has higher precedence than the `WITH` clause. |
  
## Adding Column-level Compression

You can add the following storage directives to a column for append-optimized tables with column orientation:

- Compression type
- Compression level
- Block size for a column

Add storage directives using the `CREATE TABLE`, `ALTER TABLE`, and `CREATE TYPE` commands.

The following table details the types of storage directives and possible values for each.

###### Table 2. Storage Directives for Column-level Compression

| Name              | Definition          | Values                          | Comment                        |
| :---              | :---                | :---                            | :---                           |
| `COMPRESSTYPE`    | Type of compression | `ZLIB`: deflate algorithm       | Values are not case-sensitive. |
|                   |                     | `QUICKLZ`: fast compression     |                                |
|                   |                     | `RLE_TYPE`: run-length encoding |                                |
|                   |                     | `none`: no compression           |                                |
| `COMPRESSLEVEL `  | Compression level   | `ZLIB` compression: 1-9        | 1 is the fastest method with the least compression.<BR><BR>9 is the slowest method with the most compression.<BR><BR>1 is the default value. |
|                   |                     | `QUICKLZ` compression: <BR><BR>1 - use compression | 1 is the default value. |
|                   |                     | `RLE_TYPE` compression: 1 – 4<BR><BR>1 - apply RLE only<BR><BR>2 - apply RLE then apply zlib compression level 1<BR><BR>3 - apply RLE then apply zlib compression level 5<BR><BR>4 - apply RLE then apply zlib compression level 9 | 1 is fastest method with the least compression<BR><BR>4 is the slowest method with the most compression.<BR><BR>1 is the default value. |
| `BLOCKSIZE`      | The size in bytes for each block in the table | `8192` - `2097152` | The value must be a multiple of 8192. |

The following is the format for adding storage directives.

```
[ ENCODING ( storage_directive [,…] ) ]
```
where the word `ENCODING` is required and the storage directive has three parts:

- The name of the directive
- An equals sign
- The specification

Separate multiple storage directives with a comma. Apply a storage directive to a single column or designate it as the default for all columns, as shown in the following `CREATE TABLE` clauses.

_General Usage:_

```
column_name data_type ENCODING ( storage_directive [, … ] ), … 
```
```
COLUMN column_name ENCODING ( storage_directive [, … ] ), …
```
```
DEFAULT COLUMN ENCODING ( storage_directive [, … ] )
```

_Example:_

```
C1 char ENCODING (compresstype=quicklz, blocksize=65536)
```
```
COLUMN C1 ENCODING (compresstype=zlib, compresslevel=6, blocksize=65536)
```
```
DEFAULT COLUMN ENCODING (compresstype=quicklz)
```

## Default Compression Values
If the compression type, compression level and block size are not defined, the default is no compression, and the block size is set to the Server Configuration Parameter `block_size` (unless otherwise defined `block_size` value is set by default to 32768).

## Support for Run-length Encoding

Greenplum Database supports Run-length Encoding (RLE) for column-level compression. RLE data compression stores repeated data as a single data value and a count. For example, in a table with two columns, a date and a description, that contains 200,000 entries containing the value `date1` and 400,000 entries containing the value `date2`, RLE compression for the date field is similar to `date1 200000 date2 400000`. RLE is not useful with files that do not have large sets of repeated data as it can greatly increase the file size.

There are four levels of RLE compression available. The levels progressively increase the compression ratio, but decrease the compression speed.

Greenplum Database versions 4.2.1 and later support column-oriented RLE compression. To backup a table with RLE compression that you intend to restore to an earlier version of Greenplum Database, alter the table to have no compression or a compression type supported in the earlier version (`ZLIB` or `QUICKLZ`) before you start the backup operation.

Greenplum Database combines delta compression with RLE compression for data in columns of type `BIGINT`, `INTEGER`, `DATE`, `TIME`, or `TIMESTAMP`. The delta compression algorithm is based on the change between consecutive column values and is designed to improve compression when data is loaded in sorted order or when the compression is applied to data in sorted order.

## Checking the Compression and Distribution of an Append-Optimized Table

Greenplum provides built-in functions to check the compression ratio and the distribution of an append-optimized table. The functions take either the object ID or a table name. You can qualify the table name with a schema name.

###### Table 3. Functions for compressed append-optimized table metadata
