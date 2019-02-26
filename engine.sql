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
-- TT_LowerArr
--
--   arr text[]     - An array of text value.
--
--   RETURNS text[] - The input array lower cased.
--
-- Return the lower case version of a text array.
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
-- TT_TypeGuess
-- Guess the best type for a string. Used by TT_FctCallValid()
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TypeGuess(text);
CREATE OR REPLACE FUNCTION TT_TypeGuess(
  val text
)
RETURNS text AS $$
  DECLARE
  BEGIN
    IF val ~ '^-?\d+$' AND val::bigint >= -2147483648 AND val::bigint <= 2147483647 THEN
      RETURN 'integer';
    ELSIF val ~ '^-?\d+\.\d+$' THEN
      RETURN 'double precision';
    ELSIF lower(val) = 'false' OR lower(val) = 'true' THEN
      RETURN 'boolean';
    END IF;
    RETURN 'text';
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FctExist
--
--   fctString text
--   argTypes  text[]
--
--   RETURNS boolean
--
-- Returns TRUE if fctString exists as a function having the specified parameter 
-- types.
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
    debug boolean = current_setting('tt.debug');
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
    WHERE (schemaName = '') AND argTypes IS NULL AND proname = fctName OR 
          oid::regprocedure::text = fctName || '(' || array_to_string(TT_LowerArr(argTypes), ',') || ')'
    INTO cnt;
    IF debug THEN RAISE NOTICE 'TT_FctExists END';END IF;
    IF cnt > 0 THEN 
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_FctExists(
  fctName name,
  argTypes text[] DEFAULT NULL
)
RETURNS boolean AS $$
  SELECT TT_FctExists(''::name, fctName, argTypes)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FctReturnType
--
--   fctString text
--   argTypes  text[]
--
--   RETURNS text
--
-- Returns the return type of a PostgreSQL function.
------------------------------------------------------------
-- Self contained example:
-- 
-- SELECT TT_FctReturnType('TT_FctEval', {'text', 'text[]', 'jsonb', 'anyelement'})
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_FctReturnType(text, text, text[]);
CREATE OR REPLACE FUNCTION TT_FctReturnType(
  schemaName name,
  fctName name,
  argTypes text[] DEFAULT NULL
)
RETURNS text AS $$
  DECLARE
    result text;
  BEGIN
    IF TT_FctExists(schemaName, fctName, argTypes) THEN
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
 --RAISE NOTICE 'TT_FctReturnType fctName = %', fctName;
      SELECT pg_catalog.pg_get_function_result(oid) 
      FROM pg_proc 
      WHERE (schemaName = '') AND argTypes IS NULL AND proname = fctName OR 
          oid::regprocedure::text = fctName || '(' || array_to_string(TT_LowerArr(argTypes), ',') || ')'
      INTO result;
      RETURN result;
    ELSE
      RETURN NULL;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_FctReturnType(
  fctName name,
  argTypes text[] DEFAULT NULL
)
RETURNS text AS $$
  SELECT TT_FctReturnType(''::name, fctName, argTypes)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FctSignature
