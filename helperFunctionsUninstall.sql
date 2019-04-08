﻿------------------------------------------------------------------------------
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
DROP FUNCTION IF EXISTS TT_NotNull(text);
DROP FUNCTION IF EXISTS TT_NotEmpty(text);
DROP FUNCTION IF EXISTS TT_IsInt(text);
DROP FUNCTION IF EXISTS TT_IsNumeric(text);
DROP FUNCTION IF EXISTS TT_IsString(text);
DROP FUNCTION IF EXISTS TT_Between(text, text, text);
DROP FUNCTION IF EXISTS TT_GreaterThan(text, text, text);
DROP FUNCTION IF EXISTS TT_LessThan(text, text, text);
DROP FUNCTION IF EXISTS TT_HasUniqueValues(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MatchTab(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MatchList(text,text,text);
DROP FUNCTION IF EXISTS TT_False();

DROP FUNCTION IF EXISTS TT_Copy(text);
DROP FUNCTION IF EXISTS TT_Lookup(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_Map(text,text,text,text);
DROP FUNCTION IF EXISTS TT_Length(text);
DROP FUNCTION IF EXISTS TT_Pad(text,text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text,text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text,text,text,text,text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text,text,text,text,text,text,text,text,text,text,text,text,text);