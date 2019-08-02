------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Main installation file
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
-------------------------------------------------------------------------------
-- Types Definitions...
-------------------------------------------------------------------------------
--DROP TYPE TT_RuleDef;
CREATE TYPE TT_RuleDef AS (
  fctName text,
  args text[],
  errorcode text,
  stopOnInvalid boolean
);

-- Debug configuration variable. Set tt.debug to TRUE to display all RAISE NOTICE
SET tt.debug TO FALSE;

-------------------------------------------------------------------------------
-- Function Definitions...
-------------------------------------------------------------------------------
-- TT_Debug
--
--   RETURNS boolean  - True if tt_debug is set to true. False if set to false or not set.
--
-- Wrapper to catch error when tt.error is not set.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Debug();
CREATE OR REPLACE FUNCTION TT_Debug(
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    RETURN current_setting('tt.debug')::boolean;
    EXCEPTION WHEN OTHERS THEN -- if tt.debug is not set
      RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsCastableTo
--
--   val text
--   targetType text
--
--   RETURNS boolean
--
-- Can value be cast to target type
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_IsCastableTo(text, text);
CREATE OR REPLACE FUNCTION TT_IsCastableTo(
  val text,
  targetType text
)
RETURNS boolean AS $$
  DECLARE
    query text;
  BEGIN
    query = 'SELECT ' || '''' || val || '''' || '::' || targetType || ';';
    EXECUTE query;
    RETURN TRUE;
  EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_UnSingleQuote
-- DROP FUNCTION IF EXISTS TT_UnSingleQuote(text);
CREATE OR REPLACE FUNCTION TT_UnSingleQuote(
  str text
)
RETURNS text AS $$
  SELECT CASE WHEN left(str, 1) = '''' AND right(str, 1) = '''' THEN btrim(str, '''') ELSE str END;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_EscapeSingleQuotes
-- DROP FUNCTION IF EXISTS TT_EscapeSingleQuotes(text);
CREATE OR REPLACE FUNCTION TT_EscapeSingleQuotes(
  str text
)
RETURNS text AS $$
    SELECT replace(str, '''', '''''');
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_EscapeDoubleQuotes
-- DROP FUNCTION IF EXISTS TT_EscapeDoubleQuotesAndBackslash(text);
CREATE OR REPLACE FUNCTION TT_EscapeDoubleQuotesAndBackslash(
  str text
)
RETURNS text AS $$
  SELECT replace(replace(str, '\', '\\'), '"', '\"'); -- '''
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LowerArr
-- Lowercase text array (often to compare them while ignoring case)
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
-- TT_FullTableName
--
--   schemaName name - Name of the schema.
--   tableName name  - Name of the table.
--
--   RETURNS text    - Full name of the table.
--
-- Return a well quoted, full table name, including the schema.
-- The schema default to 'public' if not provided.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_FullTableName(name, name);
CREATE OR REPLACE FUNCTION TT_FullTableName(
  schemaName name,
  tableName name
)
RETURNS text AS $$
  DECLARE
    newSchemaName text = '';
  BEGIN
    IF length(schemaName) > 0 THEN
      newSchemaName = schemaName;
    ELSE
      newSchemaName = 'public';
    END IF;
    RETURN quote_ident(newSchemaName) || '.' || quote_ident(tableName);
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FullFunctionName
--
--   schemaName name - Name of the schema.
--   fctName name    - Name of the function.
--
--   RETURNS text    - Full name of the table.
--
-- Return a full function name, including the schema.
-- The schema default to 'public' if not provided.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_FullFunctionName(name, name);
CREATE OR REPLACE FUNCTION TT_FullFunctionName(
  schemaName name,
  fctName name
)
RETURNS text AS $$
  DECLARE
  BEGIN
    IF fctName IS NULL THEN
      RETURN NULL;
    END IF;
    fctName = 'tt_' || lower(fctName);
    schemaName = lower(schemaName);
    IF schemaName = 'public' OR schemaName IS NULL THEN
      schemaName = '';
    END IF;
    IF schemaName != '' THEN
      fctName = schemaName || '.' || fctName;
    END IF;
    RETURN fctName;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_DropAllTranslateFct
--
--   RETURNS SETOF text     - All DROPed query executed.
--
-- DROP all functions starting with 'TT_Translate' (case insensitive).
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DropAllTranslateFct();
CREATE OR REPLACE FUNCTION TT_DropAllTranslateFct(
)
RETURNS SETOF text AS $$
  DECLARE
    res RECORD;
  BEGIN
    FOR res IN SELECT 'DROP FUNCTION ' || oid::regprocedure::text query
               FROM pg_proc WHERE left(proname, 12) = 'tt_translate' AND pg_function_is_visible(oid) LOOP
      EXECUTE res.query;
      RETURN NEXT res.query;
    END LOOP;
  RETURN;
END
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_TextFctExist
--
--   schemaName name,
--   fctString text
--   argLength  int
--
--   RETURNS boolean
--
-- Returns TRUE if fctString exists as a function in the catalog with the
-- specified function name and number of arguments. Only works for helper
-- functions accepting text arguments only.
------------------------------------------------------------
-- Self contained example:
--
-- SELECT TT_TextFctExists('TT_NotNull', 1)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TextFctExists(text, int);
CREATE OR REPLACE FUNCTION TT_TextFctExists(
  schemaName name,
  fctName name,
  argLength int
)
RETURNS boolean AS $$
  DECLARE
    cnt int = 0;
    debug boolean = TT_Debug();
    args text;
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_TextFctExists BEGIN';END IF;
    fctName = TT_FullFunctionName(schemaName, fctName);
    IF fctName IS NULL THEN
      RETURN FALSE;
    END IF;
    IF debug THEN RAISE NOTICE 'TT_TextFctExists 11 fctName=%, argLength=%', fctName, argLength;END IF;

    SELECT count(*)
    FROM pg_proc
    WHERE proname = fctName AND coalesce(cardinality(proargnames), 0) = argLength
    INTO cnt;

    IF cnt > 0 THEN
      IF debug THEN RAISE NOTICE 'TT_TextFctExists END TRUE';END IF;
      RETURN TRUE;
    END IF;
    IF debug THEN RAISE NOTICE 'TT_TextFctExists END FALSE';END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_TextFctExists(
  fctName name,
  argLength int
)
RETURNS boolean AS $$
  SELECT TT_TextFctExists(''::name, fctName, argLength)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_TextFctReturnType
--
--   schemaName name
--   fctName name
--   argLength int
--
--   RETURNS text
--
-- Returns the return type of a PostgreSQL function taking text arguments only.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TextFctReturnType(name, name, int);
CREATE OR REPLACE FUNCTION TT_TextFctReturnType(
  schemaName name,
  fctName name,
  argLength int
)
RETURNS text AS $$
  DECLARE
    result text;
    debug boolean = TT_Debug();
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_TextFctReturnType BEGIN';END IF;
    IF TT_TextFctExists(fctName, argLength) THEN
      fctName = TT_FullFunctionName(schemaName, fctName);
      IF fctName IS NULL THEN
        RETURN FALSE;
      END IF;
      IF debug THEN RAISE NOTICE 'TT_TextFctReturnType 11 fctName=%, argLength=%', fctName, argLength;END IF;

      SELECT pg_catalog.pg_get_function_result(oid)
      FROM pg_proc
      WHERE proname = fctName AND coalesce(cardinality(proargnames), 0) = argLength
      INTO result;

      IF debug THEN RAISE NOTICE 'TT_TextFctReturnType END result=%', result;END IF;
      RETURN result;
    ELSE
      IF debug THEN RAISE NOTICE 'TT_TextFctReturnType END NULL';END IF;
      RETURN NULL;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

--DROP FUNCTION IF EXISTS TT_TextFctReturnType(name, int);
CREATE OR REPLACE FUNCTION TT_TextFctReturnType(
  fctName name,
  argLength int
)
RETURNS text AS $$
  SELECT TT_TextFctReturnType(''::name, fctName, argLength)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ParseStringList
--
-- Parses list of strings into an array.
-- Can take a simple string, will convert it to a string array.
--
-- strip boolean - strips surrounding quotes from any strings. Used in helper functions when
-- parsing values.
--
-- e.g. TT_ParseStringList('col2, "string2", "", ""')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseStringList(text,boolean);
CREATE OR REPLACE FUNCTION TT_ParseStringList(
    argStr text DEFAULT NULL,
    strip boolean DEFAULT FALSE
)
RETURNS text[] AS $$
  DECLARE
    args text[];
    arg text;
    result text[] = '{}';
    i int;
  BEGIN
    IF argStr IS NULL THEN
      RETURN NULL;
    ENd IF;

    argStr = btrim(argStr);
    IF left(argStr, 1) = '{'  AND right(argStr, 1) = '}' THEN
      result = argStr::text[];
    ELSE
      result = ARRAY[argStr];
    END IF;
    IF strip THEN
      FOR i IN 1..cardinality(result) LOOP
        result[i] = btrim(btrim(result[i],'"'),'''');
      END LOOP;
    ELSE
      -- Remove double quotes anyway
      FOR i IN 1..cardinality(result) LOOP
        result[i] = btrim(result[i],'"');
      END LOOP;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_RepackStringList
--
-- Convert a text array into a text array string (that can be reparsed by
-- TT_ParseStringList).
--
-- When the array is composed of only one string, return as text (not as text
-- array string )
-------------------------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_RepackStringList(text[]);
CREATE OR REPLACE FUNCTION TT_RepackStringList(
    args text[] DEFAULT NULL
)
RETURNS text AS $$
  DECLARE
    arg text;
    result text = '';
    debug boolean = TT_Debug();
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_RepackStringList 00 cardinality=%', cardinality(args);END IF;
    IF args IS NULL THEN
      RETURN NULL;
    END IF;
    -- open the array string only when a true array or when only item is NULL
    IF cardinality(args) > 1 OR (cardinality(args) = 1 AND args[1] IS NULL) THEN
      result = '{';
    END IF;

    FOREACH arg in ARRAY args LOOP
      IF debug THEN RAISE NOTICE 'TT_RepackStringList 11 arg=%', arg;END IF;
      IF arg IS NULL THEN
        result = result || 'NULL' || ',';
      ELSE
        IF debug THEN RAISE NOTICE 'TT_RepackStringList 22 result=%', result;END IF;
        IF cardinality(args) > 1 THEN
          IF debug THEN RAISE NOTICE 'TT_RepackStringList 33';END IF;
          result = result || '"' || TT_EscapeDoubleQuotesAndBackslash(arg) || '",';
        ELSE
          IF debug THEN RAISE NOTICE 'TT_RepackStringList 44';END IF;
          result = result || arg || ',';
        END IF;
      END IF;
    END LOOP;
    -- remove the last comma and space, and close the array
    result = left(result, char_length(result) - 1);

    -- close the array string only when a true array or when only item is NULL
    IF cardinality(args) > 1 OR (cardinality(args) = 1 AND args[1] IS NULL) THEN
      result = result || '}';
    END IF;
    IF debug THEN RAISE NOTICE 'TT_RepackStringList 55 result=%', result;END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_TextFctEval_old
--
--  - fctName text          - Name of the function to evaluate. Will always be prefixed
--                            with "TT_".
--  - arg text[]            - Array of argument values to pass to the function.
--                            Generally includes one or two column names to get replaced
--                            with values from the vals argument.
--  - vals jsonb            - Replacement values passed as a jsonb object (since
--                            PostgresQL does not allow passing RECORDs to functions).
--  - returnType anyelement - Determines the type of the returned value
--                            (declared generically as anyelement).
--  - checkExistence        - Should the function check the existence of the helper
--                            function using TT_TextFctExists. TT_ValidateTTable also
--                            checks existence so setting this to FALSE can avoid
--                            repeating the check.
--
--    RETURNS anyelement
--
-- Evaluate a function given its name, some arguments and replacement values.
-- All arguments matching the name of a value found in the jsonb vals structure
-- are replaced with this value. returnType determines the return type of this
-- pseudo-type function.
--
-- Column values and strings are returned as text strings
-- String lists are returned as a comma separated list of single quoted strings
-- wrapped in {}. e.g. {'val1', 'val2'}
--
-- This version passes all vals as type text when running helper functions.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_TextFctEval(text, text[], jsonb, anyelement, boolean);
CREATE OR REPLACE FUNCTION TT_TextFctEval(
  fctName text,
  args text[],
  vals jsonb,
  returnType anyelement,
  checkExistence boolean DEFAULT TRUE
)
RETURNS anyelement AS $$
  DECLARE
    arg text;
    argCnt int;
    ruleQuery text;
    argNested text;
    argValNested text;
    repackArray text[];
    result ALIAS FOR $0;
    debug boolean = TT_Debug();
  BEGIN
    -- This function returns a polymorphic type (the one provided in the returnType input argument)
    IF debug THEN RAISE NOTICE 'TT_TextFctEval BEGIN fctName=%, args=%, vals=%, returnType=%', fctName, args, vals, returnType;END IF;

    -- fctName should never be NULL
    IF fctName IS NULL OR (checkExistence AND (NOT TT_TextFctExists(fctName, coalesce(cardinality(args), 0)))) THEN
      IF debug THEN RAISE NOTICE 'TT_TextFctEval 11 fctName=%, args=%', fctName, cardinality(args);END IF;
      RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE : Helper function %(%) does not exist.', fctName, btrim(repeat('text,', cardinality(args)),',');
    END IF;

    ruleQuery = 'SELECT tt_' || fctName || '(';
    argCnt = 0;
    FOREACH arg IN ARRAY coalesce(args, ARRAY[]::text[]) LOOP
      repackArray = ARRAY[]::text[];
      IF debug THEN RAISE NOTICE 'TT_TextFctEval 22 cardinality(repackArray)=%', cardinality(repackArray);END IF;
      -- add a comma if it's not the first argument
      IF argCnt != 0 THEN
        ruleQuery = ruleQuery || ', ';
      END IF;
      FOREACH argNested IN ARRAY TT_ParseStringList(arg) LOOP
        IF TT_IsName(argNested) AND vals ? argNested THEN
          argValNested = vals->>argNested;
          repackArray = array_append(repackArray, argValNested);
        ELSE
          -- if column name not in source table, return as string.
          -- we can now remove the surrounding single quotes from the string
          -- since we have processed column names
          repackArray = array_append(repackArray, TT_UnSingleQuote(argNested));
        END IF;
      END LOOP;
      ruleQuery = ruleQuery || '''' || TT_EscapeSingleQuotes(TT_RepackStringList(repackArray)) || '''::text';
      IF debug THEN RAISE NOTICE 'TT_TextFctEval 33 ruleQuery=%', ruleQuery;END IF;
      argCnt = argCnt + 1;
    END LOOP;
    ruleQuery = ruleQuery || ')::' || pg_typeof(result);
    IF debug THEN RAISE NOTICE 'TT_TextFctEval 55 ruleQuery=%', ruleQuery;END IF;
    EXECUTE ruleQuery INTO STRICT result;
    IF debug THEN RAISE NOTICE 'TT_TextFctEval END result=%', result;END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ParseArgs
--
-- Parses arguments from translation table into three classes:
-- LISTS - wrapped in {}, to be processed by TT_ParseStringList()
      -- TT_ParseStringList returns a text array of parsed strings and column names
      -- which are re-wrapped in {} and passed to the output array.
-- STRINGS - wrapped in '' or "" or empty strings. Passed directly to the output array.
-- COLUMN NAMES - words containing - or _ but no spaces. Validated and passed to the
-- output array. Error raised if invalid.
--
-- e.g. TT_ParseArgs('column_A, ''string 1'', {col2, "string2", "", ""}')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseArgs(text);
CREATE OR REPLACE FUNCTION TT_ParseArgs(
    argStr text DEFAULT NULL
)
RETURNS text[] AS $$
  -- Matches:
    -- [^\s,][-_\w\s]* - any word including '-' or '_' or a space, removes any preceding spaces or commas
    -- ''[^''\\]*(?:\\''[^''\\]*)*''
      -- '' - single quotes surrounding...
      -- [^''\\]* - anything thats not \ or ' followed by...
      -- (?:\\''[^''\\]*)* - zero or more sequences of...
        -- \\'' - a backslash escaped '
        -- [^''\\]* - anything thats not \ or '
      -- ?:\\'' - makes a non-capturing match. The match for \' is not reported.
    -- "[^"]+" - double quotes surrounding anything except double quotes. No need to escape single quotes here.
    -- {[^}]+} - anything inside curly brackets. [^}] makes it not greedy so it will match multiple lists
    -- ""|'''' - empty strings
  SELECT array_agg(str)
  FROM (SELECT (regexp_matches(argStr, '([^\s,][-_\w\s]*|''[^''\\]*(?:\\''[^''\\]*)*''|"[^"]+"|{[^}]+}|""|'''')', 'g'))[1] str) foo
