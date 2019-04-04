# Practical examples of using JSON Data in Pivotal Greenplum Database

As soon as you have put all these together, you can do cool queries like

```
SELECT * 
FROM json_data 
WHERE dat#>>'{location, street, id}' = '963841'
```

or

```
SELECT dat#>>'{self_defined_ethnicity}' AS involved_ethnicity, 
	dat#>>'{officer_defined_ethnicity}' AS officer_ethnicity, 
	dat#>>'{age_range}' AS age_range, 
	EXTRACT(YEAR FROM REPLACE(dat#>>'{datetime}', 'T', ' ')::TIMESTAMP)::SMALLINT AS DT_YEAR, 
	count(*) 
FROM metdatajsonb
GROUP BY 1, 2, 3, 4;
```

### Note
Not 100% sure whether the `#>>` notation is fully supported in GPDB 5.x yet. 
It certainly is there on 6.x. You can do it with different syntax on 5.x (probably) but it looks ugly