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

-- validation helper functions
DROP FUNCTION IF EXISTS TT_NotNull(text);
DROP FUNCTION IF EXISTS TT_NotNull(text, text);
DROP FUNCTION IF EXISTS TT_NotEmpty(text, text);
DROP FUNCTION IF EXISTS TT_NotEmpty(text) CASCADE;
DROP FUNCTION IF EXISTS TT_IsInt(text);
DROP FUNCTION IF EXISTS TT_IsInt(text, text);
DROP FUNCTION IF EXISTS TT_IsNumeric(text);
DROP FUNCTION IF EXISTS TT_IsNumeric(text, text);
DROP FUNCTION IF EXISTS TT_IsBoolean(text);
DROP FUNCTION IF EXISTS TT_IsName(text);
DROP FUNCTION IF EXISTS TT_IsChar(text);
DROP FUNCTION IF EXISTS TT_IsStringList(text, boolean);
DROP FUNCTION IF EXISTS TT_IsDoubleList(text);
DROP FUNCTION IF EXISTS TT_IsIntList(text);
DROP FUNCTION IF EXISTS TT_IsCharList(text);
DROP FUNCTION IF EXISTS TT_IsBetween(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsBetween(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsBetween(text, text, text);
DROP FUNCTION IF EXISTS TT_IsGreaterThan(text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsGreaterThan(text, text, text);
DROP FUNCTION IF EXISTS TT_IsGreaterThan(text, text);
DROP FUNCTION IF EXISTS TT_IsLessThan(text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsLessThan(text, text, text);
DROP FUNCTION IF EXISTS TT_IsLessThan(text, text);
DROP FUNCTION IF EXISTS TT_IsUnique(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsUnique(text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsUnique(text, text, text);
DROP FUNCTION IF EXISTS TT_IsUnique(text, text);
DROP FUNCTION IF EXISTS TT_MatchTable(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchTable(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchTable(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchTable(text, text, text);
DROP FUNCTION IF EXISTS TT_MatchTable(text, text);
DROP FUNCTION IF EXISTS TT_MatchList(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchList(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchList(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchList(text, text, text);
DROP FUNCTION IF EXISTS TT_MatchList(text, text);
DROP FUNCTION IF EXISTS TT_SumIntMatchList(text, text, text, text);
DROP FUNCTION IF EXISTS TT_SumIntMatchList(text, text, text);
DROP FUNCTION IF EXISTS TT_SumIntMatchList(text, text);
DROP FUNCTION IF EXISTS TT_LengthMatchList(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LengthMatchList(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LengthMatchList(text, text, text, text);
DROP FUNCTION IF EXISTS TT_LengthMatchList(text, text, text);
DROP FUNCTION IF EXISTS TT_LengthMatchList(text, text);
DROP FUNCTION IF EXISTS TT_NotMatchList(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_NotMatchList(text, text, text, text);
DROP FUNCTION IF EXISTS TT_NotMatchList(text, text, text);
DROP FUNCTION IF EXISTS TT_NotMatchList(text, text);
DROP FUNCTION IF EXISTS TT_False();
DROP FUNCTION IF EXISTS TT_True();
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNull(text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasCountOfNotNullOrZero(text, text, text);
DROP FUNCTION IF EXISTS TT_LookupTextMatchList(text, text, text, text, text);

DROP FUNCTION IF EXISTS TT_IsIntSubstring(text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsIntSubstring(text, text, text);
DROP FUNCTION IF EXISTS TT_IsBetweenSubstring(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsBetweenSubstring(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsBetweenSubstring(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsBetweenSubstring(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchListSubstring(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchListSubstring(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchListSubstring(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchListSubstring(text, text, text, text);
DROP FUNCTION IF EXISTS TT_HasLength(text, text, text);
DROP FUNCTION IF EXISTS TT_HasLength(text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexNotNull(text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexNotNull(text, text, text);
DROP FUNCTION IF EXISTS TT_MinIndexNotNull(text, text);
DROP FUNCTION IF EXISTS TT_MinIndexNotNull(text, text, text);
DROP FUNCTION IF EXISTS TT_IsXMinusYBetween(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsXMinusYBetween(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IsXMinusYBetween(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MatchListTwice(text, text, text, text);

-- translation helper functions
DROP FUNCTION IF EXISTS TT_CopyText(text);
DROP FUNCTION IF EXISTS TT_CopyDouble(text);
DROP FUNCTION IF EXISTS TT_CopyInt(text);
DROP FUNCTION IF EXISTS TT_LookupInt(text, text, text);
DROP FUNCTION IF EXISTS TT_LookupInt(text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupInt(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupInt(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupDouble(text, text, text);
DROP FUNCTION IF EXISTS TT_LookupDouble(text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupDouble(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupDouble(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupText(text, text, text);
DROP FUNCTION IF EXISTS TT_LookupText(text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupText(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_LookupText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapText(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapText(text, text, text);
DROP FUNCTION IF EXISTS TT_MapDouble(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapDouble(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapDouble(text, text, text);
DROP FUNCTION IF EXISTS TT_MapInt(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapInt(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapInt(text, text, text);
DROP FUNCTION IF EXISTS TT_Length(text);
DROP FUNCTION IF EXISTS TT_Length(text, text);
DROP FUNCTION IF EXISTS TT_Pad(text, text, text);
DROP FUNCTION IF EXISTS TT_Pad(text, text, text, text);
DROP FUNCTION IF EXISTS TT_PadConcat(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_PadConcat(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_Concat(text, text);
DROP FUNCTION IF EXISTS TT_NothingText();
DROP FUNCTION IF EXISTS TT_NothingDouble();
DROP FUNCTION IF EXISTS TT_NothingInt();
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text);
DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_SubstringText(text, text, text, text);
DROP FUNCTION IF EXISTS TT_SubstringText(text, text, text);
DROP FUNCTION IF EXISTS TT_SubstringInt(text, text, text);
DROP FUNCTION IF EXISTS TT_MapSubstringText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapSubstringText(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MapSubstringText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_SumIntMapText(text, text, text);
DROP FUNCTION IF EXISTS TT_LengthMapInt(text, text, text, text);
DROP FUNCTION IF EXISTS TT_LengthMapInt(text, text, text);
DROP FUNCTION IF EXISTS TT_XMinusYInt(text, text);
DROP FUNCTION IF EXISTS TT_XMinusYDouble(text, text);
DROP FUNCTION IF EXISTS TT_MinInt(text);
DROP FUNCTION IF EXISTS TT_MaxInt(text);
DROP FUNCTION IF EXISTS TT_MinIndexCopyText(text, text);
DROP FUNCTION IF EXISTS TT_MinIndexCopyText(text, text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexCopyText(text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexCopyText(text, text, text);
DROP FUNCTION IF EXISTS TT_MinIndexMapText(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MinIndexMapText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexMapText(text, text, text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexMapText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MinIndexLookupText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MinIndexLookupText(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MinIndexLookupText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexLookupText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexLookupText(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_MaxIndexLookupText(text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_DivideInt(text, text);
DROP FUNCTION IF EXISTS TT_DivideDouble(text, text);
DROP FUNCTION IF EXISTS TT_MapTextCoalesce(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_Multiply(text, text);

-- generic and test functions
DROP FUNCTION IF EXISTS TT_ValidateParams(text, text[]);
DROP FUNCTION IF EXISTS TT_TestNullAndWrongTypeParams(int, text, text[]);

-- internal functions
DROP FUNCTION IF EXISTS TT_Min_Internal(int[]);
DROP FUNCTION IF EXISTS TT_Max_Internal(int[]);
DROP FUNCTION IF EXISTS TT_Min_Max_Indexes_Internal(int[], text);

