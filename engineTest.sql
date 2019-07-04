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
DROP TABLE IF EXISTS test_translationTable;
CREATE TABLE test_translationTable AS
SELECT '1' rule_id,
       'CROWN_CLOSURE_UPPER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure| -8888);between(crown_closure, 0, 100| -9999)'::text validationRules,
       'copyInt(crown_closure)'::text translationRules,
       'Test'::text description,
       'TRUE' descUpToDateWithRules
UNION ALL
SELECT '2' rule_id,
       'CROWN_CLOSURE_LOWER'::text targetAttribute,
       'integer'::text targetAttributeType,
       'notNull(crown_closure| -8888);between(crown_closure, 0, 100| -9999)'::text validationRules,
       'copyInt(crown_closure)'::text translationRules,
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
------------------------------------------------------------------------------- 
-- TT_LowerArr 
-- Function needed by TT_FctExist below. 
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_LowerArr(text[]); 
CREATE OR REPLACE FUNCTION TT_LowerArr( 
  arr text[] DEFAULT NULL 
) 
RETURNS text[] AS $$ 
  DECLARE 
    newArr text[] = ARRAY[]::text[]; 
  BEGIN 
    IF NOT arr IS NULL AND arr = ARRAY[]::text[] THEN 
      RETURN ARRAY[]::text[]; 
    END IF; 
    SELECT array_agg(lower(a)) FROM unnest(arr) a INTO newArr; 
    RETURN newArr; 
  END; 
