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
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_NotNull(anyelement);
DROP FUNCTION IF EXISTS TT_Between(int, int, int);
DROP FUNCTION IF EXISTS TT_Copy(anyelement);
DROP FUNCTION IF EXISTS TT_NotEmpty(text);
DROP FUNCTION IF EXISTS TT_GreaterThan(decimal, decimal, boolean);
DROP FUNCTION IF EXISTS TT_GreaterThan(int, int, boolean);
DROP FUNCTION IF EXISTS TT_LessThan(decimal, decimal, boolean);
DROP FUNCTION IF EXISTS TT_LessThan(int, int, boolean);
DROP FUNCTION IF EXISTS TT_IsInt(numeric);
DROP FUNCTION IF EXISTS TT_IsNumeric(numeric);

