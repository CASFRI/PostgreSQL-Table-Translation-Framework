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
DROP FUNCTION IF EXISTS TT_NotNull(text);
DROP FUNCTION IF EXISTS TT_NotEmpty(text);
DROP FUNCTION IF EXISTS TT_IsInt(text);
DROP FUNCTION IF EXISTS TT_IsNumeric(text);
DROP FUNCTION IF EXISTS TT_IsString(text);
DROP FUNCTION IF EXISTS TT_Between(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_Between(text, text, text);
DROP FUNCTION IF EXISTS TT_GreaterThan(text, text, text);
DROP FUNCTION IF EXISTS TT_GreaterThan(text, text);
DROP FUNCTION IF EXISTS TT_LessThan(text, text, text);
DROP FUNCTION IF EXISTS TT_LessThan(text, text);
DROP FUNCTION IF EXISTS TT_HasUniqueValues(text,text,text,text);
DROP FUNCTION IF EXISTS TT_HasUniqueValues(text,text,text);
DROP FUNCTION IF EXISTS TT_MatchTable(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MatchTable(text,text,text);
DROP FUNCTION IF EXISTS TT_MatchList(text,text,text);
DROP FUNCTION IF EXISTS TT_MatchList(text,text);
DROP FUNCTION IF EXISTS TT_False();
DROP FUNCTION IF EXISTS TT_True();
DROP FUNCTION IF EXISTS TT_GeoIsValid(text,text);
DROP FUNCTION IF EXISTS TT_GeoIsValid(text);
DROP FUNCTION IF EXISTS TT_GeoIntersects(text,text,text,text);
DROP FUNCTION IF EXISTS TT_NotNullEmptyOr(text);
DROP FUNCTION IF EXISTS TT_IsIntSubstring(text,text,text);

DROP FUNCTION IF EXISTS TT_CopyText(text);
DROP FUNCTION IF EXISTS TT_CopyDouble(text);
DROP FUNCTION IF EXISTS TT_CopyInt(text);
DROP FUNCTION IF EXISTS TT_LookupText(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_LookupText(text,text,text,text);
DROP FUNCTION IF EXISTS TT_LookupDouble(text,text,text,text);
DROP FUNCTION IF EXISTS TT_LookupDouble(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_LookupInt(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_LookupInt(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MapText(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MapText(text,text,text);
DROP FUNCTION IF EXISTS TT_MapDouble(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MapDouble(text,text,text);
DROP FUNCTION IF EXISTS TT_MapInt(text,text,text,text);
DROP FUNCTION IF EXISTS TT_MapInt(text,text,text);
DROP FUNCTION IF EXISTS TT_Length(text);
DROP FUNCTION IF EXISTS TT_Pad(text,text,text);
DROP FUNCTION IF EXISTS TT_Pad(text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_Concat(text,text);
DROP FUNCTION IF EXISTS TT_NothingText();
DROP FUNCTION IF EXISTS TT_NothingDouble();
DROP FUNCTION IF EXISTS TT_NothingInt();
DROP FUNCTION IF EXISTS TT_GeoIntersectionText(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionInt(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionDouble(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS TT_GeoMakeValid(text);
