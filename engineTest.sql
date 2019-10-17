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
-------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';

SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create a test source table
DROP TABLE IF EXISTS test_sourcetable1;
CREATE TABLE test_sourcetable1 AS
SELECT 'a'::text id, 1 crown_closure
UNION ALL
SELECT 'b'::text, 3
UNION ALL
SELECT 'c'::text, 101;

-- Create a test translation table
DROP TABLE IF EXISTS test_translationtable;
CREATE TABLE test_translationtable AS
SELECT '1' rule_id,
       'CROWN_CLOSURE_UPPER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure|-8888);isbetween(crown_closure, ''0'', ''100''|-9999)'::text validationRules,
       'copyInt(crown_closure)'::text translationRules,
       'Test'::text description,
       'TRUE' descUpToDateWithRules
UNION ALL
SELECT '2' rule_id,
       'CROWN_CLOSURE_LOWER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure|-8888);isbetween(crown_closure, ''0'', ''100''|-9999)'::text validationRules,
       'copyInt(crown_closure)'::text translationRules,
       'Test'::text description,
       'TRUE' descUpToDateWithRules;

DROP TABLE IF EXISTS test_translationtable2;
CREATE TABLE test_translationtable2 AS
SELECT '1' rule_id,
       'CROWN CLOSURE UPPER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure|-8888);isbetween(crown_closure, ''0'', ''100''|-9999)'::text validationRules,
       'copyInt(crown_closure)'::text translationRules,
       'Test'::text description,
       'TRUE' descUpToDateWithRules;

DROP TABLE IF EXISTS test_translationtable3;
CREATE TABLE test_translationtable3 AS
SELECT '1' rule_id,
       'CROWN_CLOSURE_UPPER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure|);isbetween(crown_closure, ''0'', ''100''|-9999)'::text validationRules,
       'copyInt(crown_closure)'::text translationRules,
       'Test'::text description,
       'TRUE' descUpToDateWithRules;

DROP TABLE IF EXISTS test_translationtable4;
CREATE TABLE test_translationtable4 AS
SELECT '1' rule_id,
       'CROWN_CLOSURE_UPPER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure|-3333);isbetween(crown_closure, ''0'', ''100''|-9999)'::text validationRules,
       'copyInt(crown_closure|WRONG_TYPE)'::text translationRules,
       'Test'::text description,
       'TRUE' descUpToDateWithRules;

SELECT TT_Prepare('test_translationtable');
-------------------------------------------------------------------------------
-- TT_IsError(text)
-- Function to test if helper functions return errors
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsError(
  functionString text
)
RETURNS text AS $$
  DECLARE
    result boolean;
  BEGIN
    EXECUTE functionString INTO result;
    RETURN 'FALSE';
  EXCEPTION WHEN OTHERS THEN
    RETURN SQLERRM;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------
-- TT_FctExist
-- Function to test if a function exists.
------------------------------------------------------------
-- Self contained example:
--
-- SELECT TT_FctExists('TT_FctEval', {'text', 'text[]', 'jsonb', 'anyelement'})
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_FctExists(text, text, text[]);
CREATE OR REPLACE FUNCTION TT_FctExists(
  schemaName name,
  fctName name,
  argTypes text[] DEFAULT NULL
)
RETURNS boolean AS $$
  DECLARE
    cnt int = 0;
    debug boolean = TT_Debug();
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_FctExists BEGIN';END IF;
    fctName = 'tt_' || fctName;
    IF lower(schemaName) = 'public' OR schemaName IS NULL THEN
      schemaName = '';
    END IF;
    IF schemaName != '' THEN
      fctName = schemaName || '.' || fctName;
    END IF;
    IF fctName IS NULL THEN
      RETURN NULL;
    END IF;
    IF fctName = '' OR fctName = '.' THEN
      RETURN FALSE;
    END IF;
    fctName = lower(fctName);
    IF debug THEN RAISE NOTICE 'TT_FctExists 11 fctName=%, args=%', fctName, array_to_string(TT_LowerArr(argTypes), ',');END IF;
    SELECT count(*)
    FROM pg_proc
    WHERE schemaName = '' AND argTypes IS NULL AND proname = fctName OR
          oid::regprocedure::text = fctName || '(' || array_to_string(TT_LowerArr(argTypes), ',') || ')'
    INTO cnt;

    IF cnt > 0 THEN
      IF debug THEN RAISE NOTICE 'TT_FctExists END TRUE';END IF;
      RETURN TRUE;
    END IF;
    IF debug THEN RAISE NOTICE 'TT_FctExists END FALSE';END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
