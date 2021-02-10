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
--DROP TYPE TT_RuleDef CASCADE;
CREATE TYPE TT_RuleDef AS (
  fctName text,
  args text[],
  errorCode text,
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
--DROP FUNCTION IF EXISTS TT_Debug(int);
CREATE OR REPLACE FUNCTION TT_Debug(
  level int DEFAULT NULL
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    RETURN current_setting('tt.debug' || CASE WHEN level IS NULL THEN '' ELSE '_l' || level::text END)::boolean;
    EXCEPTION WHEN OTHERS THEN -- if tt.debug is not set
      RETURN FALSE;
  END;
$$ LANGUAGE plpgsql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_DefaultProjectErrorCode
--
--   rule text - Name of the rule.
--   type text - Required type.
--
--   RETURNS text - Default error code for this rule.
--
-- Default project error code function to be overwritten by specific projects
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DefaultProjectErrorCode(text, text);
CREATE OR REPLACE FUNCTION TT_DefaultProjectErrorCode(
  rule text, 
  targetType text
)
RETURNS text AS $$
  DECLARE
    rulelc text = lower(rule);
    targetTypelc text = lower(targetType);
  BEGIN
    IF targetTypelc = 'integer' OR targetTypelc = 'int' OR targetTypelc = 'double precision' THEN 
      RETURN CASE WHEN rulelc = 'projectrule1' THEN '-9999'
                  ELSE TT_DefaultErrorCode(rulelc, targetTypelc) END;
    ELSIF targetTypelc = 'geometry' THEN
      RETURN CASE WHEN rulelc = 'projectrule1' THEN NULL
                  ELSE TT_DefaultErrorCode(rulelc, targetTypelc) END;
    ELSE
      RETURN CASE WHEN rulelc = 'projectrule1' THEN 'ERROR_CODE'
                  ELSE TT_DefaultErrorCode(rulelc, targetTypelc) END;
    END IF;
  END;
$$ LANGUAGE plpgsql;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
-- TT_TableExists
--
-- schemaName text
-- tableName text
--
-- Return boolean (success or failure)
--
-- Determine if a table exists.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TableExists(text, text);
CREATE OR REPLACE FUNCTION TT_TableExists(
  schemaName text,
  tableName text
)
RETURNS boolean AS $$
    SELECT NOT to_regclass(TT_FullTableName(schemaName, tableName)) IS NULL;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------]

-------------------------------------------------------------------------------
-- TT_GetGeomColName
--
-- schemaName text
-- tableName text
--
-- Return text
--
-- Determine the name of the first geometry column if it exists (otherwise return NULL)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_GetGeomColName(text, text);
CREATE OR REPLACE FUNCTION TT_GetGeomColName(
  schemaName text,
  tableName text
)
RETURNS text AS $$
  SELECT column_name::text FROM information_schema.columns
  WHERE table_schema = lower(schemaName) AND table_name = lower(tableName) AND udt_name= 'geometry'
  LIMIT 1
$$ LANGUAGE sql VOLATILE;

--SELECT TT_GetGeomColName('rawfri', 'AB16r')
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_PrettyDuration
--
-- seconds int
--
-- Format pased number of seconds into a pretty print time interval
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_PrettyDuration(int);
CREATE OR REPLACE FUNCTION TT_PrettyDuration(
  seconds int
)
RETURNS text AS $$
  DECLARE
    nbDays int;
    nbHours int;
    nbMinutes int;
  BEGIN
    nbDays = seconds/(24*3600);
    seconds = seconds - nbDays*24*3600;
    nbHours = seconds/3600;
    seconds = seconds - nbHours*3600;
    nbMinutes = seconds/60;
    seconds = seconds - nbMinutes*60;
    
    RETURN CASE WHEN nbDays > 0 THEN nbDays || 'd' || lpad(nbHours::text, 2, '0') || 'h' || lpad(nbMinutes::text, 2, '0') || 'm'
                WHEN nbHours > 0 THEN lpad(nbHours::text, 2, '0') || 'h' || lpad(nbMinutes::text, 2, '0') || 'm'
                WHEN nbMinutes > 0 THEN lpad(nbMinutes::text, 2, '0') || 'm' 
                ELSE '' END || lpad(seconds::text, 2, '0') || 's';
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LogInit
--
-- schemaName text
-- translationTableName text
-- sourceTableName
-- increment boolean
-- dupLogEntriesHandling text
--
-- Return the suffix of the created log table. 'FALSE' if creation failed.
-- Create a new or overwrite former log table and initialize a new one.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_LogInit(text, text, text, boolean, text);
CREATE OR REPLACE FUNCTION TT_LogInit(
  schemaName text,
  translationTableName text,
  sourceTableName text,
  increment boolean DEFAULT TRUE,
  dupLogEntriesHandling text DEFAULT '100'
)
RETURNS text AS $$
  DECLARE
    query text;
    logInc int = 1;
    logTableName text;
    action text = 'Creating';
  BEGIN
    IF NOT (TT_NotEmpty(translationTableName) AND TT_NotEmpty(sourceTableName)) THEN
      RAISE EXCEPTION 'TT_LogInit() ERROR: Invalid translation table name...';
    END IF;
    logTableName = translationTableName || '_4_' || sourceTableName || '_log_' || TT_Pad(logInc::text, 3::text, '0');
    IF increment THEN
      -- find an available table name
      WHILE TT_TableExists(schemaName, logTableName) LOOP
        logInc = logInc + 1;
        logTableName = translationTableName || '_4_' || sourceTableName || '_log_' || TT_Pad(logInc::text, 3::text, '0');
      END LOOP;
    ELSIF TT_TableExists(schemaName, logTableName) THEN
      action = 'Overwriting';
      query = 'DROP TABLE IF EXISTS ' || TT_FullTableName(schemaName, logTableName) || ';';
      BEGIN
        EXECUTE query;
      EXCEPTION WHEN OTHERS THEN
        RETURN 'FALSE';
      END;
    END IF;
    
    query = 'CREATE TABLE ' || TT_FullTableName(schemaName, logTableName) || ' (' ||
            'logID SERIAL, logTime timestamp with time zone, logEntryType text, 
             firstRowId text, message text, currentRowNb int, count int);';

    -- display the name of the logging table being produced
    RAISE NOTICE 'TT_LogInit(): % log table ''%''...', action, TT_FullTableName(schemaName, logTableName);
    -- display the type of handling for invalid values.
    IF dupLogEntriesHandling = 'ALL_OWN_ROW' THEN
      RAISE NOTICE 'TT_LogInit(): All invalid and translation error messages in their own rows...';
    ELSE
      IF dupLogEntriesHandling = 'ALL_GROUPED' THEN
        RAISE NOTICE 'TT_LogInit(): All invalid and translation error messages of the same type grouped in the same row.';
      ELSE
        RAISE NOTICE 'TT_LogInit(): Maximum of % invalid or translation error messages of the same type grouped in the same row...', dupLogEntriesHandling;
      END IF;
    END IF;
    BEGIN
      EXECUTE query;
    EXCEPTION WHEN OTHERS THEN
      RETURN 'FALSE';
    END;

    -- create an md5 index on the message column
    query = 'CREATE ' || 
             CASE WHEN dupLogEntriesHandling != 'ALL_OWN_ROW' THEN 'UNIQUE ' ELSE '' END || 
            'INDEX ON ' || TT_FullTableName(schemaName, logTableName) || 
            ' (md5(message));';
    EXECUTE query;
    RETURN logTableName;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ShowLastLog
--
-- schemaName text
-- translationTableName text
--
-- Return the last log table for the provided translation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ShowLastLog(text, text, text, int);
CREATE OR REPLACE FUNCTION TT_ShowLastLog(
  schemaName text,
  translationTableName text,
  sourceTableName text,
  logNb int DEFAULT NULL
)
RETURNS TABLE (logID int, 
               logTime timestamp with time zone, 
               logEntryType text, 
               firstRowId text, 
               message text, 
               currentRowNb int, 
               count int) AS $$
  DECLARE
    query text;
    logInc int = 1;
    logTableName text;
    suffix text;
  BEGIN
    IF NOT logNb IS NULL THEN
      logInc = logNb;
    END IF;
    suffix = '_log_' || TT_Pad(logInc::text, 3::text, '0');
    logTableName = translationTableName || '_4_' || sourceTableName || suffix;
    IF TT_FullTableName(schemaName, logTableName) = 'public.' || suffix THEN
      RAISE NOTICE 'TT_ShowLastLog() ERROR: Invalid translation table name or number (%.%)...', schemaName, logTableName;
      RETURN;
    END IF;
    IF logNb IS NULL THEN
      -- find the last log table name
      WHILE TT_TableExists(schemaName, logTableName) LOOP
        logInc = logInc + 1;
        logTableName = translationTableName || '_4_' || sourceTableName || '_log_' || TT_Pad(logInc::text, 3::text, '0');
      END LOOP;
      -- if logInc = 1 means no log table exists
      IF logInc = 1 THEN
        RAISE NOTICE 'TT_ShowLastLog() ERROR: No translation log to show for translation table ''%.%'' and source table %...', schemaName, translationTableName, sourceTableName;
        RETURN;
      END IF;
      logInc = logInc - 1;
    ELSE
      IF NOT TT_TableExists(schemaName, logTableName) THEN
        RAISE NOTICE 'TT_ShowLastLog() ERROR: Translation log table ''%.%'' does not exist...', schemaName, logTableName;
        RETURN;
      END IF;
    END IF;
    logTableName = translationTableName || '_4_' || sourceTableName || '_log_' || TT_Pad(logInc::text, 3::text, '0');
    RAISE NOTICE 'TT_ShowLastLog(): Displaying log table ''%''', logTableName;
    query = 'SELECT logID, logTime, logEntryType, firstRowId, message, currentRowNb, count FROM ' || 
            TT_FullTableName(schemaName, logTableName) || ' ORDER BY logid;';
    RETURN QUERY EXECUTE query;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_DeleteAllLogs
