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

        EXECUTE query INTO passed;
        RETURN NEXT;
      END IF;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql STABLE;
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
-----------------------------------------------------------
DROP TABLE IF EXISTS index_test_table;
CREATE TABLE index_test_table AS
SELECT 'burn'::text source_val, 'BU'::text text_val
UNION ALL
SELECT 'wind'::text, 'WT'::text;
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
    SELECT 'TT_NotNull'::text function_tested, 1 maj_num, 14 nb_test UNION ALL
    SELECT 'TT_NotEmpty'::text,                2,         16         UNION ALL
    SELECT 'TT_Length'::text,                  3,          5         UNION ALL
    SELECT 'TT_IsInt'::text,                   4,         12         UNION ALL
    SELECT 'TT_IsNumeric'::text,               5,          8         UNION ALL
    SELECT 'TT_IsBoolean'::text,               6,          8         UNION ALL
    SELECT 'TT_IsBetween'::text,               7,         31         UNION ALL
    SELECT 'TT_IsGreaterThan'::text,           8,         13         UNION ALL
    SELECT 'TT_IsLessThan'::text,              9,         13         UNION ALL
    SELECT 'TT_IsUnique'::text,               10,         21         UNION ALL
    SELECT 'TT_MatchTable'::text,             11,         20         UNION ALL
    SELECT 'TT_MatchList'::text,              12,         38         UNION ALL
    SELECT 'TT_False'::text,                  13,          1         UNION ALL
    SELECT 'TT_True'::text,                   14,          1         UNION ALL
    SELECT 'TT_HasCountOfNotNull'::text,      15,         10         UNION ALL
    SELECT 'TT_IsIntSubstring'::text,         16,         10         UNION ALL
    SELECT 'TT_IsBetweenSubstring'::text,     17,         23         UNION ALL
    SELECT 'TT_IsName'::text,                 18,          8         UNION ALL
	  SELECT 'TT_NotMatchList'::text,           19,         30         UNION ALL
    SELECT 'TT_MatchListSubstring'::text,     20,         18         UNION ALL
    SELECT 'TT_HasLength'::text,              21,          6         UNION ALL
    SELECT 'TT_SumIntMatchList'::text,        22,         10         UNION ALL
    SELECT 'TT_LengthMatchList'::text,        23,         19         UNION ALL
    SELECT 'TT_minIndexNotNull'::text,        24,          6         UNION ALL
    SELECT 'TT_maxIndexNotNull'::text,        25,          6         UNION ALL
    -- Translation functions
    SELECT 'TT_CopyText'::text,              101,          3         UNION ALL
    SELECT 'TT_CopyDouble'::text,            102,          2         UNION ALL
    SELECT 'TT_CopyInt'::text,               103,          5         UNION ALL
    SELECT 'TT_LookupText'::text,            104,         17         UNION ALL
    SELECT 'TT_LookupDouble'::text,          105,         14         UNION ALL
    SELECT 'TT_LookupInt'::text,             106,         14         UNION ALL
    SELECT 'TT_MapText'::text,               107,         19         UNION ALL
    SELECT 'TT_MapDouble'::text,             108,         16         UNION ALL
    SELECT 'TT_MapInt'::text,                109,         16         UNION ALL
    SELECT 'TT_Pad'::text,                   110,         17         UNION ALL
    SELECT 'TT_Concat'::text,                111,          4         UNION ALL
    SELECT 'TT_PadConcat'::text,             112,         16         UNION ALL
    SELECT 'TT_NothingText'::text,           118,          1         UNION ALL
    SELECT 'TT_NothingDouble'::text,         119,          1         UNION ALL
    SELECT 'TT_NothingInt'::text,            120,          1         UNION ALL
	  SELECT 'TT_CountOfNotNull'::text,        121,          6         UNION ALL
    SELECT 'TT_IfElseCountOfNotNullText'::text,122,        4         UNION ALL
    SELECT 'TT_SubstringText'::text,         123,         10         UNION ALL
    SELECT 'TT_SubstringInt'::text,          124,          2         UNION ALL
    SELECT 'TT_MapSubstringText'::text,      125,         12         UNION ALL
    SELECT 'TT_SumIntMapText'::text,         126,          7         UNION ALL
    SELECT 'TT_LengthMapInt'::text,          127,          8         UNION ALL
    SELECT 'TT_IfElseCountOfNotNullInt'::text,128,         4         UNION ALL
    SELECT 'TT_XMinusYInt'::text,            129,          3         UNION ALL
    SELECT 'TT_MinInt'::text,                130,          3         UNION ALL
    SELECT 'TT_MaxInt'::text,                131,          3         UNION ALL
    SELECT 'TT_MinIndexCopyText'::text,      132,          6         UNION ALL
    SELECT 'TT_MaxIndexCopyText'::text,      133,          6         UNION ALL
    SELECT 'TT_MinIndexMapText'::text,       134,          8         UNION ALL
    SELECT 'TT_MaxIndexMapText'::text,       135,          8         UNION ALL
    SELECT 'TT_MinIndexLookupText'::text,    136,         12         UNION ALL
    SELECT 'TT_MaxIndexLookupText'::text,    137,         12
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
UNION ALL
SELECT '1.12'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with one NULL and any = TRUE'::text description,
       TT_NotNull('{''a'',NULL}'::text, 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '1.13'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list with all NULL and any = TRUE'::text description,
       TT_NotNull('{NULL,NULL}'::text, 'TRUE') = FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.14'::text number,
       'TT_NotNull'::text function_tested,
       'Test string list no NULLs and any = TRUE'::text description,
       TT_NotNull('{''a'',''b''}'::text, 'TRUE') passed
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
UNION ALL
SELECT '2.12'::text number,
       'TT_NotEmpty'::text function_tested,
       'multiple strings'::text description,
       TT_NotEmpty('{'' a'', ''b''}') passed
---------------------------------------------------------
UNION ALL
SELECT '2.13'::text number,
       'TT_NotEmpty'::text function_tested,
       'multiple strings'::text description,
       TT_NotEmpty('{'' '', ''  ''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.14'::text number,
       'TT_NotEmpty'::text function_tested,
       'multiple strings'::text description,
       TT_NotEmpty('{'' '', ''  '', NULL}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.15'::text number,
       'TT_NotEmpty'::text function_tested,
       'multiple strings, any false'::text description,
       TT_NotEmpty('{'' '', ''a''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.16'::text number,
       'TT_NotEmpty'::text function_tested,
       'multiple strings, any true'::text description,
       TT_NotEmpty('{'' '', ''a''}', TRUE::text) passed
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
                                      ARRAY['lookupSchemaName', 'name',
                                            'lookupTableName', 'name',
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
SELECT (TT_TestNullAndWrongTypeParams(11, 'TT_MatchTable', ARRAY['lookupSchemaName', 'name',
                                                                 'lookupTableName', 'name',
                                                                 'lookupColumnName', 'name',
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
-- Test 12 - TT_MatchList
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (8 tests)
SELECT (TT_TestNullAndWrongTypeParams(12, 'TT_MatchList', ARRAY['lst', 'stringlist',
                                                               'ignoreCase', 'boolean',
                                                                'acceptNull', 'boolean',
															                                  'matches', 'boolean',
                                                                'removeSpaces', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '12.11'::text number,
       'TT_MatchList'::text function_tested,
       'String good value'::text description,
       TT_MatchList('1'::text, '{''1'', ''2'', ''3''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.12'::text number,
       'TT_MatchList'::text function_tested,
       'String bad value'::text description,
       TT_MatchList('1'::text, '{''4'', ''5'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.13'::text number,
       'TT_MatchList'::text function_tested,
       'String Null val'::text description,
       TT_MatchList(NULL::text, '{''1'', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.14'::text number,
       'TT_MatchList'::text function_tested,
       'String, empty string in list, good value'::text description,
       TT_MatchList('1'::text, '{''a'', ''2'', ''3'', ''1''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.15'::text number,
       'TT_MatchList'::text function_tested,
       'String, empty string in list, bad value'::text description,
       TT_MatchList('4'::text, '{'''', ''2'', ''3'', ''1''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.16'::text number,
       'TT_MatchList'::text function_tested,
       'String, val is empty string, good value'::text description,
       TT_MatchList(''::text, '{'''', ''1'', ''2'', ''3''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.17'::text number,
       'TT_MatchList'::text function_tested,
       'String, val is empty string, bad value'::text description,
       TT_MatchList(''::text, '{''1'', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.18'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision good value'::text description,
       TT_MatchList(1.5::text, '{''1.5'', ''1.4'', ''1.6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.19'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision bad value'::text description,
       TT_MatchList(1.1::text, '{''1.5'', ''1.4'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.20'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision empty string in list, good value'::text description,
       TT_MatchList(1.5::text, '{'''', ''1.5'', ''1.6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.21'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision empty string in list, bad value'::text description,
       TT_MatchList(1.5::text, '{'''', ''1.7'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.22'::text number,
       'TT_MatchList'::text function_tested,
       'Integer good value'::text description,
       TT_MatchList(5::text, '{''5'', ''4'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.23'::text number,
       'TT_MatchList'::text function_tested,
       'Integer bad value'::text description,
       TT_MatchList(1::text, '{''5'', ''4'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.24'::text number,
       'TT_MatchList'::text function_tested,
       'Integer empty string in list, good value'::text description,
       TT_MatchList(5::text, '{'''', ''5'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.25'::text number,
       'TT_MatchList'::text function_tested,
       'Integer empty string in list, bad value'::text description,
       TT_MatchList(1::text, '{'''', ''2'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.26'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, true, val lower'::text description,
       TT_MatchList('a'::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.27'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, true, list lower'::text description,
       TT_MatchList('A'::text, '{''a'', ''b'', ''c''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.28'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, false, val lower'::text description,
       TT_MatchList('a'::text, '{''A'', ''B'', ''C''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.29'::text number,
       'TT_MatchList'::text function_tested,
       'Test ignoreCase, false, list lower'::text description,
       TT_MatchList('A'::text, '{''a'', ''b'', ''c''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.30'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision test ignore case TRUE'::text description,
       TT_MatchList(1.5::text, '{''1.5'', ''1.7'', ''1.6''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '12.31'::text number,
       'TT_MatchList'::text function_tested,
       'Double precision test ignore case FALSE'::text description,
       TT_MatchList(1.5::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '12.32'::text number,
       'TT_MatchList'::text function_tested,
       'Tets NULL with acceptNull true'::text description,
       TT_MatchList(NULL::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.33'::text number,
       'TT_MatchList'::text function_tested,
       'Test concatenating input vals'::text description,
       TT_MatchList('{''A'', ''B''}', '{''AB'', ''BA'', ''CC''}'::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.34'::text number,
       'TT_MatchList'::text function_tested,
       'Test string with space and character and no brackets'::text description,
       TT_MatchList(' 0', '{''0'', ''BA'', ''CC''}'::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.35'::text number,
       'TT_MatchList'::text function_tested,
       'Test string with space and no brackets, remove_spaces false'::text description,
       TT_MatchList(' ', '{'' '', ''BA'', ''CC''}'::text, FALSE::text, TRUE::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.36'::text number,
       'TT_MatchList'::text function_tested,
       'Test string with space and no brackets, remove spaces true'::text description,
       TT_MatchList(' ', '{'''', ''BA'', ''CC''}'::text, FALSE::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.37'::text number,
       'TT_MatchList'::text function_tested,
       'Two strings, remove spaces true'::text description,
       TT_MatchList('{'' B '', ''A''}', '{'' B A'', ''BB'', ''CC''}'::text, FALSE::text, TRUE::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.38'::text number,
       'TT_MatchList'::text function_tested,
       'Two strings, remove spaces true'::text description,
       TT_MatchList('{'' B '', ''A''}', '{''BA'', ''BB'', ''CC''}'::text, FALSE::text, TRUE::text, TRUE::text) passed
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
-- Test 15 - TT_HasCountOfNotNull
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(15, 'TT_HasCountOfNotNull',
                                      ARRAY['count', 'int',
                                            'exact', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '15.5'::text number,
       'TT_HasCountOfNotNull'::text function_tested,
       'exact true'::text description,
       TT_HasCountOfNotNull('{''a''}'::text, '{''a''}'::text, 2::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.6'::text number,
       'TT_HasCountOfNotNull'::text function_tested,
       'exact false, passes'::text description,
       TT_HasCountOfNotNull('{''a''}'::text, '{''a''}'::text, 1::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.7'::text number,
       'TT_HasCountOfNotNull'::text function_tested,
       'exact true, fails'::text description,
       TT_HasCountOfNotNull('{''a''}'::text, '{''a''}'::text, 1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '15.8'::text number,
       'TT_HasCountOfNotNull'::text function_tested,
       'exact false, fails'::text description,
       TT_HasCountOfNotNull('{''a''}'::text, '{''a''}'::text, 3::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '15.9'::text number,
       'TT_HasCountOfNotNull'::text function_tested,
       'passes with nulls'::text description,
       TT_HasCountOfNotNull('{''a''}'::text, '{''a''}'::text, NULL, 2::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '15.10'::text number,
       'TT_HasCountOfNotNull'::text function_tested,
       'fails with nulls'::text description,
       TT_HasCountOfNotNull('{''a''}'::text, '{''a''}'::text, NULL, 1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------

---------------------------------------------------------
-- Test 16 - TT_IsIntSubstring
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(16, 'TT_IsIntSubstring',
                                      ARRAY['startChar', 'int',
                                            'forLength', 'int',
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
-- test all NULLs and wrong types (16 tests)
SELECT (TT_TestNullAndWrongTypeParams(17, 'TT_IsBetweenSubstring',
                                      ARRAY['startChar', 'int',
                                            'forLength', 'int',
                                            'min', 'numeric',
                                            'max', 'numeric',
                                            'includeMin', 'boolean',
                                            'includeMax', 'boolean',
                                            'removeSpaces', 'boolean',
                                            'acceptNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '17.17'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Pass test'::text description,
       TT_IsBetweenSubstring('2001-01-02'::text, 1::text, 4::text, 2000::text, 2002::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.18'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Fail test'::text description,
       TT_IsBetweenSubstring('200-01-02'::text, 1::text, 4::text, 2000::text, 2002::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.19'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Default include test'::text description,
       TT_IsBetweenSubstring('2001-01-02'::text, 1::text, 4::text, 2001::text, 2002::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.20'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Include false test'::text description,
       TT_IsBetweenSubstring('2001-01-02'::text, 1::text, 4::text, 2001::text, 2002::text, FALSE::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '17.21'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Test Null with acceptNull true'::text description,
       TT_IsBetweenSubstring(NULL::text, 1::text, 4::text, 2001::text, 2002::text, FALSE::text, FALSE::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.22'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Test removeSpaces FALSE'::text description,
       TT_IsBetweenSubstring('  200b'::text, 1::text, 4::text, 19::text, 21::text, FALSE::text, FALSE::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '17.23'::text number,
       'TT_IsBetweenSubstring'::text function_tested,
       'Test removeSpaces TRUE'::text description,
       TT_IsBetweenSubstring('  200b'::text, 1::text, 4::text, 19::text, 21::text, FALSE::text, FALSE::text, TRUE::text) IS FALSE passed
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
                                                                'acceptNull', 'boolean',
                                                                'removeSpaces', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '19.9'::text number,
       'TT_NotMatchList'::text function_tested,
       'String good value'::text description,
       TT_NotMatchList('4'::text, '{''1'', ''2'', ''3''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.10'::text number,
       'TT_NotMatchList'::text function_tested,
       'String bad value'::text description,
       TT_NotMatchList('4'::text, '{''4'', ''5'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.11'::text number,
       'TT_NotMatchList'::text function_tested,
       'String Null val'::text description,
       TT_NotMatchList(NULL::text, '{''1'', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.12'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, empty string in list, good value'::text description,
       TT_NotMatchList('4'::text, '{''a'', ''2'', ''3'', ''1''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.13'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, empty string in list, bad value'::text description,
       TT_NotMatchList('2'::text, '{'''', ''2'', ''3'', ''1''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.14'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, val is empty string, good value'::text description,
       TT_NotMatchList(''::text, '{''4'', ''1'', ''2'', ''3''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.15'::text number,
       'TT_NotMatchList'::text function_tested,
       'String, val is empty string, bad value'::text description,
       TT_NotMatchList(''::text, '{'''', ''2'', ''3''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.16'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision good value'::text description,
       TT_NotMatchList(1.2::text, '{''1.5'', ''1.4'', ''1.6''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.17'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision bad value'::text description,
       TT_NotMatchList(1.4::text, '{''1.5'', ''1.4'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.18'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision empty string in list, good value'::text description,
       TT_NotMatchList(1.7::text, '{'''', ''1.5'', ''1.6''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.19'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision empty string in list, bad value'::text description,
       TT_NotMatchList(1.7::text, '{'''', ''1.7'', ''1.6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.20'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer good value'::text description,
       TT_NotMatchList(8::text, '{''5'', ''4'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '19.21'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer bad value'::text description,
       TT_NotMatchList(5::text, '{''5'', ''4'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.22'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer empty string in list, good value'::text description,
       TT_NotMatchList(1::text, '{'''', ''5'', ''6''}'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '19.23'::text number,
       'TT_NotMatchList'::text function_tested,
       'Integer empty string in list, bad value'::text description,
       TT_NotMatchList(2::text, '{'''', ''2'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.24'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, true, val lower'::text description,
       TT_NotMatchList('a'::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.25'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, true, list lower'::text description,
       TT_NotMatchList('A'::text, '{''a'', ''b'', ''c''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.26'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, false, val lower'::text description,
       TT_NotMatchList('a'::text, '{''A'', ''B'', ''C''}'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.27'::text number,
       'TT_NotMatchList'::text function_tested,
       'Test ignoreCase, false, list lower'::text description,
       TT_NotMatchList('A'::text, '{''a'', ''b'', ''c''}'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.28'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision test ignore case TRUE'::text description,
       TT_NotMatchList(1.4::text, '{''1.5'', ''1.7'', ''1.6''}'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '19.29'::text number,
       'TT_NotMatchList'::text function_tested,
       'Double precision test ignore case FALSE'::text description,
       TT_NotMatchList(1.4::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '19.30'::text number,
       'TT_NotMatchList'::text function_tested,
       'Tets NULL with acceptNull true'::text description,
       TT_NotMatchList(NULL::text, '{''1.4'', ''1.7'', ''1.6''}'::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
-- Test 20 - TT_MatchListSubstring
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (12 tests)
SELECT (TT_TestNullAndWrongTypeParams(20, 'TT_MatchListSubstring', ARRAY['startChar', 'int',
                                                                'forLength', 'int',
                                                                'lst', 'stringlist',
                                                                'ignoreCase', 'boolean',
                                                                'removeSpaces', 'boolean',
                                                                'acceptNull', 'boolean'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '20.13'::text number,
       'TT_MatchListSubstring'::text function_tested,
       'Matches'::text description,
       TT_MatchListSubstring('4321'::text, '4', '1', '{''1'', ''5'', ''6''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '20.14'::text number,
       'TT_MatchListSubstring'::text function_tested,
       'Matches with stringlist vals'::text description,
       TT_MatchListSubstring('{''4321'', ''abcd''}'::text, '3', '2', '{''21cd'', ''xx'', ''6''}'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '20.15'::text number,
       'TT_MatchListSubstring'::text function_tested,
       'Test NULL'::text description,
       TT_MatchListSubstring(NULL::text, '3', '2', '{''21cd'', ''xx'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.16'::text number,
       'TT_MatchListSubstring'::text function_tested,
       'Test not in set'::text description,
       TT_MatchListSubstring('4444', '1', '2', '{''21cd'', ''xx'', ''6''}'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.17'::text number,
       'TT_MatchListSubstring'::text function_tested,
       'Test removeSpaces FALSE'::text description,
       TT_MatchListSubstring('  4444', '1', '4', '{''  44'', ''xx'', ''6''}'::text, FALSE::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '20.18'::text number,
       'TT_MatchListSubstring'::text function_tested,
       'Test removeSpaces TRUE'::text description,
       TT_MatchListSubstring('  4444', '1', '4', '{''4444'', ''xx'', ''6''}'::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
-- Test 21 - TT_HasLength
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(21, 'TT_HasLength', ARRAY['length_test', 'int',
                                                                'acceptNull', 'boolean'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '21.5'::text number,
       'TT_HasLength'::text function_tested,
       'TRUE test'::text description,
       TT_HasLength('4321'::text, '4') passed
---------------------------------------------------------
UNION ALL
SELECT '21.6'::text number,
       'TT_HasLength'::text function_tested,
       'FALSE test'::text description,
       TT_HasLength('43215'::text, '4') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 22 - TT_SumIntMatchList
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(22, 'TT_SumIntMatchList', ARRAY['lst', 'stringlist',
                                                                'acceptNull', 'boolean',
                                                                'matches', 'boolean'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '22.7'::text number,
       'TT_SumIntMatchList'::text function_tested,
       'Passes test'::text description,
       TT_SumIntMatchList('{11,12,13}'::text, '{36,37}') passed
---------------------------------------------------------
UNION ALL
SELECT '22.8'::text number,
       'TT_SumIntMatchList'::text function_tested,
       'Fails test'::text description,
       TT_SumIntMatchList('{11,12,13}'::text, '{37}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '22.9'::text number,
       'TT_SumIntMatchList'::text function_tested,
       'Null source test'::text description,
       TT_SumIntMatchList(NULL, '{37}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '22.10'::text number,
       'TT_SumIntMatchList'::text function_tested,
       'not int'::text description,
       TT_SumIntMatchList('{a,2}', '{37}') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 23 - TT_LengthMatchList
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (10 tests)
SELECT (TT_TestNullAndWrongTypeParams(23, 'TT_LengthMatchList', ARRAY['lst', 'stringlist',
                                                                'trim_', 'boolean',
                                                                'removeSpaces', 'boolean',
                                                                'acceptNull', 'boolean',
                                                                'matches', 'boolean'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '23.11'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Passes basic test'::text description,
       TT_LengthMatchList('1234'::text, '{4,5,6}') passed
---------------------------------------------------------
UNION ALL
SELECT '23.12'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Passes with lst having no brackets'::text description,
       TT_LengthMatchList('1234'::text, '4') passed
---------------------------------------------------------
UNION ALL
SELECT '23.13'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Fails basic test'::text description,
       TT_LengthMatchList('1234'::text, '{5,6}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '23.14'::text number,
       'TT_LengthMatchList'::text function_tested,
       'NULL fails'::text description,
       TT_LengthMatchList(NULL, '{5,6}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '23.15'::text number,
       'TT_LengthMatchList'::text function_tested,
       'NULL passes with acceptNull test'::text description,
       TT_LengthMatchList(NULL, '{5,6}', FALSE::text, FALSE::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '23.16'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Passes basic test with trim'::text description,
       TT_LengthMatchList(' 1234 '::text, '{4}', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '23.17'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Passes basic test with trim'::text description,
       TT_LengthMatchList(' 1234 '::text, '{4}', 'FALSE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '23.18'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Passes basic test with removeSpaces'::text description,
       TT_LengthMatchList(' 1234 '::text, '{4}', 'FALSE', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '23.19'::text number,
       'TT_LengthMatchList'::text function_tested,
       'Passes basic test with removeSpaces even when trim is true and would fail'::text description,
       TT_LengthMatchList(' 12  34 '::text, '{4}', 'TRUE', 'TRUE') passed
---------------------------------------------------------
-- Test 24 - TT_minIndexNotNull
---------------------------------------------------------
UNION ALL
SELECT '24.1'::text number,
       'TT_minIndexNotNull'::text function_tested,
       'Passes basic test, true'::text description,
       TT_minIndexNotNull('{1990, 2000}', '{burn, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '24.2'::text number,
       'TT_minIndexNotNull'::text function_tested,
       'Passes basic test, false'::text description,
       TT_minIndexNotNull('{1990, 2000}', '{null, wind}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '24.3'::text number,
       'TT_minIndexNotNull'::text function_tested,
       'Matching ints return first index'::text description,
       TT_minIndexNotNull('{1990, 1990}', '{null, wind}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '24.4'::text number,
       'TT_minIndexNotNull'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_minIndexNotNull('{1990, null}', '{null, wind}', '0') passed
---------------------------------------------------------
UNION ALL
SELECT '24.5'::text number,
       'TT_minIndexNotNull'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_minIndexNotNull('{1990, null}', '{burn, null}', '0') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '24.6'::text number,
       'TT_minIndexNotNull'::text function_tested,
       'Test all null ints'::text description,
       TT_minIndexNotNull('{null, null}', '{null, wind}') IS FALSE passed
---------------------------------------------------------
-- Test 25 - TT_minIndexNotNull
---------------------------------------------------------
UNION ALL
SELECT '25.1'::text number,
       'TT_maxIndexNotNull'::text function_tested,
       'Passes basic test, true'::text description,
       TT_maxIndexNotNull('{1990, 2000}', '{burn, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '25.2'::text number,
       'TT_maxIndexNotNull'::text function_tested,
       'Passes basic test, false'::text description,
       TT_maxIndexNotNull('{1990, 2000}', '{burn, null}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '25.3'::text number,
       'TT_maxIndexNotNull'::text function_tested,
       'Matching ints return second index'::text description,
       TT_maxIndexNotNull('{1990, 1990}', '{burn, null}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '25.4'::text number,
       'TT_maxIndexNotNull'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_maxIndexNotNull('{1990, null}', '{null, wind}', '9999') passed
---------------------------------------------------------
UNION ALL
SELECT '25.5'::text number,
       'TT_maxIndexNotNull'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_maxIndexNotNull('{1990, null}', '{burn, null}', '9999') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '25.6'::text number,
       'TT_maxIndexNotNull'::text function_tested,
       'Test all null ints'::text description,
       TT_maxIndexNotNull('{null, null}', '{burn, null}') IS FALSE passed
---------------------------------------------------------
  
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
-- test all NULLs and wrong types (10 tests)
SELECT (TT_TestNullAndWrongTypeParams(104, 'TT_LookupText',
                                      ARRAY['lookupSchemaName', 'name',
                                            'lookupTableName', 'name',
                                            'lookupCol', 'name',
                                            'retrieveCol', 'name',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '104.11'::text number,
       'TT_LookupText'::text function_tested,
       'Text usage'::text description,
       TT_LookupText('a'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text) = 'ACB'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.12'::text number,
       'TT_LookupText'::text function_tested,
       'NULL val'::text description,
       TT_LookupText(NULL::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '104.13'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupText('A'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, TRUE::text) = 'ACB'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.14'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupText('A'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '104.15'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, true flipped case'::text description,
       TT_LookupText('aa'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, TRUE::text) = 'abcde'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.16'::text number,
       'TT_LookupText'::text function_tested,
       'Test new retrieveCol parameter'::text description,
       TT_LookupText('abcde'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, 'source_val'::text) = 'AA'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.17'::text number,
       'TT_LookupText'::text function_tested,
       'Test new retrieveCol parameter with ignoreCase = TRUE'::text description,
       TT_LookupText('AbCdE'::text, 'public'::text, 'test_table_with_null'::text, 'text_val'::text, 'source_val'::text, TRUE::text) = 'AA'::text passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 105 - TT_LookupDouble
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (10 tests)
SELECT (TT_TestNullAndWrongTypeParams(105, 'TT_LookupDouble',
                                      ARRAY['lookupSchemaName', 'name',
                                            'lookupTableName', 'name',
                                            'lookupCol', 'name',
                                            'retrieveCol', 'name',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '105.11'::text number,
       'TT_LookupDouble'::text function_tested,
       'Double precision usage'::text description,
       TT_LookupDouble('a'::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text) = 1.1::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '105.12'::text number,
       'TT_LookupDouble'::text function_tested,
       'NULL val'::text description,
       TT_LookupDouble(NULL::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '105.13'::text number,
       'TT_LookupDouble'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupDouble('A'::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text, TRUE::text) = 1.1 passed
---------------------------------------------------------
UNION ALL
SELECT '105.14'::text number,
       'TT_LookupDouble'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupDouble('A'::text, 'public'::text, 'test_table_with_null'::text, 'dbl_val'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 106 - TT_LookupInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (10 tests)
SELECT (TT_TestNullAndWrongTypeParams(106, 'TT_LookupInt',
                                      ARRAY['lookupSchemaName', 'name',
                                            'lookupTableName', 'name',
                                            'lookupCol', 'name',
                                            'retrieveCol', 'name',
                                            'ignoreCase', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '106.11'::text number,
       'TT_LookupInt'::text function_tested,
       'Int usage'::text description,
       TT_LookupInt('a'::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '106.12'::text number,
       'TT_LookupInt'::text function_tested,
       'NULL val'::text description,
       TT_LookupInt(NULL::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '106.13'::text number,
       'TT_LookupInt'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupInt('A'::text, 'public'::text, 'test_table_with_null'::text, 'int_val'::text, TRUE::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '106.14'::text number,
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
                                            'ignoreCase', 'boolean',
                                            'removeSpaces', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '107.9'::text number,
       'TT_MapText'::text function_tested,
       'Test text list, text list'::text description,
       TT_MapText('A'::text, '{''A'',''B'',''C'',''D''}'::text, '{''a'',''b'',''c'',''d''}'::text) = 'a'::text passed
---------------------------------------------------------
UNION ALL
SELECT '107.10'::text number,
       'TT_MapText'::text function_tested,
       'Test double precision list, text list'::text description,
       TT_MapText(1.1::text, '{''1.1'',''1.2'',''1.3'',''1.4''}'::text, '{''A'',''B'',''C'',''D''}'::text) = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '107.11'::text number,
       'TT_MapText'::text function_tested,
       'Test int list, text list'::text description,
       TT_MapText(2::text, '{''1'',''2'',''3'',''4''}'::text, '{''A'',''B'',''C'',''D''}'::text) = 'B' passed
---------------------------------------------------------
UNION ALL
SELECT '107.12'::text number,
       'TT_MapText'::text function_tested,
       'Test Null val'::text description,
       TT_MapText(NULL::text, '{''A'',''B'',''C'',''D''}'::text, '{''a'',''b'',''c''}'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '107.13'::text number,
       'TT_MapText'::text function_tested,
       'Test caseIgnore, true'::text description,
       TT_MapText('a'::text, '{''A'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text, TRUE::text) = 'aa' passed
---------------------------------------------------------
UNION ALL
SELECT '107.14'::text number,
       'TT_MapText'::text function_tested,
       'Test caseIgnore, false'::text description,
       TT_MapText('a'::text, '{''A'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '107.15'::text number,
       'TT_MapText'::text function_tested,
       'Test multiple vals'::text description,
       TT_MapText('{A, B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text) = 'aa' passed
---------------------------------------------------------
UNION ALL
SELECT '107.16'::text number,
       'TT_MapText'::text function_tested,
       'Test single val in stringlist format'::text description,
       TT_MapText('{B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text) = 'bb' passed
---------------------------------------------------------
UNION ALL
SELECT '107.17'::text number,
       'TT_MapText'::text function_tested,
       'Test string with space and character and no brackets, removeSpaces false'::text description,
       TT_MapText(' '::text, '{'' '',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text, FALSE::text, FALSE::text) = 'aa' passed
---------------------------------------------------------
UNION ALL
SELECT '107.18'::text number,
       'TT_MapText'::text function_tested,
       'Test string with space and no brackets, removSpaces true'::text description,
       TT_MapText(' a'::text, '{''a'',''B'',''C'',''D''}'::text, '{''aa'',''bb'',''cc'',''dd''}'::text) = 'aa' passed
---------------------------------------------------------
UNION ALL
SELECT '107.19'::text number,
       'TT_MapText'::text function_tested,
       'Test different number of mapping values'::text description,
       TT_IsError('SELECT TT_MapText(''A''::text, ''{''''A'''',''''B'''',''''C'''',''''D''''}''::text, ''{''''a'''',''''b'''',''''c''''}''::text);') = 'ERROR in TT_MapText(): number of mapVals values (4) is different from number of targetVals values (3)...' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 108 - TT_MapDouble
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(108, 'TT_MapDouble',
                                      ARRAY['mapVals', 'stringlist',
                                            'targetVals', 'doublelist',
                                            'ignoreCase', 'boolean',
                                            'removeSpaces', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '108.9'::text number,
       'TT_MapDouble'::text function_tested,
       'Test text list, double precision list'::text description,
       TT_MapDouble('A'::text, '{''A'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '1.1'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.10'::text number,
       'TT_MapDouble'::text function_tested,
       'Test double precision list, double precision list'::text description,
       TT_MapDouble(1.1::text, '{''1.1'',''1.2'',''1.3'',''1.4''}'::text, '{''1.11'',''2.22'',''3.33'',''4.44''}'::text) = '1.11'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.11'::text number,
       'TT_MapDouble'::text function_tested,
       'Test int list, double precision list'::text description,
       TT_MapDouble(2::text, '{''1'',''2'',''3'',''4''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '2.2'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.12'::text number,
       'TT_MapDouble'::text function_tested,
       'Test Null val'::text description,
       TT_MapDouble(NULL::text, '{''1'',''2'',''3'',''4''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '108.13'::text number,
       'TT_MapDouble'::text function_tested,
       'Test multiple vals'::text description,
       TT_MapDouble('{A, B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '1.1'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.14'::text number,
       'TT_MapDouble'::text function_tested,
       'Test single val in stringlist format'::text description,
       TT_MapDouble('{B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text) = '2.2'::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '108.15'::text number,
       'TT_MapDouble'::text function_tested,
       'Test string with space and character and no brackets, nospaces false'::text description,
       TT_MapDouble(' '::text, '{'' '',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text, FALSE::text, FALSE::text) = '1.1' passed
---------------------------------------------------------
UNION ALL
SELECT '108.16'::text number,
       'TT_MapDouble'::text function_tested,
       'Test string with space and no brackets, nospaces true'::text description,
       TT_MapDouble(' X'::text, '{''X'',''B'',''C'',''D''}'::text, '{''1.1'',''2.2'',''3.3'',''4.4''}'::text, FALSE::text, TRUE::text) = '1.1' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 109 - TT_MapInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(109, 'TT_MapInt',
                                      ARRAY['mapVals', 'stringlist',
                                            'targetVals', 'intlist',
                                            'ignoreCase', 'boolean',
                                            'removeSpaces', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '109.9'::text number,
       'TT_MapInt'::text function_tested,
       'Test text list, int list'::text description,
       TT_MapInt('A'::text, '{''A'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '1'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.10'::text number,
       'TT_MapInt'::text function_tested,
       'Test double precision list, int list'::text description,
       TT_MapInt(1.1::text, '{''1.1'',''1.2'',''1.3'',''1.4''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '1'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.11'::text number,
       'TT_MapInt'::text function_tested,
       'Test int list, int list'::text description,
       TT_MapInt(2::text, '{''1'',''2'',''3'',''4''}'::text, '{''5'',''6'',''7'',''8''}'::text) = '6'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.12'::text number,
       'TT_MapInt'::text function_tested,
       'Test Null val'::text description,
       TT_MapInt(NULL::text, '{''1'', ''2'', ''3'', ''4''}'::text, '{''5'', ''6'', ''7'', ''8''}'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '109.13'::text number,
       'TT_MapInt'::text function_tested,
       'Test multiple vals'::text description,
       TT_MapInt('{A, B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '1'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.14'::text number,
       'TT_MapInt'::text function_tested,
       'Test single val in stringlist format'::text description,
       TT_MapInt('{B}'::text, '{''AB'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text) = '2'::int passed
---------------------------------------------------------
UNION ALL
SELECT '109.15'::text number,
       'TT_MapInt'::text function_tested,
       'Test string with space and character and no brackets, removeSpaces false'::text description,
       TT_MapInt(' '::text, '{'' '',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text, FALSE::text, FALSE::text) = '1' passed
---------------------------------------------------------
UNION ALL
SELECT '109.16'::text number,
       'TT_MapInt'::text function_tested,
       'Test string with space and no brackets, removeSpaces true'::text description,
       TT_MapInt(' X'::text, '{''X'',''B'',''C'',''D''}'::text, '{''1'',''2'',''3'',''4''}'::text, FALSE::text, TRUE::text) = '1' passed
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
       TT_IsError('SELECT TT_Pad(1::text, 10::text, ''22''::text);') = 'ERROR in TT_Pad(): padChar is not a char value' passed
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
SELECT '111.1'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage'::text description,
       TT_Concat('{''cas'', ''id'', ''test''}'::text, '-'::text) = 'cas-id-test' passed
---------------------------------------------------------
UNION ALL
SELECT '111.2'::text number,
       'TT_Concat'::text function_tested,
       'Basic usage with numbers and symbols'::text description,
       TT_Concat('{''001'', ''--0--'', ''tt.tt''}'::text, '-'::text) = '001---0---tt.tt' passed
---------------------------------------------------------
UNION ALL
SELECT '111.3'::text number,
       'TT_Concat'::text function_tested,
       'Sep is null'::text description,
       TT_IsError('SELECT TT_Concat(''{''''cas'''', ''''id'''', ''''test''''}''::text, NULL::text);') = 'ERROR in TT_Concat(): sep is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '111.4'::text number,
       'TT_Concat'::text function_tested,
       'Test sep with empty string'::text description,
       TT_Concat('{''cas'', ''id'', ''test''}'::text, ''::text) = 'casidtest' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 112 - TT_PadConcat
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (8 tests)
SELECT (TT_TestNullAndWrongTypeParams(112, 'TT_PadConcat',
                                      ARRAY['length', 'intlist',
                                            'pad', 'charlist',
                                            'sep', 'char',
                                            'upperCase', 'boolean',
                                            'includeEmpty', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '112.9'::text number,
       'TT_PadConcat'::text function_tested,
       'Test with spaces and uppercase'::text description,
       TT_PadConcat('{''ab06'', ''GB_S21_TWP'', ''81145'', ''811451038'', ''1''}', '{''4'', ''15'', ''10'', ''10'', ''7''}', '{''x'', ''x'', ''x'', ''0'', ''0''}'::text, '-'::text, TRUE::text) = 'AB06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.10'::text number,
       'TT_PadConcat'::text function_tested,
       'Test without spaces and not uppercase'::text description,
       TT_PadConcat('{''ab06'', ''GB_S21_TWP'', ''81145'', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, FALSE::text) = 'ab06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.11'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty value'::text description,
       TT_PadConcat('{''ab06'', '''', ''81145'', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, FALSE::text) = 'ab06-xxxxxxxxxxxxxxx-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.12'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty length'::text description,
       TT_IsError('SELECT TT_PadConcat(''{''''ab06'''', '''''''', ''''81145'''', ''''811451038'''', ''''1''''}'', ''{''''4'''',''''15'''','''''''',''''10'''',''''7''''}'', ''{''''x'''',''''x'''',''''x'''',''''0'''',''''0''''}''::text, ''-''::text, FALSE::text);') = 'ERROR in TT_PadConcat(): length is not a intlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '112.13'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty pad'::text description,
       TT_IsError('SELECT TT_PadConcat(''{''''ab06'''', '''''''', ''''81145'''', ''''811451038'''', ''''1''''}'', ''{''''4'''',''''15'''',''''10'''',''''10'''',''''7''''}'', ''{''''x'''','''''''',''''x'''',''''0'''',''''0''''}''::text, ''-''::text, FALSE::text);') = 'ERROR in TT_PadConcat(): pad is not a charlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '112.14'::text number,
       'TT_PadConcat'::text function_tested,
       'Uneven val, length, pad strings'::text description,
       TT_IsError('SELECT TT_PadConcat(''{''''ab06'''', '''''''', ''''81145'''', ''''811451038''''}'', ''{''''4'''',''''15'''',''''10'''',''''10'''',''''7''''}'', ''{''''x'''','''''''',''''x'''',''''0'''',''''0''''}''::text, ''-''::text, FALSE::text);') = 'ERROR in TT_PadConcat(): pad is not a charlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '112.15'::text number,
       'TT_PadConcat'::text function_tested,
       'Empty value, includeEmpty FALSE'::text description,
       TT_PadConcat('{''ab06'', '''', ''81145'', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, TRUE::text, FALSE::text) = 'AB06-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '112.16'::text number,
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
-- Test 121 - TT_CountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '121.1'::text number,
       'TT_CountOfNotNull'::text function_tested,
       'Simple test'::text description,
       TT_CountOfNotNull('{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 7::text, 'FALSE') = 7 passed
---------------------------------------------------------
UNION ALL
SELECT '121.2'::text number,
       'TT_CountOfNotNull'::text function_tested,
       'Lower max_rank_to_consider'::text description,
       TT_CountOfNotNull('{'''',''''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 1::text, 'FALSE') = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '121.3'::text number,
       'TT_CountOfNotNull'::text function_tested,
       'Some NULLs and empties, '::text description,
       TT_CountOfNotNull('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 3::text, 'FALSE') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '121.4'::text number,
       'TT_CountOfNotNull'::text function_tested,
       'Fewer arguments, '::text description,
       TT_CountOfNotNull('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  4::text, 'FALSE') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '121.5'::text number,
       'TT_CountOfNotNull'::text function_tested,
       'zeros not counted as null'::text description,
       TT_CountOfNotNull('{'''',''''}'::text, '{NULL,NULL}'::text, '{''0'',''0''}'::text, '{''1'',''2''}'::text, 
						  4::text, 'FALSE') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '121.6'::text number,
       'TT_CountOfNotNull'::text function_tested,
       'zeros counted as null'::text description,
       TT_CountOfNotNull('{'''',''''}'::text, '{NULL,NULL}'::text, '{''0'',''0''}'::text, '{''1'',''2''}'::text, 
						  4::text, 'TRUE') = 1 passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 121 - TT_IfElseCountOfNotNullText
---------------------------------------------------------
UNION ALL
SELECT '122.1'::text number,
       'TT_IfElseCountOfNotNullText'::text function_tested,
       'Simple test'::text description,
       TT_IfElseCountOfNotNullText('{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 7::text, 1::text, 'S'::text, 'M'::text) = 'M' passed
---------------------------------------------------------
UNION ALL
SELECT '122.2'::text number,
       'TT_IfElseCountOfNotNullText'::text function_tested,
       'Lower max_rank_to_consider'::text description,
       TT_IfElseCountOfNotNullText('{'''',''''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 1::text, 1::text, 'S'::text, 'M'::text) = 'S' passed
---------------------------------------------------------
UNION ALL
SELECT '122.3'::text number,
       'TT_IfElseCountOfNotNullText'::text function_tested,
       'Some NULLs and empties, '::text description,
       TT_IfElseCountOfNotNullText('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 3::text, 2::text, 'S'::text, 'M'::text) = 'S' passed
---------------------------------------------------------
UNION ALL
SELECT '122.4'::text number,
       'TT_IfElseCountOfNotNullText'::text function_tested,
       'Fewer arguments, '::text description,
       TT_IfElseCountOfNotNullText('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  4::text, 1::text, 'S'::text, 'M'::text) = 'M' passed
---------------------------------------------------------
-- Test 123 - TT_SubstringText
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (6 tests)
SELECT (TT_TestNullAndWrongTypeParams(123, 'TT_SubstringText', ARRAY['startChar', 'int',
                                                                'forLength', 'int',
                                                                'removeSpaces', 'boolean'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '123.7'::text number,
       'TT_SubstringText'::text function_tested,
       'Basic function call'::text description,
       TT_SubstringText('abcd'::text, '3'::text, '2'::text) = 'cd' passed
---------------------------------------------------------
UNION ALL
SELECT '123.8'::text number,
       'TT_SubstringText'::text function_tested,
       'NULL value'::text description,
       TT_IsError('SELECT TT_SubstringText(NULL::text, NULL::text, NULL::text)') = 'ERROR in TT_SubstringText(): startChar is NULL' passed  
---------------------------------------------------------
UNION ALL
SELECT '123.9'::text number,
       'TT_SubstringText'::text function_tested,
       'Remove spaces false'::text description,
       TT_SubstringText(' abcd'::text, '3'::text, '2'::text) = 'bc' passed
---------------------------------------------------------
UNION ALL
SELECT '123.10'::text number,
       'TT_SubstringText'::text function_tested,
       'Remove spaces true'::text description,
       TT_SubstringText(' abcd'::text, '3'::text, '2'::text, TRUE::text) = 'cd' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 124 - TT_SubstringInt
---------------------------------------------------------
UNION ALL
SELECT '124.1'::text number,
       'TT_SubstringInt'::text function_tested,
       'Basic function call'::text description,
       TT_SubstringInt('1234'::text, '1'::text, '3'::text) = '123' passed
---------------------------------------------------------
UNION ALL
SELECT '124.2'::text number,
       'TT_SubstringInt'::text function_tested,
       'NULL value'::text description,
       TT_IsError('SELECT TT_SubstringInt(NULL::text, NULL::text, NULL::text)') = 'ERROR in TT_SubstringText(): startChar is NULL' passed  
---------------------------------------------------------
---------------------------------------------------------
-- Test 125 - TT_MapSubstringText
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (10 tests)
SELECT (TT_TestNullAndWrongTypeParams(125, 'TT_MapSubstringText', ARRAY['startChar', 'int',
                                                                'forLength', 'int',
                                                                'mapVals', 'stringlist',
                                                                'targetVals', 'stringlist',
                                                                'ignoreCase', 'boolean'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '125.11'::text number,
       'TT_MapSubstringText'::text function_tested,
       'Basic function call'::text description,
       TT_MapSubstringText('1234'::text, '1'::text, '1'::text, '{''1'', ''2''}', '{''A'',''B''}') = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '125.12'::text number,
       'TT_MapSubstringText'::text function_tested,
       'val as string list'::text description,
       TT_MapSubstringText('{''1234'', ''abcd''}'::text, '1'::text, '1'::text, '{''1a'', ''2a''}', '{''A'',''B''}') = 'A' passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 126 - TT_SumIntMapText
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(126, 'TT_SumIntMapText', ARRAY['mapVals', 'stringlist',
                                                                'targetVals', 'stringlist'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '126.5'::text number,
       'TT_SumIntMapText'::text function_tested,
       'Basic function call'::text description,
       TT_SumIntMapText('{1,2}'::text, '{3,4,5}'::text, '{''A'',''B'',''C''}') = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '126.6'::text number,
       'TT_SumIntMapText'::text function_tested,
       'Not in set'::text description,
       TT_SumIntMapText('{1,2}'::text, '{6,4,5}'::text, '{''A'',''B'',''C''}') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '126.7'::text number,
       'TT_SumIntMapText'::text function_tested,
       'Not int'::text description,
       TT_SumIntMapText('{a,2}'::text, '{6,4,5}'::text, '{''A'',''B'',''C''}') IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 127 - TT_LengthMapInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(127, 'TT_LengthMapInt', ARRAY['mapVals', 'stringlist',
                                                                'targetVals', 'stringlist'
                                                                ])).*
---------------------------------------------------------
UNION ALL
SELECT '127.5'::text number,
       'TT_LengthMapInt'::text function_tested,
       'Basic function call'::text description,
       TT_LengthMapInt('123'::text, '{3,4,5}'::text, '{1,2,3}'::text) = 1::int passed
---------------------------------------------------------
UNION ALL
SELECT '127.6'::text number,
       'TT_LengthMapInt'::text function_tested,
       'not in set'::text description,
       TT_LengthMapInt('123'::text, '{6,4,5}'::text, '{1,2,3}'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '127.7'::text number,
       'TT_LengthMapInt'::text function_tested,
       'Basic function call, with trim'::text description,
       TT_LengthMapInt(' 123 '::text, '{3}'::text, '{1}'::text, 'TRUE'::text) = 1::int passed
---------------------------------------------------------
UNION ALL
SELECT '127.8'::text number,
       'TT_LengthMapInt'::text function_tested,
       'Basic function call, with trim'::text description,
       TT_LengthMapInt(' 123 '::text, '{5}'::text, '{1}'::text) = 1::int passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 128 - TT_IfElseCountOfNotNullInt
---------------------------------------------------------
UNION ALL
SELECT '128.1'::text number,
       'TT_IfElseCountOfNotNullInt'::text function_tested,
       'Simple test'::text description,
       TT_IfElseCountOfNotNullInt('{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 7::text, 1::text, '1'::text, '2'::text) = '2' passed
---------------------------------------------------------
UNION ALL
SELECT '128.2'::text number,
       'TT_IfElseCountOfNotNullInt'::text function_tested,
       'Lower max_rank_to_consider'::text description,
       TT_IfElseCountOfNotNullInt('{'''',''''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 1::text, 1::text, '1'::text, '2'::text) = '1' passed
---------------------------------------------------------
UNION ALL
SELECT '128.3'::text number,
       'TT_IfElseCountOfNotNullInt'::text function_tested,
       'Some NULLs and empties, '::text description,
       TT_IfElseCountOfNotNullInt('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  '{''1'',''2''}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 3::text, 2::text, '1'::text, '2'::text) = '1' passed
---------------------------------------------------------
UNION ALL
SELECT '128.4'::text number,
       'TT_IfElseCountOfNotNullInt'::text function_tested,
       'Fewer arguments, '::text description,
       TT_IfElseCountOfNotNullInt('{'''',''''}'::text, '{NULL,NULL}'::text, '{''1'',''2''}'::text, '{''1'',''2''}'::text, 
						  4::text, 1::text, '1'::text, '2'::text) = '2' passed
---------------------------------------------------------
-- Test 129 - TT_XMinusYInt
---------------------------------------------------------
UNION ALL
SELECT '129.1'::text number,
       'TT_XMinusYInt'::text function_tested,
       'Simple test'::text description,
       TT_XMinusYInt(5::text, 3::text) = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '129.2'::text number,
       'TT_XMinusYInt'::text function_tested,
       'Simple test with 0'::text description,
       TT_XMinusYInt(5::text, 0::text) = 5 passed
---------------------------------------------------------
UNION ALL
SELECT '129.3'::text number,
       'TT_XMinusYInt'::text function_tested,
       'Test null'::text description,
       TT_XMinusYInt(5::text, NULL::text) IS NULL passed
---------------------------------------------------------
-- Test 130 - TT_MinInt
---------------------------------------------------------
UNION ALL
SELECT '130.1'::text number,
       'TT_MinInt'::text function_tested,
       'Simple test'::text description,
       TT_minInt('{1,2,3}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '130.2'::text number,
       'TT_MinInt'::text function_tested,
       'Simple test with null'::text description,
       TT_minInt('{null,2}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '130.3'::text number,
       'TT_MinInt'::text function_tested,
       'All nulls'::text description,
       TT_minInt('{null,null}') IS NULL passed
---------------------------------------------------------
-- Test 131 - TT_MaxInt
---------------------------------------------------------
UNION ALL
SELECT '131.1'::text number,
       'TT_MaxInt'::text function_tested,
       'Simple test'::text description,
       TT_MaxInt('{1,2,3}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '131.2'::text number,
       'TT_MaxInt'::text function_tested,
       'Simple test with null'::text description,
       TT_MaxInt('{null,2}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '131.3'::text number,
       'TT_MaxInt'::text function_tested,
       'All nulls'::text description,
       TT_MaxInt('{null,null}') IS NULL passed
---------------------------------------------------------
-- Test 132 - TT_MinIndexCopyText
---------------------------------------------------------
UNION ALL
SELECT '132.1'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Simple test'::text description,
       TT_MinIndexCopyText('{1,2,3}', '{a,b,c}') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '132.2'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Simple test 2'::text description,
       TT_MinIndexCopyText('{1,2,3,0}', '{a,b,c,d}') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '132.3'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Test negative int'::text description,
       TT_MinIndexCopyText('{1,2,3,-1}', '{a,b,c,d}') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '132.4'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Test null'::text description,
       TT_MinIndexCopyText('{1,2,3,null}', '{a,b,c,d}') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '132.5'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Test setNullTo'::text description,
       TT_MinIndexCopyText('{1,2,3,null}', '{a,b,c,d}', '0') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '132.6'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Test multiple indexes'::text description,
       TT_MinIndexCopyText('{1,1,3}', '{a,b,c}') = 'a' passed
---------------------------------------------------------
-- Test 133 - TT_MaxIndexCopyText
---------------------------------------------------------
UNION ALL
SELECT '133.1'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Simple test'::text description,
       TT_MaxIndexCopyText('{1,2,3}', '{a,b,c}') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '133.2'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Simple test 2'::text description,
       TT_MaxIndexCopyText('{4,1,2,3}', '{a,b,c,d}') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '133.3'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Test negative int'::text description,
       TT_MaxIndexCopyText('{1,2,3,-1}', '{a,b,c,d}') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '133.4'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Test null'::text description,
       TT_MaxIndexCopyText('{1,2,3,null}', '{a,b,c,d}') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '133.5'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Test setNullTo'::text description,
       TT_MaxIndexCopyText('{1,2,3,null}', '{a,b,c,d}', '4') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '133.6'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Test multiple indexes'::text description,
       TT_MaxIndexCopyText('{1,3,3}', '{a,b,c}') = 'c' passed
---------------------------------------------------------
-- Test 134 - TT_MinIndexMapText
---------------------------------------------------------
UNION ALL
SELECT '134.1'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Test for null mapVals'::text description,
       TT_IsError('SELECT TT_MinIndexMapText(''{1990, 2000}'', ''{burn, wind}'', NULL::text, ''{BU, WT}'')') = 'ERROR in TT_MinIndexMapText(): mapVals is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '134.2'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Test for null targetVals'::text description,
       TT_IsError('SELECT TT_MinIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', NULL::text)') = 'ERROR in TT_MinIndexMapText(): targetVals is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '134.3'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Test for invalid mapVals'::text description,
       TT_IsError('SELECT TT_MinIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}}}'', ''{BU, WT}'')') = 'ERROR in TT_MinIndexMapText(): mapVals is not a stringlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '134.4'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Test for invalid targetVals'::text description,
       TT_IsError('SELECT TT_MinIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', ''{BU, WT}}}'')') = 'ERROR in TT_MinIndexMapText(): targetVals is not a stringlist value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '134.5'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Simple test'::text description,
       TT_MinIndexMapText('{1990, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}') = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '134.6'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Matching indexes'::text description,
       TT_MinIndexMapText('{1990, 1990}', '{burn, wind}', '{burn, wind}', '{BU, WT}') = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '134.7'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'null integer'::text description,
       TT_MinIndexMapText('{null, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '134.8'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'setNullTo'::text description,
       TT_MinIndexMapText('{1990, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '0') = 'WT' passed
---------------------------------------------------------
-- Test 135 - TT_MaxIndexMapText
---------------------------------------------------------
UNION ALL
SELECT '135.1'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Test for null mapVals'::text description,
       TT_IsError('SELECT TT_MaxIndexMapText(''{1990, 2000}'', ''{burn, wind}'', NULL::text, ''{BU, WT}'')') = 'ERROR in TT_MaxIndexMapText(): mapVals is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '135.2'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Test for null targetVals'::text description,
       TT_IsError('SELECT TT_MaxIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', NULL::text)') = 'ERROR in TT_MaxIndexMapText(): targetVals is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '135.3'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Test for invalid mapVals'::text description,
       TT_IsError('SELECT TT_MaxIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}}}'', ''{BU, WT}'')') = 'ERROR in TT_MaxIndexMapText(): mapVals is not a stringlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '135.4'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Test for invalid targetVals'::text description,
       TT_IsError('SELECT TT_MaxIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', ''{BU, WT}}}'')') = 'ERROR in TT_MaxIndexMapText(): targetVals is not a stringlist value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '135.5'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Simple test'::text description,
       TT_MaxIndexMapText('{1990, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '135.6'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Matching indexes'::text description,
       TT_MaxIndexMapText('{1990, 1990}', '{burn, wind}', '{burn, wind}', '{BU, WT}') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '135.7'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'null integer'::text description,
       TT_MaxIndexMapText('{1990, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}') = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '135.8'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'setNullTo'::text description,
       TT_MaxIndexMapText('{null, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '9999') = 'BU' passed
---------------------------------------------------------
-- Test 136 - TT_MinIndexLookupText
---------------------------------------------------------
UNION ALL
SELECT '136.1'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test for null schema'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', NULL::text, ''index_test_table'', ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): lookupSchemaName is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '136.2'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test for null table'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', NULL::text, ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): lookupTableName is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '136.3'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test for null source column'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', NULL::text, ''text_val'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): lookupCol is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '136.4'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test for null return column'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', ''source_val'', NULL::text, NULL::text)') = 'ERROR in TT_MinIndexLookupText(): retrieveCol is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '136.5'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test invalid schema name'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''1'', ''index_test_table'', ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): lookupSchemaName is not a name value' passed
---------------------------------------------------------
UNION ALL
SELECT '136.6'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test invalid table name'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''1'', ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): lookupTableName is not a name value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '136.7'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test invalid src col name'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', ''1'', ''text_val'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): lookupCol is not a name value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '136.8'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Test invalid target col name'::text description,
       TT_IsError('SELECT TT_MinIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', ''source_val'', ''.0'', NULL::text)') = 'ERROR in TT_MinIndexLookupText(): retrieveCol is not a name value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '136.9'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Simple test'::text description,
       TT_MinIndexLookupText('{1990, 2000}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', NULL::text) = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '136.10'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'Matching indexes'::text description,
       TT_MinIndexLookupText('{1990, 1990}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', NULL::text) = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '136.11'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'null integer'::text description,
       TT_MinIndexLookupText('{null, 2000}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', NULL::text) = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '136.12'::text number,
       'TT_MinIndexLookupText'::text function_tested,
       'setNullTo'::text description,
       TT_MinIndexLookupText('{1990, null}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', '0') = 'WT' passed
---------------------------------------------------------
-- Test 137 - TT_MaxIndexLookupText
---------------------------------------------------------
UNION ALL
SELECT '137.1'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test for null schema'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', NULL::text, ''index_test_table'', ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): lookupSchemaName is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '137.2'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test for null table'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', NULL::text, ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): lookupTableName is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '137.3'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test for null source column'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', NULL::text, ''text_val'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): lookupCol is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '137.4'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test for null return column'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', ''source_val'', NULL::text, NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): retrieveCol is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '137.5'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test invalid schema name'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''1'', ''index_test_table'', ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): lookupSchemaName is not a name value' passed
---------------------------------------------------------
UNION ALL
SELECT '137.6'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test invalid table name'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''1'', ''source_val'', ''text_val'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): lookupTableName is not a name value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '137.7'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test invalid src col name'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', ''1'', ''text_val'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): lookupCol is not a name value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '137.8'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Test invalid target col name'::text description,
       TT_IsError('SELECT TT_MaxIndexLookupText(''{1990, 2000}'', ''{burn, wind}'', ''public'', ''index_test_table'', ''source_val'', ''.0'', NULL::text)') = 'ERROR in TT_MaxIndexLookupText(): retrieveCol is not a name value' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '137.9'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Simple test'::text description,
       TT_MaxIndexLookupText('{1990, 2000}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', null::text) = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '137.10'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'Matching indexes'::text description,
       TT_MaxIndexLookupText('{1990, 1990}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', null::text) = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '137.11'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'null integer'::text description,
       TT_MaxIndexLookupText('{1990, null}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', null::text) = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '137.12'::text number,
       'TT_MaxIndexLookupText'::text function_tested,
       'setNullTo'::text description,
       TT_MaxIndexLookupText('{null, 2000}', '{burn, wind}', 'public', 'index_test_table', 'source_val', 'text_val', '9999') = 'BU' passed

) AS b
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed OR passed IS NULL
-- Comment out this line to display only test number
--OR ((regexp_split_to_array(number, '\.'))[1])::int = 12
;
