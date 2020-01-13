# Loading JSON Data in Pivotal Greenplum Database

We [previously](GETTING-STARTED-GUIDE.MD) described briefly, that for the purposes of this demo, we are using the [UK Police Data REST API](https://data.police.uk/) as our source of data. 

I call a REST API to produce my  JSON files. check https://data.police.uk/api/stops-street?poly=51.7,-0.3:51.6,-0.5:51.5,-0.5:51.4,-0.5:51.3,-0.3:51.3,0.1:51.4,0.2:51.5,0.3:51.6,0.3:51.7,0&date=2018-01' where the value of `poly` is a good enough approximation of London Metropolitan area and `date` is the date in `YYYY-MM` format
I query this REST API to produce a JSON file for each month, similar to the following:

```
DROP EXTERNAL TABLE IF EXISTS sample_data;
CREATE EXTERNAL TABLE sample_data (
    dat JSON)
LOCATION ('gpfdist://0.0.0.0:8081/met-data-*.json')
FORMAT 'TEXT';
```

I have multiple JSON files on the directory which is being served by gpfdist. Each is a perfectly valid (from format point-of-view) JSON for its own right. But using a wildcard character `*` on gpfdist protocol definition, what *gpfdist* does is to “concatenate” the beginning of each to the end of the previous, so between [ …. JSON 1 ….] & […. JSON 2 …] a line end or file end is missing. To workaround this problem, we need to apply a *transformation* on the *gpfdist* level, as following:

```
DROP EXTERNAL TABLE IF EXISTS sample_data;
CREATE EXTERNAL TABLE sample_data (
    dat JSON)
LOCATION ('gpfdist://0.0.0.0:8081/met-data-*.json#transform=file_termination')
FORMAT 'TEXT';
```

For the *gpfdist/transformation* purposes, `transform.yaml` file is defined as,

```
[gpadmin@vm-gpdb-oss ~]$ cat /home/gpadmin/load_data/transform.yaml 
---
VERSION: 1.0.0.1
TRANSFORMATIONS:
  file_termination:
    TYPE:     input
    COMMAND:  /home/gpadmin/load_data/fileterminate %filename%
``` 

while the actual transformation happens within the `fileterminate` utility, which is defined as:

```
[gpadmin@vm-gpdb-oss ~]$ cat /home/gpadmin/load_data/fileterminate 
#!/bin/bash

sed -e '$s/$/\r/' $@

[gpadmin@vm-gpdb-oss ~]$ chmod +x /home/gpadmin/load_data/fileterminate 
``` 

Finally, we can now query the `sample_data` EXTERNAL table,

```
SELECT * 
FROM sample_data
```

which returns results similar to,

```
blblablabla
```

or alternatively, load the JSON data into a new internal (vs. external) GPDB table as shown here,

```
# Create new table
CREATE TABLE json_data (dat JSON);

# Load new table from the external table defined previously
INSERT INTO json_data 
SELECT json_array_elements(dat) 
FROM sample_data;
```

### Note
Make sure, when you start your gpfdist process, to use a big enough value for `-m,` that’s like buffer size or something similar i.e.
 
```
gpfdist -d /home/gpadmin/load_data/ -p 8081 -l /home/gpadmin/gpfdist.log -m 3000000 -c /home/gpadmin/load_data/transform.yaml &
```

and also, you need to make sure you add the `-c ***.yaml` file definition on the gpfdist definition.