---------------------------------------------------
CREATE OR REPLACE FUNCTION TT_FctExists(
  fctName name,
  argTypes text[] DEFAULT NULL
)
RETURNS boolean AS $$
  SELECT TT_FctExists(''::name, fctName, argTypes)
$$ LANGUAGE sql VOLATILE;
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
    SELECT 'TT_FullTableName'::text function_tested, 1 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_FullFunctionName'::text,              2,          5         UNION ALL
    SELECT 'TT_ParseArgs'::text,                     3,         11         UNION ALL
    SELECT 'TT_ParseRules'::text,                    4,          8         UNION ALL
    SELECT 'TT_ValidateTTable'::text,                5,          7         UNION ALL
    SELECT 'TT_TextFctExists'::text,                 6,          3         UNION ALL
    SELECT 'TT_Prepare'::text,                       7,          8         UNION ALL
    SELECT 'TT_TextFctReturnType'::text,             8,          1         UNION ALL
    SELECT 'TT_TextFctEval'::text,                   9,         15         UNION ALL
    SELECT 'TT_ParseStringList'::text,              10,         36         UNION ALL
    SELECT 'TT_RepackStringList'::text,             11,         37         UNION ALL
    SELECT 'TT_IsCastableTo'::text,                 12,          2
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
       coalesce(description, 'ERROR: Too many tests (' || nb_test || ') for ' || a.function_tested || ' in the initial table...') AS description,
       NOT passed IS NULL AND
          (regexp_split_to_array(number, '\.'))[1] = maj_num::text AND
          (regexp_split_to_array(number, '\.'))[2] = min_num AND passed AS passed
