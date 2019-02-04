------------------------------------------------------------------------------
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

-- Create some test table
DROP TABLE IF EXISTS test_sourcetable1; 							-- me - delete the table if it already exists
CREATE TABLE test_sourcetable1 AS 								-- me - create a new table, AS fills the table with the result of the following query
SELECT 'a'::text id, 1 height 									-- me - this is the same as >>SELECT 'a'::text AS id, 1 AS height<<. The AS is optional. '::' ia the cast to convert data to a given type.
UNION ALL											-- me - UNION ALL appends results of multiple queries. Does not remove duplicate rows (UNION does).
SELECT 'b'::text, 3 height
UNION ALL
SELECT 'c'::text, 5 height;

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
    SELECT 'TT_NotNull'::text function_tested, 1 maj_num,  4 nb_test UNION ALL			--      in this case two tables, test_nb and test_series
    SELECT 'TT_Between'::text,                 2,          3         UNION ALL
    SELECT 'TT_HelperFunction3'::text,         3,          0         UNION ALL
    SELECT 'TT_HelperFunction4'::text,         4,          0
),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, generate_series(1, nb_test)::text min_num 			-- me - generate_series() adds rows for with values 1:nb_test
FROM test_nb
)
SELECT coalesce(maj_num || '.' || min_num, b.number) number,					-- COALESCE returns first argument that is not null. If null, moves on to next argument.
       coalesce(a.function_tested, 'ERROR: Insufficient number of test for ' || 
                b.function_tested || ' in the initial table...') function_tested,
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
       TT_NotNull('test'::text) passed

---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_NotNull'::text function_tested,
       'Test if numeric'::text description,
       TT_NotNull(9.99) passed

---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_NotNull'::text function_tested,
       'Test if integer'::text description,
       TT_NotNull(999) passed

---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_NotNull'::text function_tested,
       'Test if null'::text description,
       TT_NotNull(NULL::text) IS FALSE passed

---------------------------------------------------------
-- Test 1 - TT_Between
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_Between'::text function_tested,
       'Basic test'::text description,
       TT_Between(50,0,100) passed

---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_Between'::text function_tested,
       'Failed test'::text description,
       TT_Between(150,0,100) IS FALSE passed

---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_Between'::text function_tested,
       'Test NULL'::text description,
       TT_Between(NULL,0,100) IS NULL passed
       
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num) -- me ON is the join condition for joining the two FROM tables together.
ORDER BY maj_num::int, min_num::int								  --    In this case joining on the 'function_tested' and 'number/min_num' columns
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

