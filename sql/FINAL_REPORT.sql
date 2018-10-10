SELECT * FROM (
SELECT get_ao_compression_ratio('json_standard') AS COMPRESSION_RATIO, 'json_standard' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib1') AS COMPRESSION_RATIO, 'json_zlib1' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib5') AS COMPRESSION_RATIO, 'json_zlib5' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib9') AS COMPRESSION_RATIO, 'json_zlib9' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_quicklz') AS COMPRESSION_RATIO, 'json_quicklz' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle1') AS COMPRESSION_RATIO, 'json_rle1' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle2') AS COMPRESSION_RATIO, 'json_rle2' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle3') AS COMPRESSION_RATIO, 'json_rle3' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle4') AS COMPRESSION_RATIO, 'json_rle4' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_quicklz_blocksize8K') AS COMPRESSION_RATIO, 'json_quicklz_blocksize8K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_quicklz_blocksize16K') AS COMPRESSION_RATIO, 'json_quicklz_blocksize16K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_quicklz_blocksize32K') AS COMPRESSION_RATIO, 'json_quicklz_blocksize32K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_quicklz_blocksize64K') AS COMPRESSION_RATIO, 'json_quicklz_blocksize64K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_quicklz_blocksize128K') AS COMPRESSION_RATIO, 'json_quicklz_blocksize128K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib1_blocksize8K') AS COMPRESSION_RATIO, 'json_zlib1_blocksize8K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib1_blocksize16K') AS COMPRESSION_RATIO, 'json_zlib1_blocksize16K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib1_blocksize32K') AS COMPRESSION_RATIO, 'json_zlib1_blocksize32K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib1_blocksize64K') AS COMPRESSION_RATIO, 'json_zlib1_blocksize64K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_zlib1_blocksize128K') AS COMPRESSION_RATIO, 'json_zlib1_blocksize128K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle4_blocksize8K') AS COMPRESSION_RATIO, 'json_rle4_blocksize8K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle4_blocksize16K') AS COMPRESSION_RATIO, 'json_rle4_blocksize16K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle4_blocksize32K') AS COMPRESSION_RATIO, 'json_rle4_blocksize32K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle4_blocksize64K') AS COMPRESSION_RATIO, 'json_rle4_blocksize64K' AS TABLE_NAME UNION ALL
SELECT get_ao_compression_ratio('json_rle4_blocksize128K') AS COMPRESSION_RATIO, 'json_rle4_blocksize128K' AS TABLE_NAME
) A
ORDER BY compression_ratio DESC;
