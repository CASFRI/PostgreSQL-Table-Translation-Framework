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
-----------------------------------------------------------
DROP TABLE IF EXISTS alpha_numeric_test_table;
CREATE TABLE alpha_numeric_test_table AS
SELECT 'x0'::text source_val, '1'::text species_count
UNION ALL
SELECT 'xx0xx0'::text, '2'::text;
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
  SELECT 'TT_IsGreaterThan'::text,           8,         12         UNION ALL
  SELECT 'TT_IsLessThan'::text,              9,         12         UNION ALL
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
  SELECT 'TT_MinIndexNotNull'::text,        24,          8         UNION ALL
  SELECT 'TT_MaxIndexNotNull'::text,        25,          8         UNION ALL
  SELECT 'TT_IsXMinusYBetween'::text,       26,         11         UNION ALL
  SELECT 'TT_MatchListTwice'::text,         27,          9         UNION ALL
  SELECT 'TT_HasCountOfNotNullOrZero'::text,28,         11         UNION ALL
  SELECT 'TT_LookupTextMatchList'::text,    29,          5         UNION ALL
  SELECT 'TT_MinIndexIsInt'::text,          30,          5         UNION ALL
  SELECT 'TT_MaxIndexIsInt'::text,          31,          5         UNION ALL
  SELECT 'TT_MinIndexIsBetween'::text,      32,          4         UNION ALL
  SELECT 'TT_MaxIndexIsBetween'::text,      33,          4         UNION ALL
  SELECT 'TT_MinIndexMatchList'::text,      34,          4         UNION ALL
  SELECT 'TT_MaxIndexMatchList'::text,      35,          4         UNION ALL
  SELECT 'TT_MatchTableSubstring'::text,    36,          3         UNION ALL
  SELECT 'TT_MinIndexNotEmpty'::text,       37,          8         UNION ALL
  SELECT 'TT_MaxIndexNotEmpty'::text,       38,          8         UNION ALL
  SELECT 'TT_CoalesceIsInt'::text,          39,         10         UNION ALL
  SELECT 'TT_CoalesceIsBetween'::text,      40,         12         UNION ALL
  SELECT 'TT_HasCountOfMatchList'::text,    44,          8         UNION ALL
  SELECT 'TT_AlphaNumericMatchList'::text,  45,          6         UNION ALL	
  SELECT 'TT_AlphaNumericLookupTextMatchList'::text,46,  2         UNION ALL
  SELECT 'TT_AlphaNumericMatchTable'::text, 47,          3         UNION ALL
  SELECT 'TT_GetIndexNotNull'::text,        48,          8         UNION ALL
  SELECT 'TT_GetIndexIsInt'::text,          49,          5         UNION ALL
  SELECT 'TT_GetIndexIsBetween'::text,      50,          4         UNION ALL
  SELECT 'TT_GetIndexMatchList'::text,      51,          5         UNION ALL
  SELECT 'TT_GetIndexNotEmpty'::text,       52,          9         UNION ALL

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
  SELECT 'TT_Concat'::text,                111,          6         UNION ALL
  SELECT 'TT_PadConcat'::text,             112,         17         UNION ALL
  SELECT 'TT_NothingText'::text,           118,          1         UNION ALL
  SELECT 'TT_NothingDouble'::text,         119,          1         UNION ALL
  SELECT 'TT_NothingInt'::text,            120,          1         UNION ALL
  SELECT 'TT_CountOfNotNull'::text,        121,          6         UNION ALL
  SELECT 'TT_IfElseCountOfNotNullText'::text,122,        4         UNION ALL
  SELECT 'TT_SubstringText'::text,         123,         10         UNION ALL
  SELECT 'TT_SubstringInt'::text,          124,          3         UNION ALL
  SELECT 'TT_MapSubstringText'::text,      125,         12         UNION ALL
  SELECT 'TT_SumIntMapText'::text,         126,          7         UNION ALL
  SELECT 'TT_LengthMapInt'::text,          127,          8         UNION ALL
  SELECT 'TT_IfElseCountOfNotNullInt'::text,128,         4         UNION ALL
  SELECT 'TT_XMinusYInt'::text,            129,          3         UNION ALL
  SELECT 'TT_MinInt'::text,                130,          3         UNION ALL
  SELECT 'TT_MaxInt'::text,                131,          3         UNION ALL
  SELECT 'TT_MinIndexCopyText'::text,      132,          9         UNION ALL
  SELECT 'TT_MaxIndexCopyText'::text,      133,          9         UNION ALL
  SELECT 'TT_MinIndexMapText'::text,       134,         11         UNION ALL
  SELECT 'TT_MaxIndexMapText'::text,       135,         11         UNION ALL
  SELECT 'TT_XMinusYDouble'::text,         138,          3         UNION ALL
  SELECT 'TT_DivideDouble'::text,          139,          5         UNION ALL
  SELECT 'TT_DivideInt'::text,             140,          2         UNION ALL
  SELECT 'TT_Multiply'::text,              142,          3         UNION ALL
  SELECT 'TT_MinIndexMapInt'::text,        143,          7         UNION ALL
  SELECT 'TT_MaxIndexMapInt'::text,        144,          7         UNION ALL
  SELECT 'TT_MinIndexCopyInt'::text,       145,          9         UNION ALL
  SELECT 'TT_MaxIndexCopyInt'::text,       146,          9         UNION ALL
  SELECT 'TT_LookupTextSubstring'::text,   147,          3         UNION ALL
  SELECT 'TT_CoalesceText'::text,          148,         14         UNION ALL
  SELECT 'TT_CoalesceInt'::text,           149,         10         UNION ALL
  SELECT 'TT_CountOfNotNullMapText'::text, 150,          5         UNION ALL
  SELECT 'TT_CountOfNotNullMapInt'::text,  151,          4         UNION ALL
  SELECT 'TT_CountOfNotNullMapDouble'::text,152,         4         UNION ALL
  SELECT 'TT_MapTextNotNullIndex'::text,   153,          9         UNION ALL
  SELECT 'TT_SubstringMultiplyInt'::text,  154,          3         UNION ALL
  SELECT 'TT_GetIndexCopyText'::text,      155,          9         UNION ALL
  SELECT 'TT_GetIndexMapText'::text,       156,         11         UNION ALL
  SELECT 'TT_GetIndexCopyInt'::text,       158,          9         UNION ALL
  SELECT 'TT_GetIndexMapInt'::text,        159,          7
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
SELECT '8.1'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL inclusive'::text description,
       TT_IsError('SELECT TT_IsGreaterThan(2::text, 4::text, NULL::text, TRUE::text)') = 'ERROR in TT_IsGreaterThan(): inclusive is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL acceptNull'::text description,
       TT_IsError('SELECT TT_IsGreaterThan(2::text, 4::text, TRUE::text, NULL::text)') = 'ERROR in TT_IsGreaterThan(): acceptNull is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '8.3'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Invalid inclusive'::text description,
       TT_IsError('SELECT TT_IsGreaterThan(2::text, 4::text, 10::text, TRUE::text)') = 'ERROR in TT_IsGreaterThan(): inclusive is not a boolean value' passed
---------------------------------------------------------
UNION ALL
SELECT '8.4'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Invalid acceptNull'::text description,
       TT_IsError('SELECT TT_IsGreaterThan(2::text, 4::text, TRUE::text, 10::text)') = 'ERROR in TT_IsGreaterThan(): acceptNull is not a boolean value' passed
