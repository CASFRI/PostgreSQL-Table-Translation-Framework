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
------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';

SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create a generic NULL and wrong type tester function
CREATE OR REPLACE FUNCTION TT_TestNullAndWrongTypeParams(
  baseNumber int,
  fctName text,
  params text[]
)
RETURNS TABLE(number text, function_tested text, description text, passed boolean) AS $$
  DECLARE
    query text;
    i integer;
    j integer;
    paramName text;
    paramType text;
    subnbr int = 0;
  BEGIN
    function_tested = fctName;
    -- check that all parameters have an associated type (that the number of params parameters is a multiple of 2)
    IF array_upper(params, 1) % 2 != 0 THEN
      RAISE EXCEPTION 'ERROR when calling TT_TestNullAndWrongTypeParams(): params ARRAY must have an even number of parameters';
    END IF;
    FOR i IN 1..array_upper(params, 1)/2 LOOP
      subnbr = subnbr + 1;
      number = baseNumber::text || '.' || subnbr::text;
      paramName = params[(i - 1) * 2 + 1];
      description = 'NULL ' || paramName;
      -- test not NULL
      query = 'SELECT TT_IsError(''SELECT ' || function_tested || '(''''val'''', ';
      FOR j IN 1..array_upper(params, 1)/2 LOOP
        paramType = params[(j - 1) * 2 + 2];
        IF j = i THEN -- set this parameter to NULL
          query = query || 'NULL::text, ';
        ELSE -- set other parameters to a valid value
          query = query || CASE WHEN paramType = 'int' OR paramType = 'numeric' THEN
                                     '1::text, '
                                WHEN paramType = 'char' THEN
                                     '0::text, '
                                WHEN paramType = 'boolean' THEN
                                     'TRUE::text, '
                                WHEN paramType = 'stringlist' OR paramType = 'charlist' THEN
                                     '''''{''''''''a'''''''', ''''''''b''''''''}''''::text, '
                                WHEN paramType = 'doublelist' THEN
                                     '''''{''''''''1.3'''''''', ''''''''3.4''''''''}''''::text, '
                                WHEN paramType = 'intlist' THEN
                                     '''''{''''''''3'''''''', ''''''''4''''''''}''''::text, '
                                ELSE --text
                                     '''''randomtext'''', '
                           END;
        END IF;
      END LOOP;
      -- remove the last comma.
      query = left(query, char_length(query) - 2);

      query = query || ');'') = ''ERROR in ' || function_tested || '(): ' || paramName || ' is NULL'';';
RAISE NOTICE 'query = %', query;
      EXECUTE query INTO passed;
      RETURN NEXT;

      -- test wrong type (not necessary to test text as everything is valid text)
      IF params[(i - 1) * 2 + 2] != 'text' THEN
      subnbr = subnbr + 1;
      number = baseNumber::text || '.' || subnbr::text;
        description = paramName || ' wrong type';
        query = 'SELECT TT_IsError(''SELECT ' || function_tested || '(''''val'''', ';
        FOR j IN 1..array_upper(params, 1)/2 LOOP
          paramType = params[(j - 1) * 2 + 2];
          IF j = i THEN
            -- test an invalid value
            query = query || CASE WHEN paramType = 'int' OR paramType = 'numeric' THEN
                                       '''''1a'''', '
                                  WHEN paramType = 'char' THEN
                                       '''''aa''''::text, '
                                  WHEN paramType = 'stringlist' OR paramType = 'doublelist' OR paramType = 'intlist'  OR paramType = 'charlist'THEN
                                       '''''{''''''''string1'''''''',}'''', '
                                  ELSE -- boolean
                                       '2::text, '
                             END;
          ELSE
            -- set other to valid value
            query = query || CASE WHEN paramType = 'int' OR paramType = 'numeric' THEN
                                       '1::text, '
                                  WHEN paramType = 'char' THEN
                                       '0::text, '
                                  WHEN paramType = 'boolean' THEN
                                       'TRUE::text, '
                                  WHEN paramType = 'stringlist' OR paramType = 'charlist' THEN
                                       '''''{''''''''a'''''''', ''''''''b''''''''}''''::text, '
                                  WHEN paramType = 'doublelist' OR paramType = 'intlist' THEN
                                       '''''{''''''''1'''''''', ''''''''2''''''''}''''::text, '
                                  ELSE
                                       '''''randomtext'''', '
                             END;
          END IF;
        END LOOP;
        -- remove the last comma.
        query = left(query, char_length(query) - 2);
        paramType = params[(i - 1) * 2 + 2];
        query = query || ');'') = ''ERROR in ' || function_tested || '(): ' || paramName || ' is not a ' || paramType || ' value'';';