--
-- schemaName text
-- translationTableName text
--
-- Delete all log table associated with the target table.
-- If translationTableName is NULL, delete all log tables in schema.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DeleteAllLogs(text, text);
CREATE OR REPLACE FUNCTION TT_DeleteAllLogs(
  schemaName text,
  translationTableName text DEFAULT NULL
)
RETURNS SETOF text AS $$
  DECLARE
    res RECORD;
  BEGIN
    IF translationTableName IS NULL THEN
      FOR res IN SELECT 'DROP TABLE IF EXISTS ' || TT_FullTableName(schemaName, table_name) || ';' query
                 FROM information_schema.tables 
                 WHERE lower(table_schema) = schemaName AND right(table_name, 8) ~ '_log_[0-9][0-9][0-9]'
                 ORDER BY table_name LOOP
        EXECUTE res.query;
        RETURN NEXT res.query;
      END LOOP;
    ELSE
      FOR res IN SELECT 'DROP TABLE IF EXISTS ' || TT_FullTableName(schemaName, table_name) || ';' query
                 FROM information_schema.tables 
                 WHERE char_length(table_name) > char_length(translationTableName) AND left(table_name, char_length(translationTableName)) = translationTableName
                 ORDER BY table_name LOOP
        EXECUTE res.query;
        RETURN NEXT res.query;
      END LOOP;
    END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Log
--
-- schemaName text   - Schema name of the logging table
-- logTableName text - Logging table name
-- logEntryType text - Type of logging entry (PROGRESS, INVALIDATION)
-- firstRowId text   - rowID of the first source triggering the logging entry.
-- message text      - Message to log
-- currentRowNb int  - Number of the row being processed
-- count int         - Number of rows associated with this log entry
--
-- Return boolean  -- Succees or failure.
-- Log an entry in the log table.
-- The log table has the following structure:
--   logid integer NOT NULL DEFAULT nextval('source_log_001_logid_seq'::regclass),
--   logtime timestamp,
--   logentrytype text,
--   firstrowid text,
--   message text,
--   currentrownb int,
--   count integer
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Log(text, text, text, text, text, text, int, int);
CREATE OR REPLACE FUNCTION TT_Log(
  schemaName text,
  logTableName text,
  dupLogEntriesHandling text,
  logEntryType text,
  firstRowId text,
  msg text,
  currentRowNb int,
  count int DEFAULT NULL
)
RETURNS boolean AS $$
  DECLARE
    query text;
  BEGIN
    IF upper(logEntryType) = 'PROGRESS' THEN
      query = 'INSERT INTO ' || TT_FullTableName(schemaName, logTableName) || ' VALUES (' ||
         'DEFAULT, now(), ''PROGRESS'', $1, $2, $3, $4);';
      EXECUTE query USING firstRowId, msg, currentRowNb, count;
      RETURN TRUE;
    ELSIF upper(logEntryType) = 'INVALID_VALUE' OR upper(logEntryType) = 'TRANSLATION_ERROR' THEN
      query = 'INSERT INTO ' || TT_FullTableName(schemaName, logTableName) || ' AS tbl VALUES (' ||
              'DEFAULT, now(), ''' || upper(logEntryType) || ''', $1, $2, $3, $4) ';
      IF dupLogEntriesHandling != 'ALL_OWN_ROW' THEN
        query = query || 'ON CONFLICT (md5(message)) DO UPDATE SET count = tbl.count + 1';
        IF dupLogEntriesHandling != 'ALL_GROUPED' THEN
          query = query || 'WHERE tbl.count < ' || dupLogEntriesHandling;
        END IF;
      END IF;
      query = query || ';';
      EXECUTE query USING firstRowId, msg, currentRowNb, 1;
      RETURN TRUE;
    ELSE
      RAISE EXCEPTION 'TT_Log() ERROR: Invalid logEntryType (%)...', logEntryType;
      RETURN FALSE;
    END IF;
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
    -- NULL values are castable to everything
    IF NOT val IS NULL THEN
      query = 'SELECT ' || '''' || val || '''' || '::' || targetType || ';';
      EXECUTE query;
    END IF;
    RETURN TRUE;
  EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_IsSingleQuoted
-- DROP FUNCTION IF EXISTS TT_IsSingleQuoted(text);
CREATE OR REPLACE FUNCTION TT_IsSingleQuoted(
  str text
)
RETURNS boolean AS $$
  SELECT left(str, 1) = '''' AND right(str, 1) = '''';
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_UnSingleQuote
-- DROP FUNCTION IF EXISTS TT_UnSingleQuote(text);
CREATE OR REPLACE FUNCTION TT_UnSingleQuote(
  str text
)
RETURNS text AS $$
  SELECT CASE WHEN left(str, 1) = '''' AND right(str, 1) = '''' THEN btrim(str, '''') ELSE str END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_EscapeSingleQuotes
