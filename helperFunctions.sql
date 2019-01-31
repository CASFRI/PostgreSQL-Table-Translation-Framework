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
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
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
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
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
-- Begin Translation Function Definitions...
-- Translation functions return any kind of value (not only boolean).
-------------------------------------------------------------------------------
-- TT_Copy
--
--  var any  - Variable to return.
--
-- Return the value.
------------------------------------------------------------
-- Pierre Racine (pierre.racine@sbf.ulaval.ca)
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

