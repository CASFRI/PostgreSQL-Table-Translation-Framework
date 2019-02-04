﻿------------------------------------------------------------------------------
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
SELECT TT_DropAllTranslate();
DROP FUNCTION IF EXISTS _TT_Translate(name, name, name, name, text[], boolean, int, boolean, boolean);
DROP FUNCTION IF EXISTS TT_Prepare(name, name, name);
DROP FUNCTION IF EXISTS TT_ValidateTTable(name, name);
DROP FUNCTION IF EXISTS TT_ColumnNames(name, name);
DROP FUNCTION IF EXISTS TT_Evaluate(text, text[], jsonb, anyelement);
DROP FUNCTION IF EXISTS TT_ParseRules(text);
DROP FUNCTION IF EXISTS TT_ParseArgs(text);
DROP FUNCTION IF EXISTS TT_DropAllTranslate();
DROP FUNCTION IF EXISTS TT_LowerArr(text[]);
DROP FUNCTION IF EXISTS TT_FctExists(name, name, text[]);
DROP FUNCTION IF EXISTS TT_FctExists(name, text[]);
DROP FUNCTION IF EXISTS TT_FullTableName(name, name);
DROP TYPE IF EXISTS TT_RuleDef;