$$ LANGUAGE sql STRICT VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ParseRules
--
--  ruleStr text - Rule string to parse into its different components.
--
--  RETURNS TT_RuleDef[]
--
-- Parse a rule string into function name, arguments, error code and
-- stopOnInvalid flag.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseRules(text);
CREATE OR REPLACE FUNCTION TT_ParseRules(
    ruleStr text DEFAULT NULL
)
RETURNS TT_RuleDef[] AS $$
  DECLARE
    rules text[];
    ruleDef TT_RuleDef;
    ruleDefs TT_RuleDef[];
  BEGIN
    -- Split the ruleStr into each separate rule: function name, list of arguments, error code and stopOnInvalid flag
    FOR rules IN SELECT regexp_matches(ruleStr, '(\w+)' ||       -- fonction name
                                                '\s*' ||         -- any space
                                                '\(' ||          -- first parenthesis
                                                '([^;|]*)' ||    -- a list of arguments
                                                '\|?\s*' ||      -- a vertical bar followed by any spaces
                                                '([^;,|]+)?' ||  -- the error code
                                                ',?\s*' ||       -- a comma followed by any spaces
                                                '(TRUE|FALSE)?\)'-- TRUE or FALSE
                                                , 'g') LOOP
      ruleDef.fctName = rules[1];
      ruleDef.args = TT_ParseArgs(rules[2]);
      ruleDef.errorcode = rules[3];
      ruleDef.stopOnInvalid = coalesce(rules[4]::boolean, FALSE);
      ruleDefs = array_append(ruleDefs, ruleDef);
    END LOOP;
    RETURN ruleDefs;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ValidateTTable
