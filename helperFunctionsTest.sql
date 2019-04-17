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
SELECT 'RA'::text, 'Arbu menz'::text
UNION ALL
SELECT ''::text, ''::text;

DROP TABLE IF EXISTS test_lookuptable2;
CREATE TABLE test_lookuptable2 AS
SELECT 1::int source_val, 1.1::double precision dblCol
UNION ALL
SELECT 2::int, 1.2::double precision	
UNION ALL
SELECT 3::int, 1.3::double precision;

DROP TABLE IF EXISTS test_lookuptable3;
CREATE TABLE test_lookuptable3 AS
SELECT 1.1::double precision source_val, 1::int intCol
UNION ALL
SELECT 1.2::double precision, 2::int	
UNION ALL
SELECT 1.3::double precision, 3::int;

DROP TABLE IF EXISTS test_table_with_null;
CREATE TABLE test_table_with_null AS
SELECT 'ACB'::text text_val, 1::int int_val, 1.1::double precision dbl_val, TRUE::boolean bool_val
UNION ALL
SELECT 'AAA'::text, 2::int, 1.2::double precision, TRUE::boolean	
UNION ALL
SELECT 'BBB'::text, 3::int, 1.3::double precision, FALSE::boolean
UNION ALL
SELECT NULL::text, NULL::int, NULL::double precision, NULL::boolean
UNION ALL
SELECT 'CCC'::text, NULL::int, 5.5::double precision, NULL::boolean;

