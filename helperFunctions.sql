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
--  var int  - Variable to test.
--  min int  - Minimum.
--  max int  - Maximum.
--
-- Return TRUE if var is between min and max.
------------------------------------------------------------
-- Pierre Racine
-- 29/01/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Between(
  var int,
  min int,
  max int
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
------------------------------------------------------------
-- Marc Edwards
-- 4/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   var text
)
RETURNS boolean AS $$
  BEGIN
    IF TRIM(var) = '' IS FALSE THEN -- trim removes any spaces before evaluating string.
      RETURN TRUE;
    END IF;
    IF TRIM(var) = '' IS TRUE THEN
      RETURN FALSE;
    END IF;
    IF TRIM(var) = '' IS NULL THEN
      RETURN NULL;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GreaterThan
--
--  var decimal - Variable to test.
--  lowerBound decimal - lower bound to test against
--  inclusive boolean - is lower bound inclusive? Default True
--
-- Return TRUE if var >= lowerBound and inclusive = TRUE.
-- Return TRUE if var > lowerBound and inclusive = FALSE.
-- Return FALSE otherwise.
------------------------------------------------------------
-- Marc Edwards
-- 6/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GreaterThan(
   var anyelement,
   lowerBound decimal,
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
--  var decimal - Variable to test.
--  upperBound decimal - upper bound to test against
--  inclusive boolean - is upper bound inclusive? Default True
--
-- Return TRUE if var <= lowerBound and inclusive = TRUE.
-- Return TRUE if var < lowerBound and inclusive = FALSE.
-- Return FALSE otherwise.
------------------------------------------------------------
-- Marc Edwards
-- 6/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LessThan(
   var anyelement,
   upperBound decimal,
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
--  Note NULL can pass this test. Use IsNull to catch null values.
------------------------------------------------------------
-- Marc Edwards
-- 7/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
   var numeric
)
RETURNS boolean AS $$
  BEGIN
    IF pg_typeof(var) = 'integer'::regtype THEN
      RETURN TRUE;
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
--  Note NULL can pass this test. Use IsNull to catch null values.
------------------------------------------------------------
-- Marc Edwards
-- 7/02/2019 added in v0.1
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   var numeric
)
RETURNS boolean AS $$
  BEGIN
    IF pg_typeof(var) = 'integer'::regtype THEN
      RETURN TRUE;
    ELSIF pg_typeof(var) = 'numeric'::regtype THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
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