FROM test_series AS a FULL OUTER JOIN (
---------------------------------------------------------

---------------------------------------------------------
-- Test 1 - TT_FullTableName
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_FullTableName'::text function_tested,
       'Basic test'::text description,
       TT_FullTableName('public', 'test') = 'public.test' passed

---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_FullTableName'::text function_tested,
       'Null schema'::text description,
       TT_FullTableName(NULL, 'test') = 'public.test' passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_FullTableName'::text function_tested,
       'Both NULL parameters'::text description,
        TT_FullTableName(NULL, NULL) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_FullTableName'::text function_tested,
       'Table name starting with a digit'::text description,
        TT_FullTableName(NULL, '1table') = 'public."1table"' passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_FullTableName'::text function_tested,
       'Both names starting with a digit'::text description,
        TT_FullTableName('1schema', '1table') = '"1schema"."1table"' passed
---------------------------------------------------------
-- Test 2 - TT_FullFunctionName
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_FullFunctionName'::text function_tested,
       'Basic test'::text description,
       TT_FullFunctionName('public', 'test') = 'tt_test' passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_FullFunctionName'::text function_tested,
       'Null schema'::text description,
       TT_FullFunctionName(NULL, 'test') = 'tt_test' passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_FullFunctionName'::text function_tested,
       'Both NULL parameters'::text description,
        TT_FullFunctionName(NULL, NULL) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_FullFunctionName'::text function_tested,
       'Table name starting with a digit'::text description,
        TT_FullFunctionName(NULL, '1function') = 'tt_1function' passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_FullFunctionName'::text function_tested,
       'Both names starting with a digit'::text description,
        TT_FullFunctionName('1schema', '1function') = '1schema.tt_1function' passed
---------------------------------------------------------
-- Test 3 - TT_ParseArgs
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_ParseArgs'::text function_tested,
       'Basic test, space and numeric'::text description,
        TT_ParseArgs('aa,  bb, ''-111.11''') = ARRAY['aa', 'bb', '''-111.11'''] passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test NULL'::text description,
        TT_ParseArgs() IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test empty strings'::text description,
        TT_ParseArgs(''''',""') = ARRAY['''''', '""'] passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test string containing a comma'::text description,
        TT_ParseArgs('''a,a''') = ARRAY['''a,a'''] passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test value containing escaped single quote'::text description,
        TT_ParseArgs('''a\''a''') = ARRAY['''a\''a'''] passed
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test column with _ and -'::text description,
        TT_ParseArgs('column_A, column-B') = ARRAY['column_A', 'column-B'] passed
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test strings with special chars'::text description,
        TT_ParseArgs('''str /:ng 1'', ''str   --   ing2''') = ARRAY['''str /:ng 1''', '''str   --   ing2'''] passed
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test stringLists with string'::text description,
        TT_ParseArgs('{''string 1'', ''string,2''}') = ARRAY['{''string 1'', ''string,2''}'] passed
---------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test stringList of colnames'::text description,
        TT_ParseArgs('{cola, col_b}') = ARRAY['{cola, col_b}']
---------------------------------------------------------
UNION ALL
SELECT '3.10'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test mixed stringList'::text description,
        TT_ParseArgs('{cola, ''string 1''}') = ARRAY['{cola, ''string 1''}'] passed
---------------------------------------------------------
UNION ALL
SELECT '3.11'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test two stringLists and strings and col names'::text description,
        TT_ParseArgs('col_a, {col_b, ''str1''}, {''str2'', colC}, ''str 3''') = ARRAY['col_a', '{col_b, ''str1''}', '{''str2'', colC}', '''str 3'''] passed
---------------------------------------------------------
-- Test 4 - TT_ParseRules
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_ParseRules'::text function_tested,
       'Basic test, space and numeric'::text description,
        TT_ParseRules('test1(aa, bb,''-999.55''); test2(cc, dd,''222.22'')') = ARRAY[('test1', '{aa,bb,''-999.55''}', NULL, FALSE)::TT_RuleDef, ('test2', '{cc,dd,''222.22''}', NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_ParseRules'::text function_tested,
       'Test NULL'::text description,
        TT_ParseRules() IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_ParseRules'::text function_tested,
       'Test empty'::text description,
        TT_ParseRules('') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_ParseRules'::text function_tested,
       'Test empty function'::text description,
        TT_ParseRules('test1()') = ARRAY[('test1', NULL, NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'TT_ParseRules'::text function_tested,
       'Test many empty functions'::text description,
        TT_ParseRules('test1(); test2();  test3()') = ARRAY[('test1', NULL, NULL, FALSE)::TT_RuleDef, ('test2', NULL, NULL, FALSE)::TT_RuleDef, ('test3', NULL, NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_ParseRules'::text function_tested,
       'Test quoted arguments'::text description,
        TT_ParseRules('test1(''aa'', ''bb'')') =  ARRAY[('test1', '{''aa'',''bb''}', NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_ParseRules'::text function_tested,
       'Test quoted arguments containing comma and special chars'::text description,
        TT_ParseRules('test1(''a,a'', ''b@b'')') =  ARRAY[('test1', '{"''a,a''",''b@b''}', NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'TT_ParseRules'::text function_tested,
       'Test what''s in the test translation table'::text description,
        array_agg(TT_ParseRules(validationRules)) = ARRAY[ARRAY[('notNull', '{crown_closure}', -8888, FALSE)::TT_RuleDef, ('isbetween', '{crown_closure, ''0'', ''100''}', -9999, FALSE)::TT_RuleDef]::TT_RuleDef[], ARRAY[('notNull', '{crown_closure}', -8888, FALSE)::TT_RuleDef, ('isbetween', '{crown_closure, ''0'', ''100''}', -9999, FALSE)::TT_RuleDef]::TT_RuleDef[]] passed
FROM public.test_translationtable
---------------------------------------------------------
-- Test 5 - TT_ValidateTTable
--------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Basic test'::text description,
        array_agg(rec)::text =
'{"(CROWN_CLOSURE_UPPER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(isbetween,\\\\\"\"{crown_closure,''0'',''100''}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\")","(CROWN_CLOSURE_LOWER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(isbetween,\\\\\"\"{crown_closure,''0'',''100''}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\")"}' passed
FROM (SELECT TT_ValidateTTable('public', 'test_translationtable') rec) foo
--------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test for NULL'::text description,
        array_agg(rec)::text IS NULL passed
FROM (SELECT TT_ValidateTTable(NULL) rec) foo
--------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test for empties'::text description,
        array_agg(rec)::text IS NULL passed
FROM (SELECT TT_ValidateTTable('', '') rec) foo
--------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test default schema to public'::text description,
        array_agg(rec)::text =
'{"(CROWN_CLOSURE_UPPER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(isbetween,\\\\\"\"{crown_closure,''0'',''100''}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\")","(CROWN_CLOSURE_LOWER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(isbetween,\\\\\"\"{crown_closure,''0'',''100''}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\")"}' passed
FROM (SELECT TT_ValidateTTable('test_translationtable') rec) foo
--------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Invalid target attribute name'::text description,
       TT_IsError('SELECT TT_ValidateTTable(''public'', ''test_translationtable2''::text);') =
                     'ERROR IN TRANSLATION TABLE AT RULE_ID # 1 : Target attribute name (CROWN CLOSURE UPPER) is invalid.' passed
--------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test wrong translation error type'::text description,
       TT_IsError('SELECT TT_ValidateTTable(''public'', ''test_translationtable4''::text);')
                = 'ERROR IN TRANSLATION TABLE AT RULE_ID # 1 (CROWN_CLOSURE_UPPER) : Error code (WRONG_TYPE) cannot be cast to the target attribute type (integer) for translation rule copyInt().' passed
--------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test NULL validation error type'::text description,
       TT_IsError('SELECT TT_ValidateTTable(''public'', ''test_translationtable3''::text);')
                = 'ERROR IN TRANSLATION TABLE AT RULE_ID # 1 (CROWN_CLOSURE_UPPER) : Error code is NULL or empty for validation rule notNull().' passed
---------------------------------------------------------
-- Test 6 - TT_TextFctExists
--------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_TextFctExists'::text function_tested,
       'Test two NULLs'::text description,
        TT_TextFctExists(NULL, NULL) IS FALSE passed
--------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_TextFctExists'::text function_tested,
       'Test one empty'::text description,
        TT_TextFctExists('', NULL) = FALSE passed
--------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_TextFctExists'::text function_tested,
       'Basic test'::text description,
        TT_TextFctExists('isbetween', '3') passed
--------------------------------------------------------
-- Test 7 - TT_Prepare
--------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_Prepare'::text function_tested,
       'Basic test, check if created function exists'::text description,
        TT_FctExists('public', 'translate', ARRAY['name', 'name', 'name', 'boolean', 'boolean', 'text', 'integer', 'boolean', 'boolean', 'boolean']) IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_Prepare'::text function_tested,
       'Test without schema name'::text description,
        TT_FctExists('translate', ARRAY['name', 'name', 'name', 'boolean', 'boolean', 'text', 'integer', 'boolean', 'boolean', 'boolean']) IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '7.3'::text number,
       'TT_Prepare'::text function_tested,
       'Test without parameters'::text description,
        TT_FctExists('translate') IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '7.4'::text number,
       'TT_Prepare'::text function_tested,
       'Test upper and lower case caracters'::text description,
        TT_FctExists('Public', 'translate', ARRAY['Name', 'Name', 'name', 'boOlean', 'booLean', 'text', 'intEger', 'booleaN', 'boolean', 'boolean']) IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '7.5'::text number,
       'TT_Prepare'::text function_tested,
       'Test without schema name'::text description,
        TT_Prepare('test_translationtable') = 'TT_Translate' passed
--------------------------------------------------------
UNION ALL
SELECT '7.6'::text number,
       'TT_Prepare'::text function_tested,
       'Test suffix'::text description,
        TT_Prepare('public', 'test_translationtable', '_01') = 'TT_Translate_01' passed
--------------------------------------------------------
UNION ALL
SELECT '7.7'::text number,
       'TT_Prepare'::text function_tested,
       'Test with ref translation table having less'::text description,
        TT_IsError('SELECT TT_Prepare(''public'', ''test_translationtable'', ''_01'', ''test_translationtable2'');') = 'TT_Prepare() ERROR: Translation table ''public.test_translationtable'' has more attributes than reference table ''public.test_translationtable2''...' passed
--------------------------------------------------------
UNION ALL
SELECT '7.8'::text number,
       'TT_Prepare'::text function_tested,
       'Test with identical ref translation table'::text description,
        TT_Prepare('public', 'test_translationtable', '_01', 'test_translationtable') = 'TT_Translate_01' passed
--------------------------------------------------------
-- Test 8 - TT_TextFctReturnType
--------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_TextFctReturnType'::text function_tested,
       'Basic test'::text description,
        TT_TextFctReturnType('isbetween', 3) = 'boolean' passed
--------------------------------------------------------
-- Test 9 - TT_TextFctEval
--------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_TextFctEval'::text function_tested,
       'Basic test'::text description,
        TT_TextFctEval('isbetween', '{crown_closure,''0.0'',''2.0''}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE) passed
--------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_TextFctEval'::text function_tested,
       'Basic NULLs'::text description,
        TT_Iserror('SELECT TT_TextFctEval(NULL, NULL, NULL, NULL::boolean, NULL)') = 'ERROR IN TRANSLATION TABLE: Helper function <NULL>(<NULL>) does not exist.' passed
--------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_TextFctEval'::text function_tested,
       'Wrong function name'::text description,
        TT_Iserror('SELECT TT_TextFctEval(''xisbetween'', ''{crown_closure, 0, 2}''::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE)') = 'ERROR IN TRANSLATION TABLE: Helper function xisbetween(text,text,text) does not exist.' passed
--------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_TextFctEval'::text function_tested,
       'Wrong argument type'::text description,
        TT_IsError('SELECT TT_TextFctEval(''isbetween'', ''{crown_closure, 0, ''''b''''}''::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE)') = 'ERROR in TT_IsBetween(): max is not a numeric value' passed
--------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_TextFctEval'::text function_tested,
       'Argument not found in jsonb structure'::text description,
        TT_IsError('SELECT TT_TextFctEval(''isbetween'', ''{crown_closureX, 0, 2}''::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE)') = 'ERROR IN TRANSLATION TABLE: Source attribute ''crown_closureX'', called in function ''isbetween()'', does not exist...' passed
--------------------------------------------------------
UNION ALL
SELECT '9.6'::text number,
       'TT_TextFctEval'::text function_tested,
       'Wrong but compatible return type'::text description,
        TT_TextFctEval('isbetween', '{crown_closure, 0.0, 2.0}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::int, TRUE) = 1 passed
--------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_TextFctEval'::text function_tested,
       'Comma separated string, no column names'::text description,
        TT_TextFctEval('Concat', '{"{''a'',''b'',''c''}",''-''}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) = 'a-b-c' passed
--------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_TextFctEval'::text function_tested,
       'Comma separated string, column names only'::text description,
        TT_TextFctEval('Concat', '{"{id,crown_closure}",''-''}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) = 'a-1' passed
--------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_TextFctEval'::text function_tested,
       'Comma separated string, mixed column names and strings'::text description,
        TT_TextFctEval('Concat', '{"{id,''b'',crown_closure}",''-''}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) = 'a-b-1' passed
--------------------------------------------------------
UNION ALL
SELECT '9.10'::text number,
       'TT_TextFctEval'::text function_tested,
       'NULL parameters for a function not taking parameters'::text description,
        TT_TextFctEval('NothingText', NULL, to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '9.11'::text number,
       'TT_TextFctEval'::text function_tested,
       'NULL parameters and NULL values for a function not taking parameters'::text description,
        TT_TextFctEval('NothingText', NULL, NULL, NULL::text, TRUE) IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '9.12'::text number,
       'TT_TextFctEval'::text function_tested,
       'function taking a string with a string beginning with a space'::text description,
        TT_TextFctEval('CopyText', '{''aa''}'::text[], NULL, NULL::text, TRUE) = 'aa' passed
--------------------------------------------------------
UNION ALL
SELECT '9.13'::text number,
       'TT_TextFctEval'::text function_tested,
       'function taking a string with a string beginning with a space'::text description,
        TT_TextFctEval('CopyText', '{'' aa ''}'::text[], NULL, NULL::text, TRUE) = ' aa ' passed
--------------------------------------------------------
UNION ALL
SELECT '9.14'::text number,
       'TT_TextFctEval'::text function_tested,
       'function taking a string with a string beginning with a space'::text description,
        TT_TextFctEval('CopyText', '{ src }'::text[], to_jsonb((SELECT r FROM (SELECT ' bb ' src) r)), NULL::text, TRUE) = ' bb ' passed
--------------------------------------------------------
UNION ALL
SELECT '9.15'::text number,
       'TT_TextFctEval'::text function_tested,
       'function taking a string with a string beginning with a space'::text description,
        TT_TextFctEval('CopyText', '{'' src ''}'::text[], to_jsonb((SELECT r FROM (SELECT ' bb ' src) r)), NULL::text, TRUE) = ' src ' passed
--------------------------------------------------------
-- TT_ParseStringList
--------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_ParseStringList'::text function_tested,
       'No parameters'::text description,
       TT_ParseStringList() IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_ParseStringList'::text function_tested,
       'NULL parameter'::text description,
       TT_ParseStringList(NULL) IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '10.3'::text number,
       'TT_ParseStringList'::text function_tested,
       'NULL string'::text description,
       TT_ParseStringList('NULL') = '{"NULL"}' passed
--------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_ParseStringList'::text function_tested,
       'NULL string'::text description,
       TT_ParseStringList('{NULL}') = '{NULL}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.5'::text number,
       'TT_ParseStringList'::text function_tested,
       'String and NULL string'::text description,
       TT_ParseStringList('{aa, NULL}') = '{aa, NULL}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.6'::text number,
       'TT_ParseStringList'::text function_tested,
       'string without quotes, spaces are trimmed'::text description,
       TT_ParseStringList(' a a ') = '{"a a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.7'::text number,
       'TT_ParseStringList'::text function_tested,
       'string without quotes with comma'::text description,
       TT_ParseStringList('a b ,a') = '{"a b ,a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.8'::text number,
       'TT_ParseStringList'::text function_tested,
       'single quoted string with comma'::text description,
       TT_ParseStringList('''a ,a''') = '{"''a ,a''"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.9'::text number,
       'TT_ParseStringList'::text function_tested,
       'double quoted string with comma'::text description,
       TT_ParseStringList('"a ,a"') = '{"a ,a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.10'::text number,
       'TT_ParseStringList'::text function_tested,
       'double quoted string with spaces and comma'::text description,
       TT_ParseStringList('" a ,a "') = '{" a ,a "}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.11'::text number,
       'TT_ParseStringList'::text function_tested,
       'double quoted string with doubled single quote'::text description,
       TT_ParseStringList('"a ''a"') = '{"a ''a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.12'::text number,
       'TT_ParseStringList'::text function_tested,
       'double quoted string with doubled single quote and double quotes'::text description,
       TT_ParseStringList('"a ''a", "b ''b"') = '{"a ''a\", \"b ''b"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.13'::text number,
       'TT_ParseStringList'::text function_tested,
       'string looking like a stringlist but is a string because quoted'::text description,
       TT_ParseStringList('"{ a ,b ,c ,d }"') = '{"{ a ,b ,c ,d }"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.14'::text number,
       'TT_ParseStringList'::text function_tested,
       'string with escaped double quote'::text description,
       TT_ParseStringList('a "a') = '{"a \"a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.15'::text number,
       'TT_ParseStringList'::text function_tested,
       'string with escaped double quote'::text description,
       TT_ParseStringList('a \"a') = '{"a \\\"a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.16'::text number,
       'TT_ParseStringList'::text function_tested,
       'double quoted string with non-escaped double quote'::text description,
       TT_ParseStringList('"a "a"') = '{"a \"a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.17'::text number,
       'TT_ParseStringList'::text function_tested,
       'double quoted string with escaped double quote'::text description,
       TT_ParseStringList('"a \"a"') = '{"a \\\"a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.18'::text number,
       'TT_ParseStringList'::text function_tested,
       'basic stringlist'::text description,
       TT_ParseStringList('{ a ,b ,c ,d }') = '{a,b,c,d}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.19'::text number,
       'TT_ParseStringList'::text function_tested,
       'basic stringlist surrounded by spaces'::text description,
       TT_ParseStringList(' { a ,b ,c ,d } ') = '{a,b,c,d}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.20'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with one double quoted string and one single quoted string'::text description,
       TT_ParseStringList('{ a ," b ",c ,'' d '' }') = '{a," b ",c,"'' d ''"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.21'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with one single quoted string and one double quoted string'::text description,
       TT_ParseStringList('{''str 1'', "str 2"}') = '{"''str 1''","str 2"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.22'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with two quoted strings with comma'::text description,
       TT_ParseStringList('{" a ,b" ,"c ,d "}') = '{" a ,b","c ,d "}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.23'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with two quoted strings with single quotes'::text description,
       TT_ParseStringList('{"a ''a", "b ''b"}') = '{"a ''a","b ''b"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.24'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with two double quoted strings, one with double quotes inside'::text description,
       TT_ParseStringList('{"a \"b" ," , a"}') = '{"a \"b"," , a"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.25'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with one double quoted strings with double quotes inside and one unquoted string with space'::text description,
       TT_ParseStringList('{"a \"b" , a b}') = '{"a \"b","a b"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.26'::text number,
       'TT_ParseStringList'::text function_tested,
       'stringlist with one single quoted strings with one single quoted strings with double quotes inside'::text description,
       TT_ParseStringList('{a a, ''b \"b''}') = '{"a a","''b \"b''"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.27'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - two strings'::text description,
       TT_ParseStringList('{''str 1'', "str @-_= //2"}') = '{"''str 1''","str @-_= //2"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.28'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - two column names'::text description,
       TT_ParseStringList('{column_A, column-B}') = '{column_A,column-B}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.29'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - one single quoted string and one column name'::text description,
       TT_ParseStringList('{''string 1'', column_A}') = '{''string 1'',column_A}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.30'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - two column names'::text description,
       TT_ParseStringList('{''string 1 ''}') = '{''string 1 ''}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.31'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_ParseStringList('{column_A}') = '{column_A}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.32'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_ParseStringList('{column A}') = '{column A}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.33'::text number,
       'TT_ParseStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_ParseStringList('{''string1'',"string 2"}', TRUE) = '{string1,"string 2"}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.34'::text number,
       'TT_ParseStringList'::text function_tested,
       'malformed string array'::text description,
       TT_IsError('SELECT TT_ParseStringList(''{''''string1'''',}'');') = 'malformed array literal: "{''string1'',}"' passed
--------------------------------------------------------
UNION ALL
SELECT '10.35'::text number,
       'TT_ParseStringList'::text function_tested,
       'integer array'::text description,
       TT_ParseStringList('{-134, 4567}') = '{-134,4567}'::text[] passed
--------------------------------------------------------
UNION ALL
SELECT '10.36'::text number,
       'TT_ParseStringList'::text function_tested,
       'string with single quotes'::text description,
       TT_ParseStringList(''' a ,a ''') = '{"'' a ,a ''"}'::text[] passed
--------------------------------------------------------
-- TT_RepackStringList test
--------------------------------------------------------
UNION ALL
SELECT '11.1'::text number,
       'TT_RepackStringList'::text function_tested,
       'No parameters'::text description,
       TT_RepackStringList() IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '11.2'::text number,
       'TT_RepackStringList'::text function_tested,
       'NULL parameter'::text description,
       TT_RepackStringList(NULL) IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '11.3'::text number,
       'TT_RepackStringList'::text function_tested,
       'NULL string'::text description,
       TT_RepackStringList('{"NULL"}'::text[]) = 'NULL' passed
--------------------------------------------------------
UNION ALL
SELECT '11.4'::text number,
       'TT_RepackStringList'::text function_tested,
       'NULL string'::text description,
       TT_RepackStringList('{NULL}'::text[]) IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '11.5'::text number,
       'TT_RepackStringList'::text function_tested,
       'String and NULL string'::text description,
       TT_RepackStringList('{aa, NULL}'::text[]) = '{"aa",NULL}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.6'::text number,
       'TT_RepackStringList'::text function_tested,
       'string without quotes, spaces are trimmed'::text description,
       --TT_RepackStringList('{"a a"}'::text[]) = '"a a"' passed
       TT_RepackStringList('{"a a"}'::text[]) = 'a a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.7'::text number,
       'TT_RepackStringList'::text function_tested,
       'string without quotes with comma'::text description,
       --TT_RepackStringList('{"a b ,a"}'::text[]) = '"a b ,a"' passed
       TT_RepackStringList('{"a b ,a"}'::text[]) = 'a b ,a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.8'::text number,
       'TT_RepackStringList'::text function_tested,
       'single quoted string with comma'::text description,
       --TT_RepackStringList('{"''a ,a''"}'::text[]) = '"''a ,a''"' passed
       TT_RepackStringList('{"''a ,a''"}'::text[]) = '''a ,a''' passed
--------------------------------------------------------
UNION ALL
SELECT '11.9'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with comma'::text description,
       --TT_RepackStringList('{"a ,a"}'::text[]) = '"a ,a"' passed
       TT_RepackStringList('{"a ,a"}'::text[]) = 'a ,a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.10'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with spaces and comma'::text description,
       --TT_RepackStringList('{" a ,a "}'::text[]) = '" a ,a "' passed
       TT_RepackStringList('{" a ,a "}'::text[]) = ' a ,a ' passed
--------------------------------------------------------
UNION ALL
SELECT '11.11'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with doubled single quote'::text description,
       --TT_RepackStringList('{"a ''a"}'::text[]) = '"a ''a"' passed
       TT_RepackStringList('{"a ''a"}'::text[]) = 'a ''a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.12'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with doubled single quote and double quotes'::text description,
       --TT_RepackStringList('{"a ''a\", \"b ''b"}'::text[]) = '"a ''a", "b ''b"' passed
       TT_RepackStringList('{"a ''a\", \"b ''b"}'::text[]) = 'a ''a", "b ''b' passed
--------------------------------------------------------
UNION ALL
SELECT '11.13'::text number,
       'TT_RepackStringList'::text function_tested,
       'string looking like a stringlist but is a string because quoted'::text description,
       --TT_RepackStringList('{"{ a ,b ,c ,d }"}'::text[]) = '"{ a ,b ,c ,d }"' passed
       TT_RepackStringList('{"{ a ,b ,c ,d }"}'::text[]) = '{ a ,b ,c ,d }' passed
--------------------------------------------------------
UNION ALL
SELECT '11.14'::text number,
       'TT_RepackStringList'::text function_tested,
       'string with escaped double quote'::text description,
       TT_RepackStringList('{"a \"a"}'::text[]) = 'a "a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.15'::text number,
       'TT_RepackStringList'::text function_tested,
       'string with escaped double quote'::text description,
       TT_RepackStringList('{"a \\\"a"}'::text[]) = 'a \"a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.16'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with non-escaped double quote'::text description,
       TT_RepackStringList('{"a \"a"}'::text[]) = 'a "a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.17'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with escaped double quote'::text description,
       TT_RepackStringList('{"a \\\"a"}'::text[]) = 'a \"a' passed
--------------------------------------------------------
UNION ALL
SELECT '11.18'::text number,
       'TT_RepackStringList'::text function_tested,
       'basic stringlist'::text description,
       TT_RepackStringList('{a,b,c,d}'::text[]) = '{"a","b","c","d"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.19'::text number,
       'TT_RepackStringList'::text function_tested,
       'basic stringlist surrounded by spaces'::text description,
       TT_RepackStringList('{a,b,c,d}'::text[]) = '{"a","b","c","d"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.20'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with one double quoted string and one single quoted string'::text description,
       TT_RepackStringList('{a," b ",c,"'' d ''"}'::text[]) = '{"a"," b ","c","'' d ''"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.21'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with one single quoted string and one double quoted string'::text description,
       TT_RepackStringList('{"''str 1''","str 2"}'::text[]) = '{"''str 1''","str 2"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.22'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with two quoted strings with comma'::text description,
       TT_RepackStringList('{" a ,b","c ,d "}'::text[]) = '{" a ,b","c ,d "}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.23'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with two quoted strings with single quotes'::text description,
       TT_RepackStringList('{"a ''a","b ''b"}'::text[]) = '{"a ''a","b ''b"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.24'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with two double quoted strings, one with double quotes inside'::text description,
       TT_RepackStringList('{"a \"b"," , a"}'::text[]) = '{"a \"b"," , a"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.25'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with one double quoted strings with double quotes inside and one unquoted string with space'::text description,
       TT_RepackStringList('{"a \"b","a b"}'::text[]) = '{"a \"b","a b"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.26'::text number,
       'TT_RepackStringList'::text function_tested,
       'stringlist with one single quoted strings with one single quoted strings with double quotes inside'::text description,
       TT_RepackStringList('{"a a","''b \"b''"}'::text[]) = '{"a a","''b \"b''"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.27'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - two strings'::text description,
       TT_RepackStringList('{"''str 1''","str @-_= //2"}'::text[]) = '{"''str 1''","str @-_= //2"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.28'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - two column names'::text description,
       TT_RepackStringList('{column_A,column-B}'::text[]) = '{"column_A","column-B"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.29'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - one single quoted string and one column name'::text description,
       TT_RepackStringList('{''string 1'',column_A}'::text[]) = '{"''string 1''","column_A"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.30'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - two column names'::text description,
       TT_RepackStringList('{''string 1 ''}'::text[]) = '''string 1 ''' passed
--------------------------------------------------------
UNION ALL
SELECT '11.31'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_RepackStringList('{column_A}'::text[]) = 'column_A' passed
--------------------------------------------------------
UNION ALL
SELECT '11.32'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_RepackStringList('{column A}'::text[]) = 'column A' passed
--------------------------------------------------------
UNION ALL
SELECT '11.33'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_RepackStringList('{string1,"string 2"}'::text[]) = '{"string1","string 2"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.34'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - one column name'::text description,
       TT_RepackStringList('{-134,4567}'::text[]) = '{"-134","4567"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.35'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - two single quotes strings and one column name'::text description,
       TT_RepackStringList(ARRAY['''str1''', '''str 2''', 'col_A']) = '{"''str1''","''str 2''","col_A"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.36'::text number,
       'TT_RepackStringList'::text function_tested,
       'old test - two single quotes strings and one column name'::text description,
       TT_RepackStringList(ARRAY['''str 1 --''', '''str@/\:2''']) = '{"''str 1 --''","''str@/\\:2''"}' passed
--------------------------------------------------------
UNION ALL
SELECT '11.37'::text number,
       'TT_RepackStringList'::text function_tested,
       'double quoted string with spaces and comma'::text description,
       --TT_RepackStringList('{" a ,a "}'::text[]) = '" a ,a "' passed
       TT_RepackStringList('{"'' a ,a ''"}') = ''' a ,a ''' passed
--------------------------------------------------------
-- TT_IsCastableTo
--------------------------------------------------------
UNION ALL
SELECT '12.1'::text number,
       'TT_IsCastableTo'::text function_tested,
       'Good test'::text description,
       TT_IsCastableTo('11', 'int') passed
--------------------------------------------------------
UNION ALL
SELECT '12.2'::text number,
       'TT_IsCastableTo'::text function_tested,
       'Bad test'::text description,
       TT_IsCastableTo('11a', 'int') IS FALSE passed
--------------------------------------------------------
) AS b
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed OR passed IS NULL
-- Comment out this line to display only test number
--OR ((regexp_split_to_array(number, '\.'))[1])::int = 12
;
