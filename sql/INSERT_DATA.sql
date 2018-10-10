DELETE FROM json_zlib1;
INSERT INTO json_zlib1
	SELECT * FROM json_standard;
	
DELETE FROM json_zlib5;
INSERT INTO json_zlib5
	SELECT * FROM json_standard;
  
DELETE FROM json_zlib9;
INSERT INTO json_zlib9
	SELECT * FROM json_standard;
  
DELETE FROM json_quicklz;
INSERT INTO json_quicklz
	SELECT * FROM json_standard;
  
DELETE FROM json_rle1;
INSERT INTO json_rle1
	SELECT * FROM json_standard;
  
DELETE FROM json_rle2;
INSERT INTO json_rle2
	SELECT * FROM json_standard;
  
DELETE FROM json_rle3;
INSERT INTO json_rle3
	SELECT * FROM json_standard;
  
DELETE FROM json_rle4;
INSERT INTO json_rle4
	SELECT * FROM json_standard;

DELETE FROM json_quicklz_blocksize8K;
INSERT INTO json_quicklz_blocksize8K
	SELECT array_to_json(array_agg(col1)) # produces rows of size 7,855 - 8,100 bytes
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%300 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_quicklz_blocksize16K;
INSERT INTO json_quicklz_blocksize16K
	SELECT array_to_json(array_agg(col1))  # produces rows of size 15,808 - 16,065 bytes
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%150 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_quicklz_blocksize32K;
INSERT INTO json_quicklz_blocksize32K
	SELECT array_to_json(array_agg(col1)) # produces rows of size 31,692 - 32,037 bytes
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%75 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_zlib1_blocksize8K;
INSERT INTO json_zlib1_blocksize8K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%300 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_zlib1_blocksize16K;
INSERT INTO json_zlib1_blocksize16K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%150 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_zlib1_blocksize32K;
INSERT INTO json_zlib1_blocksize32K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%75 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_rle4_blocksize8K;
INSERT INTO json_rle4_blocksize8K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%300 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_rle4_blocksize16K;
INSERT INTO json_rle4_blocksize16K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%150 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;

DELETE FROM json_rle4_blocksize32K;
INSERT INTO json_rle4_blocksize32K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%75 AS modulo150_result
		FROM json_standard
	) A
	GROUP BY modulo150_result;
