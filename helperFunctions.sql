------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Helper functions uninstallation file
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
-- Begin Validation Function Definitions...
-- Validation functions return only boolean values (TRUE or FALSE).
-------------------------------------------------------------------------------
-- TT_NotNull
--
--  var any  - Variable to test for NOT NULL.
--
-- Return TRUE if var is not NULL.
------------------------------------------------------------
-- Pierre Racine
-- 29/01/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNull(
  var anyelement
)
RETURNS boolean AS $$
  BEGIN
    RETURN var IS NOT NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Between
--
-- var double precision/int  - Variable to test.
-- min double precision  - Minimum.
-- max double precision  - Maximum.
--
-- Function overloading - make two versions named the same, one for int one for double precision. Postgres will choose the version based on input values.
--
-- Return TRUE if var is between min and max.
------------------------------------------------------------
-- Pierre Racine
-- 29/01/2019 added in v0.1
-- Edited by Marc Edwards - 11/2/2019
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Between(
  var int,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    RETURN var > min and var < max;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  var double precision,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    RETURN var > min and var < max;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotEmpty
--
--  var text  - Variable to test for empty string.
--
-- Return TRUE if var is not empty.
-- Return FALSE if var is empty string or padded spaces (e.g. '' or '  ').
-- Return NULL if input NULL
------------------------------------------------------------
-- Marc Edwards
-- 4/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   var text
)
RETURNS boolean AS $$
  DECLARE
    x text
  BEGIN
    x := TRIM(var); -- trim removes any spaces before evaluating string.
    IF x = '' IS FALSE THEN 
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

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
-- Marc Edwards
-- 6/02/2019 added in v0.1
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
-- Marc Edwards
-- 6/02/2019 added in v0.1
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
-- TT_IsInt
--
--  var numeric - Variable to test.
--  Must be numeric but cannot be decimal.
--  Does not currently deal with bigint or smallint.
--  Returns NULL if any argument NULL
--  Uses function overloading (https://www.postgresql.org/docs/9.6/xfunc-overload.html) to create two versions of the function with the same name. Postgres will select whichever matches the provided type.
------------------------------------------------------------
-- Marc Edwards
-- 7/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
   var double precision
)
RETURNS boolean AS $$
  BEGIN
    IF pg_typeof(var) = 'integer'::regtype THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION TT_IsInt(
   var int
)
RETURNS boolean AS $$
  BEGIN
    IF pg_typeof(var) = 'integer'::regtype THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
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
-- TT_MatchStr  --  ***FIX***
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
DROP FUNCTION IF EXISTS TT_MatchStr(text,text,name,name);
CREATE OR REPLACE FUNCTION TT_MatchStr(
  var text,
  lookup_col text,
  lookup_tab name,
  lookup_sch name
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    query = 'SELECT ' || var || ' IN (SELECT ' || lookup_col || ' FROM ' || TT_FullTableName(lookup_sch, lookup_tab) || ')';
    RAISE NOTICE '11 query = %',query;
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
-- Marc Edwards
-- 11/02/2019 added in v0.1
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
-- Pierre Racine
-- 31/01/2019 added in v0.1
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
-- Marc Edwards
-- 14/02/2019 added in v0.1
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