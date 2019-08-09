------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Uninstallation file
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
SELECT TT_DropAllTranslateFct();
DROP FUNCTION IF EXISTS _TT_Translate(name, name, name, name, boolean, boolean, int, boolean, boolean);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, text, name, name);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, text, name);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, text);
DROP FUNCTION IF EXISTS TT_Prepare(name, text);
DROP FUNCTION IF EXISTS TT_Prepare(name);
DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name, boolean);
DROP FUNCTION IF EXISTS TT_ValidateTTable(name, boolean);
DROP FUNCTION IF EXISTS TT_ParseRules(text);
DROP FUNCTION IF EXISTS TT_ParseArgs(text);
DROP FUNCTION IF EXISTS TT_ParseStringList(text, boolean);
DROP FUNCTION IF EXISTS TT_DropAllTranslateFct();
DROP FUNCTION IF EXISTS TT_TextFctEval(text, text[], jsonb, anyelement, boolean);
DROP FUNCTION IF EXISTS TT_LowerArr(text[]);
DROP FUNCTION IF EXISTS TT_FctExists(name, text[]);
DROP FUNCTION IF EXISTS TT_FctExists(name, name, text[]);
DROP FUNCTION IF EXISTS TT_TextFctExists(name, int);
DROP FUNCTION IF EXISTS TT_TextFctExists(name, name, int);
DROP FUNCTION IF EXISTS TT_TextFctReturnType(name, name, int);
DROP FUNCTION IF EXISTS TT_TextFctReturnType(name, int);
DROP FUNCTION IF EXISTS TT_FullTableName(name, name);
DROP FUNCTION IF EXISTS TT_FullFunctionName(name, name);
DROP FUNCTION IF EXISTS TT_Debug();
DROP FUNCTION IF EXISTS TT_IsError(text);
DROP FUNCTION IF EXISTS TT_RepackStringList(text[]);
DROP FUNCTION IF EXISTS TT_IsCastableTo(text, text);
DROP FUNCTION IF EXISTS TT_EscapeDoubleQuotesAndBackslash(text);
DROP FUNCTION IF EXISTS TT_EscapeSingleQuotes(text);
DROP FUNCTION IF EXISTS TT_UnsingleQuote(text);
DROP TYPE IF EXISTS TT_RuleDef;