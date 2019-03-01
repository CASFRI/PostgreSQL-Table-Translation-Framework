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
SET lc_messages TO 'en_US.UTF-8';

-- Create some test lookup table
DROP TABLE IF EXISTS test_lookuptable1;
CREATE TABLE test_lookuptable1 AS
SELECT 'ACB'::text source_val, 'Popu balb'::text target_val
UNION ALL
SELECT '*AX'::text, 'Popu delx'::text	
UNION ALL
SELECT 'RA'::text, 'Arbu menz'::text;

DROP TABLE IF EXISTS test_lookuptable2;
CREATE TABLE test_lookuptable2 AS
SELECT 1::int intCol, 1.1::double precision dblCol
UNION ALL
SELECT 2::int, 1.2::double precision	
UNION ALL
SELECT 3::int, 1.3::double precision;

DROP TABLE IF EXISTS test_lookuptable3;
CREATE TABLE test_lookuptable3 AS
SELECT 1.1::double precision dblCol, 1::int intCol
UNION ALL
SELECT 1.2::double precision, 2::int	
UNION ALL
SELECT 1.3::double precision, 3::int;

-- IsError(text)
-- function to test if helper functions return errors
CREATE OR REPLACE FUNCTION IsError(
  functionString text
)
RETURNS boolean AS $$
  DECLARE
    result boolean;
  BEGIN
    EXECUTE functionString INTO result;
    RETURN FALSE;
  EXCEPTION WHEN OTHERS THEN
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-----------------------------------------------------------
-- Comment out the following line and the last one of the file to display 
-- only failing tests
--SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    SELECT 'TT_NotNull'::text function_tested, 1 maj_num,  9 nb_test UNION ALL
    SELECT 'TT_NotEmpty'::text,                2,          8         UNION ALL
    SELECT 'TT_IsInt'::text,                   3,         13         UNION ALL
    SELECT 'TT_IsNumeric'::text,               4,         13         UNION ALL
    SELECT 'TT_Between'::text,                 5,         12         UNION ALL
    SELECT 'TT_GreaterThan'::text,             6,         10         UNION ALL
    SELECT 'TT_LessThan'::text,                7,         10         UNION ALL
    SELECT 'TT_Match1'::text,                  8,         17         UNION ALL
    SELECT 'TT_Match2'::text,                  9,         15         UNION ALL   
    SELECT 'TT_Concat'::text,                 10,          5         UNION ALL
    SELECT 'TT_Copy'::text,                   11,          5         UNION ALL
    SELECT 'TT_Lookup'::text,                 12,         15         UNION ALL
    SELECT 'TT_False'::text,                  13,          1         UNION ALL
    SELECT 'TT_IsString'::text,               14,          7         



),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, generate_series(1, nb_test)::text min_num
FROM test_nb
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of test for ' || 
                b.function_tested || ' in the initial table...') AS function_tested,
       description, 
       NOT passed IS NULL AND (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series AS a FULL OUTER JOIN (

---------------------------------------------------------
---------------------------------------------------------
-- Test 1 - TT_NotNull
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_NotNull'::text function_tested,
       'Test if text'::text description,
       TT_NotNull('test'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_NotNull'::text function_tested,
       'Test if boolean'::text description,
       TT_NotNull(true::boolean) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_NotNull'::text function_tested,
       'Test if double precision'::text description,
       TT_NotNull(9.99::double precision) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_NotNull'::text function_tested,
       'Test if integer'::text description,
       TT_NotNull(999::int) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_NotNull'::text function_tested,
       'Test if null text'::text description,
       TT_NotNull(NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'TT_NotNull'::text function_tested,
       'Test if null boolean'::text description,
       TT_NotNull(NULL::boolean) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'TT_NotNull'::text function_tested,
       'Test if null double precision'::text description,
       TT_NotNull(NULL::double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'TT_NotNull'::text function_tested,
       'Test if null int'::text description,
       TT_NotNull(NULL::int) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'TT_NotNull'::text function_tested,
       'Test if empty string'::text description,
       TT_NotNull(''::text) IS TRUE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 2 - TT_NotEmpty
-- Should test for empty strings with spaces (e.g.'   ')
-- Should work with both char(n) and text(). In outdated char(n) type, '' is considered same as '  '. Not so for other types.
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty text string'::text description,
       TT_NotEmpty(''::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_NotEmpty'::text function_tested,
       'Not empty text string'::text description,
       TT_NotEmpty('test test'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty text string with spaces'::text description,
       TT_NotEmpty('  '::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_NotEmpty'::text function_tested,
       'NULL text'::text description,
       TT_NotEmpty(NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty char string'::text description,
       TT_NotEmpty(''::char(3)) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'TT_NotEmpty'::text function_tested,
       'Not empty char string'::text description,
       TT_NotEmpty('test test'::char(10)) IS TRUE passed       
---------------------------------------------------------
UNION ALL
SELECT '2.7'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty char string with spaces'::text description,
       TT_NotEmpty('   '::char(3)) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.8'::text number,
       'TT_NotEmpty'::text function_tested,
       'NULL char'::text description,
       TT_NotEmpty(NULL::char(3)) IS FALSE passed       
---------------------------------------------------------
---------------------------------------------------------
-- Test 3 - TT_IsInt
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_IsInt'::text function_tested,
       'Integer'::text description,
       TT_IsInt(1::int) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_IsInt'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsInt(1.0::double precision) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_IsInt'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsInt(1.1::double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_IsInt'::text function_tested,
       'Text, good value'::text description,
       TT_IsInt('1'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_IsInt'::text function_tested,
       'Text, decimal good value'::text description,
       TT_IsInt('1.0'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_IsInt'::text function_tested,
       'Text, decimal bad value'::text description,
       TT_IsInt('1.1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with letters'::text description,
       TT_IsInt('1D'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with invalid decimal'::text description,
       TT_IsInt('1.0.0'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with leading decimal'::text description,
       TT_IsInt('.5'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.10'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with trailing decimal'::text description,
       TT_IsInt('1.'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '3.11'::text number,
       'TT_IsInt'::text function_tested,
       'NULL integer'::text description,
       TT_IsInt(NULL::integer) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.12'::text number,
       'TT_IsInt'::text function_tested,
       'NULL double precision'::text description,
       TT_IsInt(NULL::double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.13'::text number,
       'TT_IsInt'::text function_tested,
       'NULL text'::text description,
       TT_IsInt(NULL::text) IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 4 - TT_IsNumeric
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_IsNumeric'::text function_tested,
       'Small Int'::text description,
       TT_IsNumeric(1::smallint) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_IsNumeric'::text function_tested,
       'Int'::text description,
       TT_IsNumeric(1::integer) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_IsNumeric'::text function_tested,
       'Big Int'::text description,
       TT_IsNumeric(1::bigint) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_IsNumeric'::text function_tested,
       'decimal'::text description,
       TT_IsNumeric(1.1::decimal) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'TT_IsNumeric'::text function_tested,
       'numeric'::text description,
       TT_IsNumeric(1.1::numeric) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_IsNumeric'::text function_tested,
       'real'::text description,
       TT_IsNumeric(1.1::real) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_IsNumeric'::text function_tested,
       'double precision'::text description,
       TT_IsNumeric(1.1::double precision) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'TT_IsNumeric'::text function_tested,
       'text, good value'::text description,
       TT_IsNumeric('1.1'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.9'::text number,
       'TT_IsNumeric'::text function_tested,
       'text, leading decimal'::text description,
       TT_IsNumeric('.1'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.10'::text number,
       'TT_IsNumeric'::text function_tested,
       'text, trailing decimal'::text description,
       TT_IsNumeric('1.'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.11'::text number,
       'TT_IsNumeric'::text function_tested,
       'text, invalid decimals'::text description,
       TT_IsNumeric('1.1.1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.12'::text number,
       'TT_IsNumeric'::text function_tested,
       'text, with letter'::text description,
       TT_IsNumeric('1F'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.13'::text number,
       'TT_IsNumeric'::text function_tested,
       'NULL'::text description,
       TT_IsNumeric(NULL::double precision) IS FALSE passed
---------------------------------------------------------
-- Test 5 - TT_Between
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_Between'::text function_tested,
       'Integer, good value'::text description,
       TT_Between(50::int,0,100) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_Between'::text function_tested,
       'Integer, failed higher'::text description,
       TT_Between(150::int,0,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'TT_Between'::text function_tested,
       'Integer, failed lower'::text description,
       TT_Between(5::int,10,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL val'::text description,
       TT_Between(NULL::int,0,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL min'::text description,
       IsError('SELECT TT_Between(10::int,NULL,100);'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL max'::text description,
       IsError('SELECT TT_Between(10::int,0,NULL);'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'TT_Between'::text function_tested,
       'double precision, good value'::text description,
       TT_Between(50::double precision,0,100) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.8'::text number,
       'TT_Between'::text function_tested,
       'double precision, failed higher'::text description,
       TT_Between(150::double precision,0,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.9'::text number,
       'TT_Between'::text function_tested,
       'double precision, failed lower'::text description,
       TT_Between(5::double precision,10,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.10'::text number,
       'TT_Between'::text function_tested,
       'double precision, NULL val'::text description,
       TT_Between(NULL::double precision,0,100) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.11'::text number,
       'TT_Between'::text function_tested,
       'double precision, NULL min'::text description,
       IsError('SELECT TT_Between(10::double precision,NULL,100);'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.12'::text number,
       'TT_Between'::text function_tested,
       'double precision, NULL max'::text description,
       IsError('SELECT TT_Between(10::double precision,0,NULL);'::text) IS TRUE passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 6 - TT_GreaterThan
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_GreaterThan'::text function_tested,
       'Integer, good value'::text description,
       TT_GreaterThan(11::int, 10, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_GreaterThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_GreaterThan(9::int, 10::double precision, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_GreaterThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_GreaterThan(10.3::double precision, 10.2, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.4'::text number,
       'TT_GreaterThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_GreaterThan(10.1::double precision, 10.0, TRUE) IS TRUE passed
---------------------------------------------------------       
UNION ALL
SELECT '6.5'::text number,
       'TT_GreaterThan'::text function_tested,
       'Default applied'::text description,
       TT_GreaterThan(10.1::double precision, 10.1) IS TRUE passed       
---------------------------------------------------------
UNION ALL
SELECT '6.6'::text number,
       'TT_GreaterThan'::text function_tested,
       'Inclusive false'::text description,
       TT_GreaterThan(10::int, 10.0, FALSE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.7'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL int'::text description,
       TT_GreaterThan(NULL::int, 10.1, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.8'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL double precision'::text description,
       TT_GreaterThan(NULL::double precision, 10.1, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.9'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL lowerBound'::text description,
       IsError('SELECT TT_GreaterThan(10::int, NULL, TRUE);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.10'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL inclusive'::text description,
       IsError('SELECT TT_GreaterThan(10::int, 8, NULL);') IS TRUE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 7 - TT_LessThan
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_LessThan'::text function_tested,
       'Integer, good value'::text description,
       TT_LessThan(9::int, 10, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_LessThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_LessThan(11::int, 10, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.3'::text number,
       'TT_LessThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_LessThan(10.1::double precision, 10.7, TRUE) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.4'::text number,
       'TT_LessThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_LessThan(9.9::double precision, 9.5, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.5'::text number,
       'TT_LessThan'::text function_tested,
       'Default applied'::text description,
       TT_LessThan(10.1::double precision, 10.1) IS TRUE passed       
---------------------------------------------------------
UNION ALL
SELECT '7.6'::text number,
       'TT_LessThan'::text function_tested,
       'Inclusive false'::text description,
       TT_LessThan(10.1::double precision, 10.1, FALSE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.7'::text number,
       'TT_LessThan'::text function_tested,
       'NULL double precision'::text description,
       TT_LessThan(NULL::double precision, 10.1, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.8'::text number,
       'TT_LessThan'::text function_tested,
       'NULL integer'::text description,
       TT_LessThan(NULL::int, 10.1, TRUE) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.9'::text number,
       'TT_LessThan'::text function_tested,
       'NULL upperBound'::text description,
       IsError('SELECT TT_LessThan(10::int, NULL, TRUE);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.10'::text number,
       'TT_LessThan'::text function_tested,
       'NULL inclusive'::text description,
       IsError('SELECT TT_LessThan(10::int, 8, NULL);') IS TRUE passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 8 - TT_Match (array variant)
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_Match1'::text function_tested,
       'String good value'::text description,
       TT_Match('1'::text,'1'::text,'2'::text,'3'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_Match1'::text function_tested,
       'String bad value'::text description,
       TT_Match('1'::text,'4'::text,'2'::text,'3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.3'::text number,
       'TT_Match1'::text function_tested,
       'String Null val'::text description,
       TT_Match(NULL::text, '1'::text,'2'::text,'3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.4'::text number,
       'TT_Match1'::text function_tested,
       'String Null in list, good value'::text description,
       TT_Match('1'::text, NULL::text,'1'::text,'3'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.5'::text number,
       'TT_Match1'::text function_tested,
       'String Null in list, bad value'::text description,
       TT_Match('1'::text, NULL::text,'2'::text,'3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.6'::text number,
       'TT_Match1'::text function_tested,
       'String, empty string in list, good value'::text description,
       TT_Match('1'::text, ''::text,'1'::text,'3'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.7'::text number,
       'TT_Match1'::text function_tested,
       'String, val is empty string'::text description,
       TT_Match(''::text, ''::text,'1'::text,'3'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.8'::text number,
       'TT_Match1'::text function_tested,
       'Double precision good value'::text description,
       TT_Match(1.5::Double precision,1.5::Double precision,1.6::Double precision,1.7::Double precision) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.9'::text number,
       'TT_Match1'::text function_tested,
       'Double precision bad value'::text description,
       TT_Match(1.2::Double precision,1.5::Double precision,1.6::Double precision,1.7::Double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.10'::text number,
       'TT_Match1'::text function_tested,
       'Double precision NULL val'::text description,
       TT_Match(NULL::Double precision,1.5::Double precision,1.6::Double precision,1.7::Double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.11'::text number,
       'TT_Match1'::text function_tested,
       'Double precision Null in list, good value'::text description,
       TT_Match(1.5::Double precision,1.5::Double precision,NULL::Double precision,1.7::Double precision) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.12'::text number,
       'TT_Match1'::text function_tested,
       'Double precision Null in list, bad value'::text description,
       TT_Match(1.3::Double precision,1.5::Double precision,NULL::Double precision,1.7::Double precision) IS FALSE passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '8.13'::text number,
       'TT_Match1'::text function_tested,
       'Integer good value'::text description,
       TT_Match(2::integer,2::integer,3::integer,4::integer) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.14'::text number,
       'TT_Match1'::text function_tested,
       'Integer bad value'::text description,
       TT_Match(1::integer,2::integer,3::integer,4::integer) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.15'::text number,
       'TT_Match1'::text function_tested,
       'Integer Null val'::text description,
       TT_Match(NULL::integer,2::integer,3::integer,4::integer) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.16'::text number,
       'TT_Match1'::text function_tested,
       'Integer Null in list, good value'::text description,
       TT_Match(1::integer,NULL::integer,3::integer,4::integer,1::integer) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.17'::text number,
       'TT_Match1'::text function_tested,
       'Integer Null in list, bad value'::text description,
       TT_Match(12::integer,NULL::integer,3::integer,4::integer,1::integer) IS FALSE passed
------------------------------------------------------------------------------------------------------------------
-- Test 9 - TT_Match (lookup table variant)
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_Match2'::text function_tested,
       'Simple test text, pass'::text description,
       TT_Match('RA'::text, 'public'::name, 'test_lookuptable1'::name) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_Match2'::text function_tested,
       'Simple test text, fail'::text description,
       TT_Match('RAA'::text, 'public'::name, 'test_lookuptable1'::name) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_Match2'::text function_tested,
       'val NULL text'::text description,
       TT_Match(NULL::text, 'public'::name, 'test_lookuptable1'::name) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_Match2'::text function_tested,
       'schema NULL fail, text'::text description,
       IsError('SELECT TT_Match(RA::text, NULL::name, test_lookuptable1::name);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_Match2'::text function_tested,
       'table NULL fail, text'::text description,
       IsError('SELECT TT_Match(RA::text, public::name, NULL::name);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.6'::text number,
       'TT_Match2'::text function_tested,
       'Simple test double precision, pass'::text description,
       TT_Match(1.1::double precision, 'public'::name, 'test_lookuptable3'::name) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_Match2'::text function_tested,
       'Simple test double precision, fail'::text description,
       TT_Match(1.5::double precision, 'public'::name, 'test_lookuptable3'::name) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_Match2'::text function_tested,
       'NULL val double precision'::text description,
       TT_Match(NULL::double precision, 'public'::name, 'test_lookuptable3'::name) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_Match2'::text function_tested,
       'schema null fail, double precision'::text description,
       IsError('SELECT TT_Match(1.1::double precision, NULL::name, test_lookuptable3::name);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.10'::text number,
       'TT_Match2'::text function_tested,
       'table null fail, double precision'::text description,
       IsError('SELECT TT_Match(1.1::double precision, public::name, NULL::name);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.11'::text number,
       'TT_Match2'::text function_tested,
       'Simple test integer, pass'::text description,
       TT_Match(1::int, 'public'::name, 'test_lookuptable2'::name) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.12'::text number,
       'TT_Match2'::text function_tested,
       'Simple test integer, fail'::text description,
       TT_Match(5::int, 'public'::name, 'test_lookuptable2'::name) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.13'::text number,
       'TT_Match2'::text function_tested,
       'NULL val integer'::text description,
       TT_Match(NULL::int, 'public'::name, 'test_lookuptable2'::name) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.14'::text number,
       'TT_Match2'::text function_tested,
       'schema null fail, int'::text description,
       IsError('SELECT TT_Match(1::int, NULL::name, test_lookuptable2::name);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '9.15'::text number,
       'TT_Match2'::text function_tested,
       'table null fail, int'::text description,
       IsError('SELECT TT_Match(1::int, public::name, NULL::name);') IS TRUE passed
---------------------------------------------------------
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
       IsError('SELECT TT_Concat(NULL, "cas", "id", "test");') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_Concat'::text function_tested,
       'Null string'::text description,
       IsError('SELECT TT_Concat("-", NULL, "id", "test");') IS TRUE passed
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
---------------------------------------------------------
-- Test 12 - TT_Lookup
---------------------------------------------------------
UNION ALL
SELECT '12.1'::text number,
       'TT_Lookup'::text function_tested,
       'Text usage'::text description,
       TT_Lookup('RA', 'public'::name, 'test_lookuptable1'::name, 'target_val') = 'Arbu menz'::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.2'::text number,
       'TT_Lookup'::text function_tested,
       'Double precision usage'::text description,
       TT_Lookup(1.1::double precision, 'public'::name, 'test_lookuptable3'::name, 'intcol') = '1'::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.3'::text number,
       'TT_Lookup'::text function_tested,
       'Integer usage'::text description,
       TT_Lookup(2::int, 'public'::name, 'test_lookuptable2'::name, 'dblcol') = '1.2'::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.4'::text number,
       'TT_Lookup'::text function_tested,
       'NULL val, text'::text description,
       IsError('SELECT TT_Lookup(NULL::text, "public"::name, "test_lookuptable1"::name, "target_val");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.5'::text number,
       'TT_Lookup'::text function_tested,
       'NULL val, double precision'::text description,
       IsError('SELECT TT_Lookup(NULL::double precision, "public"::name, "test_lookuptable3"::name, "intcol");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.6'::text number,
       'TT_Lookup'::text function_tested,
       'NULL val, int'::text description,
       IsError('SELECT TT_Lookup(NULL::int, "public"::name, "test_lookuptable2"::name, "dblcol");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.7'::text number,
       'TT_Lookup'::text function_tested,
       'NULL schema, text'::text description,
       IsError('SELECT TT_Lookup("RA"::text, NULL::name, "test_lookuptable1"::name, "target_val");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.8'::text number,
       'TT_Lookup'::text function_tested,
       'NULL schema, double precision'::text description,
       IsError('SELECT TT_Lookup(1.1::double precision, NULL::name, "test_lookuptable3"::name, "intcol");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.9'::text number,
       'TT_Lookup'::text function_tested,
       'NULL schema, int'::text description,
       IsError('SELECT TT_Lookup(1::int, NULL::name, "test_lookuptable2"::name, "dblcol");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.10'::text number,
       'TT_Lookup'::text function_tested,
       'NULL table, text'::text description,
       IsError('SELECT TT_Lookup("RA"::text, "public"::name, NULL::name, "target_val");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.11'::text number,
       'TT_Lookup'::text function_tested,
       'NULL table, double precision'::text description,
       IsError('SELECT TT_Lookup(1.1::double precision, "public"::name, NULL::name, "intcol");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.12'::text number,
       'TT_Lookup'::text function_tested,
       'NULL table, int'::text description,
       IsError('SELECT TT_Lookup(1::int, "public"::name, NULL::name, "dblcol");') passed
---------------------------------------------------------
UNION ALL
SELECT '12.13'::text number,
       'TT_Lookup'::text function_tested,
       'NULL column, text'::text description,
       IsError('SELECT TT_Lookup("RA"::text, "public"::name, "test_lookuptable1"::name, NULL);') passed
---------------------------------------------------------
UNION ALL
SELECT '12.14'::text number,
       'TT_Lookup'::text function_tested,
       'NULL column, double precision'::text description,
       IsError('SELECT TT_Lookup(1.1::double precision, "public"::name, "test_lookuptable3"::name, NULL);') passed
---------------------------------------------------------
UNION ALL
SELECT '12.15'::text number,
       'TT_Lookup'::text function_tested,
       'NULL column, int'::text description,
       IsError('SELECT TT_Lookup(1::int, "public"::name, "test_lookuptable2"::name, NULL);') passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 13 - TT_False
---------------------------------------------------------
UNION ALL
SELECT '13.1'::text number,
       'TT_False'::text function_tested,
       'Test'::text description,
       TT_False() IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 14 - TT_IsString
---------------------------------------------------------
UNION ALL
SELECT '14.1'::text number,
       'TT_IsString'::text function_tested,
       'Test, text'::text description,
       TT_IsString('text'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '14.2'::text number,
       'TT_IsString'::text function_tested,
       'Test, double precision'::text description,
       TT_IsString(1.1::double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '14.3'::text number,
       'TT_IsString'::text function_tested,
       'Test, int'::text description,
       TT_IsString(1::int) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '14.4'::text number,
       'TT_IsString'::text function_tested,
       'Test, empty string'::text description,
       TT_IsString(''::text) passed
---------------------------------------------------------
UNION ALL
SELECT '14.5'::text number,
       'TT_IsString'::text function_tested,
       'Test, NULL double precision'::text description,
       TT_IsString(NULL::double precision) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '14.6'::text number,
       'TT_IsString'::text function_tested,
       'Test, NULL int'::text description,
       TT_IsString(NULL::int) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '14.7'::text number,
       'TT_IsString'::text function_tested,
       'Test, NULL text'::text description,
       TT_IsString(NULL::text) IS FALSE passed
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

