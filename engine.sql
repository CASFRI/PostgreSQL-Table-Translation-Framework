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
--   schemaName name - Name of the schema.
--   tableName name  - Name of the table.
--
--   RETURNS booelan  - True if tt_debug is set to true. False if set to false or not set.
--
-- Wrapper to catch error when tt.error is not set.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Debug();
CREATE OR REPLACE FUNCTION TT_Debug(
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    RETURN current_setting('tt.debug');
    EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
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
-- TT_TextFctExist
--
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
    fctName = 'tt_' || lower(fctName);
    schemaName = lower(schemaName);
    IF schemaName = 'public' OR schemaName IS NULL THEN
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
    IF debug THEN RAISE NOTICE 'TT_TextFctExists 11 fctName=%, argLength=%', fctName, argLength;END IF;
    SELECT count(*)
    FROM pg_proc
    WHERE proname = fctName AND coalesce(cardinality(proargnames),0) = argLength
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
      fctName = 'tt_' || lower(fctName);
      schemaName = lower(schemaName);
      IF schemaName = 'public' OR schemaName IS NULL THEN
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
      IF debug THEN RAISE NOTICE 'TT_TextFctReturnType 11 fctName=%, argLength=%', fctName, argLength;END IF;

      SELECT pg_catalog.pg_get_function_result(oid)
      FROM pg_proc
      WHERE proname = fctName AND coalesce(cardinality(proargnames),0) = argLength
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
-- TT_TextFctEval
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
    argVal text;
    ruleQuery text;
    argsNested text[];
    argNested text;
    argValNested text;
    ruleQueryNested text;
    result ALIAS FOR $0;
    debug boolean = TT_Debug();
  BEGIN
    -- This function returns a polymorphic type, the type returned in result
    -- will be whatever type is provided in the returnType input argument.
  
    IF debug THEN RAISE NOTICE 'TT_TextFctEval BEGIN fctName=%, args=%, vals=%, returnType=%', fctName, args, vals, returnType;END IF;

    IF checkExistence = TRUE THEN    
      -- if function has no args, pass 0 to TT_TextFctExists using coalesce.
      IF fctName IS NULL OR NOT TT_TextFctExists(fctName, coalesce(cardinality(args),0)) OR vals IS NULL THEN
        IF debug THEN RAISE NOTICE 'TT_TextFctEval 11 fctName=%, args=%', fctName, cardinality(args);END IF;
        RAISE EXCEPTION 'TT_TextFctEval FUNCTION %(%) DOES NOT EXIST', fctName, left(repeat('text,',coalesce(cardinality(args),0)), char_length(repeat('text,',coalesce(cardinality(args),0)))-1);
      END IF;
    END IF;
     
    ruleQuery = 'SELECT TT_' || fctName || '(';
    IF NOT args IS NULL THEN
      -- Search for any argument names in the provided value jsonb object
      FOREACH arg IN ARRAY args LOOP
        IF debug THEN RAISE NOTICE 'arg=%', arg;END IF;

        ------ process comma separated strings ------
	-- Unpack the string, get the string or column value, re-pack into comma separated string 
	-- for use by the helper function. Only runs if comma detected in arg.
	IF char_length(arg) - char_length(replace(arg,',','')) > 0 THEN
	  -- split string to array by comma's after removing spaces
	  argsNested = string_to_array(replace(arg, ' ', ''), ',');
	  IF debug THEN RAISE NOTICE 'argsNested=%', argsNested;END IF;
	  -- loop through array, get values, add to new string (ruleQueryNested)
	  ruleQueryNested = '''';
	  FOREACH argNested in ARRAY argsNested LOOP
	    IF debug THEN RAISE NOTICE 'argNested=%', argNested;END IF;
	    -- if arg has {} and is in vals, return column value.
	    -- note: substring call gets colname from between {}
	    IF argNested LIKE '{%}' THEN
	      IF vals ? substring(argNested from '\{(.+)\}') THEN 
                argValNested = vals->>substring(argNested from '\{(.+)\}');
	        IF debug THEN RAISE NOTICE 'TT_TextFctEval 33 argValNested=%', argValNested;END IF;
	        IF argValNested IS NULL THEN
		  ruleQueryNested = ruleQueryNested || 'NULL' || ',';
	        ELSE
		  ruleQueryNested = ruleQueryNested || argValNested || ',';
                END IF;
              ELSE
                -- if arg has {} and is not in vals, return string including {}.
                ruleQueryNested = ruleQueryNested || argNested || ',';
              END IF;
            ELSE
	      IF debug THEN RAISE NOTICE 'TT_TextFctEval 22';END IF;
	      ruleQueryNested = ruleQueryNested || argNested || ',';
	    END IF;
	  END LOOP;
	  -- remove the last comma and space, and cast string to text
	  ruleQuery = ruleQuery || left(ruleQueryNested, char_length(ruleQueryNested) - 1) || '''::text, ';

	------ process strings ------
	ELSIF arg NOT LIKE '{%}' THEN --if argument doesn' have commas and is not surrounded by {}, process it as a string
	  IF debug THEN RAISE NOTICE 'TT_TextFctEval 22';END IF;
	  ruleQuery = ruleQuery || '''' || arg || '''::text, ';
	  
        ------ process column names ------
        ELSIF arg LIKE '{%}' THEN -- if arg surrounded by {}... 
          IF vals ? substring(arg from '\{(.+)\}') THEN -- ...and colname in vals
            argVal = vals->>substring(arg from '\{(.+)\}'); 
            IF debug THEN RAISE NOTICE 'TT_TextFctEval 33 argVal=%', argVal;END IF;
            IF argVal IS NULL THEN
              ruleQuery = ruleQuery || 'NULL::text' || ', ';
            ELSE
              ruleQuery = ruleQuery || '''' || argVal || '''::text, ';
            END IF;
          ELSE
            -- if column name requested with {} but colname not in vals, return string including {}.
            ruleQuery = ruleQuery || '''' || arg || '''::text, ';
          END IF;
          IF debug THEN RAISE NOTICE 'TT_TextFctEval 44 ruleQuery=%', ruleQuery;END IF;
        END IF;
      END LOOP;
      
      -- Remove the last comma.
      ruleQuery = left(ruleQuery, char_length(ruleQuery) - 2);
    END IF;
    ruleQuery = ruleQuery || ')::' || pg_typeof(result);
    IF debug THEN RAISE NOTICE 'TT_TextFctEval 55 ruleQuery=%', ruleQuery;END IF;
    EXECUTE ruleQuery INTO STRICT result;
    IF debug THEN RAISE NOTICE 'TT_TextFctEval END result=%', result;END IF;
    RETURN result;
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
-- TT_ParseArgs
--
--  argStr text - Rule string to parse into it different components.
--
--  RETURNS text[]
--
-- Parse an argument string into its separate components. A normal argument 
-- string has arguments separated with commas: 'aa, bb, 99'
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseArgs(text);
CREATE OR REPLACE FUNCTION TT_ParseArgs(
    argStr text DEFAULT NULL
)
RETURNS text[] AS $$
  DECLARE
    result text[] = '{}';
  BEGIN
     SELECT array_agg(btrim(btrim(a[1], '"'), ''''))
     -- Match any double quoted string, double quoted string containing {}, single word, or single word surrounded by {}.
     FROM (SELECT regexp_matches(argStr, '(''[-;",\.\w\s]*''|''[-{};",\.\w\s]*''|"[-;'',\.\w\s]*"|"[-{};'',\.\w\s]*"|{[-\.''"\w]+}|[-\.''"\w]+)', 'g') a) foo
     INTO STRICT result;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
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
--   targetAttributeList text[]  - List of attribute definition to be found in 
--                                 the table.
--
--   RETURNS boolean             - TRUE if the translation table is valid.
--
-- Parse and validate the translation table. It must fullfil a number of conditions:
--
--   - the list of target attribute should match the targetAttributeList parameter,
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
--  Return an error and stop the process if any invalid value is found in the
--  translation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name);
CREATE OR REPLACE FUNCTION TT_ValidateTTable(
  translationTableSchema name DEFAULT NULL,
  translationTable name DEFAULT NULL
)
RETURNS TABLE (targetAttribute text, targetAttributeType text, validationRules TT_RuleDef[], translationRule TT_RuleDef, description text, descUpToDateWithRules boolean) AS $$
  DECLARE
    row RECORD;
    query text;
    debug boolean = TT_Debug();
    rule TT_RuleDef;
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
    query = 'SELECT rule_id::int, targetAttribute::text, targetAttributeType::text, validationRules::text, translationRules::text, description::text, descUpToDateWithRules FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ' ORDER BY rule_id::int;';
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 33 query=%', query;END IF;
    FOR row IN EXECUTE query LOOP
    
      -- check attributes not null and assign variables
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 44, row=%', row;END IF;
      IF row.rule_id IS NULL THEN RAISE EXCEPTION 'TT_ValidateTTable rule_id is null';END IF;

      IF row.targetAttribute IS NULL OR row.targetAttribute = '' THEN RAISE EXCEPTION 'TT_ValidateTTable target attribute is null or empty';END IF;
      targetAttribute = row.targetAttribute;
      
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 55';END IF;
      IF row.targetAttributeType IS NULL OR row.targetAttributeType = '' THEN RAISE EXCEPTION 'TT_ValidateTTable target attribute type is null or empty';END IF;
      targetAttributeType = row.targetAttributeType;

      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 66';END IF;
      IF row.validationRules IS NULL OR row.validationRules = '' THEN RAISE EXCEPTION 'TT_ValidateTTable validation rules is null or empty';END IF;
      validationRules = (TT_ParseRules(row.validationRules))::TT_RuleDef[];

      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 77';END IF;
      IF row.translationRules IS NULL OR row.translationRules = '' THEN RAISE EXCEPTION 'TT_ValidateTTable translation rule is null or empty';END IF;
      translationRule = ((TT_ParseRules(row.translationRules))[1])::TT_RuleDef;

      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 88';END IF;
      IF row.description IS NULL OR row.description = '' THEN RAISE EXCEPTION 'TT_ValidateTTable description is null or empty';END IF;
      description = coalesce(row.description, '');

      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 99';END IF;
      IF row.descUpToDateWithRules IS NULL THEN RAISE EXCEPTION 'TT_ValidateTTable descUpToDateWithRules is null';END IF;
      descUpToDateWithRules = row.descUpToDateWithRules;
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable AA';END IF;

      -- Check validation functions exist, error code is not null, and error code can be cast to target attribute type
      FOREACH rule IN ARRAY validationRules LOOP
        -- check function exists
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 991 function name: %, arguments: %', rule.fctName, rule.args;END IF;
        IF rule.fctName IS NULL OR NOT TT_TextFctExists(rule.fctName, coalesce(cardinality(rule.args),0)) THEN
          RAISE EXCEPTION 'TT_ValidateTTable FUNCTION %(%) DOES NOT EXIST', rule.fctName, left(repeat('text,',coalesce(cardinality(rule.args),0)), char_length(repeat('text,',coalesce(cardinality(rule.args),0)))-1);
        END IF;
        -- check error code is not null
        IF rule.errorcode IS NULL THEN
          RAISE EXCEPTION 'TT_ValidateTTable: Error code is NULL';
        END IF;
        -- check error code can be cast to attribute type, catch error with EXCEPTION
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 992 target attribute type: %, error value: %', targetAttributeType, rule.errorcode;END IF;
        BEGIN
          query = 'SELECT ' || '''' || rule.errorcode || '''' || '::' || targetAttributeType || ';';
          IF debug THEN RAISE NOTICE 'TT_ValidateTTable 993 query = %', query;END IF;
          EXECUTE query;
        EXCEPTION WHEN OTHERS THEN
          RAISE EXCEPTION 'TT_ValidateTTable error code (%) cannot be cast to %', rule.errorcode, targetAttributeType;
        END;
      END LOOP;

      -- Check translation function exists
      IF debug THEN RAISE NOTICE 'TT_ValidateTTable 992 function name: %, arguments: %', translationRule.fctName, translationRule.args;END IF;
      IF translationRule.fctName IS NULL OR NOT TT_TextFctExists(translationRule.fctName, coalesce(cardinality(translationRule.args),0)) THEN
          RAISE EXCEPTION 'TT_ValidateTTable FUNCTION %(%) DOES NOT EXIST', translationRule.fctName, left(repeat('text,',coalesce(cardinality(translationRule.args),0)), char_length(repeat('text,',coalesce(cardinality(translationRule.args),0)))-1);
      END IF;

      -- Check translation rule return type matches target attribute type
      IF NOT TT_TextFctReturnType(translationRule.fctName, coalesce(cardinality(translationRule.args),0)) = targetAttributeType THEN
        RAISE EXCEPTION 'Translation table return type (%) does not match translation function return type (%)', targetAttributeType, TT_TextFctReturnType(translationRule.fctName, coalesce(cardinality(translationRule.args),0));
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
--DROP FUNCTION IF EXISTS TT_Prepare(name, name, name);
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name DEFAULT NULL,
  fctNameSuf name DEFAULT ''
)
RETURNS text AS $f$
  DECLARE 
    query text;
    paramlist text;
  BEGIN
    IF translationTable IS NULL THEN
      translationTable = translationTableSchema;
      translationTableSchema = 'public';
    END IF;
    IF translationTable IS NULL or translationTable = '' THEN
      RETURN NULL;
    END IF;
    -- Validate the translation table
    --PERFORM TT_ValidateTTable(translationTableSchema, translationTable);

    -- Drop any existing TT_Translate function
    query = 'DROP FUNCTION IF EXISTS TT_Translate' || fctNameSuf || '(name, name, name, name, text[], boolean, int, boolean, boolean);';
    EXECUTE query;

    -- Build the list of attribute types
    query = 'SELECT string_agg(targetAttribute || '' '' || targetAttributeType, '', '' ORDER BY rule_id::int) FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ';';
    EXECUTE query INTO STRICT paramlist;
      
    query = 'CREATE OR REPLACE FUNCTION TT_Translate' || fctNameSuf || '(
               sourceTableSchema name,
               sourceTable name,
               translationTableSchema name DEFAULT NULL,
               translationTable name DEFAULT NULL,
               targetAttributeList text[] DEFAULT NULL,
               stopOnInvalid boolean DEFAULT FALSE,
               logFrequency int DEFAULT 500,
               resume boolean DEFAULT FALSE,
               ignoreDescUpToDateWithRules boolean DEFAULT FALSE
             )
             RETURNS TABLE (' || paramlist || ') AS $$
             BEGIN
               RETURN QUERY SELECT * FROM _TT_Translate(sourceTableSchema, 
                                                        sourceTable, 
                                                        translationTableSchema, 
                                                        translationTable, 
                                                        targetAttributeList, 
                                                        stopOnInvalid, 
                                                        logFrequency, 
                                                        resume, 
                                                        ignoreDescUpToDateWithRules) AS t(' || paramlist || ');
               RETURN;
             END;
             $$ LANGUAGE plpgsql VOLATILE;';
    EXECUTE query;
    RETURN 'TT_Translate' || fctNameSuf;
  END;
$f$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------
-- TT_Translate
--
--   sourceTableSchema name      - Name of the schema containing the source table.
--   sourceTable name            - Name of the source table.
--   translationTableSchema name - Name of the schema containing the translation 
--                                 table.
--   translationTable name       - Name of the translation table.
--   targetAttributeList ARRAY   - List of target atribute expected in the
--                                 translation table.
--   stopOnInvalid               - Flag indicating if the engine should stop when
--                                 a source value is declared invalid
--   logFrequency                - Number of line to report progress in the log file.
--   resume                      - Resume from last execution when set to TRUE.
--   ignoreDescUpToDateWithRules - Ignore the translation table flag indicating that 
--                                 rules are not up to date with their descriptions.
--
--   RETURNS SETOF RECORDS
--
-- Translate a source table according to the rules defined in a tranlation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS _TT_Translate(name, name, name, name, text[], boolean, int, boolean, boolean);
CREATE OR REPLACE FUNCTION _TT_Translate(
  sourceTableSchema name,
  sourceTable name,
  translationTableSchema name DEFAULT NULL,
  translationTable name DEFAULT NULL,
  targetAttributeList text[] DEFAULT NULL,
  stopOnInvalid boolean DEFAULT FALSE,
  logFrequency int DEFAULT 500,
  resume boolean DEFAULT FALSE,
  ignoreDescUpToDateWithRules boolean DEFAULT FALSE
)
RETURNS SETOF RECORD AS $$
  DECLARE
    sourcerow RECORD;
    translationrow RECORD;
    translatedrow RECORD;
    rule TT_RuleDef;
    query text;
    finalQuery text;
    finalVal text;
    isValid boolean;
    jsonbRow jsonb;
    debug boolean = TT_Debug();
  BEGIN
    -- Validate the existence of the source table. TODO
    -- Determine if we must resume from last execution or not. TODO
    -- Create the log table. TODO
    -- FOR each row of the source table
    IF debug THEN RAISE NOTICE '_TT_Translate BEGIN';END IF;
    FOR sourcerow IN EXECUTE 'SELECT * FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) LOOP

       -- Convert the row to a json object so we can pass it to TT_TextFctEval() (PostgreSQL does not allow passing RECORD to functions)
       jsonbRow = to_jsonb(sourcerow);
       IF debug THEN RAISE NOTICE '_TT_Translate 11 sourcerow=%', jsonbRow;END IF;
       finalQuery = 'SELECT';
       -- Iterate over each translation table row. One row per output attribute
       FOR translationrow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable) LOOP
         IF debug THEN RAISE NOTICE '_TT_Translate 22 translationrow=%', translationrow;END IF;
         -- Iterate over each validation rule
         isValid = TRUE;
         FOREACH rule IN ARRAY translationrow.validationRules LOOP
           IF isValid THEN
             IF debug THEN RAISE NOTICE '_TT_Translate 33 rule=%', rule;END IF;
             -- Evaluate the rule
             isValid = TT_TextFctEval(rule.fctName, rule.args, jsonbRow, NULL::boolean, FALSE);
             IF debug THEN RAISE NOTICE '_TT_Translate 44 isValid=%', isValid;END IF;
             -- initialize the final value
             finalVal = rule.errorCode;
             IF debug AND isValid THEN 
               RAISE NOTICE '_TT_Translate 55 rule is VALID %', rule;
             ELSIF debug THEN
               RAISE NOTICE '_TT_Translate 66 rule is INVALID %', rule;
             END IF;
             -- Stop now if invalid and stopOnInvalid is set to true for this validation rule
             IF NOT isValid AND rule.stopOnInvalid THEN
                 RAISE EXCEPTION 'Invalid rule found...';
             END IF;
           END IF;
         END LOOP ;
         -- If all validation rule passed, execute the translation rule
         IF isValid THEN
           query = 'SELECT TT_TextFctEval($1, $2, $3, NULL::' || translationrow.targetAttributeType || ', FALSE);';
           IF debug THEN RAISE NOTICE '_TT_Translate 77 query=%', query;END IF;
           EXECUTE query
           USING (translationrow.translationRule).fctName, (translationrow.translationRule).args, jsonbRow INTO STRICT finalVal;
           IF debug THEN RAISE NOTICE '_TT_Translate 88 finalVal=%', finalVal;END IF;
         ELSE
           IF debug THEN RAISE NOTICE '_TT_Translate 99 INVALID';END IF;
         END IF;
         -- Built the return query while computing values
         finalQuery = finalQuery || ' ''' || finalVal || '''::'  || translationrow.targetAttributeType || ',';
         IF debug THEN RAISE NOTICE '_TT_Translate AA finalVal=%, translationrow.targetAttributeType=%, finalQuery=%', finalVal, finalQuery, translationrow.targetAttributeType;END IF;
       END LOOP;
       -- Execute the final query building the returned RECORD
       finalQuery = left(finalQuery, char_length(finalQuery) - 1);
       IF debug THEN RAISE NOTICE '_TT_Translate BB finalQuery=%', finalQuery;END IF;
       EXECUTE finalQuery INTO translatedrow;
       RETURN NEXT translatedrow;
    END LOOP;
    IF debug THEN RAISE NOTICE '_TT_Translate END';END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;