--
--   translationTableSchema name - Name of the schema containing the translation
--                                 table.
--   translationTable name       - Name of the translation table.
--   checkExistence              - boolean flag indicating whether validation
--                                 and translation function existence should
--                                 be checked.
--
--   RETURNS boolean             - TRUE if the translation table is valid.
--
-- Parse and validate the translation table. It must fullfil a number of conditions:
--
--   - each of those attribute names should be shorter than 64 charaters and
--     contain no spaces,
--
--   - helper function names should match existing functions and their parameters
--     should be in the right format,
--
--   - there should be no null or empty values in the translation table,
--
--   - the return type of translation rules and the type of the error code should
--     both match the attribute type,
--
--   - targetAttribute name should be valid with no special characters
--
--  Return an error and stop the process if any invalid value is found in the
--  translation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name, boolean);
CREATE OR REPLACE FUNCTION TT_ValidateTTable(
  translationTableSchema name DEFAULT NULL,
  translationTable name DEFAULT NULL,
  checkExistence boolean DEFAULT TRUE
)
RETURNS TABLE (targetAttribute text, targetAttributeType text, validationRules TT_RuleDef[], translationRule TT_RuleDef, description text, descUpToDateWithRules boolean) AS $$
  DECLARE
    row RECORD;
    query text;
    debug boolean = TT_Debug();
    rule TT_RuleDef;
    error_msg_start text = 'ERROR IN TRANSLATION TABLE AT RULE_ID #';
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable BEGIN';END IF;
    IF translationTable IS NULL THEN
      translationTable = translationTableSchema;
      translationTableSchema = 'public';
    END IF;
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 11';END IF;
    IF translationTable IS NULL or translationTable = '' THEN
      RETURN;
    END IF;
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 22';END IF;

    -- loop through each row in the translation table
    query = 'SELECT rule_id::text, targetAttribute::text, targetAttributeType::text, validationRules::text, translationRules::text, description::text, descUpToDateWithRules::text FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ' ORDER BY to_number(rule_id::text, ''999999'');';
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 33 query=%', query;END IF;
    FOR row IN EXECUTE query LOOP

      -- validate attributes and assign values

      -- rule_id should be integer, not null, not empty string
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 44, row=%', row::text;END IF;
      IF NOT TT_NotEmpty(row.rule_id) THEN
        RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE: At least one rule_id is NULL or empty.';
      END IF;
      IF NOT TT_IsInt(row.rule_id) THEN
        RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE: rule_id (%) is not an integer.', row.rule_id;
      END IF;

      -- targetAttribute should not be null or empty string, should be word with underscore allowed but no special characters
      IF NOT TT_NotEmpty(row.targetAttribute) THEN
        RAISE EXCEPTION '% % : Target attribute is NULL or empty.', error_msg_start, row.rule_id;
      END IF;
      IF NOT row.targetAttribute ~ '^(\d|\w)+$' THEN
        RAISE EXCEPTION '% % : Target attribute name (%) is invalid.', error_msg_start, row.rule_id, row.targetAttribute;
      END IF;
      targetAttribute = row.targetAttribute;

      -- targetAttributeType should not be null or empty
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 55';END IF;
      IF NOT TT_NotEmpty(row.targetAttributeType) THEN
        RAISE EXCEPTION '% % (%) : Target attribute type is NULL or empty.', error_msg_start, row.rule_id, targetAttribute;
      END IF;
      targetAttributeType = row.targetAttributeType;

      -- validationRules should not be null or empty
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 66';END IF;
      IF NOT TT_NotEmpty(row.validationRules) THEN
        RAISE EXCEPTION '% % (%) : Validation rules is NULL or empty.', error_msg_start, row.rule_id, targetAttribute;
      END IF;
      validationRules = (TT_ParseRules(row.validationRules))::TT_RuleDef[];

      -- translationRules should not be null or empty
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 77';END IF;
      IF NOT TT_NotEmpty(row.translationRules) THEN
        RAISE EXCEPTION '% % (%) : Translation rule is NULL or empty.', error_msg_start, row.rule_id, targetAttribute;
      END IF;
      translationRule = ((TT_ParseRules(row.translationRules))[1])::TT_RuleDef;

      -- description should not be null or empty
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 88';END IF;
      IF NOT TT_NotEmpty(row.description) THEN
        RAISE EXCEPTION '% % (%) : Description is NULL or empty.', error_msg_start, row.rule_id, targetAttribute;
      END IF;
      description = coalesce(row.description, '');

      -- descUpToDateWithRules should not be null or empty
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 99';END IF;
      IF NOT TT_NotEmpty(row.descUpToDateWithRules) THEN
        RAISE EXCEPTION '% % (%) : DescUpToDateWithRules is NULL or empty.', error_msg_start, row.rule_id, targetAttribute;
      END IF;
      descUpToDateWithRules = (row.descUpToDateWithRules)::boolean;

      IF debug THEN RAISE NOTICE 'TT_ValidateTTable AA';END IF;
      -- check validation functions exist, error code is not null, and error code can be cast to target attribute type
      FOREACH rule IN ARRAY validationRules LOOP

        -- check function exists
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable BB function name: %, arguments: %', rule.fctName, rule.args;END IF;
        IF checkExistence AND NOT TT_TextFctExists(rule.fctName, coalesce(cardinality(rule.args), 0)) THEN
          RAISE EXCEPTION '% % (%) : Validation helper function %(%) does not exist.', error_msg_start, row.rule_id, targetAttribute, rule.fctName, btrim(repeat('text,', coalesce(cardinality(rule.args), 0)), ',');
        END IF;

        -- check error code is not null
        IF NOT TT_NotEmpty(rule.errorcode) THEN
          RAISE EXCEPTION '% % (%) : Error code is NULL or empty for validation rule %().', error_msg_start, row.rule_id, row.targetAttribute, rule.fctName;
        END IF;

        -- check error code can be cast to attribute type, catch error with EXCEPTION
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable CC target attribute type: %, error value: %', targetAttributeType, rule.errorcode;END IF;
        IF NOT TT_IsCastableTo(rule.errorcode, targetAttributeType) THEN
          RAISE EXCEPTION '% % (%) : Error code (%) cannot be cast to the target attribute type (%) for validation rule %().', error_msg_start, row.rule_id, row.targetAttribute, rule.errorcode, targetAttributeType, rule.fctName;
        END IF;
      END LOOP;

      -- check translation function exists
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable EE function name: %, arguments: %', translationRule.fctName, translationRule.args;END IF;
      IF checkExistence AND NOT TT_TextFctExists(translationRule.fctName, coalesce(cardinality(translationRule.args), 0)) THEN
        RAISE EXCEPTION '% % (%) : Translation helper function %(%) does not exist.', error_msg_start, row.rule_id, targetAttribute, translationRule.fctName, btrim(repeat('text,', coalesce(cardinality(translationRule.args), 0)), ',');
      END IF;

      -- check translation rule return type matches target attribute type
      IF NOT TT_TextFctReturnType(translationRule.fctName, coalesce(cardinality(translationRule.args), 0)) = targetAttributeType THEN
        RAISE EXCEPTION '% % (%) : Translation rule return type (%) does not match translation helper function return type (%).', error_msg_start, row.rule_id, targetAttribute, targetAttributeType, TT_TextFctReturnType(translationRule.fctName, coalesce(cardinality(translationRule.args), 0));
      END IF;

      -- If not null, check translation error code can be cast to attribute type
      IF translationRule.errorcode IS NOT NULL AND NOT TT_IsCastableTo(translationRule.errorcode, targetAttributeType) THEN
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable FF target attribute type: %, error value: %', targetAttributeType, translationRule.errorcode;END IF;
        RAISE EXCEPTION '% % (%) : Error code (%) cannot be cast to the target attribute type (%) for translation rule %().', error_msg_start, row.rule_id, targetAttribute, translationRule.errorcode, targetAttributeType, translationRule.fctName;
      END IF;

      RETURN NEXT;
    END LOOP;
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable END';END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Prepare
--
--   translationTableSchema name - Name of the schema containing the translation
--                                 table.
--   translationTable name       - Name of the translation table.
--   fctName name                - Name of the function to create. Default to
--                                 'TT_Translate'.
--
--   RETURNS text                - Name of the function created.
--
-- Create the base translation function to execute when tranlating. This
-- function exists in order to palliate the fact that PostgreSQL does not allow
-- creating functions able to return SETOF rows of arbitrary variable types.
-- The function created by this function "freeze" and declare the return type
-- of the actual translation funtion enabling the package to return rows of
-- arbitrary typed rows.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare(name, name, text, name, name);
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text,
  refTranslationTableSchema name,
  refTranslationTable name
)
RETURNS text AS $f$
  DECLARE
    query text;
    paramlist text[];
    refParamlist text[];
    i integer;
  BEGIN
    IF NOT TT_NotEmpty(translationTable) THEN
      RETURN NULL;
    END IF;

    -- Validate the translation table
    PERFORM TT_ValidateTTable(translationTableSchema, translationTable);

    -- Build the list of attribute names and types for the target table
    query = 'SELECT array_agg(targetAttribute || '' '' || targetAttributeType ORDER BY rule_id::int) FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ';';
    EXECUTE query INTO STRICT paramlist;

    IF TT_NotEmpty(refTranslationTableSchema) AND TT_NotEmpty(refTranslationTable) THEN
      -- Build the list of attribute names and types for the reference table
      query = 'SELECT array_agg(targetAttribute || '' '' || targetAttributeType ORDER BY rule_id::int) FROM ' || TT_FullTableName(refTranslationTableSchema, refTranslationTable) || ';';
      EXECUTE query INTO STRICT refParamlist;

      IF cardinality(paramlist) < cardinality(refParamlist) THEN
        RAISE EXCEPTION 'ERROR in TT_Prepare() when processing %.%: ''%'' has less attributes than reference table ''%''...', translationTableSchema, translationTable, translationTable, refTranslationTable;
      ELSIF cardinality(paramlist) > cardinality(refParamlist) THEN
        RAISE EXCEPTION 'ERROR in TT_Prepare() when processing %.%: ''%'' has more attributes than reference table ''%''...', translationTableSchema, translationTable, translationTable, refTranslationTable;
      ELSIF TT_LowerArr(paramlist) != TT_LowerArr(refParamlist) THEN
        FOR i IN 1..cardinality(paramlist) LOOP
          IF paramlist[i] != refParamlist[i] THEN
            RAISE EXCEPTION 'ERROR in TT_Prepare() when processing %.%: ''%'' attributes ''%'' is different from ''%'' in reference table ''%''...', translationTableSchema, translationTable, translationTable, paramlist[i], refParamlist[i], refTranslationTable;
          END IF;
        END LOOP;
      END IF;
    END IF;

    -- Drop any existing TT_Translate function with the same suffix
    query = 'DROP FUNCTION IF EXISTS TT_Translate' || coalesce(fctNameSuf, '') || '(name, name, boolean, boolean, int, boolean, boolean);';
    EXECUTE query;

    query = 'CREATE OR REPLACE FUNCTION TT_Translate' || coalesce(fctNameSuf, '') || '(
               sourceTableSchema name,
               sourceTable name,
               stopOnInvalidSource boolean DEFAULT FALSE,
               stopOnTranslationError boolean DEFAULT FALSE,
               logFrequency int DEFAULT 500,
               resume boolean DEFAULT FALSE,
               ignoreDescUpToDateWithRules boolean DEFAULT FALSE
             )
             RETURNS TABLE (' || array_to_string(paramlist, ', ') || ') AS $$
             BEGIN
               RETURN QUERY SELECT * FROM _TT_Translate(sourceTableSchema,
                                                        sourceTable, ' ||
                                                        '''' || translationTableSchema || ''', ' ||
                                                        '''' || translationTable || ''',
                                                        stopOnInvalidSource,
                                                        stopOnTranslationError,
                                                        logFrequency,
                                                        resume,
                                                        ignoreDescUpToDateWithRules) AS t(' || array_to_string(paramlist, ', ') || ');
               RETURN;
             END;
             $$ LANGUAGE plpgsql VOLATILE;';
    EXECUTE query;
    RETURN 'TT_Translate' || coalesce(fctNameSuf, '');
  END;
