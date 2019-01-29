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
--
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
    ret text[];
  BEGIN
     SELECT array_agg(a[1])
     FROM (SELECT regexp_matches(argStr, '("[-;,\w\s]+"|[-.\w]+)', 'g') a) foo
     INTO STRICT ret;
    RETURN ret;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ParseRules
--
--  ruleStr text - Rule string to parse into it differetn components.
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
    --FOR rules IN SELECT regexp_matches(ruleStr, '(\w+)\s*\(([^;]+)\)', 'g') LOOP
    FOR rules IN SELECT regexp_matches('between(crown_closure, 0, 100| -9999, TRUE)', '(\w+)\s*\(([^;|]+)\|?\s*([^;,|]+)?,?\s*(TRUE|FALSE)?\)', 'g') LOOP
      ruleDef.fctName = rules[1];
      ruleDef.args = TT_ParseArgs(rules[2]);
      ruleDef.errorcode = rules[3];
      ruleDef.stopOnInvalid = rules[4];
      ruleDefs = array_append(ruleDefs, ruleDef);
    END LOOP;
    RETURN ruleDefs;
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
RETURNS TABLE (targetAttribute text, targetAttributeType text, validationRules TT_RuleDef[], translationRules TT_RuleDef[], description text, descUpToDateWithRules boolean) AS $$
  DECLARE
    row RECORD;
    query text;
  BEGIN
    query = 'SELECT * FROM ' || TT_FullTableName(translationTableSchema, translationTable);
--RAISE NOTICE 'TT_ValidateTTable query1 = %', translationTableSchema;
--RAISE NOTICE 'TT_ValidateTTable query2 = %', translationTable;
    FOR row IN EXECUTE query LOOP
      targetAttribute = row.targetAttribute;
      targetAttributeType = row.targetAttributeType;
      validationRules = TT_ParseRules(row.validationRules);
      translationRules = TT_ParseRules(row.translationRules);
      description = COALESCE(row.description, '');
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
--   attributeList               - 
--
--   RETURNS text                - Name of the function created.
--
-- Create the base translation function to execute as the actual tranlation. This
-- function exists in order to palliate the fact that PostgreSQL does not allow creating
-- function able to return SETOF rows of arbitrary variable types. The function 
-- created by this function "freeze" and declare the return type of the translation
-- funtion enabling the package to return rows of arbitrriyl typed rows.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
-- 24/01/2019 added in v0.1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare(name, name, name, text[]);
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name,
  fctName name DEFAULT 'TT_Translate',
  attributeList text[] DEFAULT NULL
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

    query = 'SELECT string_agg(targetAttribute || '' '' || targetAttributeType, '', '') FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ';';
--RAISE NOTICE 'query11 = %', query;
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
               RETURN QUERY SELECT * FROM _TT_Translate(sourceTableSchema, sourceTable, translationTableSchema, translationTable) AS t(id int, col2 int);
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
    translatedrow RECORD;
    rule TT_RuleDef;
    ruleStr text;
    query text;
    
    arg text;
    newrule text;
    val text;
    result boolean;
  BEGIN
    -- Validate the existence of the source table. TODO
    -- Parse and validate the translation file. TODO
    --   Parsing function could:
    --   1) Parse only, leaving the validation and resolution to subsequent steps
    --      Pro: make parse and validate functions more simple as well as arguments
    --      Con: why would we want to parse and validate separately?
    --   2) Parse and validate, leaving the resolution to a subsequent step
    --      Pro: impossible to try t
    --   3) Parse, validate and resolve at the same time
    --      Con: Have to parse and validate for every input values
    -- Determine if we must resume from last execution or not. TODO
    -- Create the log table. TODO
    -- Apply each parsed translation table row to each row of the source table
    query = 'SELECT * FROM ' || TT_FullTableName(sourceTableSchema, sourceTable);

RAISE NOTICE '00 query = %', query;
    FOR sourcerow IN EXECUTE query LOOP
       FOR translatedrow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable) LOOP
RAISE NOTICE '11 translatedrow = %', translatedrow;
         FOREACH rule IN ARRAY translatedrow.validationRules LOOP
--RAISE NOTICE '11 rule.args = %', rule.args;
           newrule = 'TT_' || rule.fctname || '(';
           FOREACH arg IN ARRAY rule.args LOOP
             val = to_jsonb(sourcerow)->arg;
             IF val IS NULL THEN
               newrule = newrule || arg || ', ';
--RAISE NOTICE '22 arg = %', arg;

             ELSE
               newrule = newrule || val || ', ';
--RAISE NOTICE '33 val = %', val;
             END IF;
           END LOOP;
           newrule = left(newrule, char_length(newrule) - 2) || ')';
RAISE NOTICE '44 newrule = %', newrule::text;
           
           EXECUTE newrule INTO STRICT result;
    --       IF NOT result THEN
    --         IF stopOnInvalied THEN 
    --           RAISE NOTICE
    --         END IF;
    --         val = errorCode;
    --       END IF
         RETURN NEXT (2, 3);
         END LOOP ;
         EXIT WHEN NOT FOUND;
    --     IF val IS NULL THEN 
    --       replace values in translationRule
    --       EXECUTE invalidRule INTO STRICT val;
    --     END IF
          
       END LOOP;
       EXIT WHEN NOT FOUND;
    --   RETURN NEXT val1, val2, val3,...
       RETURN NEXT (1, 2);
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;