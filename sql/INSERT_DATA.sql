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
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%1000 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_quicklz_blocksize16K;
INSERT INTO json_quicklz_blocksize16K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%500 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_quicklz_blocksize32K;
INSERT INTO json_quicklz_blocksize32K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%250 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_quicklz_blocksize64K;
INSERT INTO json_quicklz_blocksize64K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%125 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_quicklz_blocksize128K;
INSERT INTO json_quicklz_blocksize128K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%65 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_zlib1_blocksize8K;
INSERT INTO json_zlib1_blocksize8K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%1000 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_zlib1_blocksize16K;
INSERT INTO json_zlib1_blocksize16K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%500 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_zlib1_blocksize32K;
INSERT INTO json_zlib1_blocksize32K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%250 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_zlib1_blocksize64K;
INSERT INTO json_zlib1_blocksize64K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%125 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_zlib1_blocksize128K;
INSERT INTO json_zlib1_blocksize128K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%65 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_rle4_blocksize8K;
INSERT INTO json_rle4_blocksize8K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%1000 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_rle4_blocksize16K;
INSERT INTO json_rle4_blocksize16K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%500 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_rle4_blocksize32K;
INSERT INTO json_rle4_blocksize32K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%250 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_rle4_blocksize64K;
INSERT INTO json_rle4_blocksize64K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%125 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;

DELETE FROM json_rle4_blocksize128K;
INSERT INTO json_rle4_blocksize128K
	SELECT array_to_json(array_agg(col1))
	FROM (
		SELECT col1::text, ((col1->>'id')::int)%65 AS modulo_result
		FROM json_standard
	) A
	GROUP BY modulo_result;