---------------------------------------------------------
UNION ALL
SELECT '8.5'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL upper bound'::text description,
       TT_IsGreaterThan(9::text, NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.6'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Integer, good value'::text description,
       TT_IsGreaterThan(11::text, 10::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.7'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_IsGreaterThan(9::text, 10::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.8'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsGreaterThan(10.3::text, 10.2::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '8.9'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsGreaterThan(10.1::text, 10.2::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.10'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'Inclusive false'::text description,
       TT_IsGreaterThan(10::text, 10.0::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.11'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL val'::text description,
       TT_IsGreaterThan(NULL::text, 10.1::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '8.12'::text number,
       'TT_IsGreaterThan'::text function_tested,
       'NULL val and acceptNull true'::text description,
       TT_IsGreaterThan(NULL::text, 10.1::text, TRUE::text, TRUE::text) passed
---------------------------------------------------------
---------------------------------------------------------
-- Test 9 - TT_IsLessThan
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL inclusive'::text description,
       TT_IsError('SELECT TT_IsLessThan(2::text, 4::text, NULL::text, TRUE::text)') = 'ERROR in TT_IsLessThan(): inclusive is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL acceptNull'::text description,
       TT_IsError('SELECT TT_IsLessThan(2::text, 4::text, TRUE::text, NULL::text)') = 'ERROR in TT_IsLessThan(): acceptNull is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL upper bound'::text description,
       TT_IsError('SELECT TT_IsLessThan(2::text, 4::text, 10::text, TRUE::text)') = 'ERROR in TT_IsLessThan(): inclusive is not a boolean value' passed
---------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL upper bound'::text description,
       TT_IsError('SELECT TT_IsLessThan(2::text, 4::text, TRUE::text, 10::text)') = 'ERROR in TT_IsLessThan(): acceptNull is not a boolean value' passed
---------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL upper bound'::text description,
       TT_IsLessThan(9::text, NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.6'::text number,
       'TT_IsLessThan'::text function_tested,
       'Integer, good value'::text description,
       TT_IsLessThan(9::text, 10::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_IsLessThan'::text function_tested,
       'Integer, bad value'::text description,
       TT_IsLessThan(11::text, 10::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_IsLessThan'::text function_tested,
       'Double precision, good value'::text description,
       TT_IsLessThan(10.1::text, 10.7::text) passed
---------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_IsLessThan'::text function_tested,
       'Double precision, bad value'::text description,
       TT_IsLessThan(9.9::text, 9.5::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.10'::text number,
       'TT_IsLessThan'::text function_tested,
       'Inclusive false'::text description,
       TT_IsLessThan(10.1::text, 10.1::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.11'::text number,
       'TT_IsLessThan'::text function_tested,
       'NULL val'::text description,
       TT_IsLessThan(NULL::text, 10.1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '9.12'::text number,
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
       TT_MatchTable('RA'::text, 'public'::text, 'test_lookuptable1'::text, 'source_val'::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '11.8'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test text, fail'::text description,
       TT_MatchTable('RAA'::text, 'public'::text, 'test_lookuptable1'::text, 'source_val'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.9'::text number,
       'TT_MatchTable'::text function_tested,
       'val NULL text'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable1'::text, 'source_val'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.10'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, 'source_val'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.11'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, fail'::text description,
       TT_MatchTable(1.5::text, 'public'::text, 'test_lookuptable3'::text, 'source_val'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.12'::text number,
       'TT_MatchTable'::text function_tested,
       'NULL val double precision'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable3'::text, 'source_val'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.13'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test integer, pass'::text description,
       TT_MatchTable(1::text, 'public'::text, 'test_lookuptable2'::text, 'source_val'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.14'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test integer, fail'::text description,
       TT_MatchTable(5::text, 'public'::text, 'test_lookuptable2'::text, 'source_val'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.15'::text number,
       'TT_MatchTable'::text function_tested,
       'NULL val integer'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable2'::text, 'source_val'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.16'::text number,
       'TT_MatchTable'::text function_tested,
       'Test ignoreCase when false'::text description,
       TT_MatchTable('ra'::text, 'public'::text, 'test_lookuptable1'::text, 'source_val'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '11.17'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass, ignore case false'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, 'source_val'::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.18'::text number,
       'TT_MatchTable'::text function_tested,
       'Test ignoreCase when true'::text description,
       TT_MatchTable('ra'::text, 'public'::text, 'test_lookuptable1'::text, 'source_val'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.19'::text number,
       'TT_MatchTable'::text function_tested,
       'Simple test double precision, pass, ingore case true'::text description,
       TT_MatchTable(1.1::text, 'public'::text, 'test_lookuptable3'::text, 'source_val'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.20'::text number,
       'TT_MatchTable'::text function_tested,
       'Test null with acceptNull true'::text description,
       TT_MatchTable(NULL::text, 'public'::text, 'test_lookuptable3'::text, 'source_val'::text, TRUE::text, TRUE::text) passed
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
                                            'removeSpaces', 'boolean', 
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
       TT_IsIntSubstring(NULL::text, 1::text, 4::text, FALSE::text, TRUE::text) passed
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
-- Test 24 - TT_MinIndexNotNull
---------------------------------------------------------
UNION ALL
SELECT '24.1'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Passes basic test, true'::text description,
       TT_MinIndexNotNull('{1990, 2000}', '{burn, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '24.2'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Passes basic test, false'::text description,
       TT_MinIndexNotNull('{1990, 2000}', '{null, wind}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '24.3'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Matching ints return first not null index'::text description,
       TT_MinIndexNotNull('{1990, 1990}', '{null, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '24.4'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_MinIndexNotNull('{1990, null}', '{null, wind}', '0', null::text) passed
---------------------------------------------------------
UNION ALL
SELECT '24.5'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_MinIndexNotNull('{1990, null}', '{burn, null}', '0', null::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '24.6'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Test all null ints, should return first not null return value'::text description,
       TT_MinIndexNotNull('{null, null}', '{null, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '24.7'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Test matching years with null returns'::text description,
       TT_MinIndexNotNull('{2000, 2000}', '{null, null}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '24.8'::text number,
       'TT_MinIndexNotNull'::text function_tested,
       'Test setZeroTo, true'::text description,
       TT_MinIndexNotNull('{-1, 0}', '{null, wind}', null::text, '-2') passed
---------------------------------------------------------
-- Test 25 - TT_MinIndexNotNull
---------------------------------------------------------
UNION ALL
SELECT '25.1'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Passes basic test, true'::text description,
       TT_MaxIndexNotNull('{1990, 2000}', '{burn, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '25.2'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Passes basic test, false'::text description,
       TT_MaxIndexNotNull('{1990, 2000}', '{burn, null}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '25.3'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Matching ints return last not null index'::text description,
       TT_MaxIndexNotNull('{1990, 1990}', '{burn, null}') passed
---------------------------------------------------------
UNION ALL
SELECT '25.4'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_MaxIndexNotNull('{1990, null}', '{null, wind}', '9999', null::text) passed
---------------------------------------------------------
UNION ALL
SELECT '25.5'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_MaxIndexNotNull('{1990, null}', '{burn, null}', '9999', null::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '25.6'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Test all null ints'::text description,
       TT_MaxIndexNotNull('{null, null}', '{burn, null}') passed
---------------------------------------------------------
UNION ALL
SELECT '25.7'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Test matching years with null returns'::text description,
       TT_MaxIndexNotNull('{2000, 2000}', '{null, null}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '25.8'::text number,
       'TT_MaxIndexNotNull'::text function_tested,
       'Test setZeroTo, true'::text description,
       TT_MaxIndexNotNull('{1990, 0}', '{null, wind}', null::text, '9999') passed
---------------------------------------------------------
-- Test 26 - TT_IsXMinusYBetween
---------------------------------------------------------
UNION ALL
SELECT '26.1'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'Passes basic test'::text description,
       TT_IsXMinusYBetween('2005', '5', '1999', '2000') passed
---------------------------------------------------------
UNION ALL
SELECT '26.2'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'Passes basic test, include false'::text description,
       TT_IsXMinusYBetween('2005', '5', '1999', '2000', 'FALSE', 'FALSE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '26.3'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'Fails basic test'::text description,
       TT_IsXMinusYBetween('2005', '6', '1999', '2000') passed
---------------------------------------------------------
UNION ALL
SELECT '26.4'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'min is null'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', NULL::text, ''2000'')') = 'ERROR in TT_IsXMinusYBetween(): min is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '26.5'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'max is null'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''1999'', NULL::text)') = 'ERROR in TT_IsXMinusYBetween(): max is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '26.6'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'includeMin is null'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''1999'', ''2000'', NULL::text, ''FALSE'')') = 'ERROR in TT_IsXMinusYBetween(): includeMin is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '26.7'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'includeMax is null'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''1999'', ''2000'', ''FALSE'', NULL::text)') = 'ERROR in TT_IsXMinusYBetween(): includeMax is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '26.8'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'min is wrong type'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''x'', ''2000'')') = 'ERROR in TT_IsXMinusYBetween(): min is not a numeric value' passed
---------------------------------------------------------
UNION ALL
SELECT '26.9'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'max is wrong type'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''1999'', ''x'')') = 'ERROR in TT_IsXMinusYBetween(): max is not a numeric value' passed
---------------------------------------------------------
UNION ALL
SELECT '26.10'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'includeMin is wrong type'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''1999'', ''2000'', ''x'', ''FALSE'')') = 'ERROR in TT_IsXMinusYBetween(): includeMin is not a boolean value' passed
---------------------------------------------------------
UNION ALL
SELECT '26.11'::text number,
       'TT_IsXMinusYBetween'::text function_tested,
       'includeMax is wrong type'::text description,
       TT_IsError('SELECT TT_IsXMinusYBetween(''2005'', ''6'', ''1999'', ''2000'', ''FALSE'', ''x'')') = 'ERROR in TT_IsXMinusYBetween(): includeMax is not a boolean value' passed
---------------------------------------------------------
-- Test 27 - TT_MatchListTwice
---------------------------------------------------------
UNION ALL
SELECT '27.1'::text number,
       'TT_MatchListTwice'::text function_tested,
       'Null lst1'::text description,
       TT_IsError('SELECT TT_MatchListTwice(''a'', ''b'', NULL::text, ''{''''b''''}'')') = 'ERROR in TT_MatchListTwice(): lst1 is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '27.2'::text number,
       'TT_MatchListTwice'::text function_tested,
       'Null lst2'::text description,
       TT_IsError('SELECT TT_MatchListTwice(''a'', ''b'', ''{''''b''''}'', NULL::text)') = 'ERROR in TT_MatchListTwice(): lst2 is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '27.3'::text number,
       'TT_MatchListTwice'::text function_tested,
       'Wrong type lst1'::text description,
       TT_IsError('SELECT TT_MatchListTwice(''a'', ''b'', ''{string1}}}'', ''{''''b''''}'')') = 'ERROR in TT_MatchListTwice(): lst1 is not a stringlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '27.4'::text number,
       'TT_MatchListTwice'::text function_tested,
       'Wrong type lst2'::text description,
       TT_IsError('SELECT TT_MatchListTwice(''a'', ''b'', ''{''''b''''}'', ''{string1}}}'')') = 'ERROR in TT_MatchListTwice(): lst2 is not a stringlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '27.5'::text number,
       'TT_MatchListTwice'::text function_tested,
       'First val passes'::text description,
       TT_MatchListTwice('a', 'b', '{''a''}', '{''c''}') passed
---------------------------------------------------------
UNION ALL
SELECT '27.6'::text number,
       'TT_MatchListTwice'::text function_tested,
       'Second val passes'::text description,
       TT_MatchListTwice('a', 'b', '{''c''}', '{''b''}') passed
---------------------------------------------------------
UNION ALL
SELECT '27.7'::text number,
       'TT_MatchListTwice'::text function_tested,
       'Both false'::text description,
       TT_MatchListTwice('a', 'b', '{''c''}', '{''c''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '27.7'::text number,
       'TT_MatchListTwice'::text function_tested,
       'val1 null'::text description,
       TT_MatchListTwice(NULL::text, 'b', '{''''}', '{''b''}') passed
---------------------------------------------------------
UNION ALL
SELECT '27.8'::text number,
       'TT_MatchListTwice'::text function_tested,
       'val2 null'::text description,
       TT_MatchListTwice('a', NULL::text, '{''a''}', '{''b''}') passed
---------------------------------------------------------
UNION ALL
SELECT '27.9'::text number,
       'TT_MatchListTwice'::text function_tested,
       'val1 and val2 null'::text description,
       TT_MatchListTwice(NULL::text, NULL::text, '{''a''}', '{''b''}') IS FALSE passed
---------------------------------------------------------
-- Test 28 - TT_HasCountOfNotNullOrZero
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (4 tests)
SELECT (TT_TestNullAndWrongTypeParams(28, 'TT_HasCountOfNotNullOrZero',
                                      ARRAY['count', 'int',
                                            'exact', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '28.5'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'exact true'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''a''}'::text, 2::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '28.6'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'exact false, passes'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''a''}'::text, 1::text, FALSE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '28.7'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'exact true, fails'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''a''}'::text, 1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '28.8'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'exact false, fails'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''a''}'::text, 3::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '28.9'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'passes with nulls'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''a''}'::text, NULL, 2::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '28.10'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'fails with nulls'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''a''}'::text, NULL, 1::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '28.11'::text number,
       'TT_HasCountOfNotNullOrZero'::text function_tested,
       'Zero as null'::text description,
       TT_HasCountOfNotNullOrZero('{''a''}'::text, '{''0''}'::text, NULL, 1::text, TRUE::text) passed
---------------------------------------------------------
-- Test 29 - TT_LookupTextMatchList
---------------------------------------------------------
UNION ALL
SELECT '29.1'::text number,
       'TT_LookupTextMatchList'::text function_tested,
       'Matches'::text description,
       TT_LookupTextMatchList('ACB', 'public', 'test_lookuptable1', 'target_val', 'Popu balb') passed
UNION ALL
SELECT '29.2'::text number,
       'TT_LookupTextMatchList'::text function_tested,
       'Matches with multiple test vals'::text description,
       TT_LookupTextMatchList('ACB', 'public', 'test_lookuptable1', 'target_val', '{''Popu balb'', ''Pice mari''}') passed
UNION ALL
SELECT '29.3'::text number,
       'TT_LookupTextMatchList'::text function_tested,
       'Matches with multiple test vals'::text description,
       TT_LookupTextMatchList('ACB', 'public', 'test_lookuptable1', 'target_val', '{''Popu bal'', ''Pice mari''}') IS FALSE passed
UNION ALL
SELECT '29.4'::text number,
       'TT_LookupTextMatchList'::text function_tested,
       'Matches with multiple test vals'::text description,
       TT_LookupTextMatchList('', 'public', 'test_lookuptable1', 'target_val', '{''Popu bal'', ''Pice mari''}') IS FALSE passed
UNION ALL
SELECT '29.5'::text number,
       'TT_LookupTextMatchList'::text function_tested,
       'Matches with multiple test vals'::text description,
       TT_LookupTextMatchList(NULL::text, 'public', 'test_lookuptable1', 'target_val', '{''Popu bal'', ''Pice mari''}') IS FALSE passed
---------------------------------------------------------
-- Test 30 - TT_MinIndexIsInt
---------------------------------------------------------
UNION ALL
SELECT '30.1'::text number,
       'TT_MinIndexIsInt'::text function_tested,
       'Simple pass'::text description,
       TT_MinIndexIsInt('{1,2,3}', '{1,2.2,3.3}') passed
UNION ALL
SELECT '30.2'::text number,
       'TT_MinIndexIsInt'::text function_tested,
       'Fails double'::text description,
       TT_MinIndexIsInt('{1,2,3}', '{1.1,2.2,3.3}') IS FALSE passed
UNION ALL
SELECT '30.3'::text number,
       'TT_MinIndexIsInt'::text function_tested,
       'Fails text'::text description,
       TT_MinIndexIsInt('{1,2,3}', '{a,2.2,3.3}') IS FALSE passed
UNION ALL
SELECT '30.4'::text number,
       'TT_MinIndexIsInt'::text function_tested,
       'Test set null'::text description,
       TT_MinIndexIsInt('{1,null,3}', '{1.1,2,3.3}', '0', null::text) passed
UNION ALL
SELECT '30.5'::text number,
       'TT_MinIndexIsInt'::text function_tested,
       'Test set null'::text description,
       TT_MinIndexIsInt('{1,0,3}', '{1.1,2,3.3}', null::text, '0.5') passed
---------------------------------------------------------
-- Test 31 - TT_MaxIndexIsInt
---------------------------------------------------------
UNION ALL
SELECT '31.1'::text number,
       'TT_MaxIndexIsInt'::text function_tested,
       'Simple pass'::text description,
       TT_MaxIndexIsInt('{1,2,3}', '{1.1,2.2,3}') passed
UNION ALL
SELECT '31.2'::text number,
       'TT_MaxIndexIsInt'::text function_tested,
       'Fails double'::text description,
       TT_MaxIndexIsInt('{1,2,3}', '{1.1,2.2,3.3}') IS FALSE passed
UNION ALL
SELECT '31.3'::text number,
       'TT_MaxIndexIsInt'::text function_tested,
       'Fails text'::text description,
       TT_MaxIndexIsInt('{1,2,3}', '{1,2,a}') IS FALSE passed
UNION ALL
SELECT '31.4'::text number,
       'TT_MaxIndexIsInt'::text function_tested,
       'Test set null'::text description,
       TT_MaxIndexIsInt('{1,null,3}', '{1.1,2,3.3}', '4', null::text) passed
UNION ALL
SELECT '31.5'::text number,
       'TT_MaxIndexIsInt'::text function_tested,
       'Test set zero'::text description,
       TT_MaxIndexIsInt('{1,0,3}', '{1.1,2,3.3}', null::text, '4') passed
---------------------------------------------------------
-- Test 32 - TT_MinIndexIsBetween
---------------------------------------------------------
UNION ALL
SELECT '32.1'::text number,
       'TT_MinIndexIsBetween'::text function_tested,
       'Simple pass'::text description,
       TT_MinIndexIsBetween('{1,2,3}', '{0,2,5}', '0', '2') passed
UNION ALL
SELECT '32.2'::text number,
       'TT_MinIndexIsBetween'::text function_tested,
       'Pass with setNull'::text description,
       TT_MinIndexIsBetween('{1,null,3}', '{0,2,5}', '1', '3', '-1', null::text) passed
UNION ALL
SELECT '32.3'::text number,
       'TT_MinIndexIsBetween'::text function_tested,
       'Simple fail'::text description,
       TT_MinIndexIsBetween('{1,2,3}', '{1,2,3}', '2', '3') IS FALSE passed
UNION ALL
SELECT '32.4'::text number,
       'TT_MinIndexIsBetween'::text function_tested,
       'Test setZero'::text description,
       TT_MinIndexIsBetween('{1,0,3}', '{0,2,5}', '1', '3', null::text, '-1') passed
---------------------------------------------------------
-- Test 33 - TT_MaxIndexIsBetween
---------------------------------------------------------
UNION ALL
SELECT '33.1'::text number,
       'TT_MaxIndexIsBetween'::text function_tested,
       'Simple pass'::text description,
       TT_MaxIndexIsBetween('{1,2,3}', '{1,2,3}', '3', '3.1') passed
UNION ALL
SELECT '33.2'::text number,
       'TT_MaxIndexIsBetween'::text function_tested,
       'Pass with setNull'::text description,
       TT_MaxIndexIsBetween('{1,null,3}', '{0,10,5}', '9', '10', '10', null::text) passed
UNION ALL
SELECT '33.3'::text number,
       'TT_MaxIndexIsBetween'::text function_tested,
       'Simple fail'::text description,
       TT_MaxIndexIsBetween('{1,2,3}', '{1,2,3}', '1', '2') IS FALSE passed
UNION ALL
SELECT '33.4'::text number,
       'TT_MaxIndexIsBetween'::text function_tested,
       'Test setZero'::text description,
       TT_MaxIndexIsBetween('{1,2,0}', '{1,20,30}', '29', '31', null::text, '10') passed
---------------------------------------------------------
-- Test 34 - TT_MinIndexMatchList
---------------------------------------------------------
UNION ALL
SELECT '34.1'::text number,
       'TT_MinIndexMatchList'::text function_tested,
       'Simple pass'::text description,
       TT_MinIndexMatchList('{1,2,3}', '{a,b,c}', '{a, y, z}') passed
UNION ALL
SELECT '34.2'::text number,
       'TT_MinIndexMatchList'::text function_tested,
       'Simple fail'::text description,
       TT_MinIndexMatchList('{1,2,3}', '{a,b,c}', '{x, y, z}') IS FALSE passed
UNION ALL
SELECT '34.3'::text number,
       'TT_MinIndexMatchList'::text function_tested,
       'Test setNull'::text description,
       TT_MinIndexMatchList('{1,null,3}', '{a,b,c}', '{b, y, z}', '0', null::text) passed
UNION ALL
SELECT '34.4'::text number,
       'TT_MinIndexMatchList'::text function_tested,
       'Test setZero'::text description,
       TT_MinIndexMatchList('{1,0,3}', '{a,b,c}', '{b, y, z}', null::text, '0') passed
---------------------------------------------------------
-- Test 35 - TT_MaxIndexMatchList
---------------------------------------------------------
UNION ALL
SELECT '35.1'::text number,
       'TT_MaxIndexMatchList'::text function_tested,
       'Simple pass'::text description,
       TT_MaxIndexMatchList('{1,2,3}', '{a,b,c}', '{c, y, z}') passed
UNION ALL
SELECT '35.2'::text number,
       'TT_MaxIndexMatchList'::text function_tested,
       'Simple fail'::text description,
       TT_MaxIndexMatchList('{1,2,3}', '{a,b,c}', '{x, y, z}') IS FALSE passed
UNION ALL
SELECT '35.3'::text number,
       'TT_MaxIndexMatchList'::text function_tested,
       'Test setNull'::text description,
       TT_MaxIndexMatchList('{1,null,3}', '{a,b,c}', '{b, y, z}', '4', null::text) passed
UNION ALL
SELECT '35.4'::text number,
       'TT_MaxIndexMatchList'::text function_tested,
       'Test setZero'::text description,
       TT_MaxIndexMatchList('{1,0,3}', '{a,b,c}', '{b, y, z}', null::text, '4') passed
---------------------------------------------------------
-- Test 36 - TT_MatchTableSubstring
---------------------------------------------------------
UNION ALL
SELECT '36.1'::text number,
       'TT_MatchTableSubstring'::text function_tested,
       'Simple test text, pass'::text description,
       TT_MatchTableSubstring('RA00'::text, '1', '2', 'public'::text, 'test_lookuptable1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '36.2'::text number,
       'TT_MatchTableSubstring'::text function_tested,
       'Simple test text, fail'::text description,
       TT_MatchTableSubstring('RA00'::text, '1', '3', 'public'::text, 'test_lookuptable1'::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '36.3'::text number,
       'TT_MatchTableSubstring'::text function_tested,
       'val NULL text'::text description,
       TT_MatchTableSubstring(NULL::text, '1', '3', 'public'::text, 'test_lookuptable1'::text) IS FALSE passed
---------------------------------------------------------
-- Test 37 - TT_minIndexNotEmpty
---------------------------------------------------------
UNION ALL
SELECT '37.1'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Passes basic test, true'::text description,
       TT_MinIndexNotEmpty('{1990, 2000}', '{burn, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '37.2'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Passes basic test, false'::text description,
       TT_MinIndexNotEmpty('{1990, 2000}', '{'', wind}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '37.3'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Matching ints return first string'::text description,
       TT_MinIndexNotEmpty('{1990, 1990}', '{wind, ''}') passed
---------------------------------------------------------
UNION ALL
SELECT '37.4'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_MinIndexNotEmpty('{1990, null}', '{'', wind}', '0', null::text) passed
---------------------------------------------------------
UNION ALL
SELECT '37.5'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_MinIndexNotEmpty('{1990, null}', '{burn, ''}', '0', null::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '37.6'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Test all null ints, should return first not null return value'::text description,
       TT_MinIndexNotEmpty('{null, null}', '{'', wind}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '37.7'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Test matching years with null returns'::text description,
       TT_MinIndexNotEmpty('{2000, 2000}', '{'', ''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '37.8'::text number,
       'TT_MinIndexNotEmpty'::text function_tested,
       'Test setZeroTo, true'::text description,
       TT_MinIndexNotEmpty('{-1, 0}', '{'', wind}', null::text, '-2') passed
---------------------------------------------------------
-- Test 38 - TT_MaxIndexNotEmpty
---------------------------------------------------------
UNION ALL
SELECT '38.1'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Passes basic test, true'::text description,
       TT_MaxIndexNotEmpty('{1990, 2000}', '{burn, wind}') passed
---------------------------------------------------------
UNION ALL
SELECT '38.2'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Passes basic test, false'::text description,
       TT_MaxIndexNotEmpty('{1990, 2000}', '{burn, ''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '38.3'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Matching ints return last not null index'::text description,
       TT_MaxIndexNotEmpty('{1990, 1990}', '{burn, ''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '38.4'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_MaxIndexNotEmpty('{1990, null}', '{'', wind}', '9999', null::text) passed
---------------------------------------------------------
UNION ALL
SELECT '38.5'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_MaxIndexNotEmpty('{1990, null}', '{burn, ''}', '9999', null::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '38.6'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Test all null ints, returns last string'::text description,
       TT_MaxIndexNotEmpty('{null, null}', '{burn, ''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '38.7'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Test matching years with null returns'::text description,
       TT_MaxIndexNotEmpty('{2000, 2000}', '{x, ''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '38.8'::text number,
       'TT_MaxIndexNotEmpty'::text function_tested,
       'Test setZeroTo, true'::text description,
       TT_MaxIndexNotEmpty('{1990, 0}', '{'', wind}', null::text, '9999') passed  
---------------------------------------------------------
-- Test 39 - TT_CoalesceIsInt
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (2 tests)
SELECT (TT_TestNullAndWrongTypeParams(39, 'TT_CoalesceIsInt', ARRAY['zeroAsNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '39.3'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'Basic test'::text description,
       TT_CoalesceIsInt('{NULL, ''0'', ''a''}') passed  
---------------------------------------------------------
UNION ALL
SELECT '39.4'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'First non NULL and non zero value not int'::text description,
       TT_CoalesceIsInt('{NULL, ''0'', ''a''}', TRUE::text) IS FALSE passed 
---------------------------------------------------------
UNION ALL
SELECT '39.5'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'First non NULL and non zero value int'::text description,
       TT_CoalesceIsInt('{NULL, ''0'', ''1''}', TRUE::text) passed 
---------------------------------------------------------
UNION ALL
SELECT '39.6'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'NULL valList'::text description,
       TT_CoalesceIsInt(NULL) IS FALSE passed 
---------------------------------------------------------
UNION ALL
SELECT '39.7'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'NULL as string'::text description,
       TT_CoalesceIsInt('NULL') IS FALSE passed 
---------------------------------------------------------
UNION ALL
SELECT '39.8'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'valList of one NULL'::text description,
       TT_CoalesceIsInt('{NULL}') IS FALSE passed 
---------------------------------------------------------
UNION ALL
SELECT '39.9'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'valList of many NULL'::text description,
       TT_CoalesceIsInt('{NULL, NULL, NULL}') IS FALSE passed 
---------------------------------------------------------
UNION ALL
SELECT '39.10'::text number,
       'TT_CoalesceIsInt'::text function_tested,
       'valList of many NULL'::text description,
       TT_CoalesceIsInt('{NULL, NULL, NULL, 1}') passed
---------------------------------------------------------
-- Test 40 - TT_CoalesceIsBetween
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (12 tests)
SELECT (TT_TestNullAndWrongTypeParams(40, 'TT_CoalesceIsBetween', 
                                      ARRAY['min', 'numeric',
                                            'max', 'numeric',
                                            'includeMin', 'boolean',
                                            'includeMax', 'boolean',
                                            'zeroAsNull', 'boolean'])).*
---------------------------------------------------------
UNION ALL
SELECT '40.3'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'Basic test 1'::text description,
       TT_CoalesceIsBetween('{NULL, ''0'', ''a''}', 0::text, 5::text) passed  
---------------------------------------------------------
UNION ALL
SELECT '40.4'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'Basic test 2'::text description,
       TT_CoalesceIsBetween('{NULL, ''6'', ''a''}', 0::text, 5::text) IS FALSE passed  
---------------------------------------------------------
UNION ALL
SELECT '40.5'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'Non integer first non-NULL'::text description,
       TT_CoalesceIsBetween('{NULL, ''a'', ''4''}', 0::text, 5::text) IS FALSE passed  
---------------------------------------------------------
UNION ALL
SELECT '40.6'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'Only NULLs'::text description,
       TT_CoalesceIsBetween('{NULL, NULL, NULL}', 0::text, 5::text) IS FALSE passed  
---------------------------------------------------------
UNION ALL
SELECT '40.7'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'First non-NULL value 0.0'::text description,
       TT_CoalesceIsBetween('{NULL, ''0.0'', ''2'', ''a''}', 0::text, 5::text) passed  
---------------------------------------------------------
UNION ALL
SELECT '40.8'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'First non-NULL value 0.0 but not included'::text description,
       TT_CoalesceIsBetween('{NULL, ''0.0'', ''2'', ''a''}', 0::text, 5::text, FALSE::text, FALSE::text) IS FALSE passed  
---------------------------------------------------------
UNION ALL
SELECT '40.9'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'First non-NULL value 0.0 but not included'::text description,
       TT_CoalesceIsBetween('{NULL, ''0.0'', ''5'', ''a''}', 0::text, 5::text, FALSE::text, FALSE::text) IS FALSE passed  
---------------------------------------------------------
UNION ALL
SELECT '40.10'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'First non-NULL value 2 but not included'::text description,
       TT_CoalesceIsBetween('{NULL, ''0.0'', ''2'', ''a''}', 0::text, 5::text, FALSE::text, FALSE::text, TRUE::text) passed  
---------------------------------------------------------
UNION ALL
SELECT '40.11'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'First non-NULL value 5 but not included'::text description,
       TT_CoalesceIsBetween('{NULL, ''0.0'', ''5'', ''a''}', 0::text, 5::text, FALSE::text, FALSE::text, TRUE::text) IS FALSE passed  
---------------------------------------------------------
UNION ALL
SELECT '40.12'::text number,
       'TT_CoalesceIsBetween'::text function_tested,
       'First non-NULL value 5 but not included'::text description,
       TT_CoalesceIsBetween('{NULL, ''0.0'', ''5'', ''a''}', 0::text, 5::text, FALSE::text, FALSE::text, TRUE::text) IS FALSE passed  
---------------------------------------------------------
-- Test 44 - TT_HasCountOfMatchList
---------------------------------------------------------
UNION ALL
SELECT '44.1'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Simple pass all 10'::text description,
       TT_HasCountOfMatchList('a', '{a,b,c}', 'b', '{a,b,c}',  'c', '{a,b,c}', 'd', '{a,b,c}', 'e', '{a,b,c}', 'f', '{a,b,c}', 'g', '{a,b,c}', 'h', '{a,b,c}', 'i', '{a,b,c}', 'j', '{a,b,c}', '3', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '44.2'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Simple pass 2 tests'::text description,
       TT_HasCountOfMatchList('a', '{a,b,c}', 'b', '{a,b,c}', '2', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '44.3'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test a fail with exact TRUE'::text description,
       TT_HasCountOfMatchList('a', '{a,b,c}', 'd', '{a,b,c}', '2', 'TRUE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '44.4'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test a pass with exact FALSE'::text description,
       TT_HasCountOfMatchList('a', '{a,b,c}', 'b', '{a,b,c}', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '44.4'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test a fail with exact FALSE'::text description,
       TT_HasCountOfMatchList('a', '{a,b,c}', 'd', '{a,b,c}', '2', 'FALSE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '44.5'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test count is not int'::text description,
       TT_IsError('SELECT TT_HasCountOfMatchList(''a'', ''{a,b,c}'', ''d'', ''{a,b,c}'', ''x'', ''FALSE'')') = 'ERROR in TT_HasCountOfMatchList(): count is not a int value' passed
---------------------------------------------------------
UNION ALL
SELECT '44.6'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test count is null'::text description,
       TT_IsError('SELECT TT_HasCountOfMatchList(''a'', ''{a,b,c}'', ''d'', ''{a,b,c}'', NULL::text, ''FALSE'')') = 'ERROR in TT_HasCountOfMatchList(): count is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '44.7'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test exact is not boolean'::text description,
       TT_IsError('SELECT TT_HasCountOfMatchList(''a'', ''{a,b,c}'', ''d'', ''{a,b,c}'', ''1'', ''x'')') = 'ERROR in TT_HasCountOfMatchList(): exact is not a boolean value' passed
---------------------------------------------------------
UNION ALL
SELECT '44.8'::text number,
       'TT_HasCountOfMatchList'::text function_tested,
       'Test exact is null'::text description,
       TT_IsError('SELECT TT_HasCountOfMatchList(''a'', ''{a,b,c}'', ''d'', ''{a,b,c}'', ''1'', NULL::text)') = 'ERROR in TT_HasCountOfMatchList(): exact is NULL' passed
---------------------------------------------------------
-- Test 45 - TT_AlphaNumericMatchList
---------------------------------------------------------
UNION ALL
SELECT '45.1'::text number,
       'TT_AlphaNumericMatchList'::text function_tested,
       'Simple pass'::text description,
       TT_AlphaNumericMatchList('ab1cd2ef3', '{''xx0xx0xx0''}') passed
---------------------------------------------------------
UNION ALL
SELECT '45.2'::text number,
       'TT_AlphaNumericMatchList'::text function_tested,
       'Simple fail'::text description,
       TT_AlphaNumericMatchList('ab1cd2efg', '{''xx0xx0xx0''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '45.3'::text number,
       'TT_AlphaNumericMatchList'::text function_tested,
       'Remove spaces'::text description,
       TT_AlphaNumericMatchList('ab1 cd2ef3', '{''xx0xx0xx0''}', 'FALSE', 'TRUE', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '45.4'::text number,
       'TT_AlphaNumericMatchList'::text function_tested,
       'Spaces fail'::text description,
       TT_AlphaNumericMatchList('ab1 cd2ef3', '{''xx0xx0xx0''}', 'FALSE', 'TRUE', 'FALSE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '45.5'::text number,
       'TT_AlphaNumericMatchList'::text function_tested,
       'Spaces pass'::text description,
       TT_AlphaNumericMatchList('ab1 cd2ef3', '{''xx0xx0xx0'', ''xx0 xx0xx0''}') passed
---------------------------------------------------------
UNION ALL
SELECT '45.6'::text number,
       'TT_AlphaNumericMatchList'::text function_tested,
       'Check special characters carry through'::text description,
       TT_AlphaNumericMatchList('ab1cd2ef/', '{''xx0xx0xx0'', ''xx0xx0xx/''}') passed
---------------------------------------------------------
-- Test 46 - TT_AlphaNumericLookupTextMatchList
---------------------------------------------------------
UNION ALL
SELECT '46.1'::text number,
       'TT_AlphaNumericLookupTextMatchList'::text function_tested,
       'Simple pass'::text description,
       TT_AlphaNumericLookupTextMatchList('a 1', 'public', 'alpha_numeric_test_table', 'species_count', '{''1''}') passed
---------------------------------------------------------
UNION ALL
SELECT '46.2'::text number,
       'TT_AlphaNumericLookupTextMatchList'::text function_tested,
       'Simple pass 2'::text description,
       TT_AlphaNumericLookupTextMatchList('ab 1xx 9', 'public', 'alpha_numeric_test_table', 'species_count', '{''1'', ''2''}') passed
---------------------------------------------------------
-- Test 47 - TT_AlphaNumericMatchTable
---------------------------------------------------------
UNION ALL
SELECT '47.1'::text number,
       'TT_AlphaNumericMatchTable'::text function_tested,
       'Simple pass'::text description,
       TT_AlphaNumericMatchTable('s 0', 'public', 'alpha_numeric_test_table') passed
---------------------------------------------------------
UNION ALL
SELECT '47.2'::text number,
       'TT_AlphaNumericMatchTable'::text function_tested,
       'Simple pass 2'::text description,
       TT_AlphaNumericMatchTable('ss 0bs 9', 'public', 'alpha_numeric_test_table') passed
---------------------------------------------------------
UNION ALL
SELECT '47.3'::text number,
       'TT_AlphaNumericMatchTable'::text function_tested,
       'Simple fail'::text description,
       TT_AlphaNumericMatchTable('ss 0bs 99', 'public', 'alpha_numeric_test_table') IS FALSE passed
---------------------------------------------------------
-- Test 48 - TT_GetIndexNotNull
---------------------------------------------------------
UNION ALL
SELECT '48.1'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Passes basic test, true'::text description,
       TT_GetIndexNotNull('{1990, 2000}', '{burn, wind}', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '48.2'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Passes basic test, false'::text description,
       TT_GetIndexNotNull('{1990, 2000}', '{null, wind}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '48.3'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Test index 2'::text description,
       TT_GetIndexNotNull('{1990, 2000}', '{null, wind}', '2') passed
---------------------------------------------------------
UNION ALL
SELECT '48.4'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_GetIndexNotNull('{1990, null}', '{null, wind}', '0', null::text, '1') passed
---------------------------------------------------------
UNION ALL
SELECT '48.5'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_GetIndexNotNull('{1990, null}', '{burn, null}', '0', null::text, '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '48.6'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Test all null ints, should return first not null return value'::text description,
       TT_GetIndexNotNull('{null, null}', '{null, wind}', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '48.7'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Test matching years with null returns'::text description,
       TT_GetIndexNotNull('{2000, 2000}', '{null, null}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '48.8'::text number,
       'TT_GetIndexNotNull'::text function_tested,
       'Test setZeroTo, true'::text description,
       TT_GetIndexNotNull('{-1, 0}', '{null, wind}', null::text, '-2', '1') passed
---------------------------------------------------------
-- Test 49 - TT_GetIndexIsInt
---------------------------------------------------------
UNION ALL
SELECT '49.1'::text number,
       'TT_GetIndexIsInt'::text function_tested,
       'Simple pass'::text description,
       TT_GetIndexIsInt('{1,2,3}', '{1,2.2,3.3}', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '49.2'::text number,
       'TT_GetIndexIsInt'::text function_tested,
       'Fails double'::text description,
       TT_GetIndexIsInt('{1,2,3}', '{1.1,2.2,3.3}', '3') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '49.3'::text number,
       'TT_GetIndexIsInt'::text function_tested,
       'Fails text'::text description,
       TT_GetIndexIsInt('{1,2,3}', '{a,2.2,3.3}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '49.4'::text number,
       'TT_GetIndexIsInt'::text function_tested,
       'Test set null'::text description,
       TT_GetIndexIsInt('{1,null,3}', '{1.1,2,3.3}', '2', null::text, '2') passed
---------------------------------------------------------
UNION ALL
SELECT '49.5'::text number,
       'TT_GetIndexIsInt'::text function_tested,
       'Test set zero'::text description,
       TT_GetIndexIsInt('{1,0,3}', '{1.1,2,3.3}', null::text, '0.5', '1') passed
---------------------------------------------------------
-- Test 50 - TT_GetIndexIsBetween
---------------------------------------------------------
UNION ALL
SELECT '50.1'::text number,
       'TT_GetIndexIsBetween'::text function_tested,
       'Simple pass'::text description,
       TT_GetIndexIsBetween('{1,2,3}', '{0,2,5}', '0', '2', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '50.2'::text number,
       'TT_GetIndexIsBetween'::text function_tested,
       'Pass with setNull'::text description,
       TT_GetIndexIsBetween('{1,null,3}', '{0,2,5}', '1', '3', '2', null::text, '2') passed
---------------------------------------------------------
UNION ALL
SELECT '50.3'::text number,
       'TT_GetIndexIsBetween'::text function_tested,
       'Simple fail'::text description,
       TT_GetIndexIsBetween('{1,2,3}', '{1,2,3}', '2', '3', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '50.4'::text number,
       'TT_GetIndexIsBetween'::text function_tested,
       'Test setZero'::text description,
       TT_GetIndexIsBetween('{1,0,3}', '{0,2,5}', '1', '3', null::text, '-1', '1') passed
---------------------------------------------------------
-- Test 51 - TT_GetIndexMatchList
---------------------------------------------------------
UNION ALL
SELECT '51.1'::text number,
       'TT_GetIndexMatchList'::text function_tested,
       'Simple pass'::text description,
       TT_GetIndexMatchList('{1,2,3}', '{a,b,c}', '{a, y, z}', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '51.2'::text number,
       'TT_GetIndexMatchList'::text function_tested,
       'Simple fail'::text description,
       TT_GetIndexMatchList('{1,2,3}', '{a,b,c}', '{x, y, z}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '51.3'::text number,
       'TT_GetIndexMatchList'::text function_tested,
       'Test setNull'::text description,
       TT_GetIndexMatchList('{1,null,3}', '{a,b,c}', '{b, y, z}', '0', null::text, '1') passed
---------------------------------------------------------
UNION ALL
SELECT '51.4'::text number,
       'TT_GetIndexMatchList'::text function_tested,
       'Test setZero'::text description,
       TT_GetIndexMatchList('{1,0,3}', '{a,b,c}', '{b, y, z}', null::text, '0', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '51.5'::text number,
       'TT_GetIndexMatchList'::text function_tested,
       'Test higher index'::text description,
       TT_GetIndexMatchList('{1,2,3}', '{a,b,c}', '{c, y, z}', '3') passed
---------------------------------------------------------
-- Test 52 - TT_GetIndexNotEmpty
---------------------------------------------------------
UNION ALL
SELECT '52.1'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Passes basic test, true'::text description,
       TT_GetIndexNotEmpty('{1990, 2000}', '{burn, wind}', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '52.2'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Passes basic test, false'::text description,
       TT_GetIndexNotEmpty('{1990, 2000}', '{'', wind}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '52.3'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Matching ints return first string'::text description,
       TT_GetIndexNotEmpty('{1990, 1990}', '{wind, ''}', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '52.4'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Test setNullTo, true'::text description,
       TT_GetIndexNotEmpty('{1990, null}', '{'', wind}', '0', null::text, '1') passed
---------------------------------------------------------
UNION ALL
SELECT '52.5'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Test setNullTo, false'::text description,
       TT_GetIndexNotEmpty('{1990, null}', '{burn, ''}', '0', null::text, '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '52.6'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Test all null ints, should return first not null return value'::text description,
       TT_GetIndexNotEmpty('{null, null}', '{'', wind}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '52.7'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Test matching years with null returns'::text description,
       TT_GetIndexNotEmpty('{2000, 2000}', '{'', ''}', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '52.8'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Test setZeroTo, true'::text description,
       TT_GetIndexNotEmpty('{-1, 0}', '{'', wind}', null::text, '-2', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '52.9'::text number,
       'TT_GetIndexNotEmpty'::text function_tested,
       'Test higher index'::text description,
       TT_GetIndexNotEmpty('{null, null}', '{'', wind}', '2') passed
---------------------------------------------------------
---------------------------------------------------------
--------------- Translation functions -------------------
---------------------------------------------------------
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
       TT_LookupText('a'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'text_val'::text) = 'ACB'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.12'::text number,
       'TT_LookupText'::text function_tested,
       'NULL val'::text description,
       TT_LookupText(NULL::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'text_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '104.13'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupText('A'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'text_val'::text, TRUE::text) = 'ACB'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.14'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupText('A'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'text_val'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '104.15'::text number,
       'TT_LookupText'::text function_tested,
       'Test ignore case, true flipped case'::text description,
       TT_LookupText('aa'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'text_val'::text, TRUE::text) = 'abcde'::text passed
---------------------------------------------------------
UNION ALL
SELECT '104.16'::text number,
       'TT_LookupText'::text function_tested,
       'Test new retrieveCol parameter'::text description,
       TT_LookupText('abcde'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'text_val'::text, 'source_val'::text) = 'AA'::text passed
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
       TT_LookupDouble('a'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'dbl_val'::text) = 1.1::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '105.12'::text number,
       'TT_LookupDouble'::text function_tested,
       'NULL val'::text description,
       TT_LookupDouble(NULL::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'dbl_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '105.13'::text number,
       'TT_LookupDouble'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupDouble('A'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'dbl_val'::text, TRUE::text) = 1.1 passed
---------------------------------------------------------
UNION ALL
SELECT '105.14'::text number,
       'TT_LookupDouble'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupDouble('A'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'dbl_val'::text, FALSE::text) IS NULL passed
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
       TT_LookupInt('a'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'int_val'::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '106.12'::text number,
       'TT_LookupInt'::text function_tested,
       'NULL val'::text description,
       TT_LookupInt(NULL::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'int_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '106.13'::text number,
       'TT_LookupInt'::text function_tested,
       'Test ignore case, true'::text description,
       TT_LookupInt('A'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'int_val'::text, TRUE::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '106.14'::text number,
       'TT_LookupInt'::text function_tested,
       'Test ignore case, false'::text description,
       TT_LookupInt('A'::text, 'public'::text, 'test_table_with_null'::text, 'source_val'::text, 'int_val'::text, FALSE::text) IS NULL passed
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
UNION ALL
SELECT '111.5'::text number,
       'TT_Concat'::text function_tested,
       'Test null value with nullToEmpty FALSE'::text description,
       TT_Concat('{''cas'', NULL, ''test''}'::text, '-'::text) = 'cas-test' passed
---------------------------------------------------------
UNION ALL
SELECT '111.6'::text number,
       'TT_Concat'::text function_tested,
       'Test null value with nullToEmpty TRUE'::text description,
       TT_Concat('{''cas'', NULL, ''test''}'::text, '-'::text, 'TRUE') = 'cas--test' passed
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
UNION ALL
SELECT '112.17'::text number,
       'TT_PadConcat'::text function_tested,
       'test spaces'::text description,
       TT_PadConcat('{''ab  06'', ''GB_S21_TWP'', ''  81145  '', ''811451038'', ''1''}', '{''4'',''15'',''10'',''10'',''7''}', '{''x'',''x'',''x'',''0'',''0''}'::text, '-'::text, FALSE::text) = 'ab06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
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
       'Basic remove spaces'::text description,
       TT_SubstringInt(' 1234'::text, '1'::text, '3'::text, TRUE::text) = '123' passed
---------------------------------------------------------
UNION ALL
SELECT '124.3'::text number,
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
       'Not in set'::text description,
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
       TT_MinInt('{1,2,3}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '130.2'::text number,
       'TT_MinInt'::text function_tested,
       'Simple test with null'::text description,
       TT_MinInt('{null,2}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '130.3'::text number,
       'TT_MinInt'::text function_tested,
       'All nulls'::text description,
       TT_MinInt('{null,null}') IS NULL passed
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
       TT_MinIndexCopyText('{1,2,3,null}', '{a,b,c,d}', '0', null::text) = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '132.6'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Test multiple indexes'::text description,
       TT_MinIndexCopyText('{1,1,3}', '{a,b,c}') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '132.7'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Matching indexes return first with null'::text description,
       TT_MinIndexCopyText('{1,1,1}', '{a,null,c}') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '132.8'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Matching indexes return first with null'::text description,
       TT_MinIndexCopyText('{1,1,1}', '{null,null,c}') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '132.9'::text number,
       'TT_MinIndexCopyText'::text function_tested,
       'Test setZeroTo'::text description,
       TT_MinIndexCopyText('{1,2,3,0}', '{a,b,c,d}', null::text, '-1') = 'd' passed
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
       TT_MaxIndexCopyText('{1,2,3,null}', '{a,b,c,d}', '4', null::text) = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '133.6'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Test multiple indexes'::text description,
       TT_MaxIndexCopyText('{1,3,3}', '{a,b,c}') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '133.7'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Matching indexes return last with null'::text description,
       TT_MaxIndexCopyText('{3,3,3}', '{a,b,c}') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '133.8'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Matching indexes return last with null'::text description,
       TT_MaxIndexCopyText('{null,null,null}', '{a,b,null}') = 'b' passed
---------------------------------------------------------
UNION ALL
SELECT '133.9'::text number,
       'TT_MaxIndexCopyText'::text function_tested,
       'Test setZeroTo'::text description,
       TT_MaxIndexCopyText('{1,2,3,0}', '{a,b,c,d}', null::text, '4') = 'd' passed
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
       TT_MinIndexMapText('{1990, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '0', null::text) = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '134.9'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Matching years return first not null'::text description,
       TT_MinIndexMapText('{null, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '0', null::text) = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '134.10'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'Matching years return first not null'::text description,
       TT_MinIndexMapText('{null, null}', '{null, wind}', '{burn, wind}', '{BU, WT}', '0', null::text) = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '134.11'::text number,
       'TT_MinIndexMapText'::text function_tested,
       'setZeroTo'::text description,
       TT_MinIndexMapText('{-1, 0}', '{burn, wind}', '{burn, wind}', '{BU, WT}', null::text, '-2') = 'WT' passed
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
       TT_MaxIndexMapText('{null, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '9999', null::text) = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '135.9'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Matching indexes return last not null'::text description,
       TT_MaxIndexMapText('{null, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '9999', null::text) = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '135.10'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'Matching indexes return last not null'::text description,
       TT_MaxIndexMapText('{null, null}', '{burn, null}', '{burn, wind}', '{BU, WT}', '9999', null::text) = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '135.11'::text number,
       'TT_MaxIndexMapText'::text function_tested,
       'setZeroTo'::text description,
       TT_MaxIndexMapText('{0, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}', null::text, '2001') = 'BU' passed
---------------------------------------------------------
-- Test 138 - TT_XMinusYDouble
---------------------------------------------------------
UNION ALL
SELECT '138.1'::text number,
       'TT_XMinusYDouble'::text function_tested,
       'Simple test'::text description,
       TT_XMinusYDouble(5.5::text, 3.3::text) = 2.2 passed
---------------------------------------------------------
UNION ALL
SELECT '138.2'::text number,
       'TT_XMinusYDouble'::text function_tested,
       'Simple test with 0'::text description,
       TT_XMinusYDouble(5.5::text, 0::text) = 5.5 passed
---------------------------------------------------------
UNION ALL
SELECT '138.3'::text number,
       'TT_XMinusYDouble'::text function_tested,
       'Test null'::text description,
       TT_XMinusYDouble(5.5::text, NULL::text) IS NULL passed
---------------------------------------------------------
-- Test 139 - TT_DivideDouble
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (2 tests)
SELECT (TT_TestNullAndWrongTypeParams(139, 'TT_DivideDouble', ARRAY['divideBy', 'numeric'])).*
---------------------------------------------------------
UNION ALL
SELECT '139.3'::text number,
       'TT_DivideDouble'::text function_tested,
       'Simple test, returning integer'::text description,
       TT_DivideDouble(5.5::text, 5.5::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '139.4'::text number,
       'TT_DivideDouble'::text function_tested,
       'Simple test, returning double'::text description,
       TT_DivideDouble(5::text, 2::text) = 2.5 passed
---------------------------------------------------------
UNION ALL
SELECT '139.5'::text number,
       'TT_DivideDouble'::text function_tested,
       'Dividing by zero should return NULL'::text description,
       TT_DivideDouble(5::text, 0::text) IS NULL passed
---------------------------------------------------------
-- Test 140 - TT_DivideInt
---------------------------------------------------------
UNION ALL
SELECT '140.1'::text number,
       'TT_DivideInt'::text function_tested,
       'Simple test, returning integer'::text description,
       TT_DivideInt(5::text, 5::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '140.2'::text number,
       'TT_DivideInt'::text function_tested,
       'Simple test, rounding a double to int'::text description,
       TT_DivideInt(5::text, 2::text) = 3 passed  
---------------------------------------------------------
-- Test 142 - TT_Multiply
---------------------------------------------------------
UNION ALL
SELECT '142.1'::text number,
       'TT_Multiply'::text function_tested,
       'Basic test'::text description,
       TT_Multiply('2','3.2') = 6.4 passed
---------------------------------------------------------
UNION ALL
SELECT '142.2'::text number,
       'TT_Multiply'::text function_tested,
       'Test zero'::text description,
       TT_Multiply('2','0') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '142.3'::text number,
       'TT_Multiply'::text function_tested,
       'Test zero'::text description,
       TT_Multiply('0','0') IS NULL passed
---------------------------------------------------------
-- Test 143 - TT_MinIndexMapInt
---------------------------------------------------------
UNION ALL
SELECT '143.1'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'Simple test'::text description,
       TT_MinIndexMapInt('{1990, 2000}', '{burn, wind}', '{burn, wind}', '{1, 2}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '143.2'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'Matching indexes'::text description,
       TT_MinIndexMapInt('{1990, 1990}', '{burn, wind}', '{burn, wind}', '{1, 2}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '143.3'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'null integer'::text description,
       TT_MinIndexMapInt('{null, 2000}', '{burn, wind}', '{burn, wind}', '{1, 2}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '143.4'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'setNullTo'::text description,
       TT_MinIndexMapInt('{1990, null}', '{burn, wind}', '{burn, wind}', '{1, 2}', '0', null::text) = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '143.5'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'Matching years return first not null'::text description,
       TT_MinIndexMapInt('{null, null}', '{burn, wind}', '{burn, wind}', '{1, 2}', '0', null::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '143.6'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'Matching years return first not null'::text description,
       TT_MinIndexMapInt('{null, null}', '{null, wind}', '{burn, wind}', '{1, 2}', '0', null::text) = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '143.7'::text number,
       'TT_MinIndexMapInt'::text function_tested,
       'Test setZero'::text description,
       TT_MinIndexMapInt('{-1, 0}', '{burn, wind}', '{burn, wind}', '{1, 2}', null::text, '-2') = 2 passed
---------------------------------------------------------
-- Test 144 - TT_MaxIndexMapInt
---------------------------------------------------------
UNION ALL
SELECT '144.1'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'Simple test'::text description,
       TT_MaxIndexMapInt('{1990, 2000}', '{burn, wind}', '{burn, wind}', '{1, 2}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '144.2'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'Matching indexes'::text description,
       TT_MaxIndexMapInt('{1990, 1990}', '{burn, wind}', '{burn, wind}', '{1, 2}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '144.3'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'null integer'::text description,
       TT_MaxIndexMapInt('{1990, null}', '{burn, wind}', '{burn, wind}', '{1, 2}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '144.4'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'setNullTo'::text description,
       TT_MaxIndexMapInt('{null, 2000}', '{burn, wind}', '{burn, wind}', '{1, 2}', '9999', null::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '144.5'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'Matching indexes return last not null'::text description,
       TT_MaxIndexMapInt('{null, null}', '{burn, wind}', '{burn, wind}', '{1, 2}', '9999', null::text) = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '144.6'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'Matching indexes return last not null'::text description,
       TT_MaxIndexMapInt('{null, null}', '{burn, null}', '{burn, wind}', '{1, 2}', '9999', null::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '144.7'::text number,
       'TT_MaxIndexMapInt'::text function_tested,
       'Test setZero'::text description,
       TT_MaxIndexMapInt('{0, 2}', '{burn, wind}', '{burn, wind}', '{1, 2}', null::text, '9999') = 1 passed
---------------------------------------------------------
-- Test 145 - TT_MinIndexCopyInt
---------------------------------------------------------
UNION ALL
SELECT '145.1'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Simple test'::text description,
       TT_MinIndexCopyInt('{1,2,3}', '{1,2,3}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '145.2'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Simple test 2'::text description,
       TT_MinIndexCopyInt('{1,2,3,0}', '{1,2,3,0}') = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '145.3'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Test negative int'::text description,
       TT_MinIndexCopyInt('{1,2,3,-1}', '{1,2,3,-1}') = -1 passed
---------------------------------------------------------
UNION ALL
SELECT '145.4'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Test null'::text description,
       TT_MinIndexCopyInt('{1,2,3,null}', '{1,2,3,4}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '145.5'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Test setNullTo'::text description,
       TT_MinIndexCopyInt('{1,2,3,null}', '{1,2,3,4}', '0', null::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '145.6'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Test multiple indexes'::text description,
       TT_MinIndexCopyInt('{1,1,3}', '{1,2,3}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '145.7'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Matching indexes return first with null'::text description,
       TT_MinIndexCopyInt('{1,1,1}', '{1,null,3}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '145.8'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Matching indexes return first with null'::text description,
       TT_MinIndexCopyInt('{1,1,1}', '{null,null,3}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '145.9'::text number,
       'TT_MinIndexCopyInt'::text function_tested,
       'Test setZeroTo'::text description,
       TT_MinIndexCopyInt('{2,3,4,0}', '{1,2,3,4}', null::text, '1') = 4 passed
---------------------------------------------------------
-- Test 146 - TT_MaxIndexCopyInt
---------------------------------------------------------
UNION ALL
SELECT '146.1'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Simple test'::text description,
       TT_MaxIndexCopyInt('{1,2,3}', '{1,2,3}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '146.2'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Simple test 2'::text description,
       TT_MaxIndexCopyInt('{4,1,2,3}', '{1,2,3,4}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '146.3'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Test negative int'::text description,
       TT_MaxIndexCopyInt('{1,2,3,-1}', '{1,2,3,4}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '146.4'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Test null'::text description,
       TT_MaxIndexCopyInt('{1,2,3,null}', '{1,2,3,4}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '146.5'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Test setNullTo'::text description,
       TT_MaxIndexCopyInt('{1,2,3,null}', '{1,2,3,4}', '4', null::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '146.6'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Test multiple indexes'::text description,
       TT_MaxIndexCopyInt('{1,3,3}', '{1,2,3}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '146.7'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Matching indexes return last with null'::text description,
       TT_MaxIndexCopyInt('{3,3,3}', '{1,2,3}') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '146.8'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Matching indexes return last with null'::text description,
       TT_MaxIndexCopyInt('{null,null,null}', '{1,2,null}') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '146.9'::text number,
       'TT_MaxIndexCopyInt'::text function_tested,
       'Test setZero'::text description,
       TT_MaxIndexCopyInt('{1,2,0}', '{1,2,3}', null::text, '3') = 3 passed
---------------------------------------------------------
-- Test 147 - TT_LookupTextSubstring
---------------------------------------------------------
UNION ALL
SELECT '147.1'::text number,
       'TT_LookupTextSubstring'::text function_tested,
       'Simple test text, pass'::text description,
       TT_LookupTextSubstring('RA00'::text, '1', '2', 'public'::text, 'test_lookuptable1'::text, 'target_val'::text) = 'Arbu menz' passed
---------------------------------------------------------
UNION ALL
SELECT '147.2'::text number,
       'TT_LookupTextSubstring'::text function_tested,
       'Simple test text, fail'::text description,
       TT_LookupTextSubstring('RA00'::text, '1', '3', 'public'::text, 'test_lookuptable1'::text, 'target_val'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '147.3'::text number,
       'TT_LookupTextSubstring'::text function_tested,
       'val NULL text, NULL gets converted to empty string'::text description,
       TT_LookupTextSubstring(NULL::text, '1', '3', 'public'::text, 'test_lookuptable1'::text, 'target_val'::text) = '' passed
---------------------------------------------------------
-- Test 148 - TT_CoalesceText
---------------------------------------------------------
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (2 tests)
SELECT (TT_TestNullAndWrongTypeParams(148, 'TT_CoalesceText', ARRAY['zeroAsNull', 'boolean'])).*
UNION ALL
SELECT '148.3'::text number,
       'TT_CoalesceText'::text function_tested,
       'Simple test 1'::text description,
       TT_CoalesceText('{''1'', ''2''}') = '1' passed
UNION ALL
SELECT '148.4'::text number,
       'TT_CoalesceText'::text function_tested,
       'Simple test 2'::text description,
       TT_CoalesceText('{NULL, ''2''}') = '2' passed
UNION ALL
SELECT '148.5'::text number,
       'TT_CoalesceText'::text function_tested,
       'Simple test 3'::text description,
       TT_CoalesceText('{''2'', NULL}') = '2' passed
UNION ALL
SELECT '148.6'::text number,
       'TT_CoalesceText'::text function_tested,
       'Simple test 3'::text description,
       TT_CoalesceText('{NULL, ''2'', NULL}') = '2' passed
UNION ALL
SELECT '148.7'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test single value'::text description,
       TT_CoalesceText('''2''') = '2' passed
UNION ALL
SELECT '148.8'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test single NULL'::text description,
       TT_CoalesceText(NULL) IS NULL passed
UNION ALL
SELECT '148.9'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test single NULL string'::text description,
       TT_CoalesceText('NULL') = 'NULL' passed
UNION ALL
SELECT '148.10'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test single NULL in stringList'::text description,
       TT_CoalesceText('{NULL}') IS NULL passed
UNION ALL
SELECT '148.11'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test zeroAsNull parameter'::text description,
       TT_CoalesceText('{NULL, ''0'', ''a''}', TRUE::text) = 'a' passed
UNION ALL
SELECT '148.12'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test zeroAsNull parameter with double 00'::text description,
       TT_CoalesceText('{NULL, ''00'', ''a''}', TRUE::text) = 'a' passed
UNION ALL
SELECT '148.13'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test zeroAsNull parameter with float 0'::text description,
       TT_CoalesceText('{''0.0'', ''00'', ''a''}', TRUE::text) = 'a' passed
UNION ALL
SELECT '148.14'::text number,
       'TT_CoalesceText'::text function_tested,
       'Test zeroAsNull parameter with float 0'::text description,
       TT_CoalesceText('{''0.0'', ''00'', ''a''}', FALSE::text) = '0.0' passed
---------------------------------------------------------
-- Test 149 - TT_CoalesceInt
---------------------------------------------------------
---------------------------------------------------------
UNION ALL
-- test all NULLs and wrong types (2 tests)
SELECT (TT_TestNullAndWrongTypeParams(149, 'TT_CoalesceInt', ARRAY['zeroAsNull', 'boolean'])).*
UNION ALL
SELECT '149.3'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Simple test 1'::text description,
       TT_CoalesceInt('{NULL, ''2''}') = 2 passed
UNION ALL
SELECT '149.4'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test non integer value'::text description,
       TT_CoalesceInt('{NULL, ''a''}') IS NULL passed
UNION ALL
SELECT '149.5'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test non float value'::text description,
       TT_CoalesceInt('{NULL, ''1.2''}') IS NULL passed
UNION ALL
SELECT '149.6'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test zeroAsNull parameter'::text description,
       TT_CoalesceInt('{NULL, ''0'', ''1''}', TRUE::text) = 1 passed
UNION ALL
SELECT '149.7'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test zeroAsNull parameter with double 00'::text description,
       TT_CoalesceInt('{NULL, ''00'', ''1''}', TRUE::text) = 1 passed
UNION ALL
SELECT '149.8'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test zeroAsNull parameter with float 0'::text description,
       TT_CoalesceInt('{''0.0'', ''00'', ''1''}', TRUE::text) = 1 passed
UNION ALL
SELECT '149.9'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test with float 0'::text description,
       TT_CoalesceInt('{''0.0'', ''1'', ''2''}') = 0 passed
UNION ALL
SELECT '149.10'::text number,
       'TT_CoalesceInt'::text function_tested,
       'Test zeroAsNull parameter with float 0'::text description,
       TT_CoalesceInt('{''0.0'', ''1'', ''2''}', FALSE::text) = 0 passed
---------------------------------------------------------
-- Test 150 - TT_CountOfNotNullMapText
---------------------------------------------------------
UNION ALL
SELECT '150.1'::text number,
       'TT_CountOfNotNullMapText'::text function_tested,
       'Simple test 1'::text description,
       TT_CountOfNotNullMapText('{a, b}', '{NULL}', '2', '{1,2,3}', '{A, B, C}') = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '150.2'::text number,
       'TT_CountOfNotNullMapText'::text function_tested,
       'Simple test 2'::text description,
       TT_CountOfNotNullMapText('{a, b}', '{c}', '2', '{1,2,3}', '{A, B, C}') = 'B' passed	
---------------------------------------------------------
UNION ALL
SELECT '150.3'::text number,
       'TT_CountOfNotNullMapText'::text function_tested,
       'Simple test 3'::text description,
       TT_CountOfNotNullMapText('{}', '{}', '2', '{1,2,0}', '{A, B, C}') = 'C' passed	
---------------------------------------------------------
UNION ALL
SELECT '150.4'::text number,
       'TT_CountOfNotNullMapText'::text function_tested,
       'Not in set'::text description,
       TT_CountOfNotNullMapText('{}', '{}', '2', '{1,2,3}', '{A, B, C}') IS NULL passed	
---------------------------------------------------------
UNION ALL
SELECT '150.5'::text number,
       'TT_CountOfNotNullMapText'::text function_tested,
       'Check errors pass from mapText'::text description,
       TT_isError('SELECT TT_CountOfNotNullMapText(''{}'', ''{}'', ''2'', ''{1}'', ''{A, B, C}'')') = 'ERROR in TT_MapText(): number of mapVals values (1) is different from number of targetVals values (3)...' passed	
---------------------------------------------------------
-- Test 151 - TT_CountOfNotNullMapInt
---------------------------------------------------------
UNION ALL
SELECT '151.1'::text number,
       'TT_CountOfNotNullMapInt'::text function_tested,
       'Simple test 1'::text description,
       TT_CountOfNotNullMapInt('{a, b}', '{NULL}', '2', '{1,2,3}', '{1, 2, 3}') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '151.2'::text number,
       'TT_CountOfNotNullMapInt'::text function_tested,
       'Simple test 2'::text description,
       TT_CountOfNotNullMapInt('{a, b}', '{c}', '2', '{1,2,3}', '{1, 2, 3}') = 2 passed	
---------------------------------------------------------
UNION ALL
SELECT '151.3'::text number,
       'TT_CountOfNotNullMapInt'::text function_tested,
       'Simple test 3'::text description,
       TT_CountOfNotNullMapInt('{}', '{}', '2', '{1,2,0}', '{1, 2, 3}') = 3 passed	
---------------------------------------------------------
UNION ALL
SELECT '151.4'::text number,
       'TT_CountOfNotNullMapInt'::text function_tested,
       'Not in set'::text description,
       TT_CountOfNotNullMapInt('{}', '{}', '2', '{1,2,3}', '{1, 2, 3}') IS NULL passed	
---------------------------------------------------------
---------------------------------------------------------
-- Test 152 - TT_CountOfNotNullMapDouble
---------------------------------------------------------
UNION ALL
SELECT '152.1'::text number,
       'TT_CountOfNotNullMapDouble'::text function_tested,
       'Simple test 1'::text description,
       TT_CountOfNotNullMapDouble('{a, b}', '{NULL}', '2', '{1,2,3}', '{1.1, 2.2, 3.3}') = 1.1 passed
---------------------------------------------------------
UNION ALL
SELECT '152.2'::text number,
       'TT_CountOfNotNullMapDouble'::text function_tested,
       'Simple test 2'::text description,
       TT_CountOfNotNullMapDouble('{a, b}', '{c}', '2', '{1,2,3}', '{1.1, 2.2, 3.3}') = 2.2 passed	
---------------------------------------------------------
UNION ALL
SELECT '152.3'::text number,
       'TT_CountOfNotNullMapDouble'::text function_tested,
       'Simple test 3'::text description,
       TT_CountOfNotNullMapDouble('{}', '{}', '2', '{1,2,0}', '{1.1, 2.2, 3.3}') = 3.3 passed	
---------------------------------------------------------
UNION ALL
SELECT '152.4'::text number,
       'TT_CountOfNotNullMapDouble'::text function_tested,
       'Not in set'::text description,
       TT_CountOfNotNullMapDouble('{}', '{}', '2', '{1,2,3}', '{1.1, 2.2, 3.3}') IS NULL passed	
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
-- Test 153 - TT_CountOfNotNullMapDouble
---------------------------------------------------------
UNION ALL
SELECT '153.1'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Test wrong type for index'::text description,
       TT_IsError('SELECT TT_MapTextNotNullIndex(''a'',''{a,b}'',''{A,B}'', ''b'',''{a,b}'',''{A,B}'', ''a'')') = 'ERROR in TT_MapTextNotNullIndex(): indexToReturn is not a int value' passed
---------------------------------------------------------
UNION ALL
SELECT '153.2'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Test null for index'::text description,
       TT_IsError('SELECT TT_MapTextNotNullIndex(''a'',''{a,b}'',''{A,B}'', ''b'',''{a,b}'',''{A,B}'', NULL)') = 'ERROR in TT_MapTextNotNullIndex(): indexToReturn is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '153.3'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Simple test 1'::text description,
       TT_MapTextNotNullIndex('a','{a,b}','{A,B}', 'b','{a,b}','{A,B}', '1') = 'A' passed
---------------------------------------------------------
UNION ALL
SELECT '153.4'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Simple test 2'::text description,
       TT_MapTextNotNullIndex('a','{a,b}','{A,B}', 'b','{a,b}','{A,B}', '2') = 'B' passed
---------------------------------------------------------
UNION ALL
SELECT '153.5'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Index doesnt exist'::text description,
       TT_MapTextNotNullIndex('a','{a,b}','{A,B}', 'b','{a,b}','{A,B}', '3') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '153.6'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Simple test all 10'::text description,
       TT_MapTextNotNullIndex('a','{a,b}','{A,B}', 'b','{a,b}','{A,B}', 'c','{c,d}','{C,D}', 'd','{c,d}','{C,D}', 'e','{e,f}','{E,F}', 'f','{e,f}','{E,F}',
							  'g','{g,h}','{G,H}', 'h','{g,h}','{G,H}', 'i','{i,j}','{I,J}', 'j','{i,j}','{I,J}', '10') = 'J' passed
---------------------------------------------------------
UNION ALL
SELECT '153.7'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Simple test all 10'::text description,
       TT_MapTextNotNullIndex('a','{a,b}','{A,B}', 'b','{a,b}','{A,B}', 'c','{c,d}','{C,D}', 'd','{c,d}','{C,D}', 'e','{e,f}','{E,F}', 'f','{e,f}','{E,F}',
							  'g','{g,h}','{G,H}', 'h','{g,h}','{G,H}', 'i','{i,j}','{I,J}', 'j','{i,j}','{I,J}', '5') = 'E' passed	
---------------------------------------------------------
UNION ALL
SELECT '153.8'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Test with some null sources'::text description,
       TT_MapTextNotNullIndex(NULL,'{a,b}','{A,B}', NULL,'{a,b}','{A,B}', 'c','{c,d}','{C,D}', 'd','{c,d}','{C,D}', 'e','{e,f}','{E,F}', 'f','{e,f}','{E,F}',
							  'g','{g,h}','{G,H}', 'h','{g,h}','{G,H}', 'i','{i,j}','{I,J}', 'j','{i,j}','{I,J}', '5') = 'G' passed		
---------------------------------------------------------
UNION ALL
SELECT '153.9'::text number,
       'TT_MapTextNotNullIndex'::text function_tested,
       'Test with some null results'::text description,
       TT_MapTextNotNullIndex('a','{c,b}','{C,B}', 'b','{a,r}','{A,R}', 'c','{c,d}','{C,D}', 'd','{c,d}','{C,D}', 'e','{e,f}','{E,F}', 'f','{e,f}','{E,F}',
							  'g','{g,h}','{G,H}', 'h','{g,h}','{G,H}', 'i','{i,j}','{I,J}', 'j','{i,j}','{I,J}', '5') = 'G' passed	
---------------------------------------------------------
-- Test 154 - TT_SubstringMultiplyInt
---------------------------------------------------------
UNION ALL
SELECT '154.1'::text number,
       'TT_SubstringMultiplyInt'::text function_tested,
       'Test 100'::text description,
       TT_SubstringMultiplyInt('JP10', '3', '2', '10') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '154.2'::text number,
       'TT_SubstringMultiplyInt'::text function_tested,
       'Test 08'::text description,
       TT_SubstringMultiplyInt('JP08', '3', '2', '10') = 80 passed
---------------------------------------------------------
UNION ALL
SELECT '154.3'::text number,
       'TT_SubstringMultiplyInt'::text function_tested,
       'Test error'::text description,
       TT_IsError('SELECT TT_SubstringMultiplyInt(''JPJP'', ''3'', ''2'', ''10'')') = 'invalid input syntax for type integer: "JP"' passed
---------------------------------------------------------
-- Test 155 - TT_GetIndexCopyText
---------------------------------------------------------
UNION ALL
SELECT '155.1'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Simple test'::text description,
       TT_GetIndexCopyText('{1,2,3}', '{a,b,c}', '2') = 'b' passed
---------------------------------------------------------
UNION ALL
SELECT '155.2'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Simple test 2'::text description,
       TT_GetIndexCopyText('{1,2,3,0}', '{a,b,c,d}', '1') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '155.3'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Test negative int'::text description,
       TT_GetIndexCopyText('{1,2,3,-1}', '{a,b,c,d}', '1') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '155.4'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Test null'::text description,
       TT_GetIndexCopyText('{1,2,3,null}', '{a,b,c,d}', '1') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '155.5'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Test setNullTo'::text description,
       TT_GetIndexCopyText('{1,2,3,null}', '{a,b,c,d}', '4', null::text, '4') = 'd' passed
---------------------------------------------------------
UNION ALL
SELECT '155.6'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Test multiple indexes'::text description,
       TT_GetIndexCopyText('{1,1,3}', '{a,b,c}', '1') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '155.7'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Matching indexes return first with null'::text description,
       TT_GetIndexCopyText('{1,1,1}', '{a,null,c}', '1') = 'a' passed
---------------------------------------------------------
UNION ALL
SELECT '155.8'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Matching indexes return first with null'::text description,
       TT_GetIndexCopyText('{1,1,1}', '{null,null,c}', '1') = 'c' passed
---------------------------------------------------------
UNION ALL
SELECT '155.9'::text number,
       'TT_GetIndexCopyText'::text function_tested,
       'Test setZeroTo'::text description,
       TT_GetIndexCopyText('{1,2,3,0}', '{a,b,c,d}', null::text, '-1', '1') = 'd' passed
---------------------------------------------------------
-- Test 156 - TT_GetIndexMapText
---------------------------------------------------------
UNION ALL
SELECT '156.1'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Test for null mapVals'::text description,
       TT_IsError('SELECT TT_GetIndexMapText(''{1990, 2000}'', ''{burn, wind}'', NULL::text, ''{BU, WT}'', ''1'')') = 'ERROR in TT_GetIndexMapText(): mapVals is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '156.2'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Test for null targetVals'::text description,
       TT_IsError('SELECT TT_GetIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', NULL::text, ''1'')') = 'ERROR in TT_GetIndexMapText(): targetVals is NULL' passed
---------------------------------------------------------
UNION ALL
SELECT '156.3'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Test for invalid mapVals'::text description,
       TT_IsError('SELECT TT_GetIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}}}'', ''{BU, WT}'', ''1'')') = 'ERROR in TT_GetIndexMapText(): mapVals is not a stringlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '156.4'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Test for invalid targetVals'::text description,
       TT_IsError('SELECT TT_GetIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', ''{BU, WT}}}'', ''1'')') = 'ERROR in TT_GetIndexMapText(): targetVals is not a stringlist value' passed
---------------------------------------------------------
UNION ALL
SELECT '156.5'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Test for invalid indexToReturn'::text description,
       TT_IsError('SELECT TT_GetIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', ''{BU, WT}'', ''a'')') = 'ERROR in TT_GetIndexMapText(): indexToReturn is not a int value' passed
---------------------------------------------------------
UNION ALL
SELECT '156.6'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Test for invalid targetVals'::text description,
       TT_IsError('SELECT TT_GetIndexMapText(''{1990, 2000}'', ''{burn, wind}'', ''{burn, wind}'', ''{BU, WT}'', NULL::text)') = 'ERROR in TT_GetIndexMapText(): indexToReturn is NULL' passed
------------------------------------------------------------------------------------------------------------------
UNION ALL
SELECT '156.7'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Simple test'::text description,
       TT_GetIndexMapText('{1990, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '1') = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '156.6'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Matching indexes'::text description,
       TT_GetIndexMapText('{1990, 1990}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '2') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '156.7'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'null integer'::text description,
       TT_GetIndexMapText('{null, 2000}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '1') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '156.8'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'setNullTo'::text description,
       TT_GetIndexMapText('{1990, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '0', null::text, '1') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '156.9'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Matching years return first not null'::text description,
       TT_GetIndexMapText('{null, null}', '{burn, wind}', '{burn, wind}', '{BU, WT}', '0', null::text, '1') = 'BU' passed
---------------------------------------------------------
UNION ALL
SELECT '156.10'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'Matching years return first not null'::text description,
       TT_GetIndexMapText('{null, null}', '{null, wind}', '{burn, wind}', '{BU, WT}', '0', null::text, '1') = 'WT' passed
---------------------------------------------------------
UNION ALL
SELECT '156.11'::text number,
       'TT_GetIndexMapText'::text function_tested,
       'setZeroTo'::text description,
       TT_GetIndexMapText('{-1, 0}', '{burn, wind}', '{burn, wind}', '{BU, WT}', null::text, '-2', '2') = 'BU' passed
---------------------------------------------------------
-- Test 158 - TT_GetIndexCopyInt
---------------------------------------------------------
UNION ALL
SELECT '158.1'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Simple test'::text description,
       TT_GetIndexCopyInt('{1,2,3}', '{1,2,3}', '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '158.2'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Simple test 2'::text description,
       TT_GetIndexCopyInt('{4,1,2,3}', '{1,2,3,4}', '4') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '158.3'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Test negative int'::text description,
       TT_GetIndexCopyInt('{1,2,3,-1}', '{1,2,3,4}', '1') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '158.4'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Test null'::text description,
       TT_GetIndexCopyInt('{1,2,3,null}', '{1,2,3,4}', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '158.5'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Test setNullTo'::text description,
       TT_GetIndexCopyInt('{1,2,3,null}', '{1,2,3,4}', '4', null::text, '4') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '158.6'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Test multiple indexes'::text description,
       TT_GetIndexCopyInt('{1,3,3}', '{1,2,3}', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '158.7'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Matching indexes return last with null'::text description,
       TT_GetIndexCopyInt('{3,3,3}', '{1,2,3}', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '158.8'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Matching indexes return last with null'::text description,
       TT_GetIndexCopyInt('{null,null,null}', '{1,2,null}', '2') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '158.9'::text number,
       'TT_GetIndexCopyInt'::text function_tested,
       'Test setZero'::text description,
       TT_GetIndexCopyInt('{1,2,0}', '{1,2,3}', null::text, '3', '3') = 3 passed
---------------------------------------------------------
-- Test 159 - TT_GetIndexMapInt
---------------------------------------------------------
UNION ALL
SELECT '159.1'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'Simple test'::text description,
       TT_GetIndexMapInt('{1990, 2000}', '{burn, wind}', '{burn, wind}', '{1, 2}', '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '159.2'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'Matching indexes'::text description,
       TT_GetIndexMapInt('{1990, 1990}', '{burn, wind}', '{burn, wind}', '{1, 2}', '2') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '159.3'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'null integer'::text description,
       TT_GetIndexMapInt('{1990, null}', '{burn, wind}', '{burn, wind}', '{1, 2}', '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '159.4'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'setNullTo'::text description,
       TT_GetIndexMapInt('{null, 2000}', '{burn, wind}', '{burn, wind}', '{1, 2}', '9999', null::text, '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '159.5'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'Matching indexes return last not null'::text description,
       TT_GetIndexMapInt('{null, null}', '{burn, wind}', '{burn, wind}', '{1, 2}', '9999', null::text, '2') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '159.6'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'Matching indexes return last not null'::text description,
       TT_GetIndexMapInt('{null, null}', '{burn, null}', '{burn, wind}', '{1, 2}', '9999', null::text, '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '159.7'::text number,
       'TT_GetIndexMapInt'::text function_tested,
       'Test setZero'::text description,
       TT_GetIndexMapInt('{0, 2}', '{burn, wind}', '{burn, wind}', '{1, 2}', null::text, '9999', '2') = 1 passed
) AS b
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed OR passed IS NULL
-- Comment out this line to display only test number
--OR ((regexp_split_to_array(number, '\.'))[1])::int = 12
;