-- IsError(text)
-- function to test if helper functions return errors
CREATE OR REPLACE FUNCTION TT_IsError(
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
    SELECT 'TT_NotNull'::text function_tested, 1 maj_num,  6 nb_test UNION ALL
    SELECT 'TT_NotEmpty'::text,                2,         11         UNION ALL
    SELECT 'TT_IsInt'::text,                   3,         11         UNION ALL
    SELECT 'TT_IsNumeric'::text,               4,          7         UNION ALL
    SELECT 'TT_IsString'::text,                5,          6         UNION ALL
    SELECT 'TT_Between'::text,                 6,         12         UNION ALL
    SELECT 'TT_GreaterThan'::text,             7,          9         UNION ALL
    SELECT 'TT_LessThan'::text,                8,          9         UNION ALL
    SELECT 'TT_MatchList'::text,               9,         20         UNION ALL
    SELECT 'TT_MatchTable'::text,               10,         19         UNION ALL   
    SELECT 'TT_Concat'::text,                 11,         15         UNION ALL
    SELECT 'TT_Copy'::text,                   12,          5         UNION ALL
    SELECT 'TT_Lookup'::text,                 13,          9         UNION ALL
    SELECT 'TT_False'::text,                  14,          1         UNION ALL
    SELECT 'TT_Length'::text,                 15,          5         UNION ALL
    SELECT 'TT_Pad'::text,                    16,         15         UNION ALL
    SELECT 'TT_HasUniqueValues'::text,        17,         17         UNION ALL
    SELECT 'TT_Map'::text,                    18,          6         UNION ALL
    SELECT 'TT_PadConcat'::text,              19,          4


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
       TT_NotNull('test'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_NotNull'::text function_tested,
       'Test if boolean'::text description,
       TT_NotNull(true::text) passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_NotNull'::text function_tested,
       'Test if double precision'::text description,
       TT_NotNull(9.99::text) passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_NotNull'::text function_tested,
       'Test if integer'::text description,
       TT_NotNull(999::text) passed
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
       'Test if empty string'::text description,
       TT_NotNull(''::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 2 - TT_NotEmpty
-- Should test for empty strings with spaces (e.g.'   ')
-- Should work with both char(n) and text(). In outdated char(n) type, '' is considered same as '  '. Not so for other types.
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_NotEmpty'::text function_tested,
       'Text string'::text description,
       TT_NotEmpty('a') passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_NotEmpty'::text function_tested,
       'Text string with spaces'::text description,
       TT_NotEmpty('test test') passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty text string'::text description,
       TT_NotEmpty(''::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_NotEmpty'::text function_tested,
       'Empty text string with spaces'::text description,
       TT_NotEmpty('  '::text) IS FALSE passed
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
       TT_NotEmpty('test test'::char(10)) passed       
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
UNION ALL
SELECT '2.9'::text number,
       'TT_NotEmpty'::text function_tested,
       'NULL text'::text description,
       TT_NotEmpty(NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.10'::text number,
       'TT_NotEmpty'::text function_tested,
       'Integer'::text description,
       TT_NotEmpty(1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '2.11'::text number,
       'TT_NotEmpty'::text function_tested,
       'Double precision'::text description,
       TT_NotEmpty(1.2::text) passed       
---------------------------------------------------------
---------------------------------------------------------
-- Test 3 - TT_IsInt
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_IsInt'::text function_tested,
       'Integer'::text description,
       TT_IsInt(1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_IsInt'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsInt(1.0::text) passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_IsInt'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsInt(1.1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_IsInt'::text function_tested,
       'Text, good value'::text description,
       TT_IsInt('1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_IsInt'::text function_tested,
       'Text, decimal good value'::text description,
       TT_IsInt('1.0'::text) passed
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
       TT_IsInt('1.'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '3.11'::text number,
       'TT_IsInt'::text function_tested,
       'NULL'::text description,
       TT_IsInt(NULL::text) IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 4 - TT_IsNumeric
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_IsNumeric'::text function_tested,
       'Integer'::text description,
       TT_IsNumeric(1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_IsNumeric'::text function_tested,
       'Double precision'::text description,
       TT_IsNumeric(1.1::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_IsNumeric'::text function_tested,
       'leading decimal'::text description,
       TT_IsNumeric('.1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_IsNumeric'::text function_tested,
       'Trailing decimal'::text description,
       TT_IsNumeric('1.'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'TT_IsNumeric'::text function_tested,
       'Invalid decimals'::text description,
       TT_IsNumeric('1.1.1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_IsNumeric'::text function_tested,
       'Text, with letter'::text description,
       TT_IsNumeric('1F'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_IsNumeric'::text function_tested,
       'NULL'::text description,
       TT_IsNumeric(NULL::text) IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 5 - TT_IsString
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_IsString'::text function_tested,
       'Test, text'::text description,
       TT_IsString('a'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_IsString'::text function_tested,
       'Test, double'::text description,
       TT_IsString(5.55555::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'TT_IsString'::text function_tested,
       'Test, int'::text description,
       TT_IsString(4::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'TT_IsString'::text function_tested,
       'Test, mixed double and letters as string'::text description,
       TT_IsString('4D.008'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'TT_IsString'::text function_tested,
       'Test, empty string'::text description,
       TT_IsString(''::text) passed
---------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'TT_IsString'::text function_tested,
       'Test, NULL'::text description,
       TT_IsString(NULL::text) IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 6 - TT_Between
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_Between'::text function_tested,
       'Integer, good value'::text description,
       TT_Between(50::text,0::text,100::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_Between'::text function_tested,
       'Integer, failed higher'::text description,
       TT_Between(150::text,0::text,100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_Between'::text function_tested,
       'Integer, failed lower'::text description,
       TT_Between(5::text,10::text,100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.4'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL val'::text description,
       TT_Between(NULL::text,0::text,100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.5'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL min'::text description,
       TT_IsError('SELECT TT_Between(10::text,NULL::text,100::text);'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.6'::text number,
       'TT_Between'::text function_tested,
       'Integer, NULL max'::text description,
       TT_IsError('SELECT TT_Between(10::text,0::text,NULL::text);'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '6.7'::text number,
       'TT_Between'::text function_tested,
       'double precision, good value'::text description,
       TT_Between(50.5::text,0::text,100::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.8'::text number,
       'TT_Between'::text function_tested,
       'double precision, failed higher'::text description,
       TT_Between(150.5::text,0::text,100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.9'::text number,
       'TT_Between'::text function_tested,
       'double precision, failed lower'::text description,
       TT_Between(5.5::text,10::text,100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.10'::text number,
       'TT_Between'::text function_tested,
       'Integer, test inclusive lower'::text description,
       TT_Between(0::text,0::text,100::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.11'::text number,
       'TT_Between'::text function_tested,
       'Integer, test inclusive higher'::text description,
       TT_Between(100::text,0::text,100::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.12'::text number,
       'TT_Between'::text function_tested,
       'Non-valid val'::text description,
       TT_IsError('SELECT TT_Between("1a"::text,0::text,100::text);'::text) passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 7 - TT_GreaterThan
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_GreaterThan'::text function_tested,
       'Integer, good value'::text description,
       TT_GreaterThan(11::text, 10::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_GreaterThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_GreaterThan(9::text, 10::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.3'::text number,
       'TT_GreaterThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_GreaterThan(10.3::text, 10.2::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.4'::text number,
       'TT_GreaterThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_GreaterThan(10.1::text, 10.2::text, TRUE::text) IS FALSE passed
---------------------------------------------------------       
UNION ALL
SELECT '7.5'::text number,
       'TT_GreaterThan'::text function_tested,
       'Default applied'::text description,
       TT_GreaterThan(10.1::text, 10.1::text) passed       
---------------------------------------------------------
UNION ALL
SELECT '7.6'::text number,
       'TT_GreaterThan'::text function_tested,
       'Inclusive false'::text description,
       TT_GreaterThan(10::text, 10.0::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.7'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL val'::text description,
       TT_GreaterThan(NULL::text, 10.1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.8'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL lowerBound'::text description,
       TT_IsError('SELECT TT_GreaterThan(10::text, NULL::text, TRUE::text);') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.9'::text number,
       'TT_GreaterThan'::text function_tested,
       'NULL inclusive'::text description,
       TT_IsError('SELECT TT_GreaterThan(10::text, 8::text, NULL::text);') IS TRUE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 8 - TT_LessThan
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_LessThan'::text function_tested,
       'Integer, good value'::text description,
       TT_LessThan(9::text, 10::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_LessThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_LessThan(11::text, 10::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.3'::text number,
       'TT_LessThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_LessThan(10.1::text, 10.7::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '8.4'::text number,
       'TT_LessThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_LessThan(9.9::text, 9.5::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.5'::text number,
       'TT_LessThan'::text function_tested,
       'Default applied'::text description,
       TT_LessThan(10.1::text, 10.1::text) passed       
---------------------------------------------------------
UNION ALL
SELECT '8.6'::text number,
       'TT_LessThan'::text function_tested,
       'Inclusive false'::text description,
       TT_LessThan(10.1::text, 10.1::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.7'::text number,
       'TT_LessThan'::text function_tested,
       'NULL val'::text description,
       TT_LessThan(NULL::text, 10.1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.8'::text number,
       'TT_LessThan'::text function_tested,
       'NULL upperBound'::text description,
       TT_IsError('SELECT TT_LessThan(10::text, NULL::text, TRUE::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '8.9'::text number,
       'TT_LessThan'::text function_tested,
       'NULL inclusive'::text description,
       TT_IsError('SELECT TT_LessThan(10::text, 8::text, NULL::text);') passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 9 - TT_MatchList (list variant)
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_MatchList'::text function_tested,
       'String good value'::text description,
       TT_MatchList('1'::text,'1,2,3'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_MatchList'::text function_tested,
       'String bad value'::text description,
       TT_MatchList('1'::text,'4,5,6'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_MatchList'::text function_tested,
       'String Null val'::text description,
       TT_MatchList(NULL::text, '1,2,3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_MatchList'::text function_tested,
       'String, empty string in list, good value'::text description,
       TT_MatchList('1'::text, ',2,3,1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_MatchList'::text function_tested,
       'String, empty string in list, bad value'::text description,
       TT_MatchList('4'::text, ',2,3,1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.6'::text number,
       'TT_MatchList'::text function_tested,
       'String, val is empty string, good value'::text description,
       TT_MatchList(''::text, ',1,2,3'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_MatchList'::text function_tested,
       'String, val is empty string, bad value'::text description,
       TT_MatchList(''::text, '1,2,3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision good value'::text description,
       TT_MatchList(1.5::text, '1.5,1.4,1.6'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision bad value'::text description,
       TT_MatchList(1.1::text, '1.5,1.4,1.6'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.10'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision empty string in list, good value'::text description,
       TT_MatchList(1.5::text,',1.5,1.6'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.11'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision empty string in list, bad value'::text description,
       TT_MatchList(1.5::text,',1.7,1.6'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.12'::text number,
       'TT_MatchList'::text function_tested,
       'Integer good value'::text description,
       TT_MatchList(5::text, '5,4,6'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.12'::text number,
       'TT_MatchList'::text function_tested,
       'Integer bad value'::text description,
       TT_MatchList(1::text, '5,4,6'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.13'::text number,
       'TT_MatchList'::text function_tested,
       'Integer empty string in list, good value'::text description,
       TT_MatchList(5::text,',5,6'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.14'::text number,
       'TT_MatchList'::text function_tested,
       'Integer empty string in list, bad value'::text description,
       TT_MatchList(1::text,',2,6'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.15'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, true, val lower'::text description,
       TT_MatchList('a'::text,'A,B,C'::text,TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.16'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, true, list lower'::text description,
       TT_MatchList('A'::text,'a,b,c'::text,TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.17'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, false, val lower'::text description,
       TT_MatchList('a'::text,'A,B,C'::text,FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.18'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, false, list lower'::text description,
       TT_MatchList('A'::text,'a,b,c'::text,FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.19'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision test ignore case TRUE'::text description,
       TT_MatchList(1.5::text,'1.5,1.7,1.6'::text,TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.20'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision test ignore case FALSE'::text description,
       TT_MatchList(1.5::text,'1.4,1.7,1.6'::text,FALSE::text) IS FALSE passed
------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
-- Test 10 - TT_MatchTable (lookup table variant)
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test text, pass'::text description,
       TT_MatchTable('RA'::text, 'public'::text, 'test_lookuptable1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test text, fail'::text description,
       TT_MatchTable('RAA'::text, 'public'::text, 'test_lookuptable1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.3'::text number,
       'TT_MatchTable'::text function_tested,
       'val NULL text'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_MatchTable'::text function_tested,
       'schema NULL fail, text'::text description,
       TT_IsError('SELECT TT_MatchTable(RA::text, NULL::text, test_lookuptable1::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '10.5'::text number,
       'TT_MatchTable'::text function_tested,
       'table NULL fail, text'::text description,
       TT_IsError('SELECT TT_MatchTable(RA::text, public::text, NULL::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '10.6'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.7'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, fail'::text description,
       TT_MatchTable(1.5::text, 'public'::text, 'test_lookuptable3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.8'::text number,
       'TT_MatchTable'::text function_tested,
       'NULL val double precision'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.9'::text number,
       'TT_MatchTable'::text function_tested,
       'schema null fail, double precision'::text description,
       TT_IsError('SELECT TT_MatchTable(1.1::text, NULL::text, test_lookuptable3::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '10.10'::text number,
       'TT_MatchTable'::text function_tested,
       'table null fail, double precision'::text description,
       TT_IsError('SELECT TT_MatchTable(1.1::text, public::text, NULL::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '10.11'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test integer, pass'::text description,
       TT_MatchTable(1::text, 'public'::text, 'test_lookuptable2'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.12'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test integer, fail'::text description,
       TT_MatchTable(5::text, 'public'::text, 'test_lookuptable2'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.13'::text number,
       'TT_MatchTable'::text function_tested,
       'NULL val integer'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable2'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.14'::text number,
       'TT_MatchTable'::text function_tested,
       'schema null fail, int'::text description,
       TT_IsError('SELECT TT_MatchTable(1::text, NULL::text, test_lookuptable2::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '10.15'::text number,
       'TT_MatchTable'::text function_tested,
       'table null fail, int'::text description,
       TT_IsError('SELECT TT_MatchTable(1::text, public::text, NULL::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '10.16'::text number,
       'TT_MatchTable'::text function_tested,
       'Test ignoreCase when false'::text description,
       TT_MatchTable('ra'::text, 'public'::text, 'test_lookuptable1'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.17'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass, ignore case false'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.18'::text number,
       'TT_MatchTable'::text function_tested,
       'Test ignoreCase when true'::text description,
       TT_MatchTable('ra'::text, 'public'::text, 'test_lookuptable1'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.19'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass, ingore case true'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 11 - TT_Concat
---------------------------------------------------------
UNION ALL
SELECT '11.1'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage 2 vals and processNulls=FALSE'::text description,
       TT_Concat('cas'::text,'id'::text, '-'::text, FALSE::text) = 'cas-id' passed
---------------------------------------------------------
UNION ALL
SELECT '11.2'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage 3 vals and processNulls=FALSE'::text description,
       TT_Concat('cas'::text,'id'::text, 'test'::text, '-'::text, FALSE::text) = 'cas-id-test' passed
---------------------------------------------------------
UNION ALL
SELECT '11.3'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage 4 vals and processNulls=FALSE'::text description,
       TT_Concat('cas'::text,'id'::text,'another'::text, 'test'::text, '-'::text, FALSE::text) = 'cas-id-another-test' passed
---------------------------------------------------------
UNION ALL
SELECT '11.4'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage 5 vals and processNulls=FALSE'::text description,
       TT_Concat('cas'::text,'id'::text,'another'::text, 'new'::text, 'test'::text, '-'::text, FALSE::text) = 'cas-id-another-new-test' passed
---------------------------------------------------------
UNION ALL
SELECT '11.5'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 2 vals and processNulls=TRUE'::text description,
       TT_Concat('cas'::text,NULL::text, '-'::text, TRUE::text) = 'cas' passed
---------------------------------------------------------
UNION ALL
SELECT '11.6'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 3 vals and processNulls=TRUE'::text description,
       TT_Concat('cas'::text,'id'::text, NULL::text, '-'::text, TRUE::text) = 'cas-id' passed
---------------------------------------------------------
UNION ALL
SELECT '11.7'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 4 vals and processNulls=TRUE'::text description,
       TT_Concat('cas'::text,'id'::text,'another'::text, NULL::text, '-'::text, TRUE::text) = 'cas-id-another' passed
---------------------------------------------------------
UNION ALL
SELECT '11.8'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 5 vals and processNulls=TRUE'::text description,
       TT_Concat('cas'::text,'id'::text,'another'::text, 'new'::text, NULL::text, '-'::text, TRUE::text) = 'cas-id-another-new' passed
---------------------------------------------------------
UNION ALL
SELECT '11.9'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 2 vals and processNulls=FALSE'::text description,
       TT_IsError('SELECT TT_Concat(''cas''::text,NULL::text, ''-''::text, TRUE::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '11.10'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 3 vals and processNulls=FALSE'::text description,
       TT_IsError('SELECT TT_Concat(''cas''::text,''id''::text, NULL::text, ''-''::text, TRUE::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '11.11'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 4 vals and processNulls=FALSE'::text description,
       TT_IsError('SELECT TT_Concat(''cas''::text,''id''::text,''another''::text, NULL::text, ''-''::text, TRUE::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '11.12'::text number,
       'TT_Concat'::text function_tested,
       'Null val, 5 vals and processNulls=FALSE'::text description,
       TT_IsError('SELECT TT_Concat(''cas''::text,''id''::text,''another''::text, ''new''::text, NULL::text, ''-''::text, TRUE::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '11.13'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage empty string'::text description,
       TT_Concat('cas'::text,''::text, 'test'::text, '-'::text, FALSE::text) = 'cas--test' passed
---------------------------------------------------------
UNION ALL
SELECT '11.14'::text number,
       'TT_Concat'::text function_tested,
       'Test in table'::text description,
       (SELECT TT_Concat(text_val::text,int_val::text,dbl_val::text, '-'::text, TRUE::text) FROM test_table_with_null WHERE text_val = 'CCC') = 'CCC-5.5' passed
---------------------------------------------------------
UNION ALL
SELECT '11.15'::text number,
       'TT_Concat'::text function_tested,
       'Test in table'::text description,
       TT_IsError('SELECT TT_Concat(text_val::text,int_val::text,dbl_val::text, ''-''::text, FALSE::text) FROM test_table_with_null WHERE text_val = ''CCC'');') passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 12 - TT_Copy
---------------------------------------------------------
UNION ALL
SELECT '12.1'::text number,
       'TT_Copy'::text function_tested,
       'Text usage'::text description,
       TT_Copy('copytest'::text) = 'copytest'::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.2'::text number,
       'TT_Copy'::text function_tested,
       'Int usage'::text description,
       TT_Copy(111::text) = 111::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.3'::text number,
       'TT_Copy'::text function_tested,
       'Double precision usage'::text description,
       TT_Copy(111.4::text) = 111.4::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.4'::text number,
       'TT_Copy'::text function_tested,
       'Empty string usage'::text description,
       TT_Copy(''::text) = ''::text passed
---------------------------------------------------------
UNION ALL
SELECT '12.5'::text number,
       'TT_Copy'::text function_tested,
       'Null'::text description,
       TT_Copy(NULL::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 13 - TT_Lookup
---------------------------------------------------------
UNION ALL
SELECT '13.1'::text number,
       'TT_Lookup'::text function_tested,
       'Text usage'::text description,
       TT_Lookup('RA'::text, 'public'::text, 'test_lookuptable1'::text, 'target_val'::text) = 'Arbu menz'::text passed
---------------------------------------------------------
UNION ALL
SELECT '13.2'::text number,
       'TT_Lookup'::text function_tested,
       'Double precision usage'::text description,
       TT_Lookup(1.1::text, 'public'::text, 'test_lookuptable3'::text, 'intcol'::text) = '1'::text passed
---------------------------------------------------------
UNION ALL
SELECT '13.3'::text number,
       'TT_Lookup'::text function_tested,
       'Integer usage'::text description,
       TT_Lookup(2::text, 'public'::text, 'test_lookuptable2'::text, 'dblcol'::text) = '1.2'::text passed
---------------------------------------------------------
UNION ALL
SELECT '13.4'::text number,
       'TT_Lookup'::text function_tested,
       'NULL val, text'::text description,
       TT_IsError('SELECT TT_Lookup(NULL::text, "public"::text, "test_lookuptable1"::text, "target_val"::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '13.5'::text number,
       'TT_Lookup'::text function_tested,
       'NULL schema, text'::text description,
       TT_IsError('SELECT TT_Lookup("RA"::text, NULL::text, "test_lookuptable1"::text, "target_val"::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '13.6'::text number,
       'TT_Lookup'::text function_tested,
       'NULL table, text'::text description,
       TT_IsError('SELECT TT_Lookup("RA"::text, "public"::text, NULL::text, "target_val"::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '13.7'::text number,
       'TT_Lookup'::text function_tested,
       'NULL column, text'::text description,
       TT_IsError('SELECT TT_Lookup("RA"::text, "public"::text, "test_lookuptable1"::text, NULL::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '13.8'::text number,
       'TT_Lookup'::text function_tested,
       'Test ignore case, true'::text description,
       TT_Lookup('ra'::text, 'public'::text, 'test_lookuptable1'::text, 'target_val'::text, TRUE::text) = 'Arbu menz'::text passed
---------------------------------------------------------
UNION ALL
SELECT '13.9'::text number,
       'TT_Lookup'::text function_tested,
       'Test ignore case, false'::text description,
       TT_Lookup('ra'::text, 'public'::text, 'test_lookuptable1'::text, 'target_val'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 14 - TT_False
---------------------------------------------------------
UNION ALL
SELECT '14.1'::text number,
       'TT_False'::text function_tested,
       'Test'::text description,
       TT_False() IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 15 - TT_Length
---------------------------------------------------------
UNION ALL
SELECT '15.1'::text number,
       'TT_Length'::text function_tested,
       'Test, text'::text description,
       TT_Length('text'::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '15.2'::text number,
       'TT_Length'::text function_tested,
       'Test empty string'::text description,
       TT_Length(''::text) = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '15.3'::text number,
       'TT_Length'::text function_tested,
       'Test double precision'::text description,
       TT_Length(5.5555::text) = 6 passed
---------------------------------------------------------
UNION ALL
SELECT '15.4'::text number,
       'TT_Length'::text function_tested,
       'Test int'::text description,
       TT_Length(1234::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '15.5'::text number,
       'TT_Length'::text function_tested,
       'Test NULL text'::text description,
       TT_Length(NULL::text) = 0 passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 16 - TT_Pad
---------------------------------------------------------
UNION ALL
SELECT '16.1'::text number,
       'TT_Pad'::text function_tested,
       'Test, text, pad'::text description,
       TT_Pad('species1'::text,10::text,'X'::text) = 'XXspecies1' passed
---------------------------------------------------------
UNION ALL
SELECT '16.2'::text number,
       'TT_Pad'::text function_tested,
       'Test, int, pad'::text description,
       TT_Pad(12345::text,10::text,'0'::text) = '0000012345' passed
---------------------------------------------------------
UNION ALL
SELECT '16.3'::text number,
       'TT_Pad'::text function_tested,
       'Test, double precision, pad'::text description,
       TT_Pad(1.234::text,10::text,'0'::text) = '000001.234' passed
---------------------------------------------------------
UNION ALL
SELECT '16.4'::text number,
       'TT_Pad'::text function_tested,
       'Test, empty string, pad'::text description,
       TT_Pad(''::text,10::text,'x'::text) = 'xxxxxxxxxx' passed
---------------------------------------------------------
UNION ALL
SELECT '16.5'::text number,
       'TT_Pad'::text function_tested,
       'Test, text, trim'::text description,
       TT_Pad('123456'::text,5::text,'0'::text) = '12345' passed
---------------------------------------------------------
UNION ALL
SELECT '16.6'::text number,
       'TT_Pad'::text function_tested,
       'Test, int, trim'::text description,
       TT_Pad(123456789::text,5::text,'x'::text) = '12345' passed
---------------------------------------------------------
UNION ALL
SELECT '16.7'::text number,
       'TT_Pad'::text function_tested,
       'Test, double precision, trim'::text description,
       TT_Pad(1.3456789::text,5::text,'x'::text) = '1.345' passed
---------------------------------------------------------
UNION ALL
SELECT '16.8'::text number,
       'TT_Pad'::text function_tested,
       'Test default, text'::text description,
       TT_Pad('sp1'::text,10::text) = 'xxxxxxxsp1' passed
---------------------------------------------------------
UNION ALL
SELECT '16.9'::text number,
       'TT_Pad'::text function_tested,
       'Test default, int'::text description,
       TT_Pad(12345678::text,10::text) = 'xx12345678' passed
---------------------------------------------------------
UNION ALL
SELECT '16.10'::text number,
       'TT_Pad'::text function_tested,
       'Test default, double precision'::text description,
       TT_Pad(1.345678::text,5::text) = '1.345' passed
---------------------------------------------------------
UNION ALL
SELECT '16.11'::text number,
       'TT_Pad'::text function_tested,
       'Test error, pad_char < 1'::text description,
       TT_IsError('SELECT TT_Pad(''sp1''::text,10::text,''''::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '16.12'::text number,
       'TT_Pad'::text function_tested,
       'Test error, pad_char > 1'::text description,
       TT_IsError('SELECT TT_Pad(1::text,10::text,''22''::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '16.13'::text number,
       'TT_Pad'::text function_tested,
       'Test error, null val'::text description,
       TT_Pad(NULL::text,3::text) = 'xxx' passed
---------------------------------------------------------
UNION ALL
SELECT '16.14'::text number,
       'TT_Pad'::text function_tested,
       'Test error, null target_length'::text description,
       TT_IsError('SELECT TT_Pad(1::text,NULL::text,''2''::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '16.15'::text number,
       'TT_Pad'::text function_tested,
       'Test error, null pad_char'::text description,
       TT_IsError('SELECT TT_Pad(1.234::text,10::text,NULL::text);') passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 17 - TT_HasUniqueValues
---------------------------------------------------------
UNION ALL
SELECT '17.1'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, text, good value'::text description,
       TT_HasUniqueValues('*AX'::text, 'public'::text, 'test_lookuptable1'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.2'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, double precision, good value'::text description,
       TT_HasUniqueValues(1.2::text, 'public'::text, 'test_lookuptable3'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.3'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, integer, good value'::text description,
       TT_HasUniqueValues(3::text, 'public'::text, 'test_lookuptable2'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.4'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, text, bad value'::text description,
       TT_HasUniqueValues('*AX'::text, 'public'::text, 'test_lookuptable1'::text, 2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.5'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, double precision, bad value'::text description,
       TT_HasUniqueValues(1.2::text, 'public'::text, 'test_lookuptable3'::text, 2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.6'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, integer, bad value'::text description,
       TT_HasUniqueValues(3::text, 'public'::text, 'test_lookuptable2'::text, 2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.7'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, empty string, good value'::text description,
       TT_HasUniqueValues(''::text, 'public'::text, 'test_lookuptable1'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.8'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Null val, text'::text description,
       TT_HasUniqueValues(NULL::text, 'public'::text, 'test_lookuptable1'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.9'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Null val, double precision'::text description,
       TT_HasUniqueValues(NULL::text, 'public'::text, 'test_lookuptable3'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.10'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Null val, int'::text description,
       TT_HasUniqueValues(NULL::text, 'public'::text, 'test_lookuptable2'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.11'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Null schema'::text description,
       TT_IsError('SELECT TT_HasUniqueValues(''RA''::text, NULL::text, ''test_lookuptable1''::text, 1::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '17.12'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Null table'::text description,
       TT_IsError('SELECT TT_HasUniqueValues(1.1::text, ''public''::text, NULL::text, 1::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '17.13'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Null occureces'::text description,
       TT_IsError('SELECT TT_HasUniqueValues(1, ''public'', ''test_lookuptable2'', NULL::int);') passed
---------------------------------------------------------
UNION ALL
SELECT '17.14'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test default, text'::text description,
       TT_HasUniqueValues('RA'::text, 'public'::text, 'test_lookuptable1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.15'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test default, double precision'::text description,
       TT_HasUniqueValues(1.3::text, 'public'::text, 'test_lookuptable3'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.16'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test default, int'::text description,
       TT_HasUniqueValues(3::text, 'public'::text, 'test_lookuptable2'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.17'::text number,
       'TT_HasUniqueValues'::text function_tested,
       'Test, text, missing value'::text description,
       TT_HasUniqueValues('**AX'::text, 'public'::text, 'test_lookuptable1'::text, 1::text) IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 18 - TT_Map
---------------------------------------------------------
UNION ALL
SELECT '18.1'::text number,
       'TT_Map'::text function_tested,
       'Test text'::text description,
       TT_Map('A'::text,'A,B,C,D'::text,'1,2,3,4'::text) = '1' passed
---------------------------------------------------------
UNION ALL
SELECT '18.2'::text number,
       'TT_Map'::text function_tested,
       'Test double precision'::text description,
       TT_Map(1.1::text,'1.1,1.2,1.3,1.4'::text,'A,B,C,D'::text) = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '18.3'::text number,
       'TT_Map'::text function_tested,
       'Test int'::text description,
       TT_Map(2::text,'1,2,3,4'::text,'A,B,C,D'::text) = 'B' passed
---------------------------------------------------------
UNION ALL
SELECT '18.4'::text number,
       'TT_Map'::text function_tested,
       'Test Null val'::text description,
       TT_IsError('SELECT TT_Map(NULL::text,''A,B,C,D''::text,''1,2,3,4''::text);') passed
---------------------------------------------------------
UNION ALL
SELECT '18.5'::text number,
       'TT_Map'::text function_tested,
       'Test caseIgnore, true'::text description,
       TT_Map('a'::text,'A,B,C,D'::text,'1,2,3,4'::text,TRUE::text) = '1' passed
---------------------------------------------------------
UNION ALL
SELECT '18.6'::text number,
       'TT_Map'::text function_tested,
       'Test caseIgnore, false'::text description,
       TT_Map('a'::text,'A,B,C,D'::text,'1,2,3,4'::text,FALSE::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 19 - TT_PadConcat
---------------------------------------------------------
UNION ALL
SELECT '19.1'::text number,
       'TT_PadConcat'::text function_tested,
       'Test AB06'::text description,
       TT_PadConcat('ab06'::text, 'GB_S21_TWP'::text, '81145'::text, '811451038'::text, '1'::text,   4::text,15::text,10::text,10::text,7::text, 'x'::text,'x'::text,'x'::text,0::text,0::text,  '-'::text, TRUE::text, TRUE::text) = 'AB06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '19.2'::text number,
       'TT_PadConcat'::text function_tested,
       'Test AB16'::text description,
       TT_PadConcat('ab16'::text, 'CANFOR'::text, 't059R04M6'::text, '109851'::text, '1'::text,   4::text,15::text,10::text,10::text,7::text, 'x'::text,'x'::text,'x'::text,0::text,0::text,  '-'::text, TRUE::text, TRUE::text) = 'AB16-xxxxxxxxxCANFOR-xT059R04M6-0000109851-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '19.3'::text number,
       'TT_PadConcat'::text function_tested,
       'Test NB01'::text description,
       TT_PadConcat('nb01'::text, 'waterbody'::text, ''::text, ''::text, '1'::text,   4::text,15::text,10::text,10::text,7::text, 'x'::text,'x'::text,'x'::text,0::text,0::text,  '-'::text, TRUE::text, TRUE::text) = 'NB01-xxxxxxWATERBODY-xxxxxxxxxx-0000000000-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '19.4'::text number,
       'TT_PadConcat'::text function_tested,
       'Test BC08'::text description,
       TT_PadConcat('bc08'::text, 'VEG_COMP_LYR_R1'::text, '83D093'::text, '2035902'::text, '1'::text,   4::text,15::text,10::text,10::text,7::text, 'x'::text,'x'::text,'x'::text,0::text,0::text,  '-'::text, TRUE::text, TRUE::text) = 'BC08-VEG_COMP_LYR_R1-xxxx83D093-0002035902-0000001' passed
---------------------------------------------------------
---------------------------------------------------------
              
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;