RAISE NOTICE 'query = %', query;
        EXECUTE query INTO passed;
        RETURN NEXT;
      END IF;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-----------------------------------------------------------
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
-----------------------------------------------------------
DROP TABLE IF EXISTS test_lookuptable2;
CREATE TABLE test_lookuptable2 AS
SELECT 1::int source_val, 1.1::double precision dblCol
UNION ALL
SELECT 2::int, 1.2::double precision
UNION ALL
SELECT 3::int, 1.3::double precision;
-----------------------------------------------------------
DROP TABLE IF EXISTS test_lookuptable3;
CREATE TABLE test_lookuptable3 AS
SELECT 1.1::double precision source_val, 1::int intCol
UNION ALL
SELECT 1.2::double precision, 2::int
UNION ALL
SELECT 1.3::double precision, 3::int;
-----------------------------------------------------------
DROP TABLE IF EXISTS test_table_with_null;
CREATE TABLE test_table_with_null AS
SELECT 'a'::text source_val, 'ACB'::text text_val, 1::int int_val, 1.1::double precision dbl_val, TRUE::boolean bool_val
UNION ALL
SELECT 'b'::text, 'AAA'::text, 2::int, 1.2::double precision, TRUE::boolean
UNION ALL
SELECT 'c'::text, 'BBB'::text, 3::int, 1.3::double precision, FALSE::boolean
UNION ALL
SELECT NULL::text, NULL::text, NULL::int, NULL::double precision, NULL::boolean
UNION ALL
SELECT 'd'::text, 'CCC'::text, NULL::int, 5.5::double precision, NULL::boolean
UNION ALL
SELECT 'AA'::text, 'abcde'::text, NULL::int, 5.5::double precision, NULL::boolean;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
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
    SELECT 'TT_NotNull'::text function_tested, 1 maj_num, 11 nb_test UNION ALL
    SELECT 'TT_NotEmpty'::text,                2,         11         UNION ALL
    SELECT 'TT_Length'::text,                  3,          5         UNION ALL
    SELECT 'TT_IsInt'::text,                   4,         12         UNION ALL
    SELECT 'TT_IsNumeric'::text,               5,          8         UNION ALL
    SELECT 'TT_IsBoolean'::text,               6,          8         UNION ALL
    SELECT 'TT_IsBetween'::text,               7,         31         UNION ALL
    SELECT 'TT_IsGreaterThan'::text,           8,         13         UNION ALL
    SELECT 'TT_IsLessThan'::text,              9,         13         UNION ALL
    SELECT 'TT_IsUnique'::text,               10,         21         UNION ALL
    SELECT 'TT_MatchTable'::text,             11,         20         UNION ALL
    SELECT 'TT_MatchList'::text,              12,         30         UNION ALL
    SELECT 'TT_False'::text,                  13,          1         UNION ALL
    SELECT 'TT_True'::text,                   14,          1         UNION ALL
    SELECT 'TT_CountNotNull'::text,           15,         18         UNION ALL
    SELECT 'TT_IsIntSubstring'::text,         16,         10         UNION ALL
    SELECT 'TT_IsBetweenSubstring'::text,     17,         19         UNION ALL
    SELECT 'TT_IsName'::text,                 18,          8         UNION ALL
	SELECT 'TT_NotMatchList'::text,           19,         28         UNION ALL
    -- Translation functions
    SELECT 'TT_CopyText'::text,              101,          3         UNION ALL
    SELECT 'TT_CopyDouble'::text,            102,          2         UNION ALL
    SELECT 'TT_CopyInt'::text,               103,          5         UNION ALL
    SELECT 'TT_LookupText'::text,            104,         10         UNION ALL
    SELECT 'TT_LookupDouble'::text,          105,          9         UNION ALL
    SELECT 'TT_LookupInt'::text,             106,          9         UNION ALL
    SELECT 'TT_MapText'::text,               107,         14         UNION ALL
    SELECT 'TT_MapDouble'::text,             108,         12         UNION ALL
    SELECT 'TT_MapInt'::text,                109,         12         UNION ALL
    SELECT 'TT_Pad'::text,                   110,         17         UNION ALL
    SELECT 'TT_Concat'::text,                111,          4         UNION ALL
    SELECT 'TT_PadConcat'::text,             112,         18         UNION ALL
    SELECT 'TT_NothingText'::text,           118,          1         UNION ALL
    SELECT 'TT_NothingDouble'::text,         119,          1         UNION ALL
    SELECT 'TT_NothingInt'::text,            120,          1         UNION ALL
	SELECT 'TT_NumberOfNotNull'::text,       121,          4
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
UNION ALL
SELECT '1.7'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with values'::text description,
       TT_NotNull('{''a'',''b''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with one NULL'::text description,
       TT_NotNull('{''a'',NULL}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with all NULL'::text description,
       TT_NotNull('{NULL,NULL}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.10'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with one NULL'::text description,
       TT_NotNull('{NULL}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.11'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with one value'::text description,
       TT_NotNull('{test}'::text) passed
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
-- Test 3 - TT_Length
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_Length'::text function_tested,
       'Test, text'::text description,
       TT_Length('text'::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_Length'::text function_tested,
       'Test empty string'::text description,
       TT_Length(''::text) = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_Length'::text function_tested,
       'Test double precision'::text description,
       TT_Length(5.5555::text) = 6 passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_Length'::text function_tested,
       'Test int'::text description,
       TT_Length(1234::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_Length'::text function_tested,
       'Test NULL text'::text description,
       TT_Length(NULL::text) = 0 passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 4 - TT_IsInt
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_IsInt'::text function_tested,
       'Integer'::text description,
       TT_IsInt(1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_IsInt'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsInt(1.0::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_IsInt'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsInt(1.1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_IsInt'::text function_tested,
       'Text, good value'::text description,
       TT_IsInt('1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'TT_IsInt'::text function_tested,
       'Text, decimal good value'::text description,
       TT_IsInt('1.0'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_IsInt'::text function_tested,
       'Text, decimal bad value'::text description,
       TT_IsInt('1.1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with letters'::text description,
       TT_IsInt('1D'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with invalid decimal'::text description,
       TT_IsInt('1.0.0'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.9'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with leading decimal'::text description,
       TT_IsInt('.5'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.10'::text number,
       'TT_IsInt'::text function_tested,
       'Text, with trailing decimal'::text description,
       TT_IsInt('1.'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '4.11'::text number,
       'TT_IsInt'::text function_tested,
       'NULL'::text description,
       TT_IsInt(NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '4.12'::text number,
       'TT_IsInt'::text function_tested,
       'NULL passes with acceptNull'::text description,
       TT_IsInt(NULL::text, TRUE::text) passed
---------------------------------------------------------
-- Test 5 - TT_IsNumeric
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_IsNumeric'::text function_tested,
       'Integer'::text description,
       TT_IsNumeric(1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_IsNumeric'::text function_tested,
       'Double precision'::text description,
       TT_IsNumeric(1.1::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'TT_IsNumeric'::text function_tested,
       'leading decimal'::text description,
       TT_IsNumeric('.1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'TT_IsNumeric'::text function_tested,
       'Trailing decimal'::text description,
       TT_IsNumeric('1.'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'TT_IsNumeric'::text function_tested,
       'Invalid decimals'::text description,
       TT_IsNumeric('1.1.1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'TT_IsNumeric'::text function_tested,
       'Text, with letter'::text description,
       TT_IsNumeric('1F'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'TT_IsNumeric'::text function_tested,
       'NULL'::text description,
       TT_IsNumeric(NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '5.8'::text number,
       'TT_IsNumeric'::text function_tested,
       'Pass with acceptNull'::text description,
       TT_IsNumeric(NULL::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 6 - TT_IsBoolean
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test true'::text description,
       TT_IsBoolean(TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test false'::text description,
       TT_IsBoolean(FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test true as string'::text description,
       TT_IsBoolean('TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '6.4'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test false as string'::text description,
       TT_IsBoolean('FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '6.5'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test true as int'::text description,
       TT_IsBoolean(1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.6'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test false as int'::text description,
       TT_IsBoolean(0::text) passed
---------------------------------------------------------
UNION ALL
SELECT '6.7'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test too big int'::text description,
       TT_IsBoolean(2::text) = FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '6.8'::text number,
       'TT_IsBoolean'::text function_tested,
       'Test other text'::text description,
       TT_IsBoolean('2a') = FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 7 - TT_IsBetween
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (10 tests)
SELECT (TT_TestNullAndWrongTypeParams(7, 'TT_IsBetween',
                                      ARRAY['min', 'numeric',
                                            'max', 'numeric',
                                            'includeMin', 'boolean',
                                            'includeMax', 'boolean',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '7.11'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, good value'::text description,
       TT_IsBetween(50::text, 0::text, 100::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.12'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, failed higher'::text description,
       TT_IsBetween(150::text, 0::text, 100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.13'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, failed lower'::text description,
       TT_IsBetween(5::text, 10::text, 100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.14'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, NULL val'::text description,
       TT_IsBetween(NULL::text, 0::text, 100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.15'::text number,
       'TT_IsBetween'::text function_tested,
       'double precision, good value'::text description,
       TT_IsBetween(50.5::text, 0::text, 100::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.16'::text number,
       'TT_IsBetween'::text function_tested,
       'double precision, failed higher'::text description,
       TT_IsBetween(150.5::text, 0::text, 100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.17'::text number,
       'TT_IsBetween'::text function_tested,
       'double precision, failed lower'::text description,
       TT_IsBetween(5.5::text, 10::text, 100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.18'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, test inclusive lower'::text description,
       TT_IsBetween(0::text, 0::text, 100::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.19'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, test inclusive higher'::text description,
       TT_IsBetween(100::text, 0::text, 100::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.20'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, test inclusive lower false'::text description,
       TT_IsBetween(0::text, 0::text, 100::text, FALSE::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.21'::text number,
       'TT_IsBetween'::text function_tested,
       'Integer, test inclusive higher false'::text description,
       TT_IsBetween(100::text, 0::text, 100::text, TRUE::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.22'::text number,
       'TT_IsBetween'::text function_tested,
       'Non-valid val'::text description,
       TT_IsBetween('1a'::text, 0::text, 100::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.23'::text number,
       'TT_IsBetween'::text function_tested,
       'min equal to max'::text description,
       TT_IsError('SELECT TT_IsBetween(0::text, 100::text, 100::text);'::text) = 'ERROR in TT_IsBetween(): min is equal to max' passed
---------------------------------------------------------
UNION ALL
SELECT '7.24'::text number,
       'TT_IsBetween'::text function_tested,
       'min higher than max'::text description,
       TT_IsError('SELECT TT_IsBetween(0::text, 150::text, 100::text);'::text) = 'ERROR in TT_IsBetween(): min is greater than max' passed
--------------------------------------------------------
UNION ALL
SELECT '7.25'::text number,
       'TT_IsBetween'::text function_tested,
       'Text includeMin'::text description,
       TT_IsBetween(0::text, 0::text, 100::text, 'TRUE', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '7.26'::text number,
       'TT_IsBetween'::text function_tested,
       'Text includeMax'::text description,
       TT_IsBetween(100::text, 0::text, 100::text, 'TRUE', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '7.27'::text number,
       'TT_IsBetween'::text function_tested,
       'Numeric includeMin false'::text description,
       TT_IsBetween(0::text, 0::text, 100::text, '0', 'TRUE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.28'::text number,
       'TT_IsBetween'::text function_tested,
       'Numeric includeMin true'::text description,
       TT_IsBetween(0::text, 0::text, 100::text, '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '7.29'::text number,
       'TT_IsBetween'::text function_tested,
       'Numeric includeMax false'::text description,
       TT_IsBetween(100::text, 0::text, 100::text, 'TRUE', '0') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.30'::text number,
       'TT_IsBetween'::text function_tested,
       'Numeric includeMax true'::text description,
       TT_IsBetween(100::text, 0::text, 100::text, 'TRUE', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '7.31'::text number,
       'TT_IsBetween'::text function_tested,
       'Test null with acceptNull true'::text description,
       TT_IsBetween(NULL::text, 0::text, 100::text, 'TRUE'::text, '1'::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 8 - TT_IsGreaterThan
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(8, 'TT_IsGreaterThan',
                                      ARRAY['lowerBound', 'numeric',
                                            'inclusive', 'boolean',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '8.7'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Integer, good value'::text description,
       TT_IsGreaterThan(11::text, 10::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.8'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_IsGreaterThan(9::text, 10::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.9'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsGreaterThan(10.3::text, 10.2::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.10'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsGreaterThan(10.1::text, 10.2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.11'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Inclusive false'::text description,
       TT_IsGreaterThan(10::text, 10.0::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.12'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL val'::text description,
       TT_IsGreaterThan(NULL::text, 10.1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.13'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL val and acceptNull true'::text description,
       TT_IsGreaterThan(NULL::text, 10.1::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 9 - TT_IsLessThan
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(9, 'TT_IsLessThan',
                                      ARRAY['upperBound', 'numeric',
                                            'inclusive', 'boolean',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_IsLessThan'::text function_tested,
       'Integer, good value'::text description,
       TT_IsLessThan(9::text, 10::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_IsLessThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_IsLessThan(11::text, 10::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_IsLessThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsLessThan(10.1::text, 10.7::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.10'::text number,
       'TT_IsLessThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsLessThan(9.9::text, 9.5::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.11'::text number,
       'TT_IsLessThan'::text function_tested,
       'Inclusive false'::text description,
       TT_IsLessThan(10.1::text, 10.1::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.12'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL val'::text description,
       TT_IsLessThan(NULL::text, 10.1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.13'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL val and acceptNull true'::text description,
       TT_IsLessThan(NULL::text, 10.1::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 10 - TT_IsUnique
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(10, 'TT_IsUnique',
                                      ARRAY['lookupSchemaName', 'text',
                                            'lookupTableName', 'text',
                                            'occurrences', 'int',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '10.7'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, text, good value'::text description,
       TT_IsUnique('*AX'::text, 'public'::text, 'test_lookuptable1'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.8'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, double precision, good value'::text description,
       TT_IsUnique(1.2::text, 'public'::text, 'test_lookuptable3'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.9'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, integer, good value'::text description,
       TT_IsUnique(3::text, 'public'::text, 'test_lookuptable2'::text, 1::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.10'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, text, bad value'::text description,
       TT_IsUnique('*AX'::text, 'public'::text, 'test_lookuptable1'::text, 2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.11'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, double precision, bad value'::text description,
       TT_IsUnique(1.2::text, 'public'::text, 'test_lookuptable3'::text, 2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.12'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, integer, bad value'::text description,
       TT_IsUnique(3::text, 'public'::text, 'test_lookuptable2'::text, 2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.13'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, empty string, good value'::text description,
       TT_IsUnique(''::text, 'public'::text, 'test_lookuptable1'::text, 1::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '10.14'::text number,
       'TT_IsUnique'::text function_tested,
       'Null val, text'::text description,
       TT_IsUnique(NULL::text, 'public'::text, 'test_lookuptable1'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.15'::text number,
       'TT_IsUnique'::text function_tested,
       'Null val, double precision'::text description,
       TT_IsUnique(NULL::text, 'public'::text, 'test_lookuptable3'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.16'::text number,
       'TT_IsUnique'::text function_tested,
       'Null val, int'::text description,
       TT_IsUnique(NULL::text, 'public'::text, 'test_lookuptable2'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.17'::text number,
       'TT_IsUnique'::text function_tested,
       'Test default, text'::text description,
       TT_IsUnique('RA'::text, 'public'::text, 'test_lookuptable1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.18'::text number,
       'TT_IsUnique'::text function_tested,
       'Test default, double precision'::text description,
       TT_IsUnique(1.3::text, 'public'::text, 'test_lookuptable3'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.19'::text number,
       'TT_IsUnique'::text function_tested,
       'Test default, int'::text description,
       TT_IsUnique(3::text, 'public'::text, 'test_lookuptable2'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '10.20'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, text, missing value'::text description,
       TT_IsUnique('**AX'::text, 'public'::text, 'test_lookuptable1'::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '10.21'::text number,
       'TT_IsUnique'::text function_tested,
       'Test, text, missing value'::text description,
       TT_IsUnique(NULL::text, 'public'::text, 'test_lookuptable1'::text, 1::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 11 - TT_MatchTable (lookup table variant)
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(11, 'TT_MatchTable', ARRAY['lookupSchemaName', 'text',
                                                                 'lookupTableName', 'text',
                                                                 'ignoreCase', 'boolean',
                                                                 'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '11.7'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test text, pass'::text description,
       TT_MatchTable('RA'::text, 'public'::text, 'test_lookuptable1'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '11.8'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test text, fail'::text description,
       TT_MatchTable('RAA'::text, 'public'::text, 'test_lookuptable1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.9'::text number,
       'TT_MatchTable'::text function_tested,
       'val NULL text'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.10'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.11'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, fail'::text description,
       TT_MatchTable(1.5::text, 'public'::text, 'test_lookuptable3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.12'::text number,
       'TT_MatchTable'::text function_tested,
       'NULL val double precision'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable3'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.13'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test integer, pass'::text description,
       TT_MatchTable(1::text, 'public'::text, 'test_lookuptable2'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.14'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test integer, fail'::text description,
       TT_MatchTable(5::text, 'public'::text, 'test_lookuptable2'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.15'::text number,
       'TT_MatchTable'::text function_tested,
       'NULL val integer'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable2'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.16'::text number,
       'TT_MatchTable'::text function_tested,
       'Test ignoreCase when false'::text description,
       TT_MatchTable('ra'::text, 'public'::text, 'test_lookuptable1'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.17'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass, ignore case false'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.18'::text number,
       'TT_MatchTable'::text function_tested,
       'Test ignoreCase when true'::text description,
       TT_MatchTable('ra'::text, 'public'::text, 'test_lookuptable1'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.19'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass, ingore case true'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.20'::text number,
       'TT_MatchTable'::text function_tested,
       'Test null with acceptNull true'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable3'::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 12 - TT_MatchList (list variant)
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (8 tests)
SELECT (TT_TestNullAndWrongTypeParams(12, 'TT_MatchList', ARRAY['lst', 'stringlist',
                                                               'ignoreCase', 'boolean',
                                                                'acceptNull', 'boolean',
															   'matches', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '12.9'::text number,
       'TT_MatchList'::text function_tested,
       'String good value'::text description,
       TT_MatchList('1'::text, '{''1'', ''2'', ''3''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.10'::text number,
       'TT_MatchList'::text function_tested,
       'String bad value'::text description,
       TT_MatchList('1'::text, '{''4'', ''5'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.11'::text number,
       'TT_MatchList'::text function_tested,
       'String Null val'::text description,
       TT_MatchList(NULL::text, '{''1'', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.12'::text number,
       'TT_MatchList'::text function_tested,
       'String, empty string in list, good value'::text description,
       TT_MatchList('1'::text, '{''a'', ''2'', ''3'', ''1''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.13'::text number,
       'TT_MatchList'::text function_tested,
       'String, empty string in list, bad value'::text description,
       TT_MatchList('4'::text, '{'''', ''2'', ''3'', ''1''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.14'::text number,
       'TT_MatchList'::text function_tested,
       'String, val is empty string, good value'::text description,
       TT_MatchList(''::text, '{'''', ''1'', ''2'', ''3''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.15'::text number,
       'TT_MatchList'::text function_tested,
       'String, val is empty string, bad value'::text description,
       TT_MatchList(''::text, '{''1'', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.16'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision good value'::text description,
       TT_MatchList(1.5::text, '{''1.5'', ''1.4'', ''1.6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.17'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision bad value'::text description,
       TT_MatchList(1.1::text, '{''1.5'', ''1.4'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.18'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision empty string in list, good value'::text description,
       TT_MatchList(1.5::text, '{'''', ''1.5'', ''1.6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.19'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision empty string in list, bad value'::text description,
       TT_MatchList(1.5::text, '{'''', ''1.7'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.20'::text number,
       'TT_MatchList'::text function_tested,
       'Integer good value'::text description,
       TT_MatchList(5::text, '{''5'', ''4'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.21'::text number,
       'TT_MatchList'::text function_tested,
       'Integer bad value'::text description,
       TT_MatchList(1::text, '{''5'', ''4'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.22'::text number,
       'TT_MatchList'::text function_tested,
       'Integer empty string in list, good value'::text description,
       TT_MatchList(5::text, '{'''', ''5'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.23'::text number,
       'TT_MatchList'::text function_tested,
       'Integer empty string in list, bad value'::text description,
       TT_MatchList(1::text, '{'''', ''2'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.24'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, true, val lower'::text description,
       TT_MatchList('a'::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.25'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, true, list lower'::text description,
       TT_MatchList('A'::text, '{''a'', ''b'', ''c''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.26'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, false, val lower'::text description,
       TT_MatchList('a'::text, '{''A'', ''B'', ''C''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.27'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, false, list lower'::text description,
       TT_MatchList('A'::text, '{''a'', ''b'', ''c''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.28'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision test ignore case TRUE'::text description,
       TT_MatchList(1.5::text, '{''1.5'', ''1.7'', ''1.6''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.29'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision test ignore case FALSE'::text description,
       TT_MatchList(1.5::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.30'::text number,
       'TT_MatchList'::text function_tested,
       'Tets NULL with acceptNull true'::text description,
       TT_MatchList(NULL::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text, TRUE::text) passed
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
-- Test 14 - TT_True
---------------------------------------------------------
UNION ALL
SELECT '14.1'::text number,
       'TT_True'::text function_tested,
       'Simple test'::text description,
       TT_True() passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 15 - TT_CountNotNull
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(15, 'TT_CountNotNull',
                                      ARRAY['count', 'int',
                                            'exact', 'boolean',
                                            'testEmpty', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '15.7'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact true, empty true, passes'::text description,
       TT_CountNotNull('{''a'',''b'',''c''}'::text, 3::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.8'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact true, empty true, fails'::text description,
       TT_CountNotNull('{''a'',''b'',NULL}'::text, 3::text, TRUE::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '15.9'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact true, empty true, passes with a NULL'::text description,
       TT_CountNotNull('{''a'',''b'',NULL}'::text, 2::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.10'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact true, empty true, passes with a NULL and an empty'::text description,
       TT_CountNotNull('{"",''b'',NULL}'::text, 1::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.11'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact true, empty true, fails with a NULL and an empty'::text description,
       TT_CountNotNull('{"",''b'',NULL}'::text, 2::text, TRUE::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '15.12'::text number,
       'TT_CountNotNull'::text function_tested,
       'test zero passes'::text description,
       TT_CountNotNull('{"","",NULL}'::text, 0::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.13'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact false, empty true, passes greater than'::text description,
       TT_CountNotNull('{''a'',''b'',''c''}'::text, 2::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.14'::text number,
       'TT_CountNotNull'::text function_tested,
       'exact false, empty true, passes with exact'::text description,
       TT_CountNotNull('{''a'',NULL,''c''}'::text, 2::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.15'::text number,
       'TT_CountNotNull'::text function_tested,
       'empty false, passes'::text description,
       TT_CountNotNull('{''a'',''b'',NULL}'::text, 2::text, TRUE::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.16'::text number,
       'TT_CountNotNull'::text function_tested,
       'empty false, fails'::text description,
       TT_CountNotNull('{''a'',''b'',""}'::text, 2::text, TRUE::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '15.17'::text number,
       'TT_CountNotNull'::text function_tested,
       'empty false, fails, test default 1'::text description,
       TT_CountNotNull('{''a'',''b'',""}'::text, 3::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.18'::text number,
       'TT_CountNotNull'::text function_tested,
       'empty false, fails, test default 2'::text description,
       TT_CountNotNull('{''a'',''b'',""}'::text, 3::text) passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 16 - TT_IsIntSubstring
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(16, 'TT_IsIntSubstring',
                                      ARRAY['start_char', 'int',
                                            'for_length', 'int',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '16.7'::text number,
       'TT_IsIntSubstring'::text function_tested,
       'NULL value'::text description,
       TT_IsIntSubstring(NULL::text, 4::text, 1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '16.8'::text number,
       'TT_IsIntSubstring'::text function_tested,
       'Good string'::text description,
       TT_IsIntSubstring('2001-01-02'::text, 1::text, 4::text) passed
---------------------------------------------------------
UNION ALL
SELECT '16.9'::text number,
       'TT_IsIntSubstring'::text function_tested,
       'Bad string'::text description,
       TT_IsIntSubstring('200-01-02'::text, 1::text, 4::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '16.10'::text number,
       'TT_IsIntSubstring'::text function_tested,
       'Test acceptNull'::text description,
       TT_IsIntSubstring(NULL::text, 1::text, 4::text, TRUE::text) passed
---------------------------------------------------------
-- Test 17 - TT_IsBetweenSubstring
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (14 tests)
SELECT (TT_TestNullAndWrongTypeParams(17, 'TT_IsBetweenSubstring',
                                      ARRAY['start_char', 'int',
                                            'for_length', 'int',
                                            'min', 'numeric',
                                            'max', 'numeric',
                                            'includeMin', 'boolean',
                                            'includeMax', 'boolean',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '17.15'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Pass test'::text description,
       TT_IsBetweenSubstring('2001-01-02'::text, 1::text, 4::text, 2000::text, 2002::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.16'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Fail test'::text description,
       TT_IsBetweenSubstring('200-01-02'::text, 1::text, 4::text, 2000::text, 2002::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.17'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Default include test'::text description,
       TT_IsBetweenSubstring('2001-01-02'::text, 1::text, 4::text, 2001::text, 2002::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.18'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Include false test'::text description,
       TT_IsBetweenSubstring('2001-01-02'::text, 1::text, 4::text, 2001::text, 2002::text, FALSE::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.19'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Test Null with acceptNull true'::text description,
       TT_IsBetweenSubstring(NULL::text, 1::text, 4::text, 2001::text, 2002::text, FALSE::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
-- Test 18 - TT_IsName
---------------------------------------------------------
UNION ALL
SELECT '18.1'::text number,
       'TT_IsName'::text function_tested,
       'basic name with underscore and accent'::text description,
       TT_IsName('my_tablée') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '18.2'::text number,
       'TT_IsName'::text function_tested,
       'basic invalid name'::text description,
       TT_IsName('1aa_') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '18.3'::text number,
       'TT_IsName'::text function_tested,
       'begin with underscore'::text description,
       TT_IsName('_1aa') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '18.4'::text number,
       'TT_IsName'::text function_tested,
       'underscore alone'::text description,
       TT_IsName('_') IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '18.5'::text number,
       'TT_IsName'::text function_tested,
       'with space'::text description,
       TT_IsName('my table') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '18.6'::text number,
       'TT_IsName'::text function_tested,
       'starting and ending with single quotes'::text description,
       TT_IsName('''mytable''') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '18.7'::text number,
       'TT_IsName'::text function_tested,
       'test TRUE'::text description,
       TT_IsName('true') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '18.8'::text number,
       'TT_IsName'::text function_tested,
       'test FALSE'::text description,
       TT_IsName('FALSE') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 19 - TT_MotMatchList
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(19, 'TT_NotMatchList', ARRAY['lst', 'stringlist',
                                                               'ignoreCase', 'boolean',
                                                                'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '19.7'::text number,
       'TT_NotMatchList'::text function_tested,
       'String good value'::text description,
       TT_NotMatchList('4'::text, '{''1'', ''2'', ''3''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.8'::text number,
       'TT_NotMatchList'::text function_tested,
       'String bad value'::text description,
       TT_NotMatchList('4'::text, '{''4'', ''5'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.9'::text number,
       'TT_NotMatchList'::text function_tested,
       'String Null val'::text description,
       TT_NotMatchList(NULL::text, '{''1'', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.10'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, empty string in list, good value'::text description,
       TT_NotMatchList('4'::text, '{''a'', ''2'', ''3'', ''1''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.11'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, empty string in list, bad value'::text description,
       TT_NotMatchList('2'::text, '{'''', ''2'', ''3'', ''1''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.12'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, val is empty string, good value'::text description,
       TT_NotMatchList(''::text, '{''4'', ''1'', ''2'', ''3''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.13'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, val is empty string, bad value'::text description,
       TT_NotMatchList(''::text, '{'''', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.14'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision good value'::text description,
       TT_NotMatchList(1.2::text, '{''1.5'', ''1.4'', ''1.6''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.15'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision bad value'::text description,
       TT_NotMatchList(1.4::text, '{''1.5'', ''1.4'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.16'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision empty string in list, good value'::text description,
       TT_NotMatchList(1.7::text, '{'''', ''1.5'', ''1.6''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.17'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision empty string in list, bad value'::text description,
       TT_NotMatchList(1.7::text, '{'''', ''1.7'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.18'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer good value'::text description,
       TT_NotMatchList(8::text, '{''5'', ''4'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '19.19'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer bad value'::text description,
       TT_NotMatchList(5::text, '{''5'', ''4'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.20'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer empty string in list, good value'::text description,
       TT_NotMatchList(1::text, '{'''', ''5'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '19.21'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer empty string in list, bad value'::text description,
       TT_NotMatchList(2::text, '{'''', ''2'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.22'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, true, val lower'::text description,
       TT_NotMatchList('a'::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.23'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, true, list lower'::text description,
       TT_NotMatchList('A'::text, '{''a'', ''b'', ''c''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.24'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, false, val lower'::text description,
       TT_NotMatchList('a'::text, '{''A'', ''B'', ''C''}'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.25'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, false, list lower'::text description,
       TT_NotMatchList('A'::text, '{''a'', ''b'', ''c''}'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.26'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision test ignore case TRUE'::text description,
       TT_NotMatchList(1.4::text, '{''1.5'', ''1.7'', ''1.6''}'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.27'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision test ignore case FALSE'::text description,
       TT_NotMatchList(1.4::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.28'::text number,
       'TT_NotMatchList'::text function_tested,
       'Tets NULL with acceptNull true'::text description,
       TT_NotMatchList(NULL::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text, TRUE::text) passed
  
	
---------------------------------------------------------
--------------- Translation functions -------------------
---------------------------------------------------------
-- Test 101 - TT_CopyText
---------------------------------------------------------
UNION ALL
SELECT '101.1'::text number,
       'TT_CopyText'::text function_tested,
       'Text usage'::text description,
       TT_CopyText('copytest'::text) = 'copytest'::text passed
---------------------------------------------------------
UNION ALL
SELECT '101.2'::text number,
       'TT_CopyText'::text function_tested,
       'Empty string usage'::text description,
       TT_CopyText(''::text) = ''::text passed
---------------------------------------------------------
UNION ALL
SELECT '101.3'::text number,
       'TT_CopyText'::text function_tested,
       'Null'::text description,
       TT_CopyText(NULL::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 102 - TT_CopyDouble
---------------------------------------------------------
UNION ALL
SELECT '102.1'::text number,
       'TT_CopyDouble'::text function_tested,
       'Double usage'::text description,
       TT_CopyDouble('1.111'::text) = 1.111::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '102.2'::text number,
       'TT_CopyDouble'::text function_tested,
       'Null'::text description,
       TT_CopyDouble(NULL::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 103 - TT_CopyInt
---------------------------------------------------------
UNION ALL
SELECT '103.1'::text number,
       'TT_CopyInt'::text function_tested,
       'Int usage'::text description,
       TT_CopyInt('1'::text) = 1::int passed
---------------------------------------------------------
UNION ALL
SELECT '103.2'::text number,
       'TT_CopyInt'::text function_tested,
       'Int usage from double with zero decimal'::text description,
       TT_CopyInt('1.0'::text) = 1::int passed
---------------------------------------------------------
UNION ALL
SELECT '103.3'::text number,
       'TT_CopyInt'::text function_tested,
       'Int usage from double with decimal round down'::text description,
       TT_CopyInt('1.2'::text) = 1::int passed
---------------------------------------------------------
UNION ALL
SELECT '103.4'::text number,
       'TT_CopyInt'::text function_tested,
       'Int usage from double with decimal round up'::text description,
       TT_CopyInt('1.5'::text) = 2::int passed
---------------------------------------------------------
UNION ALL
SELECT '103.5'::text number,
       'TT_CopyInt'::text function_tested,
       'Null'::text description,
       TT_CopyInt(NULL::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 104 - TT_LookupText
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (5 tests)
SELECT (TT_TestNullAndWrongTypeParams(104, 'TT_LookupText',
                                      ARRAY['lookupSchemaName', 'text',
                                            'lookupTableName', 'text',
                                            'lookupCol', 'text',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '104.6'::text number,
       'TT_LookupText'::text function_tested,
       'Text usage'::text description,
       TT_LookupText('a'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text) = 'ACB'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.7'::text number,
       'TT_LookupText'::text function_tested,
       'NULL val'::text description,
       TT_LookupText(NULL::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '104.8'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupText('A'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, TRUE::text) = 'ACB'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.9'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupText('A'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, FALSE::text) IS NULL passed
       UNION ALL
---------------------------------------------------------
SELECT '104.10'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, true flipped case'::text description,
       TT_LookupText('aa'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, TRUE::text) = 'abcde'::text passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 105 - TT_LookupDouble
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (5 tests)
SELECT (TT_TestNullAndWrongTypeParams(105, 'TT_LookupDouble',
                                      ARRAY['lookupSchemaName', 'text',
                                            'lookupTableName', 'text',
                                            'lookupCol', 'text',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '105.6'::text number,
       'TT_LookupDouble'::text function_tested,
       'Double precision usage'::text description,
       TT_LookupDouble('a'::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text) = 1.1::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '105.7'::text number,
       'TT_LookupDouble'::text function_tested,
       'NULL val'::text description,
       TT_LookupDouble(NULL::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '105.8'::text number,
       'TT_LookupDouble'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupDouble('A'::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text, TRUE::text) = 1.1 passed
---------------------------------------------------------
UNION ALL
SELECT '105.9'::text number,
       'TT_LookupDouble'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupDouble('A'::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 106 - TT_LookupInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (5 tests)
SELECT (TT_TestNullAndWrongTypeParams(106, 'TT_LookupInt',
                                      ARRAY['lookupSchemaName', 'text',
                                            'lookupTableName', 'text',
                                            'lookupCol', 'text',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '106.6'::text number,
       'TT_LookupInt'::text function_tested,
       'Int usage'::text description,
       TT_LookupInt('a'::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '106.7'::text number,
       'TT_LookupInt'::text function_tested,
       'NULL val'::text description,
       TT_LookupInt(NULL::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '106.8'::text number,
       'TT_LookupInt'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupInt('A'::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text, TRUE::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '106.9'::text number,
       'TT_LookupInt'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupInt('A'::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 107 - TT_MapText
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(107, 'TT_MapText',
                                      ARRAY['mapVals', 'stringlist',
                                            'targetVals', 'stringlist',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '107.7'::text number,
       'TT_MapText'::text function_tested,
       'Test text list, text list'::text description,
       TT_MapText('A'::text, '{''A'',''B'',''C'',''D''}'::text, '{''a'',''b'',''c'',''d''}'::text) = 'a'::text passed
---------------------------------------------------------
UNION ALL
SELECT '107.8'::text number,
       'TT_MapText'::text function_tested,
       'Test double precision list, text list'::text description,
       TT_MapText(1.1::text, '{''1.1'',''1.2'',''1.3'',''1.4''}'::text, '{''A'',''B'',''C'',''D''}'::text) = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '107.9'::text number,
       'TT_MapText'::text function_tested,
       'Test int list, text list'::text description,
       TT_MapText(2::text, '{''1'',''2'',''3'',''4''}'::text, '{''A'',''B'',''C'',''D''}'::text) = 'B' passed
---------------------------------------------------------
UNION ALL
SELECT '107.10'::text number,
       'TT_MapText'::text function_tested,
       'Test Null val'::text description,
       TT_IsError('SELECT TT_MapText(NULL::text, ''{''A'',''B'',''C'',''D''}''::text, ''{''a'',''b'',''c'',''d''}''::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '107.11'::text number,
       'TT_MapText'::text function_tested,
       'Test caseIgnore, true'::text description,
       TT_MapText('a'::text, '{''A'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text, TRUE::text) = 'aa' passed
---------------------------------------------------------
UNION ALL
SELECT '107.12'::text number,
       'TT_MapText'::text function_tested,
       'Test caseIgnore, false'::text description,
       TT_MapText('a'::text, '{''A'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '107.13'::text number,
       'TT_MapText'::text function_tested,
       'Test multiple vals'::text description,
       TT_MapText('{A, B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text) = 'aa' passed
---------------------------------------------------------
UNION ALL
SELECT '107.14'::text number,
       'TT_MapText'::text function_tested,
       'Test single val in stringlist format'::text description,
       TT_MapText('{B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text) = 'bb' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 108 - TT_MapDouble
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(108, 'TT_MapDouble',
                                      ARRAY['mapVals', 'stringlist',
                                            'targetVals', 'doublelist',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '108.7'::text number,
       'TT_MapDouble'::text function_tested,
       'Test text list, double precision list'::text description,
       TT_MapDouble('A'::text, '{''A'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '1.1'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.8'::text number,
       'TT_MapDouble'::text function_tested,
       'Test double precision list, double precision list'::text description,
       TT_MapDouble(1.1::text, '{''1.1'',''1.2'',''1.3'',''1.4''}'::text, '{''1.11'',''2.22'',''3.33'',''4.44''}'::text) = '1.11'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.9'::text number,
       'TT_MapDouble'::text function_tested,
       'Test int list, double precision list'::text description,
       TT_MapDouble(2::text, '{''1'',''2'',''3'',''4''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '2.2'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.10'::text number,
       'TT_MapDouble'::text function_tested,
       'Test Null val'::text description,
       TT_IsError('SELECT TT_MapDouble(NULL::text, ''{''1'',''2'',''3'',''4''}''::text, ''{''1.1'',''2.2'',''3.3'',''4.4''}''::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '108.11'::text number,
       'TT_MapDouble'::text function_tested,
       'Test multiple vals'::text description,
       TT_MapDouble('{A, B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '1.1'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.12'::text number,
       'TT_MapDouble'::text function_tested,
       'Test single val in stringlist format'::text description,
       TT_MapDouble('{B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '2.2'::double precision passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 109 - TT_MapInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(109, 'TT_MapInt',
                                      ARRAY['mapVals', 'stringlist',
                                            'targetVals', 'intlist',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '109.7'::text number,
       'TT_MapInt'::text function_tested,
       'Test text list, int list'::text description,
       TT_MapInt('A'::text, '{''A'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '1'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.8'::text number,
       'TT_MapInt'::text function_tested,
       'Test double precision list, int list'::text description,
       TT_MapInt(1.1::text, '{''1.1'',''1.2'',''1.3'',''1.4''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '1'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.9'::text number,
       'TT_MapInt'::text function_tested,
       'Test int list, int list'::text description,
       TT_MapInt(2::text, '{''1'',''2'',''3'',''4''}'::text, '{''5'',''6'',''7'',''8''}'::text) = '6'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.10'::text number,
       'TT_MapInt'::text function_tested,
       'Test Null val'::text description,
       TT_IsError('SELECT TT_MapInt(NULL::text, ''{''1'',''2'',''3'',''4''}''::text, ''{''5'',''6'',''7'',''8''}''::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '109.11'::text number,
       'TT_MapInt'::text function_tested,
       'Test multiple vals'::text description,
       TT_MapInt('{A, B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '1'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.12'::text number,
       'TT_MapInt'::text function_tested,
       'Test single val in stringlist format'::text description,
       TT_MapInt('{B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '2'::int passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 110 - TT_Pad
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(110, 'TT_Pad',
                                      ARRAY['targetLength', 'int',
                                            'padChar', 'char',
                                            'trunc', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '110.5'::text number,
       'TT_Pad'::text function_tested,
       'Basic test'::text description,
       TT_Pad('species1'::text, 10::text, 'X'::text) = 'XXspecies1' passed
---------------------------------------------------------
UNION ALL
SELECT '110.6'::text number,
       'TT_Pad'::text function_tested,
       'Basic int test'::text description,
       TT_Pad(12345::text, 10::text, '0'::text) = '0000012345' passed
---------------------------------------------------------
UNION ALL
SELECT '110.7'::text number,
       'TT_Pad'::text function_tested,
       'Basic double precision test'::text description,
       TT_Pad(1.234::text, 10::text, '0'::text) = '000001.234' passed
---------------------------------------------------------
UNION ALL
SELECT '110.8'::text number,
       'TT_Pad'::text function_tested,
       'Empty string'::text description,
       TT_Pad(''::text, 10::text, 'x'::text) = 'xxxxxxxxxx' passed
---------------------------------------------------------
UNION ALL
SELECT '110.9'::text number,
       'TT_Pad'::text function_tested,
       'String longer than pad length, trunc TRUE'::text description,
       TT_Pad('123456'::text, 5::text, '0'::text) = '12345' passed
---------------------------------------------------------
UNION ALL
SELECT '110.10'::text number,
       'TT_Pad'::text function_tested,
       'String longer than pad length, trunc FALSE'::text description,
       TT_Pad('123456'::text, 5::text, '0'::text, FALSE::text) = '123456' passed
---------------------------------------------------------
UNION ALL
SELECT '110.11'::text number,
       'TT_Pad'::text function_tested,
       'Int longer than pad length'::text description,
       TT_Pad(123456789::text, 5::text, 'x'::text) = '12345' passed
---------------------------------------------------------
UNION ALL
SELECT '110.12'::text number,
       'TT_Pad'::text function_tested,
       'Test, double precision, trim'::text description,
       TT_Pad(1.3456789::text, 5::text, 'x'::text) = '1.345' passed
---------------------------------------------------------
UNION ALL
SELECT '110.13'::text number,
       'TT_Pad'::text function_tested,
       'Test default, int'::text description,
       TT_Pad(12345678::text, 10::text, 'x'::text) = 'xx12345678' passed
---------------------------------------------------------
UNION ALL
SELECT '110.14'::text number,
       'TT_Pad'::text function_tested,
       'Test default, double precision'::text description,
       TT_Pad(1.345678::text, 5::text, 'x'::text) = '1.345' passed
---------------------------------------------------------
UNION ALL
SELECT '110.15'::text number,
       'TT_Pad'::text function_tested,
       'Test error, pad_char > 1'::text description,
       TT_IsError('SELECT TT_Pad(1::text, 10::text, ''22''::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '110.16'::text number,
       'TT_Pad'::text function_tested,
       'Test error, null val'::text description,
       TT_Pad(NULL::text, 3::text, 'x'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '110.17'::text number,
       'TT_Pad'::text function_tested,
       'Test negative padding length'::text description,
       TT_IsError('SELECT TT_Pad(''aaa''::text, ''-3''::text, ''x''::text)'::text) = 'ERROR in TT_Pad(): targetLength is smaller than 0' passed
---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
-- Test 111 - TT_Concat
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(111, 'TT_Concat',
                                      ARRAY['sep', 'text'])).*
---------------------------------------------------------
UNION ALL
SELECT '111.2'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage'::text description,
       TT_Concat('{''cas'', ''id'', ''test''}'::text, '-'::text) = 'cas-id-test' passed
---------------------------------------------------------
UNION ALL
SELECT '111.3'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage with numbers and symbols'::text description,
       TT_Concat('{''001'', ''--0--'', ''tt.tt''}'::text, '-'::text) = '001---0---tt.tt' passed
---------------------------------------------------------
UNION ALL
SELECT '111.4'::text number,
       'TT_Concat'::text function_tested,
       'Sep is null'::text description,
       TT_IsError('SELECT TT_Concat(''{''''cas'''', ''''id'''', ''''test''''}''::text, NULL::text);') != 'FALSE' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 112 - TT_PadConcat
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(112, 'TT_PadConcat',
                                      ARRAY['length', 'intlist',
                                            'pad', 'charlist',
                                            'sep', 'char',
                                            'upperCase', 'boolean',
                                            'includeEmpty', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '112.11'::text number,
       'TT_PadConcat'::text function_tested,
       'Test with spaces and uppercase'::text description,
       TT_PadConcat('{''ab06'', ''GB_S21_TWP'', ''81145'', ''811451038'', ''1''}', '{''4'', ''15'', ''10'', ''10'', ''7''}', '{''x'', ''x'', ''x'', ''0'', ''0''}'::text, '-'::text, TRUE::text) = 'AB06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.12'::text number,
       'TT_PadConcat'::text function_tested,
       'Test without spaces and not uppercase'::text description,
       TT_PadConcat('{''ab06'', ''GB_S21_TWP'', ''81145'', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, FALSE::text) = 'ab06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.13'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty value'::text description,
       TT_PadConcat('{''ab06'', '''', ''81145'', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, FALSE::text) = 'ab06-xxxxxxxxxxxxxxx-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.14'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty length'::text description,
       TT_IsError('SELECT TT_PadConcat(''{''ab06'', '''', ''81145'', ''811451038'', ''1''}'', ''{''4'',''15'','''',''10'',''7''}'', ''{''x'',''x'',''x'',''0'',''0''}''::text, ''-''::text, FALSE::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '112.15'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty pad'::text description,
       TT_IsError('SELECT TT_PadConcat(''{''ab06'', '''', ''81145'', ''811451038'', ''1''}'', ''{''4'',''15'',''10'',''10'',''7''}'', ''{''x'','''',''x'',''0'',''0''}''::text, ''-''::text, FALSE::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '112.16'::text number,
       'TT_PadConcat'::text function_tested,
       'Uneven val, length, pad strings'::text description,
       TT_IsError('SELECT TT_PadConcat(''{''ab06'', '''', ''81145'', ''811451038''}'', ''{''4'',''15'',''10'',''10'',''7''}'', ''{''x'','''',''x'',''0'',''0''}''::text, ''-''::text, FALSE::text);') != 'FALSE' passed
---------------------------------------------------------
UNION ALL
SELECT '112.17'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty value, includeEmpty FALSE'::text description,
       TT_PadConcat('{''ab06'', '''', ''81145'', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, TRUE::text, FALSE::text) = 'AB06-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.18'::text number,
       'TT_PadConcat'::text function_tested,
       'Zero length'::text description,
       TT_PadConcat('{''ab06'', ''GB_S21_TWP'', ''81145'', ''811451038'', ''1''}', '{''4'',''0'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, FALSE::text) = 'ab06--xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 118 - TT_NothingText
---------------------------------------------------------
UNION ALL
SELECT '118.1'::text number,
       'TT_NothingText'::text function_tested,
       'Simple test'::text description,
       TT_NothingText() IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 119 - TT_NothingDouble
---------------------------------------------------------
UNION ALL
SELECT '119.1'::text number,
       'TT_NothingDouble'::text function_tested,
       'Simple test'::text description,
       TT_NothingDouble() IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 120 - TT_NothingInt
---------------------------------------------------------
UNION ALL
SELECT '120.1'::text number,
       'TT_NothingInt'::text function_tested,
       'Simple test'::text description,
       TT_NothingInt() IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 121 - TT_NumberOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '121.1'::text number,
       'TT_NumberOfNotNull'::text function_tested,
       'Simple test'::text description,
       TT_NumberOfNotNull('{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 7::text) = 7 passed
---------------------------------------------------------
UNION ALL
SELECT '121.2'::text number,
       'TT_NumberOfNotNull'::text function_tested,
       'Lower max_return_val'::text description,
       TT_NumberOfNotNull('{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 1::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '121.3'::text number,
       'TT_NumberOfNotNull'::text function_tested,
       'Some NULLs and empties, '::text description,
       TT_NumberOfNotNull('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 7::text) = 5 passed
---------------------------------------------------------
UNION ALL
SELECT '121.4'::text number,
       'TT_NumberOfNotNull'::text function_tested,
       'Fewer arguments, '::text description,
       TT_NumberOfNotNull('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  7::text) = 2 passed
---------------------------------------------------------
) AS b
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed OR passed IS NULL
-- Comment out this line to display only test number
--OR ((regexp_split_to_array(number, '\.'))[1])::int = 12
;
