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
DROP FUNCTION IF EXISTS _TT_TranslateWithLogging(name, name, name, name, name, boolean, boolean, text, int, boolean, boolean, boolean);
DROP FUNCTION IF EXISTS _TT_Translate(text, text, name, name, name, name);
DROP FUNCTION IF EXISTS TT_PrepareWithLogging(name, name, text, name, name);
DROP FUNCTION IF EXISTS TT_PrepareWithLogging(name, name, text, name);
DROP FUNCTION IF EXISTS TT_PrepareWithLogging(name, name, text);
DROP FUNCTION IF EXISTS TT_PrepareWithLogging(name, name);
DROP FUNCTION IF EXISTS TT_PrepareWithLogging(name);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, text, name, name);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, text, name);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, text);
DROP FUNCTION IF EXISTS TT_Prepare(name, name);
DROP FUNCTION IF EXISTS TT_Prepare(name);
DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name, boolean);
DROP FUNCTION IF EXISTS TT_ValidateTTable(name, boolean);
DROP FUNCTION IF EXISTS TT_ParseRules(text, text, boolean);
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
DROP FUNCTION IF EXISTS TT_Debug(int);
DROP FUNCTION IF EXISTS TT_IsError(text);
DROP FUNCTION IF EXISTS TT_RepackStringList(text[], boolean);
DROP FUNCTION IF EXISTS TT_IsCastableTo(text, text);
DROP FUNCTION IF EXISTS TT_EscapeDoubleQuotesAndBackslash(text);
DROP FUNCTION IF EXISTS TT_EscapeSingleQuotes(text);
DROP FUNCTION IF EXISTS TT_IsSingleQuoted(text);
DROP FUNCTION IF EXISTS TT_UnsingleQuote(text);
DROP FUNCTION IF EXISTS TT_TableExists(text, text);
DROP FUNCTION IF EXISTS TT_LogInit(text, text, text, boolean, text);
DROP FUNCTION IF EXISTS TT_ShowLastLog(text, text, text, int);
DROP FUNCTION IF EXISTS TT_DeleteAllLogs(text, text);
DROP FUNCTION IF EXISTS TT_Log(text, text, text, text, text, text, int, int);
DROP FUNCTION IF EXISTS TT_TextFctQuery(text, text[], jsonb, boolean, boolean);
DROP FUNCTION IF EXISTS TT_RuleToSQL(text, text[]);
DROP FUNCTION IF EXISTS TT_ReportError(text, name, name, text, text, text[], jsonb, text, text, int, text, boolean, boolean);
DROP FUNCTION IF EXISTS TT_DefaultErrorCode(text, text);
DROP FUNCTION IF EXISTS TT_DefaultProjectErrorCode(text, text);
DROP FUNCTION IF EXISTS TT_GetGeomColName(text, text);
DROP FUNCTION IF EXISTS TT_PrettyDuration(int);
DROP TYPE IF EXISTS TT_RuleDef;