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
-- Return TRUE if val is not empty or if val is Null.
-- Return FALSE if val is empty string or padded spaces (e.g. '' or '  ').
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   val text
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    val = TRIM(val); -- trim removes any spaces before evaluating string.
    IF val IS NULL THEN
      RETURN TRUE;
    ELSEIF val != '' THEN 
      RETURN TRUE;
    ELSE
      RETURN FALSE;
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
  BEGIN
    IF val ~ '^[0-9\.]+$' THEN
      RETURN TT_IsInt(val::double precision);
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNumeric
--
--  var numeric - Variable to test.
--  Must be numeric, can be decimal, can be integer.
--  Returns NULL if any argument NULL
------------------------------------------------------------
-- Marc Edwards
-- 7/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   var double precision
)
RETURNS boolean AS $$
  BEGIN
    IF pg_typeof(var) = ANY ('{smallint, bigint, integer, double precision, real, numeric, decimal}'::regtype[]) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   var int
)
RETURNS boolean AS $$
  BEGIN
    IF pg_typeof(var) = ANY ('{smallint, bigint, integer, double precision, real, numeric, decimal}'::regtype[]) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
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
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Between(
  val double precision,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NOT NULL AND min IS NOT NULL AND max IS NOT NULL THEN
      RETURN val > min and val < max;
    ELSE
      RETURN FALSE;
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
--  var double precision/int - Variable to test.
--  lowerBound double precision - upper bound to test against
--  inclusive boolean - is upper bound inclusive? Default True
--  
--  Function overloading - make two versions named the same, one for int one for double precision. Postgres will choose the version based on input values.
--
--  Return TRUE if var >= lowerBound and inclusive = TRUE.
--  Return TRUE if var > lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GreaterThan(
   var double precision,
   lowerBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF inclusive = TRUE THEN
      RETURN var >= lowerBound;
    ELSE
      RETURN var > lowerBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GreaterThan(
   var int,
   lowerBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF inclusive = TRUE THEN
      RETURN var >= lowerBound;
    ELSE
      RETURN var > lowerBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LessThan
--
--  var double precision/int - Variable to test.
--  upperBound double precision - upper bound to test against
--  inclusive boolean - is upper bound inclusive? Default True
--  
--  Function overloading - make two versions named the same, one for int one for double precision. Postgres will choose the version based on input values.
--
--  Return TRUE if var <= lowerBound and inclusive = TRUE.
--  Return TRUE if var < lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LessThan(
   var double precision,
   upperBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF inclusive = TRUE THEN
      RETURN var <= upperBound;
    ELSE
      RETURN var < upperBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LessThan(
   var int,
   upperBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF inclusive = TRUE THEN
      RETURN var <= upperBound;
    ELSE
      RETURN var < upperBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchStr -- change to TT_Match
--
-- looks up string in table column
-- var text - column to test.
-- lookup_col text - lookup column in species table
-- lookup_tab name - table name of species table
-- lookup_sch name - schema name holding species table
------------------------------------------------------------
-- Marc Edwards
-- 11/02/2019 added in v0.1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_MatchStr(text,name,name);
CREATE OR REPLACE FUNCTION TT_MatchStr(
  var text,
  lookupCol text, -- drop
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    query = 'SELECT ' || quote_literal(var) || ' IN (SELECT ' || quote_ident(lookupCol) || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
    EXECUTE query INTO return;
    RETURN return;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------
-- TT_MatchStr
--
-- looks up string array
-- var text - string to test.
-- vat text[] - array.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchStr(
  var text,
  lst text[]
)
RETURNS boolean AS $$
  BEGIN
    RETURN var = ANY(lst);
  END;
$$ LANGUAGE plpgsql VOLATILE;

------------------------------------------------------------
-- Begin Translation Function Definitions...
-- Translation functions return any kind of value (not only boolean).
-------------------------------------------------------------------------------
-- TT_Copy
--
--  var any  - Variable to return.
--
-- Return the value.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Copy(
  var anyelement
)
RETURNS anyelement AS $$
  BEGIN
    RETURN var;
  END;
$$ LANGUAGE plpgsql VOLATILE;
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
    IF coalesce(array_position(var, NULL::text), 0) > 0 THEN -- with VARIADIC, STRICT only returns NULL if entire array returns NULL. So need to manually return NULL if a single array element is NULL.
      RETURN NULL;
    ELSE
      RETURN array_to_string(var, sep);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
-------------------------------------------------------------------------------