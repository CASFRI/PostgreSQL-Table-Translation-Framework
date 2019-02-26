------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Helper functions installation file
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
--
--
-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-- Validation functions return only boolean values (TRUE or FALSE).
-------------------------------------------------------------------------------
-- TT_NotNull
--
--  var text/boolean/double precision/int  - Value to test for NOT NULL.
--
-- Return TRUE if val is not NULL.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNull(
  val text
)
RETURNS boolean AS $$
  BEGIN
    RETURN val IS NOT NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val double precision
)
RETURNS boolean AS $$
  BEGIN
    RETURN val IS NOT NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val boolean
)
RETURNS boolean AS $$
  SELECT TT_NotNull(val::text);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val int
)
RETURNS boolean AS $$
  SELECT TT_NotNull(val::double precision);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotEmpty
--
--  val text  - Value to test for empty string.
--
-- Return TRUE if val is not empty.
-- Return FALSE if val is empty string or padded spaces (e.g. '' or '  ') or Null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   val text
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    val = TRIM(val); -- trim removes any spaces before evaluating string.
    IF val IS NULL OR val = '' THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE; 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsInt
--
--  val double precision/int/text - Value to test
--  Must be numeric but cannot be decimal
--  Null values return FALSE
--  Strings with numeric characters and '.' will be passed to IsInt
--  Strings with anything else (e.g. letter characters) return FALSE.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
   val double precision
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NOT NULL THEN
      RETURN val - val::int = 0;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsInt(
   val int
)
RETURNS boolean AS $$
  SELECT TT_IsInt(val::double precision);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsInt(
   val text
)
RETURNS boolean AS $$
  DECLARE
    x double precision;
  BEGIN
    x = val::double precision;
    RETURN TT_IsInt(val::double precision);
  EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNumeric
--
--  val double precision/int/text - Value to test.
--  Must be numeric, can be decimal, can be integer.
--  Null values return FALSE
--  Strings with numeric characters and '.' will be passed to IsNumeric
--  Strings with anything else (e.g. letter characters) return FALSE.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val text
)
  RETURNS boolean AS $$
    DECLARE
      x double precision;
    BEGIN
      IF val IS NOT NULL THEN
        x = val::double precision;
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
    END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val int
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(val::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val double precision
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(val::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Between
--
-- val double precision/int  - Value to test.
-- min double precision  - Minimum.
-- max double precision  - Maximum.
--
-- Return TRUE if var is between min and max.
-- Return FALSE otherwise.
-- Return FALSE if val is NULL.
-- Return error if min or max are null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Between(
  val double precision,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    IF min IS NULL OR max IS NULL THEN
      RAISE EXCEPTION 'min or max is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN val > min and val < max;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val int,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  SELECT TT_Between(val::double precision,min,max);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GreaterThan
--
--  val double precision/int - Value to test.
--  lowerBound double precision - lower bound to test against
--  inclusive boolean - is lower bound inclusive? Default True
--
--  Return TRUE if val >= lowerBound and inclusive = TRUE.
--  Return TRUE if val > lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if lowerBound or inclusive are null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GreaterThan(
   val double precision,
   lowerBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF lowerBound IS NULL OR inclusive IS NULL THEN
      RAISE EXCEPTION 'lowerBound or inclusive is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF inclusive = TRUE THEN
      RETURN val >= lowerBound;
    ELSE
      RETURN val > lowerBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GreaterThan(
   val int,
   lowerBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  SELECT TT_GreaterThan(val::double precision,lowerBound,inclusive);
$$ LANGUAGE sql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LessThan
--
--  val double precision/int - Value to test.
--  upperBound double precision - upper bound to test against
--  inclusive boolean - is upper bound inclusive? Default True
--
--  Return TRUE if val <= upperBound and inclusive = TRUE.
--  Return TRUE if val < upperBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if upperBound or inclusive are null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LessThan(
   val double precision,
   upperBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF upperBound IS NULL OR inclusive IS NULL THEN
      RAISE EXCEPTION 'upperBound or inclusive is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF inclusive = TRUE THEN
      RETURN val <= upperBound;
    ELSE
      RETURN val < upperBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LessThan(
   val int,
   upperBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  SELECT TT_LessThan(val::double precision,upperBound,inclusive);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Match (table version)                     -    why does this return true? Would expect it to fail due to incompatable types... SELECT TT_Match('1.1'::text, 'public'::name, 'test_lookuptable3'::name);
--
-- val text/double precision/int - column to test.
-- lookupSchemaName name - schema name holding lookup table
-- lookupTableName name - lookup table
-- if val is present in first column of lookup table, returns TRUE.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_Match(text,name,name);
-- DROP FUNCTION IF EXISTS TT_Match(double precision,name,name);
-- DROP FUNCTION IF EXISTS TT_Match(integer,name,name);
CREATE OR REPLACE FUNCTION TT_Match(
  val text,
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF val IS NOT NULL THEN
      query = 'SELECT ' || quote_literal(val) || ' IN (SELECT ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val double precision,
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF val IS NOT NULL THEN
      query = 'SELECT ' || val || ' IN (SELECT ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val int,
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  SELECT TT_Match(val::double precision,lookupSchemaName,lookupTableName)
$$ LANGUAGE sql VOLATILE;

-------------------------------------------------------------------------------
-- TT_Match (list version) - does first argument match any of the following arguments?

--
-- var text/double precision/int - value to test.
-- lst text/double precision/int - list to test against
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Match(
  val text,
  VARIADIC lst text[]
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NOT NULL THEN
      RETURN val = ANY(array_remove(lst, NULL));
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val double precision,
  VARIADIC lst double precision[]
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NOT NULL THEN
      RETURN val = ANY(array_remove(lst, NULL));
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val integer,
  VARIADIC lst integer[]
)
RETURNS boolean AS $$
  SELECT TT_Match(val::double precision, VARIADIC lst::double precision[])
$$ LANGUAGE sql VOLATILE;

------------------------------------------------------------
-- Begin Translation Function Definitions...
-- Translation functions return any kind of value (not only boolean).
-------------------------------------------------------------------------------
-- TT_Copy
--
--  val text/boolean/double precision/int  - Value to return.
--
-- Return the value.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Copy(
  val text
)
RETURNS text AS $$
  BEGIN
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Copy(
  val double precision
)
RETURNS double precision AS $$
  BEGIN
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Copy(
  val int
)
RETURNS int AS $$
  SELECT TT_Copy(val::double precision)::int
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Copy(
  val boolean
)
RETURNS boolean AS $$
  SELECT TT_Copy(val::text)::boolean
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Concat
--
--  sep text  - Separator (e.g. '_'). If no sep required use '' as first argument.
--  var text[] - list of strings to concat
--
-- Return the value.
-- Returns NULL if any argument NULL
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  sep text,
  VARIADIC var text[]
)
RETURNS text AS $$
  BEGIN
    IF sep is NULL OR coalesce(array_position(var, NULL::text), 0) > 0 THEN -- with VARIADIC, STRICT only returns NULL if entire array returns NULL. So need to manually return NULL if a single array element is NULL.
      RAISE EXCEPTION 'null values present';
    ELSE
      RETURN array_to_string(var, sep);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------