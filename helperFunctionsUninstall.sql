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
DROP FUNCTION IF EXISTS TT_NotNull(boolean);
DROP FUNCTION IF EXISTS TT_NotNull(double precision);
DROP FUNCTION IF EXISTS TT_NotNull(int);
DROP FUNCTION IF EXISTS TT_Between(integer, double precision, double precision);
DROP FUNCTION IF EXISTS TT_Between(double precision, double precision, double precision);
DROP FUNCTION IF EXISTS TT_NotEmpty(text);
DROP FUNCTION IF EXISTS TT_GreaterThan(double precision, double precision, boolean);
DROP FUNCTION IF EXISTS TT_GreaterThan(integer, double precision, boolean);
DROP FUNCTION IF EXISTS TT_LessThan(double precision, double precision, boolean);
DROP FUNCTION IF EXISTS TT_LessThan(integer, double precision, boolean);
DROP FUNCTION IF EXISTS TT_IsInt(double precision);
DROP FUNCTION IF EXISTS TT_IsInt(integer);
DROP FUNCTION IF EXISTS TT_IsInt(text);
DROP FUNCTION IF EXISTS TT_IsNumeric(double precision);
DROP FUNCTION IF EXISTS TT_IsNumeric(integer);
DROP FUNCTION IF EXISTS TT_IsNumeric(text);
DROP FUNCTION IF EXISTS TT_Match(text,text[]);
DROP FUNCTION IF EXISTS TT_Match(int,int[]);
DROP FUNCTION IF EXISTS TT_Match(double precision,double precision[]);
DROP FUNCTION IF EXISTS TT_Match(text, name, name);
DROP FUNCTION IF EXISTS TT_Match(double precision, name, name);
DROP FUNCTION IF EXISTS TT_Match(integer, name, name);
DROP FUNCTION IF EXISTS TT_Concat(text,text[]);
DROP FUNCTION IF EXISTS IsError(text);
DROP FUNCTION IF EXISTS TT_Copy(text);
DROP FUNCTION IF EXISTS TT_Copy(double precision);
DROP FUNCTION IF EXISTS TT_Copy(int);
DROP FUNCTION IF EXISTS TT_Copy(boolean);
DROP FUNCTION IF EXISTS TT_Lookup(text,name,name,text);
DROP FUNCTION IF EXISTS TT_Lookup(double precision,name,name,text);
DROP FUNCTION IF EXISTS TT_Lookup(int,name,name,text);
DROP FUNCTION IF EXISTS TT_Map(text,text[],text[]);
DROP FUNCTION IF EXISTS TT_False();
DROP FUNCTION IF EXISTS TT_IsString(text);
DROP FUNCTION IF EXISTS TT_IsString(double precision);
DROP FUNCTION IF EXISTS TT_IsString(int);
DROP FUNCTION IF EXISTS TT_Length(text);
DROP FUNCTION IF EXISTS TT_Length(double precision);
DROP FUNCTION IF EXISTS TT_Length(int);
DROP FUNCTION IF EXISTS TT_Pad(text,int,text);
DROP FUNCTION IF EXISTS TT_Pad(double precision,int,text);
DROP FUNCTION IF EXISTS TT_Pad(int,int,text);
DROP FUNCTION IF EXISTS TT_IsOccurence(text,name,name,int);
DROP FUNCTION IF EXISTS TT_IsOccurence(double precision,name,name,int);
DROP FUNCTION IF EXISTS TT_IsOccurence(int,name,name,int);
DROP FUNCTION IF EXISTS TT_IsOccurence(text,int,text);
DROP FUNCTION IF EXISTS TT_IsOccurence(double precision,int,double precision);
DROP FUNCTION IF EXISTS TT_IsOccurence(int,int,int);


