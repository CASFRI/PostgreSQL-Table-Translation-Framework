------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - GIS helper functions test file
-- Version 0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>,
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--
-------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';
-----------------------------------------------------------
DROP TABLE IF EXISTS photo_test;
CREATE TABLE photo_test AS
SELECT ST_GeometryFromText('MULTIPOLYGON(((0 0, 0 7, 7 7, 7 0, 0 0)))', 4268) AS the_geom, 1990::text AS YEAR, 'ninety'::text AS YEARtext, 19.90::text AS dbl
UNION ALL
SELECT ST_GeometryFromText('MULTIPOLYGON(((0 0, 0 2, 2 2, 2 0, 0 0)))', 4268), 1999::text, 'ninetynine'::text, 19.99::text
UNION ALL
SELECT ST_GeometryFromText('MULTIPOLYGON(((6 6, 6 15, 15 15, 15 6, 6 6)))', 4268), 2001::text, 'twothousandone'::text, 20.01::text;

-----------------------------------------------------------
-- Comment out the following line and the last one of the file to display
-- only failing tests
SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    -- Validation functions
    SELECT 'TT_GeoIsValid'::text function_tested, 1 maj_num, 6 nb_test UNION ALL
    SELECT 'TT_GeoIntersects'::text,              2,         7         UNION ALL
    -- Translation functions
    SELECT 'TT_GeoIntersectionText'::text,      101,         13         UNION ALL
    SELECT 'TT_GeoIntersectionDouble'::text,    102,         10         UNION ALL
    SELECT 'TT_GeoIntersectionInt'::text,       103,         10         UNION ALL
    SELECT 'TT_GeoMakeValid'::text,             104,         2          UNION ALL
    SELECT 'TT_GeoArea'::text,                  105,         1          UNION ALL
    SELECT 'TT_GeoPerimeter'::text,             106,         1
),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, nb_test, generate_series(1, nb_test)::text min_num
FROM test_nb
ORDER BY maj_num, min_num
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of tests for ' ||
                b.function_tested || ' in the initial table...') AS function_tested,
       coalesce(description, 'ERROR: Too many tests (' || nb_test || ') for ' || a.function_tested || ' in the initial table...') description,
       NOT passed IS NULL AND
          (regexp_split_to_array(number, '\.'))[1] = maj_num::text AND
          (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series AS a FULL OUTER JOIN (

---------------------------------------------------------
---------------- Validation functions -------------------
---------------------------------------------------------

---------------------------------------------------------
-- Test 1 - TT_GeoIsValid
---------------------------------------------------------
-- test all NULLs and wrong types (1 tests)
SELECT (TT_TestNullAndWrongTypeParams(1, 'TT_GeoIsValid', ARRAY['fix', 'boolean'])).*
UNION ALL
SELECT '1.2'::text number,
       'TT_GeoIsValid'::text function_tested,
       'Valid geometry'::text description,
       TT_GeoIsValid(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 10, 10 10, 0 0)'), 4268)))::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_GeoIsValid'::text function_tested,
       'Invalid geometry, fix=false'::text description,
       TT_GeoIsValid(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 1, 2 1, 2 2, 1 2, 1 0, 0 0)'), 4268)))::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_GeoIsValid'::text function_tested,
       'Invalid geometry, fix=true'::text description,
       TT_GeoIsValid(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 1, 2 1, 2 2, 1 2, 1 0, 0 0)'), 4268)))::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_GeoIsValid'::text function_tested,
       'Invalid geometry, fix default to true'::text description,
       TT_GeoIsValid(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 1, 2 1, 2 2, 1 2, 1 0, 0 0)'), 4268)))::text) passed
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'TT_GeoIsValid'::text function_tested,
       'NULL geometry, fix=false'::text description,
       TT_GeoIsValid(NULL::text) IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 2 - TT_GeoIntersects
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (3 tests)
SELECT (TT_TestNullAndWrongTypeParams(2, 'TT_GeoIntersects',
                                      ARRAY['intersectSchemaName', 'text',
                                            'intersectTableName', 'text',
                                            'geoCol', 'text'])).*
UNION ALL
SELECT '2.4'::text number,
       'TT_GeoIntersects'::text function_tested,
       'No overlap'::text description,
       TT_GeoIntersects(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(20 20, 20 21, 21 21, 21 20, 20 20)'), 4268)))::text, 'public', 'photo_test', 'the_geom') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_GeoIntersects'::text function_tested,
       'One overlap'::text description,
       TT_GeoIntersects(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(3 3, 3 5, 5 5, 5 3, 3 3)'), 4268)))::text, 'public', 'photo_test', 'the_geom') passed
---------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'TT_GeoIntersects'::text function_tested,
       'Three overlap'::text description,
       TT_GeoIntersects(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom') passed
---------------------------------------------------------
UNION ALL
SELECT '2.7'::text number,
       'TT_GeoIntersects'::text function_tested,
       'Invalid geometry'::text description,
       TT_GeoIntersects(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 1, 2 1, 2 2, 1 2, 1 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom') passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 101 - TT_GeoIntersectionText
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (5 tests)
SELECT (TT_TestNullAndWrongTypeParams(101, 'TT_GeoIntersectionText',
                                      ARRAY['intersectSchemaName', 'text',
                                            'intersectTableName', 'text',
                                            'geoCol', 'text',
                                            'returnCol', 'text',
                                            'method', 'text'])).*
UNION ALL
SELECT '101.6'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'One intersect'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(3 3, 3 5, 5 5, 5 3, 3 3)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEARtext', 'GREATEST_AREA') = 'ninety' passed
---------------------------------------------------------
UNION ALL
SELECT '101.7'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'Area test, two intersects'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 5, 5 5, 5 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEARtext', 'GREATEST_AREA') = 'ninety' passed
---------------------------------------------------------
UNION ALL
SELECT '101.8'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'Area test, three intersects'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEARtext', 'GREATEST_AREA') = 'twothousandone' passed
---------------------------------------------------------
UNION ALL
SELECT '101.9'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'lowestVal test, three intersects'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'LOWEST_VALUE') = '1990' passed
---------------------------------------------------------
UNION ALL
SELECT '101.10'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'highestVal test, three intersects'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'HIGHEST_VALUE') = '2001' passed
---------------------------------------------------------
UNION ALL
SELECT '101.11'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'No overlap error'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(25 25, 25 26, 26 26, 26 25, 25 25)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEARtext', 'GREATEST_AREA') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '101.12'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'Invalid method'::text description,
       TT_IsError('SELECT TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText(''LINESTRING(5 5, 5 6, 6 6, 6 5, 5 5)''), 4268)))::text, ''public'', ''photo_test'', ''the_geom'', ''YEARtext'', ''area2'')') = 'ERROR in TT_GeoIntersectionText(): method is not one of "GREATEST_AREA", "LOWEST_VALUE", or "HIGHEST_VALUE"' passed
---------------------------------------------------------
UNION ALL
SELECT '101.13'::text number,
       'TT_GeoIntersectionText'::text function_tested,
       'Invalid geo'::text description,
       TT_GeoIntersectionText(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 1, 2 1, 2 2, 1 2, 1 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'HIGHEST_VALUE') = '1999' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 102 - TT_GeoIntersectionDouble
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (5 tests)
SELECT (TT_TestNullAndWrongTypeParams(102, 'TT_GeoIntersectionDouble',
                                      ARRAY['intersectSchemaName', 'text',
                                            'intersectTableName', 'text',
                                            'geoCol', 'text',
                                            'returnCol', 'text',
                                            'method', 'text'])).*
UNION ALL
SELECT '102.6'::text number,
       'TT_GeoIntersectionDouble'::text function_tested,
       'One intersect'::text description,
       TT_GeoIntersectionDouble(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(3 3, 3 5, 5 5, 5 3, 3 3)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'dbl', 'GREATEST_AREA') = 19.90 passed
---------------------------------------------------------
UNION ALL
SELECT '102.7'::text number,
       'TT_GeoIntersectionDouble'::text function_tested,
       'Area test, three intersect'::text description,
       TT_GeoIntersectionDouble(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'dbl', 'GREATEST_AREA') = 20.01 passed
---------------------------------------------------------
UNION ALL
SELECT '102.8'::text number,
       'TT_GeoIntersectionDouble'::text function_tested,
       'lowestVal test, three intersect'::text description,
       TT_GeoIntersectionDouble(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'dbl', 'LOWEST_VALUE') = 19.90 passed
---------------------------------------------------------
UNION ALL
SELECT '102.9'::text number,
       'TT_GeoIntersectionDouble'::text function_tested,
       'highestVal test, three intersect'::text description,
       TT_GeoIntersectionDouble(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'dbl', 'HIGHEST_VALUE') = 20.01 passed
---------------------------------------------------------
UNION ALL
SELECT '102.10'::text number,
       'TT_GeoIntersectionDouble'::text function_tested,
       'No overlap error'::text description,
       TT_GeoIntersectionDouble(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(20 20, 20 21, 21 21, 21 20, 20 20)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'dbl', 'GREATEST_AREA') IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 103 - TT_GeoIntersectionInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (5 tests)
SELECT (TT_TestNullAndWrongTypeParams(103, 'TT_GeoIntersectionInt',
                                      ARRAY['intersectSchemaName', 'text',
                                            'intersectTableName', 'text',
                                            'geoCol', 'text',
                                            'returnCol', 'text',
                                            'method', 'text'])).*
UNION ALL
SELECT '103.6'::text number,
       'TT_GeoIntersectionInt'::text function_tested,
       'One intersect'::text description,
       TT_GeoIntersectionInt(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(3 3, 3 5, 5 5, 5 3, 3 3)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'GREATEST_AREA') = 1990 passed
---------------------------------------------------------
UNION ALL
SELECT '103.7'::text number,
       'TT_GeoIntersectionInt'::text function_tested,
       'Area test, three intersect'::text description,
       TT_GeoIntersectionInt(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'GREATEST_AREA') = 2001 passed
---------------------------------------------------------
UNION ALL
SELECT '103.8'::text number,
       'TT_GeoIntersectionInt'::text function_tested,
       'lowestVal test, three intersect'::text description,
       TT_GeoIntersectionInt(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'LOWEST_VALUE') = 1990 passed
---------------------------------------------------------
UNION ALL
SELECT '103.9'::text number,
       'TT_GeoIntersectionInt'::text function_tested,
       'highestVal test, three intersect'::text description,
       TT_GeoIntersectionInt(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 15, 15 15, 15 0, 0 0)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'HIGHEST_VALUE') = 2001 passed
---------------------------------------------------------
UNION ALL
SELECT '103.10'::text number,
       'TT_GeoIntersectionInt'::text function_tested,
       'No overlap error'::text description,
       TT_GeoIntersectionInt(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(20 20, 20 21, 21 21, 21 20, 20 20)'), 4268)))::text, 'public', 'photo_test', 'the_geom', 'YEAR', 'GREATEST_AREA') IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 104 - TT_GeoMakeValid
---------------------------------------------------------
UNION ALL
SELECT '104.1'::text number,
       'TT_GeoMakeValid'::text function_tested,
       'Good geo'::text description,
       ST_AsText(TT_GeoMakeValid(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 10, 10 10, 0 0)'), 4268)))::text)) = 'MULTIPOLYGON(((0 0,0 10,10 10,0 0)))' passed
---------------------------------------------------------
UNION ALL
SELECT '104.2'::text number,
       'TT_GeoMakeValid'::text function_tested,
       'Bad geo'::text description,
       ST_AsText(TT_GeoMakeValid(ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(0 0, 0 1, 2 1, 2 2, 1 2, 1 0, 0 0)'), 4268)))::text)) = 'MULTIPOLYGON(((0 0,0 1,1 1,1 0,0 0)),((1 1,1 2,2 2,2 1,1 1)))' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 105 - TT_GeoArea
---------------------------------------------------------
UNION ALL
SELECT '105.1'::text number,
       'TT_GeoArea'::text function_tested,
       'Area test'::text description,
       TT_GeoArea(ST_GeometryFromText('POLYGON((0 0, 0 1000, 1000 1000, 1000 0, 0 0))')) = 1::double precision passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 106 - TT_GeoPerimeter
---------------------------------------------------------
UNION ALL
SELECT '106.1'::text number,
       'TT_GeoPerimeter'::text function_tested,
       'Perimeter test'::text description,
       TT_GeoPerimeter(ST_GeometryFromText('POLYGON((0 0, 0 1000, 1000 1000, 1000 0, 0 0))')) = 4::double precision passed
---------------------------------------------------------
) AS b
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed OR passed IS NULL;
