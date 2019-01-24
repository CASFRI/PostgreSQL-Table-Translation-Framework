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
-- Begin Function Definitions...
-------------------------------------------------------------------------------
-- TT_FullTableName
--
--   schemaName name - Name of the schema.
--   tableName name       - Name of the table.
--
-- RETURNS text       - Full name of the table.
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_FullTableName(name, name);
CREATE OR REPLACE FUNCTION TT_FullTableName(
  schemaName name,
  tableName name
)
RETURNS text AS $$
  DECLARE newSchemaName text = '';
  BEGIN
    IF length(schemaName) > 0 THEN
      newSchemaName := schemaName;
    ELSE
      newSchemaName := 'public';
    END IF;
    RETURN quote_ident(newschemaname) || '.' || quote_ident(tablename);
  END;
$$ LANGUAGE plpgsql VOLATILE;

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
-- Validate that the translation table fullfil a number of conditions:
--   - the list of target attribute should match the targetAttributeList parameter,
--   - each of those attribute names should be shorter than 64 charaters and 
--     contain no spaces,
--   - helper function names should match existing functions and their parameters 
--     should be in the right format,
--   - there should be no null or empty values in the translation table.
--  Return an error and stop the process if any invalid value is found in the
--  translation table.
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name, name, text[]);
CREATE OR REPLACE FUNCTION TT_ValidateTTable(
  translationTableSchema name,
  translationTable name,
  fctName name DEFAULT 'TT_Translate',
  attributeList text[] DEFAULT NULL
)
RETURNS text AS $f$
  BEGIN
    RETURN TRUE;
  END;
$f$ LANGUAGE plpgsql VOLATILE;

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
-------------------------------------------------------------------------------
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
    IF TT_ValidateTTable(translationTableSchema, translationTable, fctName, attributeList) THEN

      -- Drop any existing TT_Translate function
      query = 'DROP FUNCTION TT_Translate(name, name, name, name, text[], boolean, int, boolean, boolean);';
      EXECUTE query;

      query = 'SELECT string_agg(targetAttribute || '' '' || targetAttributeType, '', '') FROM ' || TT_FullTableName(translationTableSchema, translationTable) || ';';
      EXECUTE query INTO paramlist;
      
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
    RETURN QUERY SELECT * FROM _TT_Translate(sourceTableSchema, sourceTable) AS t(id int, col2 int);
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;';
      EXECUTE query;
    END IF;
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
-------------------------------------------------------------------------------

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
    rec tt_type;
  BEGIN
    -- Validate the translation file. TODO
    -- Validate the existence of source table. TODO
    
    SELECT 1, 2 INTO rec;
    RETURN NEXT rec;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;