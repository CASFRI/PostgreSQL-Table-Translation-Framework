﻿------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Test file
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
SET lc_messages TO 'en_US.UTF-8'; 								-- me - this sets the language of messages

-- Create some test lookup table
DROP TABLE IF EXISTS test_lookuptable1; 							-- me - delete the table if it already exists
CREATE TABLE test_lookuptable1 AS 								-- me - create a new table, AS fills the table with the result of the following query
SELECT 'ACB'::text source_val, 'Popu balb'::text target_val								-- me - this is the same as >>SELECT 'a'::text AS id, 1 AS height<<. The AS is optional. '::' ia the cast to convert data to a given type.
UNION ALL											-- me - UNION ALL appends results of multiple queries. Does not remove duplicate rows (UNION does).
SELECT '*AX'::text, 'Popu delx'::text	
UNION ALL
SELECT 'RA'::text, 'Arbu menz'::text;

-- me --
-- structure of test query:
-- WITH test_nb, test_series 
-- SELECT 
-- FROM test_series AS a OUTER_JOIN as b 
-- ON 
-- ORDER BY


-----------------------------------------------------------
-- Comment out the following line and the last one of the file to display 
-- only failing tests
--SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (										-- me - WITH creates temp tables for use in the query
    SELECT 'TT_NotNull'::text function_tested, 1 maj_num,  5 nb_test UNION ALL			--      in this case two tables, test_nb and test_series
    SELECT 'TT_Between'::text,                 2,         12         UNION ALL
    SELECT 'TT_NotEmpty'::text,                3,          8         UNION ALL
    SELECT 'TT_GreaterThan'::text,             4,          9         UNION ALL
    SELECT 'TT_LessThan'::text,                5,          9         UNION ALL
    SELECT 'TT_IsInt'::text,                   6,          8         UNION ALL
    SELECT 'TT_IsNumeric'::text,               7,          8         UNION ALL
    SELECT 'TT_MatchStr1'::text,               8,          7         UNION ALL
    SELECT 'TT_MatchStr2'::text,               9,          1         UNION ALL   
    SELECT 'TT_Concat'::text,                 10,          5         UNION ALL
    SELECT 'TT_Copy'::text,                   11,          5         
),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, generate_series(1, nb_test)::text min_num 			-- me - generate_series() adds rows for with values 1:nb_test
FROM test_nb
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,					-- COALESCE returns first argument that is not null. If null, moves on to next argument.
       coalesce(a.function_tested, 'ERROR: Insufficient number of test for ' || 
                b.function_tested || ' in the initial table...') AS function_tested,
       description, 
       NOT passed IS NULL AND (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed -- me - returns true if 'passed' not null, numbers match, and passed is true
FROM test_series AS a FULL OUTER JOIN (								-- me - this combines the test_series tables with the result of the outer join

---------------------------------------------------------
-- Test 1 - TT_NotNull
---------------------------------------------------------
---------------------------------------------------------

SELECT '1.1'::text number,
       'TT_NotNull'::text function_tested,
       'Test if text'::text description,
       TT_NotNull('test'::text) IS TRUE passed

---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_NotNull'::text function_tested,
       'Test if numeric'::text description,
       TT_NotNull(9.99) IS TRUE passed

---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_NotNull'::text function_tested,
       'Test if integer'::text description,
       TT_NotNull(999) IS TRUE passed

---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_NotNull'::text function_tested,
       'Test if null'::text description,
       TT_NotNull(NULL::text) IS FALSE passed
       
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_NotNull'::text function_tested,
       'Test if empty string'::text description,
       TT_NotNull(''::text) IS TRUE passed

---------------------------------------------------------
-- Test 2 - TT_Between
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_Between'::text function_tested,
       'Integer, good value'::text description,
       TT_Between(50::int,0,100) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_Between'::text function_tested,
       'Integer, failed higher'::text description,
       TT_Between(150::int,0,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_Between'::text function_tested,
       'Integer, failed lower'::text description,
       TT_Between(5::int,10,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL var'::text description,
       TT_Between(NULL::int,0,100) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_Between'::text function_tested,
       'Integer NULL min'::text description,
       TT_Between(10::int,NULL,100) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL max'::text description,
       TT_Between(10::int,1,NULL) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.7'::text number,
       'TT_Between'::text function_tested,
       'double precision, good value'::text description,
       TT_Between(50::double precision,0,100) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '2.8'::text number,
       'TT_Between'::text function_tested,
       'double precision, failed higher'::text description,
       TT_Between(150::double precision,0,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.9'::text number,
       'TT_Between'::text function_tested,
       'double precision, failed lower'::text description,
       TT_Between(5::double precision,10,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.10'::text number,
       'TT_Between'::text function_tested,
       'double precision, NULL var'::text description,
       TT_Between(NULL::double precision,0,100) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.11'::text number,
       'TT_Between'::text function_tested,
       'double precision NULL min'::text description,
       TT_Between(10::double precision,NULL,100) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.12'::text number,
       'TT_Between'::text function_tested,
       'double precision, NULL max'::text description,
       TT_Between(10::double precision,1,NULL) IS NULL passed
---------------------------------------------------------
-- Test 3 - TT_NotEmpty
-- Should test for empty strings with spaces (e.g.'   ')
-- Should work with both char(n) and text(). In outdated char(n) type, '' is considered same as '  '. Not so for other types.
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty text()'::text description,
       TT_NotEmpty(''::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_NotEmpty'::text function_tested,
       'Not empty text()'::text description,
       TT_NotEmpty('test test'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty spaces text()'::text description,
       TT_NotEmpty('  '::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_NotEmpty'::text function_tested,
       'NULL text()'::text description,
       TT_NotEmpty(NULL::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty char()'::text description,
       TT_NotEmpty(''::char(3)) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_NotEmpty'::text function_tested,
       'Not empty char()'::text description,
       TT_NotEmpty('test test'::char(10)) IS TRUE passed       
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty spaces char()'::text description,
       TT_NotEmpty('   '::char(3)) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_NotEmpty'::text function_tested,
       'NULL char()'::text description,
       TT_NotEmpty(NULL::char(3)) IS NULL passed       

---------------------------------------------------------
-- Test 4 - TT_GreaterThan
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_GreaterThan'::text function_tested,
       'Integer, good value'::text description,
       TT_GreaterThan(11::int, 10, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_GreaterThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_GreaterThan(9::int, 10::double precision, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_GreaterThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_GreaterThan(10.3::double precision, 10.2, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_GreaterThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_GreaterThan(10.1::double precision, 10.0, TRUE) IS TRUE passed
---------------------------------------------------------       
UNION ALL
SELECT '4.5'::text number,
       'TT_GreaterThan'::text function_tested,
       'Default applied'::text description,
       TT_GreaterThan(10.1::double precision, 10.1) IS TRUE passed       
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_GreaterThan'::text function_tested,
       'Inclusive false'::text description,
       TT_GreaterThan(10::int, 10.0, FALSE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL int'::text description,
       TT_GreaterThan(NULL::int, 10.1, TRUE) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL double precision'::text description,
       TT_GreaterThan(NULL::double precision, 10.1, TRUE) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '4.9'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL lowerBound'::text description,
       TT_GreaterThan(10::int, NULL, TRUE) IS NULL passed

---------------------------------------------------------
-- Test 5 - TT_LessThan
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_LessThan'::text function_tested,
       'Integer, good value'::text description,
       TT_LessThan(9::int, 10, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_LessThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_LessThan(11::int, 10, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'TT_LessThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_LessThan(10.1::double precision, 10.1, TRUE) passed
---------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'TT_LessThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_LessThan(9.9::double precision, 10.1, TRUE) passed
---------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'TT_LessThan'::text function_tested,
       'Default applied'::text description,
       TT_LessThan(10.1::double precision, 10.1) passed       
---------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'TT_LessThan'::text function_tested,
       'Inclusive false'::text description,
       TT_LessThan(10.1::double precision, 10.1, FALSE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'TT_LessThan'::text function_tested,
       'NULL double precision'::text description,
       TT_LessThan(NULL::double precision, 10.1, TRUE) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '5.8'::text number,
       'TT_LessThan'::text function_tested,
       'NULL integer'::text description,
       TT_LessThan(NULL::int, 10.1, TRUE) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '5.9'::text number,
       'TT_LessThan'::text function_tested,
       'NULL upperBound'::text description,
       TT_LessThan(10.1::double precision, NULL::double precision, TRUE) IS NULL passed
---------------------------------------------------------
-- Test 6 - TT_IsInt
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_IsInt'::text function_tested,
       'Small int'::text description,
       TT_IsInt(1::smallint) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_IsInt'::text function_tested,
       'Integer'::text description,
       TT_IsInt(1::integer) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_IsInt'::text function_tested,
       'Big int'::text description,
       TT_IsInt(1::bigint) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.4'::text number,
       'TT_IsInt'::text function_tested,
       'Decimal'::text description,
       TT_IsInt(1.1::decimal) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.5'::text number,
       'TT_IsInt'::text function_tested,
       'numeric'::text description,
       TT_IsInt(1.1::numeric) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.6'::text number,
       'TT_IsInt'::text function_tested,
       'real'::text description,
       TT_IsInt(1.1::real) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.7'::text number,
       'TT_IsInt'::text function_tested,
       'Decimal'::text description,
       TT_IsInt(1::decimal) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.8'::text number,
       'TT_IsInt'::text function_tested,
       'NULL'::text description,
       TT_IsInt(NULL::integer) IS NULL passed

---------------------------------------------------------
-- Test 7 - TT_IsNumeric
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_IsNumeric'::text function_tested,
       'Small Int'::text description,
       TT_IsNumeric(1::smallint) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_IsNumeric'::text function_tested,
       'Int'::text description,
       TT_IsNumeric(1::integer) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.3'::text number,
       'TT_IsNumeric'::text function_tested,
       'Big Int'::text description,
       TT_IsNumeric(1::bigint) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.4'::text number,
       'TT_IsNumeric'::text function_tested,
       'decimal'::text description,
       TT_IsNumeric(1.1::decimal) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.5'::text number,
       'TT_IsNumeric'::text function_tested,
       'numeric'::text description,
       TT_IsNumeric(1.1::numeric) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.6'::text number,
       'TT_IsNumeric'::text function_tested,
       'real'::text description,
       TT_IsNumeric(1.1::real) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.7'::text number,
       'TT_IsNumeric'::text function_tested,
       'double precision'::text description,
       TT_IsNumeric(1.1::double precision) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.8'::text number,
       'TT_IsNumeric'::text function_tested,
       'NULL'::text description,
       TT_IsNumeric(NULL::double precision) IS NULL passed
---------------------------------------------------------
-- Test 8 - TT_MatchStr (array variant)
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - string in array'::text description,
       TT_MatchStr('1', ARRAY['1','2','3']) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - string not in array'::text description,
       TT_MatchStr('4', ARRAY['1','2','3']) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.3'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - string null'::text description,
       TT_MatchStr(NULL, ARRAY['1','2','3']) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.4'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - array contains null'::text description,
       TT_MatchStr('1', ARRAY[NULL,'2','3']) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.5'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - string empty'::text description,
       TT_MatchStr('', ARRAY['1','2','3']) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.6'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - string empty matches'::text description,
       TT_MatchStr('', ARRAY['1','','3']) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.7'::text number,
       'TT_MatchStr1'::text function_tested,
       'Array - array contains empty string'::text description,
       TT_MatchStr('1', ARRAY['1','2','']) IS TRUE passed
---------------------------------------------------------
-- Test 9 - TT_MatchStr (lookup table variant)
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_MatchStr2'::text function_tested,
       'Simple test'::text description,
       TT_MatchStr('RA', 'source_val', 'public', 'test_lookuptable1') Is TRUE passed
---------------------------------------------------------
-- Test 10- TT_Concat
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage with sep'::text description,
       TT_Concat('-', 'cas', 'id', 'test') = 'cas-id-test' passed
---------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage without sep'::text description,
       TT_Concat('', 'cas', 'id', 'test') = 'casidtest' passed
---------------------------------------------------------
UNION ALL
SELECT '10.3'::text number,
       'TT_Concat'::text function_tested,
       'Null sep'::text description,
       TT_Concat(NULL, 'cas', 'id', 'test') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_Concat'::text function_tested,
       'Null string'::text description,
       TT_Concat('-', NULL, 'id', 'test') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '10.5'::text number,
       'TT_Concat'::text function_tested,
       'Empty string'::text description,
       TT_Concat('-', 'cas', '', 'test') = 'cas--test' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 11 - TT_Copy
---------------------------------------------------------
UNION ALL
SELECT '11.1'::text number,
       'TT_Copy'::text function_tested,
       'Text usage'::text description,
       TT_Copy('copytest'::text) = 'copytest'::text passed
---------------------------------------------------------
UNION ALL
SELECT '11.2'::text number,
       'TT_Copy'::text function_tested,
       'Int usage'::text description,
       TT_Copy(111::int) = 111::int passed
---------------------------------------------------------
UNION ALL
SELECT '11.3'::text number,
       'TT_Copy'::text function_tested,
       'Double precision usage'::text description,
       TT_Copy(111.4::double precision) = 111.4::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '11.4'::text number,
       'TT_Copy'::text function_tested,
       'Empty string usage'::text description,
       TT_Copy(''::text) = ''::text passed
---------------------------------------------------------
UNION ALL
SELECT '11.5'::text number,
       'TT_Copy'::text function_tested,
       'Null'::text description,
       TT_Copy(NULL::text) IS NULL passed
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num) -- me ON is the join condition for joining the two FROM tables together.
ORDER BY maj_num::int, min_num::int								  --    In this case joining on the 'function_tested' and 'number/min_num' columns
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