--
--  - arg text[]   - Array of arguments to pass to the function.
--  - vals josnb   - Replacement values passed as a jsonb object (since  
--                   PostgresQL does not allow passing RECORDs to functions).
--
--    RETURNS text[]
--
-- Determines the argument types of the provided function considering the .
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_FctSignature(text[], jsonb);
CREATE OR REPLACE FUNCTION TT_FctSignature(
  args text[],
  vals jsonb
)
RETURNS text[] AS $$
  DECLARE
    cond text;
    argVal text;
    arg text;
    result text[] = '{}';
  BEGIN
    -- There are two ways to determine the signature from the function name 
    -- and an imprecise array of values (some might be reference to column 
    -- names in the vals argument):
    --  1) We can compare only the precise arguments (which are not column 
    --     names) with the arguments of the function in the catalog. The 
    --     risk is that two functions exist with different first argument. 
    --     e.g. Can't find an example...
    --  2) Try to guess the types of the given column names. (we can't use 
    --     their own types since they could be esoteric types like float6 
    --     or varchar(18). We could map those type to simple types or we 
    --     can guess from the value.
    --     See http://www.postgresqltutorial.com/postgresql-data-types/
    
    --cond = 'tt_' || lower(fctName) || '(';
    -- Search for any argument names in the provided value jsonb object
    FOREACH arg IN ARRAY args LOOP
      argVal = vals->arg;
      IF argVal IS NULL THEN
        result = array_append(result, TT_TypeGuess(arg));
        --cond = cond || TT_TypeGuess(arg) || ', ';
      ELSE
        result = array_append(result, TT_TypeGuess(argVal));
        --cond = cond || TT_TypeGuess(argVal) || ', ';
      END IF;
    END LOOP;
    -- Remove the last comma.
    --cond = left(cond, char_length(cond) - 2) || ')';
--RAISE NOTICE 'result 11 %', result::text;

    --SELECT 'a'::text FROM pg_proc WHERE lower(oid::regprocedure::text) LIKE cond INTO arg;
    --EXECUTE ruleQuery INTO STRICT result;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FctEval
--
--  - fctName text - Name of the function to evaluate. Will always be prefixed 
--                   with "TT_".
--  - arg text[]   - Array of argument values to pass to the function. 
--                   Generally includes one or two column names to get replaced 
--                   with values from the vals argument.
--  - vals jsonb   - Replacement values passed as a jsonb object (since  
--                   PostgresQL does not allow passing RECORDs to functions).
--  - returnType anyelement - Determines the type of the returned value 
--                            (declared generically as anyelement).
--
--    RETURNS anyelement
--
-- Evaluate a function given its name, some arguments and replacement values. 
-- All arguments matching the name of a value found in the jsonb vals structure
-- are replaced with this value. returnType determines the return type of this 
-- pseudo-type function.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_FctEval(text, text[], jsonb, anyelement);
CREATE OR REPLACE FUNCTION TT_FctEval(
  fctName text,
  args text[],
  vals jsonb,
  returnType anyelement
)
RETURNS anyelement AS $$
  DECLARE
    ruleQuery text;
    argVal text;
    arg text;
    result ALIAS FOR $0;
    debug boolean = current_setting('tt.debug');
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_FctEval BEGIN';END IF;
    IF fctName IS NULL OR NOT TT_FctExists(fctName, TT_FctSignature(args, vals)) OR args IS NULL OR vals IS NULL THEN
      IF debug THEN RAISE NOTICE 'TT_FctEval 11 fctName=%, signature=%', fctName, TT_FctSignature(args, vals);END IF;
      RETURN NULL;
    END IF;
    ruleQuery = 'SELECT TT_' || fctName || '(';
    -- Search for any argument names in the provided value jsonb object
    FOREACH arg IN ARRAY args LOOP
      argVal = vals->arg;
      IF argVal IS NULL THEN
        IF TT_TypeGuess('''' || arg || '''') = 'text' THEN
          ruleQuery = ruleQuery || '''' || arg || ''', ';
        ELSE
          ruleQuery = ruleQuery || arg || ', ';
        END IF;
      ELSE
        IF TT_TypeGuess('''' || arg || '''') = 'text' THEN
          ruleQuery = ruleQuery || '''' || argVal || ''', ';
        ELSE
          ruleQuery = ruleQuery || argVal || ', ';
        END IF;
      END IF;
    END LOOP;
    -- Remove the last comma.
    ruleQuery = left(ruleQuery, char_length(ruleQuery) - 2) || ')::' || pg_typeof(result);
    IF debug THEN RAISE NOTICE 'TT_FctEval 22 ruleQuery=%', ruleQuery;END IF;
    EXECUTE ruleQuery INTO STRICT result;
    IF debug THEN RAISE NOTICE 'TT_FctEval END';END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_TableColumnNames
--
--   tableSchema name - Name of the schema containing the table.
--   table name       - Name of the table.
--
--   RETURNS text[]   - ARRAY of column names.
--
-- Return the column names for the speficied table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ColumnNames(name, name);
CREATE OR REPLACE FUNCTION TT_TableColumnNames(
  schemaName name,
  tableName name
)
RETURNS text[] AS $$
  DECLARE
    colNames text[];
  BEGIN
    SELECT array_agg(column_name::text)
    FROM information_schema.columns
    WHERE table_schema = schemaName AND table_name = tableName
    INTO STRICT colNames;
    
    RETURN colNames;
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
--  argStr text - Rule string to parse into it differetn components.
--
--  RETURNS text[]
--
-- Parse an argument string into its separate components. A normal argument 
-- string has arguments separated with commas: 'aa, bb, 99'
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseRules(text);
CREATE OR REPLACE FUNCTION TT_ParseArgs(
    argStr text DEFAULT NULL
)
RETURNS text[] AS $$
  DECLARE
    result text[] = '{}';
  BEGIN
     SELECT array_agg(btrim(btrim(a[1], '"'), ''''))
     -- Match any double quoted string or word
     FROM (SELECT regexp_matches(argStr, '(''[-;",\.\w\s]*''|"[-;'',\.\w\s]*"|[-\.''"\w]+)', 'g') a) foo
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
  BEGIN
    IF translationTable IS NULL THEN
      translationTable = translationTableSchema;
      translationTableSchema = 'public';
    END IF;
    IF translationTable IS NULL or translationTable = '' THEN
      RETURN;
    END IF;
    query = 'SELECT * FROM ' || TT_FullTableName(translationTableSchema, translationTable);
    FOR row IN EXECUTE query LOOP
      targetAttribute = row.targetAttribute;
      targetAttributeType = row.targetAttributeType;
      validationRules = TT_ParseRules(row.validationRules);
      translationRule = (TT_ParseRules(row.translationRules))[1];
      description = coalesce(row.description, '');
      descUpToDateWithRules = row.descUpToDateWithRules;
      RETURN NEXT;
    END LOOP;
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
    PERFORM TT_ValidateTTable(translationTableSchema, translationTable);

    -- Drop any existing TT_Translate function
    query = 'DROP FUNCTION IF EXISTS TT_Translate(name, name, name, name, text[], boolean, int, boolean, boolean);';
    EXECUTE query;

    -- Build the list of attribute types
    query = 'SELECT string_agg(targetAttribute || '' '' || targetAttributeType, '', '') FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ';';
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
                                                        ignoreDescUpToDateWithRules) AS t(id int, col2 int);
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
    debug boolean = current_setting('tt.debug');
  BEGIN
    -- Validate the existence of the source table. TODO
    -- Determine if we must resume from last execution or not. TODO
    -- Create the log table. TODO
    -- FOR each row of the source table
    IF debug THEN RAISE NOTICE '_TT_Translate BEGIN';END IF;
    FOR sourcerow IN EXECUTE 'SELECT * FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) LOOP
       -- Convert the row to a json object so we can pass it to TT_FctEval() (PostgreSQL does not allow passing RECORD to functions)
       jsonbRow = to_jsonb(sourcerow);
       IF debug THEN RAISE NOTICE '_TT_Translate 11 sourcerow=%', jsonbRow;END IF;
       finalQuery = 'SELECT';
       -- Iterate over each translation table row. One row per output attribute
       FOR translationrow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable) LOOP
         IF debug THEN RAISE NOTICE '_TT_Translate 22 translationrow=%', translationrow;END IF;
         -- Iterate over each invalid rule
         FOREACH rule IN ARRAY translationrow.validationRules LOOP
           IF debug THEN RAISE NOTICE '_TT_Translate 33 rule=%', rule;END IF;
           -- Evaluate the rule
           isValid = TT_FctEval(rule.fctName, rule.args, jsonbRow, NULL::boolean);
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
         END LOOP ;
         -- If all validation rule passed, execute the translation rule
         IF isValid THEN
           query = 'SELECT TT_FctEval($1, $2, $3, NULL::' || TT_FctReturnType($1, $2) || ');';
           IF debug THEN RAISE NOTICE '_TT_Translate 77 query=%', query;END IF;
           -- EXECUTE 'SELECT TT_FctEval($1, $2, $3, NULL::' || translationrow.targetAttributeType || ');' 
           EXECUTE query
           USING (translationrow.translationRule).fctName, (translationrow.translationRule).args, jsonbRow INTO STRICT finalVal;
           IF debug THEN RAISE NOTICE '_TT_Translate 88 finalVal=%', finalVal;END IF;
         ELSE
           IF debug THEN RAISE NOTICE '_TT_Translate 99 INVALID';END IF;
         END IF;
         -- Built the return query while computing values
         finalQuery = finalQuery || ' ''' || finalVal || '''::'  || translationrow.targetAttributeType || ',';
         IF debug THEN RAISE NOTICE '_TT_Translate AA finalQuery=%', finalQuery;END IF;
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