-- DROP FUNCTION IF EXISTS TT_EscapeSingleQuotes(text);
CREATE OR REPLACE FUNCTION TT_EscapeSingleQuotes(
  str text
)
RETURNS text AS $$
    SELECT replace(str, '''', '''''');
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_EscapeDoubleQuotes
-- DROP FUNCTION IF EXISTS TT_EscapeDoubleQuotesAndBackslash(text);
CREATE OR REPLACE FUNCTION TT_EscapeDoubleQuotesAndBackslash(
  str text
)
RETURNS text AS $$
  SELECT replace(replace(str, '\', '\\'), '"', '\"'); -- '''
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_DropAllTTFct
--
--   RETURNS SETOF text     - All DROPed query executed.
--
-- DROP all functions starting with 'TT_' (case insensitive).
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DropAllTTFct();
CREATE OR REPLACE FUNCTION TT_DropAllTTFct(
)
RETURNS SETOF text AS $$
  DECLARE
    res RECORD;
  BEGIN
    FOR res IN SELECT 'DROP FUNCTION ' || oid::regprocedure::text || ';' query
               FROM pg_proc WHERE left(proname, 3) = 'tt_' AND pg_function_is_visible(oid) LOOP
      EXECUTE res.query;
      RETURN NEXT res.query;
    END LOOP;
  RETURN;
END
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
    FOR res IN SELECT 'DROP FUNCTION ' || oid::regprocedure::text || ';' query
               FROM pg_proc WHERE left(proname, 12) = 'tt_translate' AND pg_function_is_visible(oid) LOOP
      EXECUTE res.query;
      RETURN NEXT res.query;
    END LOOP;
  RETURN;
END
$$ LANGUAGE plpgsql VOLATILE;
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
    LIMIT 1
    INTO cnt;

    IF cnt = 1 THEN
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
-- DROP FUNCTION IF EXISTS TT_RepackStringList(text[], boolean);
CREATE OR REPLACE FUNCTION TT_RepackStringList(
  args text[] DEFAULT NULL,
  toSQL boolean DEFAULT FALSE
)
RETURNS text AS $$
  DECLARE
    arg text;
    result text = '';
    debug boolean = TT_Debug();
    openingBrace text = '{';
    closingBrace text = '}';
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_RepackStringList 00 cardinality=%', cardinality(args);END IF;
    IF (cardinality(args) = 1 AND args[1] IS NULL) THEN
      RETURN NULL;
    END IF;
    IF toSQL THEN
     openingBrace = 'ARRAY[';
     closingBrace = ']';
    END IF;
    -- open the array string only when a true array or when only item is NULL
    IF cardinality(args) > 1 THEN
      result = openingBrace;
    END IF;

    FOREACH arg in ARRAY args LOOP
      IF debug THEN RAISE NOTICE 'TT_RepackStringList 11 arg=%', arg;END IF;
      IF arg IS NULL THEN
        result = result || 'NULL' || ',';
      ELSE
        IF debug THEN RAISE NOTICE 'TT_RepackStringList 22 result=%', result;END IF;
        IF cardinality(args) > 1 AND (NOT toSQL OR (NOT TT_IsName(arg) AND NOT TT_IsSingleQuoted(arg) AND NOT TT_IsNumeric(arg))) THEN
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
    IF cardinality(args) > 1 THEN
      result = result || closingBrace;
    END IF;
    IF debug THEN RAISE NOTICE 'TT_RepackStringList 55 result=%', result;END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_RuleToSQL
--
--  - fctName text  - Name of the function to evaluate. Will always be prefixed
--                    with "TT_".
--  - arg text[]    - Array of argument values to pass to the function.
--                    Generally includes one or two column names to get replaced
--                    with values from the vals argument.
--
--    RETURNS text
--
-- Reconstruct a query string from passed function name and arguments.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RuleToSQL(text, text[]);
CREATE OR REPLACE FUNCTION TT_RuleToSQL(
  fctName text,
  args text[]
)
RETURNS text AS $$
  DECLARE
    queryStr text = '';
    arg text;
    argCnt int;
    debug boolean = FALSE;
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_RuleToSQL BEGIN fctName=%, args=%, vals=%', fctName, args::text, vals::text;END IF;
    queryStr = 'TT_' || fctName || '(';
    argCnt = 0;
    IF debug THEN RAISE NOTICE 'TT_RuleToSQL 11 queryStr=%', queryStr;END IF;

    FOREACH arg IN ARRAY coalesce(args, ARRAY[]::text[]) LOOP
      -- Add a comma if it's not the first argument
      IF argCnt != 0 THEN
        queryStr = queryStr || ', ';
      END IF;
      IF debug THEN RAISE NOTICE 'TT_RuleToSQL 22 queryStr=%', queryStr;END IF;
      queryStr = queryStr || TT_RepackStringList(TT_ParseStringList(arg), TRUE) || CASE WHEN TT_IsStringList(arg, TRUE) THEN '::text[]' ELSE '' END || '::text';
      IF debug THEN RAISE NOTICE 'TT_RuleToSQL 33 queryStr=%', queryStr;END IF;
      argCnt = argCnt + 1;
    END LOOP;
    queryStr = queryStr || ')';

    IF debug THEN RAISE NOTICE 'TT_RuleToSQL END queryStr=%', queryStr;END IF;
    RETURN queryStr;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_TextFctQuery
--
--  - fctName text  - Name of the function to evaluate. Will always be prefixed
--                    with "TT_".
--  - arg text[]    - Array of argument values to pass to the function.
--                    Generally includes one or two column names to get replaced
--                    with values from the vals argument.
--  - vals jsonb    - Replacement values passed as a jsonb object (since
--
--    RETURNS text
--
-- Replace column names with source values and return a complete query string.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TextFctQuery(text, text[], jsonb, boolean, boolean);
CREATE OR REPLACE FUNCTION TT_TextFctQuery(
  fctName text,
  args text[],
  vals jsonb,
  escape boolean DEFAULT TRUE,
  varName boolean DEFAULT FALSE
)
RETURNS text AS $$
  DECLARE
    queryStr text = '';
    arg text;
    argCnt int;
    argNested text;
    argValNested text;
    repackArray text[];
    isStrList boolean;
    repackStr text;
    debug boolean = FALSE;
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_TextFctQuery BEGIN fctName=%, args=%, vals=%', fctName, args::text, vals::text;END IF;
    queryStr = fctName || '(';
    argCnt = 0;
    IF debug THEN RAISE NOTICE 'TT_TextFctQuery 11 queryStr=%', queryStr;END IF;

    FOREACH arg IN ARRAY coalesce(args, ARRAY[]::text[]) LOOP
      repackArray = ARRAY[]::text[];
      IF debug THEN RAISE NOTICE 'TT_TextFctQuery 22 cardinality(repackArray)=%', cardinality(repackArray);END IF;
      -- add a comma if it's not the first argument
      IF argCnt != 0 THEN
        queryStr = queryStr || ', ';
      END IF;
      isStrList = TT_IsStringList(arg, TRUE);
      FOREACH argNested IN ARRAY TT_ParseStringList(arg) LOOP
        IF debug THEN RAISE NOTICE 'TT_TextFctQuery 33';END IF;
        IF TT_IsName(argNested) THEN
          IF vals ? argNested THEN
            argValNested = vals->>argNested;
            IF varName THEN
              argValNested = argNested || CASE WHEN argValNested IS NULL THEN '=NULL'
                                               ELSE '=''' || TT_EscapeSingleQuotes(argValNested) || '''' END;
            END IF;
            repackArray = array_append(repackArray, argValNested);
            IF debug THEN RAISE NOTICE 'TT_TextFctQuery 44 argValNested=%', argValNested;END IF;
          ELSE
            -- if column name not in source table, raise exception
            RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE: Source attribute ''%'', called in function ''%()'', does not exist in the source table...', argNested, fctName;
          END IF;
        ELSE
          IF debug THEN RAISE NOTICE 'TT_TextFctQuery 55 argNested=%', argNested;END IF;
          -- we can now remove the surrounding single quotes from the string
          -- since we have processed column names
          IF varName AND NOT isStrList THEN
            repackArray = array_append(repackArray, argNested);
          ELSE
            repackArray = array_append(repackArray, TT_UnSingleQuote(argNested));
          END IF;
        END IF;
      END LOOP;
      IF debug THEN RAISE NOTICE 'TT_TextFctQuery 66 queryStr=%', queryStr;END IF;
      repackStr = TT_RepackStringList(repackArray);
      IF escape AND NOT repackStr IS NULL THEN
        queryStr = queryStr || '''' || TT_EscapeSingleQuotes(repackStr) || '''::text';
      ELSE
        queryStr = queryStr || coalesce(repackStr, 'NULL');
      END IF;
      IF debug THEN RAISE NOTICE 'TT_TextFctQuery 88 queryStr=%', queryStr;END IF;
      argCnt = argCnt + 1;
    END LOOP;
    queryStr = queryStr || ')';

    IF debug THEN RAISE NOTICE 'TT_TextFctQuery END queryStr=%', queryStr;END IF;
    RETURN queryStr;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
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
    queryStr text;
    result ALIAS FOR $0;
    debug boolean = FALSE;
  BEGIN
    -- This function returns a polymorphic type (the one provided in the returnType input argument)
    IF debug THEN RAISE NOTICE 'TT_TextFctEval BEGIN fctName=%, args=%, vals=%, returnType=%', fctName, args, vals, returnType;END IF;

    -- fctName should never be NULL
    IF fctName IS NULL OR (checkExistence AND (NOT TT_TextFctExists(fctName, coalesce(cardinality(args), 0)))) THEN
      IF debug THEN RAISE NOTICE 'TT_TextFctEval 11 fctName=%, args=%', fctName, cardinality(args);END IF;
      RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE: Helper function %(%) does not exist.', fctName, btrim(repeat('text,', cardinality(args)),',');
    END IF;

    IF debug THEN RAISE NOTICE 'TT_TextFctEval 22 fctName=%, args=%', fctName, cardinality(args);END IF;
    queryStr = 'SELECT TT_' || TT_TextFctQuery(fctName, args, vals) || '::' || pg_typeof(result);

    IF debug THEN RAISE NOTICE 'TT_TextFctEval 33 queryStr=%', queryStr;END IF;
    EXECUTE queryStr INTO STRICT result;
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
    -- [^\s,][-_\.\w\s]* - any word including '-' or '_' or a space, removes any preceding spaces or commas
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
  FROM (SELECT (regexp_matches(argStr, '([^\s,][-_\.\w\s]*|''[^''\\]*(?:\\''[^''\\]*)*''|"[^"]+"|{[^}]+}|""|'''')', 'g'))[1] str) foo
$$ LANGUAGE sql IMMUTABLE STRICT;
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
  ruleStr text DEFAULT NULL,
  targetType text DEFAULT NULL,
  isTranslation boolean DEFAULT FALSE
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
                                                '([Ss][Tt][Oo][Pp])?\)'-- STOP or not
                                                , 'g') LOOP
      ruleDef.fctName = rules[1];
      ruleDef.args = TT_ParseArgs(rules[2]);
      ruleDef.errorCode = TT_DefaultProjectErrorCode(CASE WHEN isTranslation THEN 'translation_error' ELSE ruleDef.fctName END, targetType);
      IF upper(rules[3]) = 'STOP' THEN
        ruleDef.stopOnInvalid = TRUE;
      ELSE
        ruleDef.errorCode = coalesce(rules[3], ruleDef.errorCode);
        ruleDef.stopOnInvalid = (NOT upper(rules[4]) IS NULL AND upper(rules[4]) = 'STOP');
      END IF;
      ruleDefs = array_append(ruleDefs, ruleDef);
    END LOOP;
    RETURN ruleDefs;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ValidateTTable
--
--   translationTableSchema name - Name of the schema containing the translation
--                                 table.
--   translationTable name       - Name of the translation table.
--   validate                    - boolean flag indicating whether translation 
--                               - table attributes should be validated.
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
--   - target_attribute name should be valid with no special characters
--
--  Return an error and stop the process if any invalid value is found in the
--  translation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name, boolean);
CREATE OR REPLACE FUNCTION TT_ValidateTTable(
  translationTableSchema name,
  translationTable name,
  validate boolean DEFAULT TRUE
)
RETURNS TABLE (target_attribute text, 
               target_attribute_type text, 
               validation_rules TT_RuleDef[], 
               translation_rule TT_RuleDef) AS $$
  DECLARE
    row RECORD;
    query text;
    debug boolean = TT_Debug();
    rule TT_RuleDef;
    error_msg_start text = 'ERROR IN TRANSLATION TABLE AT RULE_ID #';
    warning_msg_start text = 'WARNING FOR TRANSLATION TABLE AT RULE_ID #';
  BEGIN
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable BEGIN';END IF;
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 11';END IF;
    IF translationTable IS NULL OR translationTable = '' THEN
      RETURN;
    END IF;
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 22';END IF;

    -- loop through each row in the translation table
    query = 'SELECT rule_id::text, 
                    target_attribute::text, 
                    target_attribute_type::text, 
                    validation_rules::text, 
                    translation_rules::text, 
                    description::text, 
                    desc_uptodate_with_rules::text
             FROM ' || TT_FullTableName(translationTableSchema, translationTable) || 
           ' ORDER BY to_number(rule_id::text, ''999999'');';
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable 33 query=%', query;END IF;
    FOR row IN EXECUTE query LOOP
      -- validate attributes and assign values
      target_attribute = row.target_attribute;
      target_attribute_type = row.target_attribute_type;
      validation_rules = (TT_ParseRules(row.validation_rules, row.target_attribute_type))::TT_RuleDef[];
      translation_rule = ((TT_ParseRules(row.translation_rules, row.target_attribute_type, TRUE))[1])::TT_RuleDef;
      --description = coalesce(row.description, '');
      --desc_uptodate_with_rules should not be null or empty
      --desc_uptodate_with_rules = (row.desc_uptodate_with_rules)::boolean;

      IF validate THEN
        -- rule_id should be integer, not null, not empty string
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 44, row=%', row::text;END IF;
        IF NOT TT_NotEmpty(row.rule_id) THEN
          RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE: At least one rule_id is NULL or empty...';
        END IF;
        IF NOT TT_IsInt(row.rule_id) THEN
          RAISE EXCEPTION 'ERROR IN TRANSLATION TABLE: rule_id (%) is not an integer...', row.rule_id;
        END IF;

        -- target_attribute should not be null or empty string, should be word with underscore allowed but no special characters
        IF NOT TT_NotEmpty(row.target_attribute) THEN
          RAISE EXCEPTION '% %: Target attribute is NULL or empty...', error_msg_start, row.rule_id;
        END IF;
        IF NOT TT_IsName(row.target_attribute) THEN -- ~ '^(\d|\w)+$' THEN
          RAISE EXCEPTION '% %: Target attribute name (%) is invalid...', error_msg_start, row.rule_id, row.target_attribute;
        END IF;

        -- target_attribute_type should not be null or empty
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 55';END IF;
        IF NOT TT_NotEmpty(row.target_attribute_type) THEN
          RAISE EXCEPTION '% % (%): Target attribute type is NULL or empty...', error_msg_start, row.rule_id, row.target_attribute;
        END IF;

        -- validation_rules should not be null or empty
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 66';END IF;
        IF NOT TT_NotEmpty(row.validation_rules) THEN
          RAISE EXCEPTION '% % (%): Validation rules is NULL or empty...', error_msg_start, row.rule_id, row.target_attribute;
        END IF;

        -- translation_rules should not be null or empty
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 77';END IF;
        IF NOT TT_NotEmpty(row.translation_rules) THEN
          RAISE EXCEPTION '% % (%): Translation rule is NULL or empty...', error_msg_start, row.rule_id, row.target_attribute;
        END IF;

        -- description should not be null or empty
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 88';END IF;
        IF NOT TT_NotEmpty(row.description) THEN
          RAISE EXCEPTION '% % (%): Description is NULL or empty...', error_msg_start, row.rule_id, row.target_attribute;
        END IF;
        IF debug THEN RAISE NOTICE 'TT_ValidateTTable 99';END IF;
        IF NOT TT_NotEmpty(row.desc_uptodate_with_rules) THEN
          RAISE EXCEPTION '% % (%): desc_uptodate_with_rules is NULL or empty...', error_msg_start, row.rule_id, row.target_attribute;
        END IF;
        
        -- target_attribute_type should be equal to NA when target_attribute = ROW_TRANSLATION_RULE
        IF row.target_attribute = 'ROW_TRANSLATION_RULE' AND upper(row.target_attribute_type) != 'NA' THEN
          RAISE NOTICE '% % (%): target_attribute_type (%) should be equal to ''NA'' for special target_attribute ROW_TRANSLATION_RULE...', warning_msg_start, row.rule_id, row.target_attribute, row.target_attribute_type;
        END IF;

        IF row.target_attribute = 'ROW_TRANSLATION_RULE' AND upper(row.translation_rules) != 'NA'  THEN
          RAISE NOTICE '% % (%): translation_rules (%) should be equal to ''NA'' for special target_attribute ''ROW_TRANSLATION_RULE''...', warning_msg_start, row.rule_id, row.target_attribute, row.translation_rules;
        END IF;

        IF debug THEN RAISE NOTICE 'TT_ValidateTTable AA';END IF;
        -- Check validation functions exist, error code is not null, and error code can be cast to target attribute type
        FOREACH rule IN ARRAY validation_rules LOOP
          -- Check function exists
          IF debug THEN RAISE NOTICE 'TT_ValidateTTable BB function name: %, arguments: %', rule.fctName, rule.args;END IF;
          IF NOT TT_TextFctExists(rule.fctName, coalesce(cardinality(rule.args), 0)) THEN
            RAISE EXCEPTION '% % (%): Validation helper function ''%(%)'' does not exist...', error_msg_start, row.rule_id, row.target_attribute, rule.fctName, btrim(repeat('text,', coalesce(cardinality(rule.args), 0)), ',');
          END IF;

          -- check error code is not null
          IF rule.errorCode = '' OR rule.errorCode = 'NO_DEFAULT_ERROR_CODE' THEN
            RAISE EXCEPTION '% % (%): No error code defined for validation rule ''%()''. Define or update your own project TT_DefaultProjectErrorCode() function...', error_msg_start, row.rule_id, row.target_attribute, rule.fctName;
          END IF;

          -- Check error code can be cast to attribute type, catch error with EXCEPTION
          IF debug THEN RAISE NOTICE 'TT_ValidateTTable CC target attribute type: %, error value: %', row.target_attribute_type, rule.errorCode;END IF;
          IF rule.errorCode IS NULL THEN
            RAISE NOTICE '% % (%): Error code for target attribute type (%) and validation rule ''%()'' is NULL.', warning_msg_start, row.rule_id, row.target_attribute, row.target_attribute_type, rule.fctName;
          END IF;
          IF row.target_attribute != 'ROW_TRANSLATION_RULE' AND NOT TT_IsCastableTo(rule.errorCode, row.target_attribute_type) THEN
            RAISE EXCEPTION '% % (%): Error code (%) cannot be cast to the target attribute type (%) for validation rule ''%()''.', error_msg_start, row.rule_id, row.target_attribute, rule.errorCode, row.target_attribute_type, rule.fctName;
          END IF;
        END LOOP;

        -- Validate translation_rule only when for target_attribute other then ROW_TRANSLATION_RULE
        IF row.target_attribute != 'ROW_TRANSLATION_RULE' THEN
          -- check translation function exists
          IF debug THEN RAISE NOTICE 'TT_ValidateTTable EE function name: %, arguments: %', translation_rule.fctName, translation_rule.args;END IF;
          IF NOT TT_TextFctExists(translation_rule.fctName, coalesce(cardinality(translation_rule.args), 0)) THEN
            RAISE EXCEPTION '% % (%): Translation helper function ''%(%)'' does not exist...', error_msg_start, row.rule_id, row.target_attribute, translation_rule.fctName, btrim(repeat('text,', coalesce(cardinality(translation_rule.args), 0)), ',');
          END IF;

          -- Check translation rule return type matches target attribute type
          IF NOT TT_TextFctReturnType(translation_rule.fctName, coalesce(cardinality(translation_rule.args), 0)) = row.target_attribute_type THEN
            RAISE EXCEPTION '% % (%): Translation rule return type (%) does not match translation helper function return type (%)...', error_msg_start, row.rule_id, row.target_attribute, target_attribute_type, TT_TextFctReturnType(translation_rule.fctName, coalesce(cardinality(translation_rule.args), 0));
          END IF;
          IF translation_rule.errorCode IS NULL THEN
            RAISE NOTICE '% % (%): Error code for target attribute type (%) and translation rule ''%()'' is NULL.', warning_msg_start, row.rule_id, row.target_attribute, target_attribute_type, translation_rule.fctName;
          END IF;
          -- If not null, check translation error code can be cast to attribute type
          IF NOT TT_IsCastableTo(translation_rule.errorCode, row.target_attribute_type) THEN
            IF debug THEN RAISE NOTICE 'TT_ValidateTTable FF target attribute type: %, error value: %', row.target_attribute_type, translation_rule.errorCode;END IF;
            RAISE EXCEPTION '% % (%): Error code (%) cannot be cast to the target attribute type (%) for translation rule ''%()''...', error_msg_start, row.rule_id, row.target_attribute, translation_rule.errorCode, row.target_attribute_type, translation_rule.fctName;
          END IF;
        END IF;
      END IF;
      RETURN NEXT;
    END LOOP;
    IF debug THEN RAISE NOTICE 'TT_ValidateTTable END';END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql STABLE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_ValidateTTable(
  translationTable name,
  validate boolean DEFAULT TRUE
)
RETURNS TABLE (target_attribute text, target_attribute_type text, validation_rules TT_RuleDef[], translation_rule TT_RuleDef) AS $$
  SELECT TT_ValidateTTable('public', translationTable, validate);
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Prepare
--
--   translationTableSchema name    - Name of the schema containing the 
--                                    translation table.
--   translationTable name          - Name of the translation table.
--   fctName name                   - Name of the function to create. Default to
--                                    'TT_Translate'.
--   refTranslationTableSchema name - Name of the schema containing the reference 
--                                    translation table.
--   refTranslationTable name       - Name of the reference translation table.
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
    query = 'SELECT array_agg(target_attribute || '' '' || target_attribute_type ORDER BY rule_id::int) ' ||
            'FROM ' || TT_FullTableName(translationTableSchema, translationTable) || 
           ' WHERE target_attribute != ''ROW_TRANSLATION_RULE'';';
    EXECUTE query INTO STRICT paramlist;

    IF TT_NotEmpty(refTranslationTableSchema) AND TT_NotEmpty(refTranslationTable) THEN
      -- Build the list of attribute names and types for the reference table
      query = 'SELECT array_agg(target_attribute || '' '' || target_attribute_type ORDER BY rule_id::int) ' ||
              'FROM ' || TT_FullTableName(refTranslationTableSchema, refTranslationTable) || 
             ' WHERE target_attribute != ''ROW_TRANSLATION_RULE'';';
      EXECUTE query INTO STRICT refParamlist;

      IF cardinality(paramlist) < cardinality(refParamlist) THEN
        RAISE EXCEPTION 'TT_Prepare() ERROR: Translation table ''%.%'' has less attributes than reference table ''%.%''...', translationTableSchema, translationTable, refTranslationTableSchema, refTranslationTable;
      ELSIF cardinality(paramlist) > cardinality(refParamlist) THEN
        RAISE EXCEPTION 'TT_Prepare() ERROR: Translation table ''%.%'' has more attributes than reference table ''%.%''...', translationTableSchema, translationTable, refTranslationTableSchema, refTranslationTable;
      ELSIF TT_LowerArr(paramlist) != TT_LowerArr(refParamlist) THEN
        FOR i IN 1..cardinality(paramlist) LOOP
          IF paramlist[i] != refParamlist[i] THEN
            RAISE EXCEPTION 'TT_Prepare() ERROR: Translation table ''%.%'' attribute ''%'' is different from reference table ''%.%'' attribute ''%''...', translationTableSchema, translationTable, paramlist[i], refTranslationTableSchema, refTranslationTable, refParamlist[i];
          END IF;
        END LOOP;
      END IF;
    END IF;

    -- Drop any existing TT_Translate function with the same suffix
    query = 'DROP FUNCTION IF EXISTS TT_Translate' || coalesce(fctNameSuf, '') || '(name, name, name, boolean, boolean, text, int, boolean, boolean, boolean);';
    EXECUTE query;

    query = 'CREATE OR REPLACE FUNCTION TT_Translate' || coalesce(fctNameSuf, '') || '(
               sourceTableSchema name,
               sourceTable name,
               sourceTableIdColumn name DEFAULT NULL,
               stopOnInvalidSource boolean DEFAULT FALSE,
               stopOnTranslationError boolean DEFAULT FALSE,
               dupLogEntriesHandling text DEFAULT ''100'',
               logFrequency int DEFAULT 500,
               incrementLog boolean DEFAULT TRUE,
               resume boolean DEFAULT FALSE,
               ignoreDescUpToDateWithRules boolean DEFAULT FALSE
             )
             RETURNS TABLE (' || array_to_string(paramlist, ', ') || ') AS $$
             BEGIN
               RETURN QUERY SELECT * FROM _TT_Translate(sourceTableSchema,
                                                        sourceTable,
                                                        sourceTableIdColumn, ' ||
                                                        '''' || translationTableSchema || ''', ' ||
                                                        '''' || translationTable || ''', 
                                                        stopOnInvalidSource,
                                                        stopOnTranslationError,
                                                        dupLogEntriesHandling, 
                                                        logFrequency,
                                                        incrementLog,
                                                        resume,
                                                        ignoreDescUpToDateWithRules) AS t(' || array_to_string(paramlist, ', ') || ');
               RETURN;
             END;
             $$ LANGUAGE plpgsql VOLATILE;';
    EXECUTE query;
    RETURN 'SELECT * FROM TT_Translate' || coalesce(fctNameSuf, '') || '(''schemaName'', ''tableName'', ''uniqueIDColumn'');';
  END;
$f$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare(name, name, text, name);
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
--DROP FUNCTION IF EXISTS TT_Prepare(name, name, text);
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text
)
RETURNS text AS $$
  SELECT TT_Prepare(translationTableSchema, translationTable, fctNameSuf, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare(name, name);
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTableSchema name,
  translationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare(translationTableSchema, translationTable, NULL, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Prepare(
  translationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare('public', translationTable, NULL::text, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_ReportError
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ReportError(text, name, name, name, text, text, text[], jsonb, text, text, int, text, boolean, boolean);
CREATE OR REPLACE FUNCTION TT_ReportError(
  errorType text,
  translationTableSchema name,
  logTableName name,
  dupLogEntriesHandling text,
  fctName text, 
  args text[], 
  jsonbRow jsonb, 
  targetAttribute text,
  errorCode text,
  currentRowNb int,
  lastFirstRowID text,
  stopOnInvalidLocal boolean,
  stopOnInvalidGlobal boolean
)
RETURNS SETOF RECORD AS $$
  DECLARE
    logMsg text := '';
    localGlobal text;
  BEGIN
     IF errorType IN ('INVALID_PARAMETER', 'INVALID_TRANSLATION_PARAMETER') THEN
       logMsg = logMsg || 'Invalid parameter value passed to rule ''' || TT_TextFctQuery(fctName, args, jsonbRow, FALSE, TRUE) ||
                ''' for attribute ''' || targetAttribute || '''. Revise your translation table...';
       IF errorType = 'INVALID_PARAMETER' THEN
         logMsg = 'STOP ON INVALID PARAMETER: ' ||  logMsg;
       ELSE
         logMsg = 'STOP ON INVALID TRANSLATION PARAMETER: ' ||  logMsg;
       END IF;
       RAISE EXCEPTION '%', logMsg;
     ELSIF errorType IN ('INVALID_VALUE', 'TRANSLATION_ERROR') THEN
       logMsg = 'Rule ''' || TT_TextFctQuery(fctName, args, jsonbRow, FALSE, TRUE) ||
                ''' failed for attribute ''' || targetAttribute || 
                ''' and reported error code ''' || errorCode || '''...';
       IF stopOnInvalidLocal OR stopOnInvalidGlobal THEN
         IF stopOnInvalidLocal THEN
           localGlobal = 'LOCAL';
         ELSE
           localGlobal = 'GLOBAL';
         END IF;
         IF errorType  = 'INVALID_VALUE' THEN
           RAISE EXCEPTION '% STOP ON INVALID SOURCE VALUE at row #%: %', localGlobal, currentRowNb, logMsg;
         ELSE
           RAISE EXCEPTION '% STOP ON TRANSLATION ERROR at row #%: %', localGlobal, currentRowNb, logMsg;
         END IF;
       ELSIF NOT logTableName IS NULL THEN
         PERFORM TT_Log(translationTableSchema, logTableName, dupLogEntriesHandling, 
                        errorType, lastFirstRowID, logMsg, currentRowNb);
       ELSE
         RAISE NOTICE '% at row #%: %', errorType, currentRowNb, logMsg;
       END IF;
     ELSE
       RAISE EXCEPTION 'TT_ReportError() ERROR: Invalid error type...';
     END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- _TT_Translate
--
--   sourceTableSchema name      - Name of the schema containing the source table.
--   sourceTable name            - Name of the source table.
--   sourceRowIdColumn name      - Name of the source unique identifier column used 
--                                 for logging.
--   translationTableSchema name - Name of the schema containing the translation
--                                 table.
--   translationTable name       - Name of the translation table.
--   stopOnInvalidSource         - Boolean indicating if the engine should stop when
--                                 a source value is declared invalid
--   stopOnTranslationError      - Boolean indicating if the engine should stop when
--                                 the translation rule result into a NULL value
--   dupLogEntriesHandling       - Determine how logging handles invalid entries:
--                               - ALL_GROUPED: log all invalid entries grouped with 
--                               -              a count (slowest option).
--                               - ALL_OWN_ROW: log all invalid entries on their own 
--                               -              row (fastest option).
--                               - integer (as string): log a limited number of invalid.
--                               -                      entries grouped with a count.
--                               - Default is '100'.
--   logFrequency int            - Number of line to report progress in the log table.
--                                 Default to 500.
--   incrementLog                - Boolean indicating if log table names should be 
--                                 incremented or not. Default to TRUE.
--   resume                      - Boolean indicating if translation should resume 
--                                 from last execution. Default to FALSE.
--   ignoreDescUpToDateWithRules - Boolean indicating if translation engine should 
--                                 ignore rules that are not up to date with their 
--                                 descriptions and resume translation. Stop the 
--                                 translation engine otherwise. Default to FALSE.
--
--   RETURNS SETOF RECORDS
--
-- Translate a source table according to the rules defined in a tranlation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS _TT_Translate(name, name, name, name, name, boolean, boolean, text, int, boolean, boolean, boolean);
CREATE OR REPLACE FUNCTION _TT_Translate(
  sourceTableSchema name,
  sourceTable name,
  sourceRowIdColumn name,
  translationTableSchema name,
  translationTable name,
  stopOnInvalidSource boolean DEFAULT FALSE,
  stopOnTranslationError boolean DEFAULT FALSE,
  dupLogEntriesHandling text DEFAULT '100',
  logFrequency int DEFAULT 500,
  incrementLog boolean DEFAULT TRUE,
  resume boolean DEFAULT FALSE,
  ignoreDescUpToDateWithRules boolean DEFAULT FALSE
)
RETURNS SETOF RECORD AS $$
  DECLARE
    sourceRow RECORD;
    translationRow RECORD;
    translatedRow RECORD;
    rule TT_RuleDef;
    fctEvalQuery text;
    finalQuery text;
    finalVal text;
    isValid boolean;
    jsonbRow jsonb;
    currentRowNb int = 1;
    debug boolean = TT_Debug();
    debug_l3 boolean = TT_Debug(3); -- tt.debug_l3
    lastFirstRowID text;
    logTableName text;
    logMsg text;
    sourceRowWhere text = '';
    geomColName name;
    startTime timestamptz;
    attStartTime timestamptz;
    rowStartTime timestamptz;
    percentDone numeric;
    remainingSeconds int;
    expectedRowNb int;
  BEGIN
    startTime = clock_timestamp();
    -- Validate the existence of the source table. TODO
    -- Determine if we must resume from last execution or not. TODO
    -- FOR each row of the source table
    IF debug THEN RAISE NOTICE 'DEBUG ACTIVATED...';END IF;
    IF debug THEN RAISE NOTICE '_TT_Translate BEGIN';END IF;
    IF debug_l3 THEN RAISE NOTICE 'DEBUG LEVEL 3 ACTIVATED...';END IF;
--RAISE NOTICE '_TT_Translate BEGIN';
    -- initialize logging table
    IF sourceRowIdColumn IS NULL THEN
      RAISE NOTICE '_TT_Translate(): sourceRowIdColumn is NULL. No logging with be performed...';
    ELSE
      dupLogEntriesHandling = upper(dupLogEntriesHandling);
      IF NOT dupLogEntriesHandling IN ('ALL_GROUPED', 'ALL_OWN_ROW') AND NOT TT_IsInt(dupLogEntriesHandling) THEN
        RAISE EXCEPTION '_TT_Translate() ERROR: Invalid dupLogEntriesHandling parameter (%). Should be ''ALL_GROUPED'', ''ALL_OWN_ROW'' or a an integer...', dupLogEntriesHandling;
      END IF;
      logTableName = TT_LogInit(translationTableSchema, translationTable, sourceTable, incrementLog, dupLogEntriesHandling);
      IF logTableName = 'FALSE' THEN
        RAISE EXCEPTION '_TT_Translate() ERROR: Logging initialization failed...';
      END IF;
    END IF;
--RAISE NOTICE '_TT_Translate BEGIN2';

    -- Get the ROW_TRANSLATION_RULE if it exists
    SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable, TRUE)
    WHERE target_attribute = 'ROW_TRANSLATION_RULE' INTO translationRow;
    IF NOT translationRow IS NULL THEN
      sourceRowWhere = ' WHERE ';
--RAISE NOTICE '_TT_Translate 00 translationRow=%', translationRow;
      FOREACH rule IN ARRAY translationRow.validation_rules LOOP
--RAISE NOTICE '_TT_Translate 11 rule.args=%', rule.args;
        sourceRowWhere = sourceRowWhere || TT_RuleToSQL(rule.fctName, rule.args) || ' OR ';
--RAISE NOTICE '_TT_Translate 11 sourceRowWhere=%', sourceRowWhere;
      END LOOP;
      -- Remove the last 'OR'
      sourceRowWhere = left(sourceRowWhere, char_length(sourceRowWhere) - 4);
      RAISE NOTICE '_TT_Translate(): ROW_TRANSLATION_RULE is%', sourceRowWhere;
    END IF;
    
    -- Get the name of the geometry column if there is one
    geomColName = TT_GetGeomColName(sourceTableSchema, sourceTable);
    
    -- Estimate the number of rows to return
    RAISE NOTICE 'Computing the number of rows to translate... (%)', 'SELECT count(*) FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) || sourceRowWhere;

    EXECUTE 'SELECT count(*) FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) || sourceRowWhere
    INTO expectedRowNb;
    RAISE NOTICE '% ROWS TO TRANSLATE...', expectedRowNb;

    -- Main loop
    FOR sourceRow IN EXECUTE 'SELECT *' || coalesce(', ' || geomColName || ' sdt_geometry_col_name', '') || ' FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) || sourceRowWhere
    LOOP
       IF debug_l3 THEN rowStartTime = clock_timestamp();END IF;
       -- convert the row to a json object so we can pass it to TT_TextFctEval() (PostgreSQL does not allow passing RECORD to functions)
       jsonbRow = to_jsonb(sourceRow);
       -- Replace the geometry converted to jsonb by the WKB string
       IF NOT geomColName IS NULL THEN
         jsonbRow = jsonb_set(jsonbRow, '{wkb_geometry}', to_jsonb(sourceRow.sdt_geometry_col_name::text));
       END IF;
       
       -- identify the first rowid for logging
       IF NOT logTableName IS NULL AND currentRowNb % logFrequency = 1 THEN
         lastFirstRowID = jsonbRow->>sourceRowIdColumn;
       END IF;
       IF debug THEN RAISE NOTICE '_TT_Translate 11 sourceRow=%', jsonbRow;END IF;

       finalQuery = 'SELECT';
       -- iterate over each translation table row. One row per target attribute
       FOR translationRow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable, FALSE)
                             WHERE target_attribute != 'ROW_TRANSLATION_RULE' LOOP
         IF debug_l3 THEN attStartTime = clock_timestamp();END IF;
         IF debug THEN RAISE NOTICE '_TT_Translate 22 translationRow=%', translationRow;END IF;
         -- iterate over each validation rule
         isValid = TRUE;
         FOREACH rule IN ARRAY translationRow.validation_rules LOOP
           EXIT WHEN NOT isValid; -- exit the loop as soon as one rule is invalidated
           IF debug THEN RAISE NOTICE '_TT_Translate 33 rule=%', rule;END IF;
           -- evaluate the rule and catch errors
           BEGIN
             isValid = TT_TextFctEval(rule.fctName, rule.args, jsonbRow, NULL::boolean, FALSE);
           EXCEPTION WHEN OTHERS THEN
             PERFORM TT_ReportError('INVALID_PARAMETER', translationTableSchema, logTableName, dupLogEntriesHandling, 
                                    rule.fctName, rule.args, jsonbRow, translationRow.target_attribute, NULL,
                                    currentRowNb, lastFirstRowID, rule.stopOnInvalid, stopOnInvalidSource);
           END;
           IF debug THEN RAISE NOTICE '_TT_Translate 44 isValid=%', isValid;END IF;

           -- initialize the final value
           finalVal = rule.errorCode;
           
           -- report an error on invalid values
           IF NOT isValid AND (rule.stopOnInvalid OR stopOnInvalidSource OR NOT sourceRowIdColumn IS NULL) THEN
             PERFORM TT_ReportError('INVALID_VALUE', translationTableSchema, logTableName, dupLogEntriesHandling,
                                    rule.fctName, rule.args, jsonbRow, translationRow.target_attribute, finalVal,
                                    currentRowNb, lastFirstRowID, rule.stopOnInvalid, stopOnInvalidSource);
           END IF;
         END LOOP; -- FOREACH rule

         -- if all validation rule passed, execute the translation rule
         IF isValid THEN
           fctEvalQuery = 'SELECT TT_TextFctEval($1, $2, $3, NULL::' || translationRow.target_attribute_type || 
                   ', FALSE);';
           IF debug THEN RAISE NOTICE '_TT_Translate 77 fctEvalQuery=% with fctName=%, args=% and jsonbRow=%', fctEvalQuery, (translationRow.translation_rule).fctName, (translationRow.translation_rule).args, jsonbRow;END IF;
           BEGIN
             EXECUTE fctEvalQuery
             USING (translationRow.translation_rule).fctName, (translationRow.translation_rule).args, jsonbRow
             INTO STRICT finalVal;
           EXCEPTION WHEN OTHERS THEN
             PERFORM TT_ReportError('INVALID_TRANSLATION_PARAMETER', translationTableSchema, logTableName, dupLogEntriesHandling, 
                                    (translationRow.translation_rule).fctName, (translationRow.translation_rule).args, jsonbRow, translationRow.target_attribute, NULL,
                                    currentRowNb, lastFirstRowID, (translationRow.translation_rule).stopOnInvalid, 
                                    stopOnInvalidSource);
           END;

           IF debug THEN RAISE NOTICE '_TT_Translate 88 finalVal=%', finalVal;END IF;

           IF finalVal IS NULL THEN
             -- determine the proper error code
             IF (translationRow.translation_rule).errorCode IS NULL THEN -- if no error code provided, use the defaults
               IF translationRow.target_attribute_type IN ('text', 'char', 'character', 'varchar', 'character varying') THEN
                 finalVal = 'TRANSLATION_ERROR';
               ELSE
                 finalVal = -3333;
               END IF;
             ELSE -- if translation error code provided, return it
               finalVal = (translationRow.translation_rule).errorCode;
             END IF;
             PERFORM TT_ReportError('TRANSLATION_ERROR', translationTableSchema, logTableName, dupLogEntriesHandling,
                                    (translationRow.translation_rule).fctName, (translationRow.translation_rule).args, 
                                    jsonbRow, translationRow.target_attribute, finalVal,
                                    currentRowNb, lastFirstRowID, (translationRow.translation_rule).stopOnInvalid, 
                                    stopOnInvalidSource);
           END IF;
         END IF;
         -- Built the return query while computing values
         finalQuery = finalQuery || ' ''' || finalVal || '''::'  || translationRow.target_attribute_type || ',';
         IF debug THEN RAISE NOTICE '_TT_Translate AA finalVal=%, translationRow.target_attribute_type=%, finalQuery=%', finalVal, translationRow.target_attribute_type, finalQuery;END IF;
         IF debug_l3 THEN RAISE NOTICE '% computing time: % s', translationRow.target_attribute, EXTRACT(EPOCH FROM clock_timestamp() - attStartTime);END IF;
       END LOOP; -- FOR TRANSLATION ROW

       -- Execute the final query building the returned RECORD
       finalQuery = left(finalQuery, char_length(finalQuery) - 1);
       IF debug THEN RAISE NOTICE '_TT_Translate BB finalQuery=%', finalQuery;END IF;
       EXECUTE finalQuery INTO translatedRow;
       RETURN NEXT translatedRow;

       -- log progress
       IF NOT logTableName IS NULL AND currentRowNb % logFrequency = 0 THEN
         PERFORM TT_Log(translationTableSchema, logTableName, dupLogEntriesHandling, 
                'PROGRESS', lastFirstRowID, currentRowNb || ' rows processed...', currentRowNb, logFrequency);
       END IF;
       IF currentRowNb % 10 = 0 THEN
         percentDone = currentRowNb::numeric/expectedRowNb*100;
         remainingSeconds = (100 - percentDone)*(EXTRACT(EPOCH FROM clock_timestamp() - startTime))/percentDone;
         RAISE NOTICE '%/% rows translated (% %%) - % remaining...', currentRowNb, expectedRowNb, round(percentDone, 3), 
              TT_PrettyDuration(remainingSeconds);
       END IF;
       IF debug_l3 THEN RAISE NOTICE 'ROW computing time: % s', EXTRACT(EPOCH FROM clock_timestamp() - rowStartTime);END IF;
       IF debug_l3 THEN RAISE NOTICE '---------------------------';END IF;
       currentRowNb = currentRowNb + 1;
       
    END LOOP; -- FOR sourceRow
    -- log progress
    currentRowNb = currentRowNb - 1;
    IF NOT logTableName IS NULL AND currentRowNb % logFrequency != 0 THEN
      PERFORM TT_Log(translationTableSchema, logTableName, dupLogEntriesHandling,
              'PROGRESS', lastFirstRowID, currentRowNb || ' rows processed...', currentRowNb, currentRowNb % logFrequency);
    END IF;
    RAISE NOTICE 'TOTAL TIME: %', TT_PrettyDuration(EXTRACT(EPOCH FROM clock_timestamp() - startTime)::int);

    IF debug THEN RAISE NOTICE '_TT_Translate END';END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------
-- TT_Prepare2
--
--   translationTableSchema name    - Name of the schema containing the 
--                                    translation table.
--   translationTable name          - Name of the translation table.
--   fctName name                   - Name of the function to create. Default to
--                                    'TT_Translate'.
--   refTranslationTableSchema name - Name of the schema containing the reference 
--                                    translation table.
--   refTranslationTable name       - Name of the reference translation table.
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
--DROP FUNCTION IF EXISTS TT_Prepare2(name, name, text, name, name);
CREATE OR REPLACE FUNCTION TT_Prepare2(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text,
  refTranslationTableSchema name,
  refTranslationTable name
)
RETURNS text AS $f$
  DECLARE
    query text;
    translationQuery text;
		rowTranslationRuleClause text;
		returnQuery text;
    translationRow RECORD;
    rule TT_RuleDef;
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
    query = 'SELECT array_agg(target_attribute || '' '' || target_attribute_type ORDER BY rule_id::int) ' ||
            'FROM ' || TT_FullTableName(translationTableSchema, translationTable) || 
           ' WHERE target_attribute != ''ROW_TRANSLATION_RULE'';';
    EXECUTE query INTO STRICT paramlist;

    IF TT_NotEmpty(refTranslationTableSchema) AND TT_NotEmpty(refTranslationTable) THEN
      -- Build the list of attribute names and types for the reference table
      query = 'SELECT array_agg(target_attribute || '' '' || target_attribute_type ORDER BY rule_id::int) ' ||
              'FROM ' || TT_FullTableName(refTranslationTableSchema, refTranslationTable) || 
             ' WHERE target_attribute != ''ROW_TRANSLATION_RULE'';';
      EXECUTE query INTO STRICT refParamlist;

      IF cardinality(paramlist) < cardinality(refParamlist) THEN
        RAISE EXCEPTION 'TT_Prepare() ERROR: Translation table ''%.%'' has less attributes than reference table ''%.%''...', translationTableSchema, translationTable, refTranslationTableSchema, refTranslationTable;
      ELSIF cardinality(paramlist) > cardinality(refParamlist) THEN
        RAISE EXCEPTION 'TT_Prepare() ERROR: Translation table ''%.%'' has more attributes than reference table ''%.%''...', translationTableSchema, translationTable, refTranslationTableSchema, refTranslationTable;
      ELSIF TT_LowerArr(paramlist) != TT_LowerArr(refParamlist) THEN
        FOR i IN 1..cardinality(paramlist) LOOP
          IF paramlist[i] != refParamlist[i] THEN
            RAISE EXCEPTION 'TT_Prepare() ERROR: Translation table ''%.%'' attribute ''%'' is different from reference table ''%.%'' attribute ''%''...', translationTableSchema, translationTable, paramlist[i], refTranslationTableSchema, refTranslationTable, refParamlist[i];
          END IF;
        END LOOP;
      END IF;
    END IF;

    -- Drop any existing TT_Translate function with the same suffix
    query = 'DROP FUNCTION IF EXISTS TT_Translate' || coalesce(fctNameSuf, '') || '(name, name, name, boolean, boolean, text, int, boolean, boolean, boolean);';
    EXECUTE query;
    
    -- Build the translation query
    translationQuery = 'SELECT ' || CHR(10);
		rowTranslationRuleClause = 'WHERE ';
		FOR translationRow IN SELECT * FROM TT_ValidateTTable(translationTableSchema, translationTable, FALSE)
    LOOP
      IF translationRow.target_attribute != 'ROW_TRANSLATION_RULE' THEN
        translationQuery = translationQuery || '  CASE ' || CHR(10);
      END IF;
		  -- Build the validation part and the ROW_TRANSLATION_RULE part at the same time
      FOREACH rule IN ARRAY translationRow.validation_rules 
			LOOP
			  IF translationRow.target_attribute = 'ROW_TRANSLATION_RULE' THEN
          rowTranslationRuleClause = rowTranslationRuleClause || TT_RuleToSQL(rule.fctName, rule.args) || ' OR ' || CHR(10);
				ELSE
          translationQuery = translationQuery || '    WHEN NOT ' || TT_RuleToSQL(rule.fctName, rule.args) || ' THEN ''' || coalesce(rule.errorCode, TT_DefaultProjectErrorCode(rule.fctName, translationRow.target_attribute_type)) || '''' || CHR(10);
	      END IF;
		  END LOOP; -- FOREACH rule
			
		  -- Build the translation part
      translationQuery = translationQuery || '    ELSE coalesce(' || 
			                   TT_RuleToSQL((translationRow.translation_rule).fctName, (translationRow.translation_rule).args) || 
												 ', ''' || coalesce((translationRow.translation_rule).errorCode, 
												          CASE WHEN translationRow.target_attribute_type IN ('text', 'char', 'character', 'varchar', 'character varying') THEN 'TRANSLATION_ERROR'
                                       ELSE  '-3333'
															    END) || ''') ' || CHR(10) || 
												 '  END::' || lower(translationRow.target_attribute_type) || ' ' || lower(translationRow.target_attribute) || ',' || CHR(10);
			
    END LOOP; -- FOR TRANSLATION ROW
		-- Remove the last comma from translationQuery and complete
		translationQuery = left(translationQuery, char_length(translationQuery) - 2);

		-- Remove the last 'OR' from rowTranslationRuleClause
		IF rowTranslationRuleClause = 'WHERE ' THEN
		   rowTranslationRuleClause = '';
		ELSE
      rowTranslationRuleClause = left(rowTranslationRuleClause, char_length(rowTranslationRuleClause) - 4);
    END IF;

    query = 'CREATE OR REPLACE FUNCTION TT_Translate' || coalesce(fctNameSuf, '') || '(
               sourceTableSchema name,
               sourceTable name,
               sourceTableIdColumn name DEFAULT NULL,
               stopOnInvalidSource boolean DEFAULT FALSE,
               stopOnTranslationError boolean DEFAULT FALSE,
               dupLogEntriesHandling text DEFAULT ''100'',
               logFrequency int DEFAULT 500,
               incrementLog boolean DEFAULT TRUE,
               resume boolean DEFAULT FALSE,
               ignoreDescUpToDateWithRules boolean DEFAULT FALSE
             )
             RETURNS TABLE (' || array_to_string(paramlist, ', ') || ') AS $$
             BEGIN
               RETURN QUERY SELECT * FROM _TT_Translate2(' || quote_literal(translationQuery) || ', ' ||
							                                          quote_literal(rowTranslationRuleClause) || ', 
																												sourceTableSchema,
                                                        sourceTable,
                                                        sourceTableIdColumn, ' ||
                                                        '''' || translationTableSchema || ''', ' ||
                                                        '''' || translationTable || ''', 
                                                        stopOnInvalidSource,
                                                        stopOnTranslationError,
                                                        dupLogEntriesHandling, 
                                                        logFrequency,
                                                        incrementLog,
                                                        resume,
                                                        ignoreDescUpToDateWithRules) AS t(' || array_to_string(paramlist, ', ') || ');
               RETURN;
             END;
             $$ LANGUAGE plpgsql VOLATILE;';
    EXECUTE query;

    RETURN 'SELECT * FROM TT_Translate' || coalesce(fctNameSuf, '') || '(''schemaName'', ''tableName'', ''uniqueIDColumn'');';

		--RETURN translationQuery || CHR(10) || 'FROM rawfri.ab06_l1_to_ab_l1_map_100' || CHR(10) || rowTranslationRuleClause || ';';

  END;
$f$ LANGUAGE plpgsql VOLATILE;

------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare2(name, name, text, name);
CREATE OR REPLACE FUNCTION TT_Prepare2(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text,
  refTranslationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare2(translationTableSchema, translationTable, fctNameSuf, translationTableSchema, refTranslationTable);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare2(name, name, text);
CREATE OR REPLACE FUNCTION TT_Prepare2(
  translationTableSchema name,
  translationTable name,
  fctNameSuf text
)
RETURNS text AS $$
  SELECT TT_Prepare2(translationTableSchema, translationTable, fctNameSuf, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_Prepare2(name, name);
CREATE OR REPLACE FUNCTION TT_Prepare2(
  translationTableSchema name,
  translationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare2(translationTableSchema, translationTable, NULL, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Prepare2(
  translationTable name
)
RETURNS text AS $$
  SELECT TT_Prepare2('public', translationTable, NULL::text, NULL::name, NULL::name);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- _TT_Translate2
--
--   sourceTableSchema name      - Name of the schema containing the source table.
--   sourceTable name            - Name of the source table.
--   sourceRowIdColumn name      - Name of the source unique identifier column used 
--                                 for logging.
--   translationTableSchema name - Name of the schema containing the translation
--                                 table.
--   translationTable name       - Name of the translation table.
--   stopOnInvalidSource         - Boolean indicating if the engine should stop when
--                                 a source value is declared invalid
--   stopOnTranslationError      - Boolean indicating if the engine should stop when
--                                 the translation rule result into a NULL value
--   dupLogEntriesHandling       - Determine how logging handles invalid entries:
--                               - ALL_GROUPED: log all invalid entries grouped with 
--                               -              a count (slowest option).
--                               - ALL_OWN_ROW: log all invalid entries on their own 
--                               -              row (fastest option).
--                               - integer (as string): log a limited number of invalid.
--                               -                      entries grouped with a count.
--                               - Default is '100'.
--   logFrequency int            - Number of line to report progress in the log table.
--                                 Default to 500.
--   incrementLog                - Boolean indicating if log table names should be 
--                                 incremented or not. Default to TRUE.
--   resume                      - Boolean indicating if translation should resume 
--                                 from last execution. Default to FALSE.
--   ignoreDescUpToDateWithRules - Boolean indicating if translation engine should 
--                                 ignore rules that are not up to date with their 
--                                 descriptions and resume translation. Stop the 
--                                 translation engine otherwise. Default to FALSE.
--
--   RETURNS SETOF RECORDS
--
-- Translate a source table according to the rules defined in a tranlation table.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS _TT_Translate2(name, name, name, name, name, boolean, boolean, text, int, boolean, boolean, boolean);
CREATE OR REPLACE FUNCTION _TT_Translate2(
  translationQuery text,
	rowTranslationRuleClause text,
  sourceTableSchema name,
  sourceTable name,
  sourceRowIdColumn name,
  translationTableSchema name,
  translationTable name,
  stopOnInvalidSource boolean DEFAULT FALSE,
  stopOnTranslationError boolean DEFAULT FALSE,
  dupLogEntriesHandling text DEFAULT '100',
  logFrequency int DEFAULT 500,
  incrementLog boolean DEFAULT TRUE,
  resume boolean DEFAULT FALSE,
  ignoreDescUpToDateWithRules boolean DEFAULT FALSE
)
RETURNS SETOF RECORD AS $$
  DECLARE
    sourceRow RECORD;
    translationRow RECORD;
    translatedRow RECORD;
    rule TT_RuleDef;
    fctEvalQuery text;
    finalQuery text;
    finalVal text;
    isValid boolean;
    jsonbRow jsonb;
    currentRowNb int = 1;
    debug boolean = TT_Debug();
    debug_l3 boolean = TT_Debug(3); -- tt.debug_l3
    lastFirstRowID text;
    logTableName text;
    logMsg text;
    sourceRowWhere text = '';
    geomColName name;
    startTime timestamptz;
    attStartTime timestamptz;
    rowStartTime timestamptz;
    percentDone numeric;
    remainingSeconds int;
    expectedRowNb int;
  BEGIN
    startTime = clock_timestamp();
    -- Validate the existence of the source table. TODO
    -- Determine if we must resume from last execution or not. TODO
    -- FOR each row of the source table
    IF debug THEN RAISE NOTICE 'DEBUG ACTIVATED...';END IF;
    IF debug THEN RAISE NOTICE '_TT_Translate BEGIN';END IF;
    IF debug_l3 THEN RAISE NOTICE 'DEBUG LEVEL 3 ACTIVATED...';END IF;
--RAISE NOTICE '_TT_Translate BEGIN';

    -- Initialize logging table
    IF sourceRowIdColumn IS NULL THEN
      RAISE NOTICE '_TT_Translate(): sourceRowIdColumn is NULL. No logging with be performed...';
    ELSE
      dupLogEntriesHandling = upper(dupLogEntriesHandling);
      IF NOT dupLogEntriesHandling IN ('ALL_GROUPED', 'ALL_OWN_ROW') AND NOT TT_IsInt(dupLogEntriesHandling) THEN
        RAISE EXCEPTION '_TT_Translate() ERROR: Invalid dupLogEntriesHandling parameter (%). Should be ''ALL_GROUPED'', ''ALL_OWN_ROW'' or a an integer...', dupLogEntriesHandling;
      END IF;
      logTableName = TT_LogInit(translationTableSchema, translationTable, sourceTable, incrementLog, dupLogEntriesHandling);
      IF logTableName = 'FALSE' THEN
        RAISE EXCEPTION '_TT_Translate() ERROR: Logging initialization failed...';
      END IF;
    END IF;
--RAISE NOTICE '_TT_Translate BEGIN2';

    -- Estimate the number of rows to return
    RAISE NOTICE 'Computing the number of rows to translate... (%)', 'SELECT count(*) FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) || rowTranslationRuleClause;

    EXECUTE 'SELECT count(*) FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) || rowTranslationRuleClause
    INTO expectedRowNb;
    RAISE NOTICE '% ROWS TO TRANSLATE...', expectedRowNb;

    -- Main loop
		FOR sourceRow IN EXECUTE translationQuery || CHR(10) || 'FROM ' || TT_FullTableName(sourceTableSchema, sourceTable) || CHR(10) || rowTranslationRuleClause
		LOOP
       -- Identify the first rowid for logging
       IF NOT logTableName IS NULL AND currentRowNb % logFrequency = 1 THEN
         lastFirstRowID = sourceRow.std_rowid_col_name;
       END IF;
       finalQuery = 'SELECT';
       IF debug THEN RAISE NOTICE '_TT_Translate 22 translationRow=%', translationRow;END IF;
       IF currentRowNb % 10 = 0 THEN
         percentDone = currentRowNb::numeric/expectedRowNb*100;
         remainingSeconds = (100 - percentDone)*(EXTRACT(EPOCH FROM clock_timestamp() - startTime))/percentDone;
         RAISE NOTICE '%/% rows translated (% %%) - % remaining...', currentRowNb, expectedRowNb, round(percentDone, 3), 
              TT_PrettyDuration(remainingSeconds);
       END IF;
       currentRowNb = currentRowNb + 1;
			 RETURN NEXT sourceRow;
  		END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;