$f$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text,
  refTranslationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare(translationTableSchema, translationTable, fctNameSuf, translationTableSchema, refTranslationTable);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text
)
RETURNS text AS $$
  SELECT TT_Prepare(translationTableSchema, translationTable, fctNameSuf, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTable name,
  fctNameSuf text
)
RETURNS text AS $$
  SELECT TT_Prepare('public', translationTable, fctNameSuf, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare('public', translationTable, NULL::text, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------------------------
-- _TT_Translate
--
--   sourceTableSchema name      - Name of the schema containing the source table.
--   sourceTable name            - Name of the source table.
--   translationTableSchema name - Name of the schema containing the translation
--                                 table.
--   translationTable name       - Name of the translation table.
--   stopOnInvalidSource         - Flag indicating if the engine should stop when
--                                 a source value is declared invalid
--   stopOnTranslationError      - Flag indicating if the engine should stop when
--                                 the translation rule result into a NULL value
--   logFrequency                - Number of line to report progress in the log file.
--   resume                      - Resume from last execution when set to TRUE.
--   ignoreDescUpToDateWithRules - Ignore the translation table flag indicating that
--                                 rules are not up to date with their descriptions.
--
--   RETURNS SETOF RECORDS
--
-- Translate a source table according to the rules defined in a tranlation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS _TT_Translate(name, name, name, name, boolean, boolean, int, boolean, boolean);
CREATE OR REPLACE FUNCTION _TT_Translate(
  sourceTableSchema name,
  sourceTable name,
  translationTableSchema name,
  translationTable name,
  stopOnInvalidSource boolean DEFAULT FALSE,
  stopOnTranslationError boolean DEFAULT FALSE,
  logFrequency int DEFAULT 500,
  resume boolean DEFAULT FALSE,
  ignoreDescUpToDateWithRules boolean DEFAULT FALSE
)
RETURNS SETOF RECORD AS $$
  DECLARE
    sourceRow RECORD;
    translationRow RECORD;
    translatedRow RECORD;
    rule TT_RuleDef;
    query text;
    finalQuery text;
    finalVal text;
    isValid boolean;
    jsonbRow jsonb;
    rownb int = 1;
    debug boolean = TT_Debug();
    _checkExistence boolean;
  BEGIN
    -- Validate the existence of the source table. TODO
    -- Determine if we must resume from last execution or not. TODO
    -- Create the log table. TODO
    -- FOR each row of the source table
    IF debug THEN RAISE NOTICE '_TT_Translate BEGIN';END IF;
    -- Set variable so TT_ValidateTTable only checks for functions on the first row
    _checkExistence = TRUE;
    FOR sourceRow IN EXECUTE 'SELECT * FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) LOOP
       -- Convert the row to a json object so we can pass it to TT_TextFctEval() (PostgreSQL does not allow passing RECORD to functions)
       jsonbRow = to_jsonb(sourceRow);
       IF debug THEN RAISE NOTICE '_TT_Translate 11 sourceRow=%', jsonbRow;END IF;

       finalQuery = 'SELECT';
       -- Iterate over each translation table row. One row per output attribute
       FOR translationRow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable, _checkExistence) LOOP
         IF debug THEN RAISE NOTICE '_TT_Translate 22 translationRow=%', translationRow;END IF;
         -- Iterate over each validation rule
         isValid = TRUE;
         FOREACH rule IN ARRAY translationRow.validationRules LOOP
           IF isValid THEN
             IF debug THEN RAISE NOTICE '_TT_Translate 33 rule=%', rule;END IF;
             -- Evaluate the rule and catch errors
             BEGIN
               isValid = TT_TextFctEval(rule.fctName, rule.args, jsonbRow, NULL::boolean, FALSE);
             EXCEPTION WHEN OTHERS THEN
               RAISE NOTICE '%', SQLERRM;
               RAISE EXCEPTION 'STOP ON INVALID RULE PARAMETER: Invalid parameter value passed to %() at row #% while validating source values for target attribute ''%''. Revise your translation table...', rule.fctName, rownb, translationRow.targetAttribute;
             END;
             IF debug THEN RAISE NOTICE '_TT_Translate 44 isValid=%', isValid;END IF;
             -- initialize the final value
             finalVal = rule.errorCode;
             --IF debug THEN RAISE NOTICE '_TT_Translate 55 rule is % %', CASE WHEN isValid THEN 'VALID' ELSE 'INVALID' END, rule;
             -- Stop now if invalid and stopOnInvalid is set to true for this validation rule
             IF NOT isValid AND (rule.stopOnInvalid OR stopOnInvalidSource)THEN
               RAISE EXCEPTION 'STOP ON INVALID SOURCE VALUE: Invalid source value passed to %() at row #% while validating source values for target attribute ''%''...', rule.fctName, rownb, translationRow.targetAttribute;
             END IF;
           END IF;
         END LOOP; -- FOR EACH RULE
         -- If all validation rule passed, execute the translation rule
         IF isValid THEN
           query = 'SELECT TT_TextFctEval($1, $2, $3, NULL::' || translationRow.targetAttributeType || ', FALSE);';
           IF debug THEN RAISE NOTICE '_TT_Translate 77 query=%', query;END IF;
           BEGIN
             EXECUTE query
             USING (translationRow.translationRule).fctName, (translationRow.translationRule).args, jsonbRow
             INTO STRICT finalVal;
           EXCEPTION WHEN OTHERS THEN
             RAISE NOTICE '%', SQLERRM;
             RAISE EXCEPTION 'STOP ON INVALID TRANSLATION PARAMETER: Invalid parameter value passed to %() at row #% while translating target attribute ''%''. Revise your translation table...', (translationRow.translationRule).fctName, rownb, translationRow.targetAttribute;
           END;

           IF debug THEN RAISE NOTICE '_TT_Translate 88 finalVal=%', finalVal;END IF;

           IF finalVal IS NULL THEN
             IF stopOnTranslationError THEN
               RAISE EXCEPTION 'STOP ON TRANSLATION ERROR: Translation error in %() at row #% while translating target attribute ''%''...', (translationRow.translationRule).fctName, rownb, translationRow.targetAttribute;
             ELSE
               IF (translationRow.translationRule).errorCode IS NULL THEN -- if no error code provided, use the defaults
                 IF translationRow.targetAttributeType IN ('text', 'char', 'character', 'varchar', 'character varying') THEN
                   finalVal = 'TRANSLATION_ERROR';
                 ELSE
                   finalVal = -3333;
                 END IF;
               ELSE -- if translation error code provided, return it
                 finalVal = (translationRow.translationRule).errorCode;
               END IF;
             END IF;
           END IF;
         END IF;
         -- Built the return query while computing values
         finalQuery = finalQuery || ' ''' || finalVal || '''::'  || translationRow.targetAttributeType || ',';
         IF debug THEN RAISE NOTICE '_TT_Translate AA finalVal=%, translationRow.targetAttributeType=%, finalQuery=%', finalVal, translationRow.targetAttributeType, finalQuery;END IF;
       END LOOP; -- FOR TRANSLATION ROW

       -- Execute the final query building the returned RECORD
       finalQuery = left(finalQuery, char_length(finalQuery) - 1);
       IF debug THEN RAISE NOTICE '_TT_Translate BB finalQuery=%', finalQuery;END IF;
       EXECUTE finalQuery INTO translatedRow;
       RETURN NEXT translatedRow;

       _checkExistence = FALSE; --only check existence of helper function on first source row
       rownb = rownb + 1;
    END LOOP; -- FOR sourceRow
    IF debug THEN RAISE NOTICE '_TT_Translate END';END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;