$$ LANGUAGE plpgsql VOLATILE STRICT; 
-------------------------------------------------------------------------------

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
    --WHERE proname = fctName     
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
--SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    SELECT 'TT_FullTableName'::text function_tested, 1 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_ParseArgs'::text,                     2,         11         UNION ALL
    SELECT 'TT_ParseRules'::text,                    3,          9         UNION ALL
    SELECT 'TT_ValidateTTable'::text,                4,          4         UNION ALL
    SELECT 'TT_TextFctExists'::text,                 6,          2         UNION ALL
    SELECT 'TT_Prepare'::text,                       7,          4         UNION ALL
    SELECT 'TT_TextFctReturnType'::text,             8,          1         UNION ALL
    SELECT 'TT_TextFctEval'::text,                   9,          9         UNION ALL
    SELECT '_TT_Translate'::text,                   10,          0
),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, generate_series(1, nb_test)::text min_num 
FROM test_nb
)
SELECT coalesce(maj_num || '.' || min_num, b.number) number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of test for ' || 
                b.function_tested || ' in the initial table...') function_tested,
       description, 
       NOT passed IS NULL AND (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series a FULL OUTER JOIN (

---------------------------------------------------------
-- Test 1 - TT_FullTableName
---------------------------------------------------------
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
UNION ALL
SELECT '2.1'::text number,
       'TT_ParseArgs'::text function_tested,
       'Basic test, space and numeric'::text description,
        TT_ParseArgs('aa,  bb,-111.11') = ARRAY['aa', 'bb', '-111.11'] passed
---------------------------------------------------------
-- Test 2 - TT_ParseArgs
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test NULL'::text description,
        TT_ParseArgs() IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test empty'::text description,
        TT_ParseArgs('') IS NULL  passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test value containing a comma'::text description,
        TT_ParseArgs('"a,a", bb,-111.11') = ARRAY['a,a', 'bb', '-111.11'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test value containing a single quote'::text description,
        TT_ParseArgs('"a''a", bb,-111.11') = ARRAY['a''a', 'bb', '-111.11'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test one empty value'::text description,
        TT_ParseArgs('"", bb,-111.11') = ARRAY['', 'bb', '-111.11'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.7'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test one NULL value'::text description,
        TT_ParseArgs(', bb,-111.11') = ARRAY['bb', '-111.11'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.8'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test only quoted values'::text description,
        TT_ParseArgs('"aa", "bb", "-111.11"') = ARRAY['aa', 'bb', '-111.11'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.9'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test only single quoted values'::text description,
        TT_ParseArgs('''aa'', ''bb'', ''-111.11''') = ARRAY['aa', 'bb', '-111.11'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.10'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test trailing spaces'::text description,
        TT_ParseArgs('aa''bb') = ARRAY['aa''bb'] passed
---------------------------------------------------------
UNION ALL
SELECT '2.11'::text number,
       'TT_ParseArgs'::text function_tested,
       'Test single quote inside single quotes'::text description,
        TT_ParseArgs('  aa, bb  ') = ARRAY['aa', 'bb'] passed
---------------------------------------------------------
-- Test 3 - TT_ParseRules
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_ParseRules'::text function_tested,
       'Basic test, space and numeric'::text description,
        TT_ParseRules('test1(aa, bb,-999.55); test2(cc, dd,222.22)') = ARRAY[('test1', '{aa,bb,-999.55}', NULL, FALSE)::TT_RuleDef, ('test2', '{cc,dd,222.22}', NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_ParseRules'::text function_tested,
       'Test NULL'::text description,
        TT_ParseRules() IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_ParseRules'::text function_tested,
       'Test empty'::text description,
        TT_ParseRules('') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_ParseRules'::text function_tested,
       'Test empty function'::text description,
        TT_ParseRules('test1()') = ARRAY[('test1', NULL, NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_ParseRules'::text function_tested,
       'Test many empty functions'::text description,
        TT_ParseRules('test1(); test2();  test3()') = ARRAY[('test1', NULL, NULL, FALSE)::TT_RuleDef, ('test2', NULL, NULL, FALSE)::TT_RuleDef, ('test3', NULL, NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_ParseRules'::text function_tested,
       'Test quoted arguments'::text description,
        TT_ParseRules('test1("aa", ''bb'')') =  ARRAY[('test1', '{aa,bb}', NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_ParseRules'::text function_tested,
       'Test quoted arguments containing comma and quotes'::text description,
        TT_ParseRules('test1("a,a", ''b''b'', ''c"c'')') = ARRAY[('test1', '{"a,a","b''b","c\"c"}', NULL, FALSE)::TT_RuleDef]::TT_RuleDef[] passed
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_ParseRules'::text function_tested,
       'Test that quoted is equivalent to unquoted (when not containing comma or quotes)'::text description,
        TT_ParseRules('test1("aa", ''bb'')') =  TT_ParseRules('test1(aa, bb)') passed
---------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'TT_ParseRules'::text function_tested,
       'Test what''s in the test translation table'::text description,
        array_agg(TT_ParseRules(validationRules)) = ARRAY[ARRAY[('notNull', '{crown_closure}', -8888, FALSE)::TT_RuleDef, ('between', '{crown_closure, 0, 100}', -9999, FALSE)::TT_RuleDef]::TT_RuleDef[], ARRAY[('notNull', '{crown_closure}', -8888, FALSE)::TT_RuleDef, ('between', '{crown_closure, 0, 100}', -9999, FALSE)::TT_RuleDef]::TT_RuleDef[]] passed
FROM public.test_translationtable
---------------------------------------------------------
-- Test 4 - TT_ValidateTTable
--------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Basic test'::text description,
        array_agg(rec)::text = 
'{"(CROWN_CLOSURE_UPPER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(between,\\\\\"\"{crown_closure,0,100}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\",Test,t)","(CROWN_CLOSURE_LOWER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(between,\\\\\"\"{crown_closure,0,100}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\",Test,t)"}' passed
FROM (SELECT TT_ValidateTTable('public', 'test_translationtable') rec) foo
--------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test for NULL'::text description,
        array_agg(rec)::text IS NULL passed
FROM (SELECT TT_ValidateTTable() rec) foo
--------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test for emptys'::text description,
        array_agg(rec)::text IS NULL passed
FROM (SELECT TT_ValidateTTable('', '') rec) foo
--------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_ValidateTTable'::text function_tested,
       'Test default schema to public'::text description,
        array_agg(rec)::text = 
'{"(CROWN_CLOSURE_UPPER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(between,\\\\\"\"{crown_closure,0,100}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\",Test,t)","(CROWN_CLOSURE_LOWER,integer,\"{\"\"(notNull,{crown_closure},-8888,f)\"\",\"\"(between,\\\\\"\"{crown_closure,0,100}\\\\\"\",-9999,f)\"\"}\",\"(copyInt,{crown_closure},,f)\",Test,t)"}' passed
FROM (SELECT TT_ValidateTTable('test_translationtable') rec) foo
---------------------------------------------------------
-- Test 6 - TT_TextFctExists
--------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_TextFctExists'::text function_tested,
       'Test two NULLs'::text description,
        TT_TextFctExists(NULL, NULL) IS NULL passed
--------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_TextFctExists'::text function_tested,
       'Test one empty'::text description,
        TT_TextFctExists('', NULL) = FALSE passed
--------------------------------------------------------
-- Test 7 - TT_Prepare
--------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_Prepare'::text function_tested,
       'Basic test, check if created function exists'::text description,
        TT_FctExists('public', 'translate', ARRAY['name', 'name', 'name', 'name', 'text[]', 'boolean', 'integer', 'boolean', 'boolean']) passed
--------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_Prepare'::text function_tested,
       'Test without schema name'::text description,
        TT_FctExists('translate', ARRAY['name', 'name', 'name', 'name', 'text[]', 'boolean', 'integer', 'boolean', 'boolean']) passed
--------------------------------------------------------
UNION ALL
SELECT '7.3'::text number,
       'TT_Prepare'::text function_tested,
       'Test without parameters'::text description,
        TT_FctExists('translate') passed
--------------------------------------------------------
UNION ALL
SELECT '7.4'::text number,
       'TT_Prepare'::text function_tested,
       'Test upper and lower case caracters'::text description,
        TT_FctExists('Public', 'translate', ARRAY['Name', 'name', 'name', 'name', 'tExt[]', 'boolean', 'intEger', 'boolean', 'boolean']) passed
--------------------------------------------------------
-- Test 8 - TT_TextFctReturnType
--------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_TextFctReturnType'::text function_tested,
       'Basic test'::text description,
        TT_TextFctReturnType('between', 3) = 'boolean' passed
--------------------------------------------------------
-- Test 9 - TT_TextFctEval
--------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_TextFctEval'::text function_tested,
       'Basic test'::text description,
        TT_TextFctEval('between', '{crown_closure,0.0,2.0}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE) passed
--------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_TextFctEval'::text function_tested,
       'Basic NULLs'::text description,
        TT_Iserror('TT_TextFctEval(NULL, NULL, NULL, NULL::boolean, NULL)') IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_TextFctEval'::text function_tested,
       'Wrong fonction name'::text description,
        TT_Iserror('TT_TextFctEval(''xbetween'', ''{crown_closure, 0, 2}''::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE)') IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_TextFctEval'::text function_tested,
       'Wrong argument type'::text description,
        TT_IsError('TT_TextFctEval(''between'', ''{crown_closure, 0, ''b''}''::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE)') IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_TextFctEval'::text function_tested,
       'Argument not found in jsonb structure'::text description,
        TT_IsError('TT_TextFctEval(''between'', ''{xcrown_closure, 0, 2}''::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::boolean, TRUE)') IS TRUE passed
--------------------------------------------------------
UNION ALL
SELECT '9.6'::text number,
       'TT_TextFctEval'::text function_tested,
       'Wrong but compatible return type'::text description,
        TT_TextFctEval('between', '{crown_closure, 0.0, 2.0}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::int, TRUE) = 1 passed
--------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_TextFctEval'::text function_tested,
       'Comma separated string, no column names'::text description,
        TT_TextFctEval('Concat', '{"a,b,c",-}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) = 'a-b-c' passed
--------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_TextFctEval'::text function_tested,
       'Comma separated string, column names only'::text description,
        TT_TextFctEval('Concat', '{"id,crown_closure",-}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) = 'a-1' passed
--------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_TextFctEval'::text function_tested,
       'Comma separated string, mixed column names and strings'::text description,
        TT_TextFctEval('Concat', '{"id,b,crown_closure",-}'::text[], to_jsonb((SELECT r FROM (SELECT * FROM test_sourcetable1 LIMIT 1) r)), NULL::text, TRUE) = 'a-b-1' passed
--------------------------------------------------------
) b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num) 
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed
;
