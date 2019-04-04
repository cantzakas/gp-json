# Getting Started Guide
- [Purpose](GETTING-STARTED-GUIDE.MD#purpose)
- [Bill of Materials](GETTING-STARTED-GUIDE.MD#bill-of-materials)
  - [Software](GETTING-STARTED-GUIDE.MD#software)
  - [Data](GETTING-STARTED-GUIDE.MD#data)
- [Introduction to Pivotal Greenplum Database and JSON Data](GETTING-STARTED-GUIDE.MD#introduction-to-pivotal-greenplum-database)
  - [Pivotal Greenplum Database](GETTING-STARTED-GUIDE.MD#pivotal-greenplum-database)
  - [JSON Data Support in Pivotal Greenplum Database](GETTING-STARTED-GUIDE.MD#json-data-support-in-pivotal-greenplum-database)
  - [JSON Functions and Operators](GETTING-STARTED-GUIDE.MD#json-functions-and-operators)
- [Loading JSON Data in Pivotal Greenplum Database](https://github.com/cantzakas/gp-json/blob/master/LOADING-JSON-DATA.md).
- [Practical examples of using JSON Data in Pivotal Greenplum Database](https://github.com/cantzakas/gp-json/blob/master/JSON-EXAMPLES.md).

# Purpose

The purpose of this Getting Started Guide is to demonstrate the support and capabilities of [Pivotal](http://pivotal.io) [Greenplum Database](http://greenplum.org) for working with JSON data and datasets. 

# Bill of Materials

- [Software](GETTING-STARTED-GUIDE.MD#software)
- [Data](GETTING-STARTED-GUIDE.MD#data)

## Software

- Greenplum Database Sandbox OVA for VMWare (available to download from [Pivotal Network](https://network.pivotal.io/products/pivotal-gpdb)).

## Data

- For the purposes of this *Getting Started Guide*, we are using the [UK Police Data REST API](data.police.uk) as our source of data. 
- [data.police.uk](data.police.uk) is the site for open data about crime and policing in England, Wales and Northern Ireland. One can download street-level crime, outcome, and stop and search data in clear and simple format and explore the API containing detailed crime data and information about individual police forces and neighbourhood teams. One can also download data on police activity, and a range of data collected under the police annual data requirement (ADR) including arrests and 101 call handling.
- All the data on [data.police.uk](data.police.uk) is made available under the Open Government Licence v3.0.

# Introduction to Pivotal Greenplum Database and JSON Data
## Pivotal Greenplum Database

Read [Welcome to Pivotal Greenplum Database](http://greenplum.org) page for an introduction and more information on Greenplum Database.

## JSON Data Support in Pivotal Greenplum Database

Greenplum Database supports the `json` data type that stores JSON (JavaScript Object Notation) data.

Greenplum Database supports JSON as specified in the [RFC 7159](https://tools.ietf.org/html/rfc7159) document and enforces data validity according to the JSON rules. The following are all valid `json` expressions:

```sql
-- Simple scalar/primitive value
-- Primitive values can be numbers, quoted strings, true, false, or null
SELECT '5'::json;

-- Array of zero or more elements (elements need not be of same type)
SELECT '[1, 2, "foo", null]'::json;

-- Object containing pairs of keys and values
-- Note that object keys must always be quoted strings
SELECT '{"bar": "baz", "balance": 7.77, "active": false}'::json;

-- Arrays and objects can be nested arbitrarily
SELECT '{"foo": [true, "bar"], "tags": {"a": 1, "b": null}}'::json;
```

When Greenplum Database stores data as json data type, an exact copy of the input text is stored and the JSON processing functions reparse the data on each execution.

- Semantically-insignificant white space between tokens is retained, as well as the order of keys within JSON objects.
- All key/value pairs are kept even if a JSON object contains duplicate keys. For duplicate keys, JSON processing functions consider the last value as the operative one.

Greenplum Database allows only one character set encoding per database. It is not possible for the `json` type to conform rigidly to the JSON specification unless the database encoding is `UTF8`. Attempts to include characters that cannot be represented in the database encoding will fail. Characters that can be represented in the database encoding but not in UTF8 are allowed.

The [RFC 7159](https://tools.ietf.org/html/rfc7159) document permits JSON strings to contain Unicode escape sequences denoted by \u*XXXX*. For the `json` type, the Greenplum Database input function allows Unicode escapes regardless of the database encoding and checks Unicode escapes only for syntactic correctness (a \u followed by four hex digits).

**Note**: Many of the JSON processing functions described in [JSON Functions and Operators](GETTING-STARTED-GUIDE.MD#json-functions-and-operators) convert Unicode escapes to regular characters. The functions throw an error for characters that cannot be represented in the database encoding. You should avoid mixing Unicode escapes in JSON with a non-UTF8 database encoding, if possible.  

## JSON Functions and Operators
There are also built-in JSON-specific functions and operators available for creating, manipulating and processing `json` data:  

- [JSON Operators](GETTING-STARTED-GUIDE.MD#json-operators)
- [JSON Creation Functions](GETTING-STARTED-GUIDE.MD#json-creation-functions)
- [JSON Processing Functions](GETTING-STARTED-GUIDE.MD#json-processing-functions)

### JSON Operators

This table describes the operators that are available for use with the `json` data type.

| Operator | Right Operand Type | Description | Example | Example Result |
| :------- | :----------------- | :---------- | :------ | :------------- |
| `->`     | `int`              | Get JSON array element (indexed from zero). | `'[{"a":"foo"},{"b":"bar"},{"c":"baz"}]'::json->2` | `{"c":"baz"}` |
| `->`     | `text`             | Get JSON object field by key. | `'{"a": {"b":"foo"}}'::json->'a'` | `{"b":"foo"}` |
| `->>`    | `int`              | Get JSON array element as text. | `'[1,2,3]'::json->>2` | `3` |
| `->>`    | `text`             | Get JSON object field as text. | `'{"a":1,"b":2}'::json->>'b'` | `2` |
| `#>`     | `text[]`           | Get JSON object at specified path. | `'{"a": {"b":{"c": "foo"}}}'::json#>'{a,b}'` | `{"c": "foo"}` |
| `#>>`    | `text[]`           | Get JSON object at specified path as text.	 | `'{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}'` | `3` |

### JSON Creation Functions

This table describes the functions that create `json` values.

| Function | Description | Example | Example Result |
| :------- | :---------- | :------ | :------------- |
| `array_to_json(anyarray [, pretty_bool])` | Returns the array as a JSON array. A Greenplum Database multidimensional array becomes a JSON array of arrays. <br>Line feeds are added between dimension 1 elements if `pretty_bool` is `true`. | `array_to_json('{{1,5},{99,100}}'::int[])` | `[[1,5],[99,100]]` |
| `row_to_json(record [, pretty_bool])` | Returns the row as a JSON object.<br>Line feeds are added between level 1 elements if `pretty_bool` is `true`. | `row_to_json(row(1,'foo'))` | `{"f1":1,"f2":"foo"}` |

### JSON Processing Functions

This table describes the functions that process `json` values.

| Operator | Right Operand Type | Description | Example | Example Result |
| :------- | :----------------- | :---------- | :------ | :------------- |
| `json_each(json)` | `setof key text, value json`<br>`setof key text, value jsonb` | Expands the outermost JSON object into a set of key/value pairs. | `select * from json_each_text('{"a":"foo", "b":"bar"}')` | <pre> key \| value <br> ----+------- <br> a   \| "foo" <br> b   \| "bar" |
| `json_each_text(json)` | `setof key text, value text` | Expands the outermost JSON object into a set of key/value pairs. The returned values are of type `text`. | `select * from json_each('{"a":"foo", "b":"bar"}')` | <pre> key \| value <br> ----+------- <br> a   \| foo <br> b   \| bar |

**Note**: Many of these functions and operators convert Unicode escapes in JSON strings to regular characters. The functions throw an error for characters that cannot be represented in the database encoding.  

For `json_populate_record` and `json_populate_recordset`, type coercion from JSON is best effort and might not result in desired values for some types. JSON keys are matched to identical column names in the target row type. JSON fields that do not appear in the target row type are omitted from the output, and target columns that do not match any JSON field return `NULL`.
