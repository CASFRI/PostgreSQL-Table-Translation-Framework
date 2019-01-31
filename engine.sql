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

-------------------------------------------------------------------------------
-- Function Definitions...
-------------------------------------------------------------------------------
-- TT_FullTableName
--
--   schemaName name - Name of the schema.
--   tableName name  - Name of the table.
--
-- RETURNS text      - Full name of the table.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_FullTableName(name, name);
CREATE OR REPLACE FUNCTION TT_FullTableName(
  schemaName name,
  tableName name
)
RETURNS text AS $$
  DECLARE newSchemaName text = '';
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
-- TT_ParseArgs
--
--  argStr text - Rule string to parse into it differetn components.
--
--  RETURNS text[]
--
-- Parse an argument string into its separate components.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseRules(text);
CREATE OR REPLACE FUNCTION TT_ParseArgs(
    argStr text
)
RETURNS text[] AS $$
  DECLARE
    result text[];
  BEGIN
     SELECT array_agg(a[1])
     -- Match any double quoted string or word
     FROM (SELECT regexp_matches(argStr, '("[-;,\w\s]+"|[-.\w]+)', 'g') a) foo
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
--  RETURNS TT_HelperFctDef[]
--
-- Parse a rule string into function name, arguments, error code and stop on 
-- invalid flag.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_ParseRules(text);
CREATE OR REPLACE FUNCTION TT_ParseRules(
    ruleStr text
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
                                                '([^;|]+)' ||    -- a list of arguments
                                                '\|?\s*' ||      -- a vertical bar followed by any spaces
                                                '([^;,|]+)?' ||  -- the error code
                                                ',?\s*' ||       -- a comma followed by any spaces
                                                '(TRUE|FALSE)?\)'-- TRUE or FALSE
                                                , 'g') LOOP
   
    --FOR rules IN SELECT regexp_matches(ruleStr, '(\w+)\s*\(([^;|]+)\|?\s*([^;,|]+)?,?\s*(TRUE|FALSE)?\)', 'g') LOOP
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
-- TT_Evaluate
--
--  - fctName    - Name of the founction to evaluate. Will always be prefixed 
--                 with "TT_"
--  - arg        - Array of arguments to passs to the function
--  - vals       - Replacement values passed as a jsonb object (since PostgresQL 
--                 does not allow passing RECORD to functions).
--  - returnType - Determine the type of the returned value (declared 
--                 generically as anyelement).
--
--  RETURNS anyelement
--
-- Evaluate a function given its name, some arguments and replacement values. 
-- returnType determines the return type.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 30/01/2019 added in v0.1
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_Evaluate(text, text[], jsonb, anyelement);
CREATE OR REPLACE FUNCTION TT_Evaluate(
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
  BEGIN
    ruleQuery = 'SELECT TT_' || fctName || '(';
    -- Search for any argument names in the provided value jsonb object
    FOREACH arg IN ARRAY args LOOP
      argVal = vals->arg;
      IF argVal IS NULL THEN
        ruleQuery = ruleQuery || arg || ', ';
      ELSE
        ruleQuery = ruleQuery || argVal || ', ';
      END IF;
    END LOOP;
    -- Remove the last comma.
    ruleQuery = left(ruleQuery, char_length(ruleQuery) - 2) || ')';

    EXECUTE ruleQuery INTO STRICT result;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_TypeGuess
-- Guess the best type for a string. Used by TT_FctCallValid()
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
-- Code
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FctExist
--
--   fctString text
--
-- RETURNS boolean
--
-- Return TRUE if fctString exists as a function having the specified parameter types
------------------------------------------------------------
--
-- Self contained example:
-- 
-- SELECT TT_FctExist('TT_TypeGuess(text)')
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
-- Code
-- See https://stackoverflow.com/questions/24773603/how-to-find-if-a-function-exists-in-postgresql
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_FctCallValid
-- Determine if a function having the specified parameter values. Use TT_TypeGuess
-- to determine the type and then TT_FctExist()
------------------------------------------------------------
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
-- Code
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ColumnNames
--
--   tableSchema name - Name of the schema containing the table.
--   table name       - Name of the table.
--
--   RETURNS text[]   - ARRAY of column names.
--
-- Return the column names for the speficied table.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ColumnNames(name, name);
CREATE OR REPLACE FUNCTION TT_ColumnNames(
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
-- TT_ParseTTable
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
--  Return an error and 
--  Stop the process if any invalid value is found in the
--  translation table.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name);
CREATE OR REPLACE FUNCTION TT_ValidateTTable(
  translationTableSchema name,
  translationTable name
)
RETURNS TABLE (targetAttribute text, targetAttributeType text, validationRules TT_RuleDef[], translationRule TT_RuleDef, description text, descUpToDateWithRules boolean) AS $$
  DECLARE
    row RECORD;
    query text;
  BEGIN
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
--   fctName name                - Name iof the function to create. Default to 
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
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare(name, name, name);
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name,
  fctName name DEFAULT 'TT_Translate'
)
RETURNS text AS $f$
  DECLARE 
    query text;
    paramlist text;
  BEGIN
    -- Validate the translation table
    PERFORM TT_ValidateTTable(translationTableSchema, translationTable);

    -- Drop any existing TT_Translate function
    query = 'DROP FUNCTION TT_Translate(name, name, name, name, text[], boolean, int, boolean, boolean);';
    EXECUTE query;

    -- Build the list of attribute types
    query = 'SELECT string_agg(targetAttribute || '' '' || targetAttributeType, '', '') FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ';';
    EXECUTE query INTO STRICT paramlist;
      
    query = 'CREATE OR REPLACE FUNCTION TT_Translate(
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
    RETURN fctName;
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
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
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
    finalQuery text;
    finalVal text;
    isValid boolean;
    jsonbRow jsonb;
  BEGIN
    -- Validate the existence of the source table. TODO
    -- Determine if we must resume from last execution or not. TODO
    -- Create the log table. TODO
    -- FOR each row of the source table
    FOR sourcerow IN EXECUTE 'SELECT * FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) LOOP
       -- Convert the row to a json object so we can pass it to TT_Evaluate() (PostgreSQL does not allow passing RECORD to functions)
       jsonbRow = to_jsonb(sourcerow);
       finalQuery = 'SELECT';
       -- Iterate over each translation table row. One row per output attribute
       FOR translationrow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable) LOOP
         -- Iterate over each invalid rule
         FOREACH rule IN ARRAY translationrow.validationRules LOOP
           -- Evaluate the rule
           isValid = TT_Evaluate(rule.fctName, rule.args, jsonbRow, NULL::boolean);
           -- initialize the final value
           finalVal = rule.errorCode;
           -- Stop now if invalid and stopOnInvalid is set to true for this validation rule
           IF NOT isValid AND rule.stopOnInvalid THEN
               RAISE EXCEPTION 'Invalid rule found...';
           END IF;
         END LOOP ;
         -- If all validation rule passed, execute the translation rule
         IF isValid THEN
           EXECUTE 'SELECT TT_Evaluate($1, $2, $3, NULL::' || translationrow.targetAttributeType || ');' 
           USING (translationrow.translationRule).fctName, (translationrow.translationRule).args, jsonbRow INTO STRICT finalVal;
         END IF;
         -- Built the return query while computing values
         finalQuery = finalQuery || ' ''' || finalVal || '''::'  || translationrow.targetAttributeType || ',';
       END LOOP;
       -- Execute the final query building the returned RECORD
       finalQuery = left(finalQuery, char_length(finalQuery) - 1);
       EXECUTE finalQuery INTO translatedrow;
       RETURN NEXT translatedrow;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;