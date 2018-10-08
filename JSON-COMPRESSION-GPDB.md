# JSON Data Compression in Pivotal Greenplum Database

The experiment described below, investigates the compression capabilities available in Pivotal Greenplum Database in relation with JSON data types.

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
| `COMPRESSTYPE`    | Type of compression | `ZLIB`: deflate algorithm, `QUICKLZ`: fast compression, `RLE_TYPE`: run-length encoding, `none`: no compression | Values are not case-sensitive. |
| `COMPRESSLEVEL `  | Compression level   | `ZLIB` compression: 1-9, `QUICKLZ` compression: 1 (_use compression_), `RLE_TYPE` compression: 1 – 4 (1 - _apply RLE only_, 2 - _apply RLE then apply zlib compression level 1_, 3 - _apply RLE then apply zlib compression level 5_, 4 - _apply RLE then apply zlib compression level 9_. | `ZLIB` 1 is the default and the fastest method with the least compression. 
`ZLIB` 9 is the slowest method with the most compression. `QUICKLZ` 1 is the default. `RLE_TYPE` 1 is the default and fastest method with the least compression, `RLE_TYPE` 4 is the slowest method with the most compression.|
| `BLOCKSIZE `      | The size in bytes for each block in the table | `8192` - `2097152` | The value must be a multiple of 8192. |

## Support for Run-length Encoding

...


## Checking the Compression and Distribution of an Append-Optimized Table

...

## Testing

### Preparing mock-up JSON data

[data](https://github.com/cantzakas/gp-json/tree/master/data)
- [MOCK_DATA.json](https://github.com/cantzakas/gp-json/blob/master/data/MOCK_DATA.json)

### Preparing the tables

- [CREATE_TABLE.sql](https://github.com/cantzakas/gp-json/blob/master/sql/CREATE_TABLE.sql)

### Loading JSON data into the tables

- [COPY_DATA.sql](https://github.com/cantzakas/gp-json/blob/master/sql/COPY_DATA.sql)
- [INSERT_DATA.sql](https://github.com/cantzakas/gp-json/blob/master/sql/INSERT_DATA.sql)


## Results

- [FINAL_REPORT.sql](https://github.com/cantzakas/gp-json/blob/master/sql/FINAL_REPORT.sql)

| Compression Ratio vs. json\_standard | Table |
| :---:                                | :---- |
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