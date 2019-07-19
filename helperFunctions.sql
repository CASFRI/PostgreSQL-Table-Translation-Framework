------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Helper functions installation file
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
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-- Validation functions return only boolean values (TRUE or FALSE).
-- Consist of a source value to be validated, and any parameters associated
-- with validation.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- TT_NotNULL
--
--  val text - Value to test.
--
-- Return TRUE if val is not NULL.
-- Return FALSE if val is NULL.
-- e.g. TT_NotNULL('a')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNULL(
  val text
)
RETURNS boolean AS $$
  BEGIN
    RETURN val IS NOT NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotEmpty
--
--  val text - value to test
--
-- Return TRUE if val is not an empty string.
-- Return FALSE if val is empty string or padded spaces (e.g. '' or '  ') or NULL.
-- e.g. TT_NotEmpty('a')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   val text
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN replace(val, ' ', '') != '';
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE; 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Length
--
-- val text - values to test.
--
-- Count characters in string
-- e.g. TT_Length('12345')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Length(
  val text
)
RETURNS int AS $$
      SELECT coalesce(char_length(val), 0);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsInt
--
--  val text - value to test.
--
--  Does value represent integer? (e.g. 1 or 1.0)
--  NULL values return FALSE
--  Strings with numeric characters and '.' will be evaluated
--  Strings with anything else (e.g. letter characters) return FALSE.
--  e.g. TT_IsInt('1.0')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
   val text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      BEGIN
        _val = val::double precision;
        RETURN _val - _val::int = 0;
      EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
      END;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNumeric
--
--  val text - Value to test.
--
--  Can value be cast to double precision? (e.g. 1.1, 1, '1.5')
--  NULL values return FALSE
--  e.g. TT_IsNumeric('1.1')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      BEGIN
        _val = val::double precision;
        RETURN TRUE;
      EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
      END;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsBoolean
--
-- Return TRUE if val is boolean
-- e.g. TT_IsBoolean('TRUE')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsBoolean(
  val text
)
RETURNS boolean AS $$
  DECLARE
    _val boolean;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      BEGIN
        _val = val::boolean;
        RETURN TRUE;
      EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
      END;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsChar
--
-- Return TRUE if val is a char
-- e.g. TT_IsBoolean('TRUE')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsChar(
  val text
)
RETURNS boolean AS $$
  SELECT TT_Length(val) = 1;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsGeometry
--
-- Return TRUE if val is a geometry
-- e.g. TT_IsGeometry('LNESTRING(0 0, 0 10, 10 10, 0 0)')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsGeometry(
  val text
)
RETURNS boolean AS $$
  DECLARE
    _val geometry;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      BEGIN
        _val = val::geometry;
        RETURN TRUE;
      EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
      END;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsStringList
--
-- Return TRUE if val is a string list
-- e.g. TT_IsStringList('{''val1'', ''val2'', ''val3''}')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsStringList(
  val text
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF val ~ '{.+}' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsDoubleList
--
-- Return TRUE if val is a list of text double precision values
-- e.g. TT_IsDoubleList('{''val1'', ''val2'', ''val3''}')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsDoubleList(
  val text
)
RETURNS boolean AS $$
  DECLARE
    i text;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    ELSE
      FOREACH i IN ARRAY TT_ParseStringList(val, TRUE) LOOP
        IF NOT TT_IsNumeric(i) THEN
          RETURN FALSE;
        END IF;
      END LOOP;
    END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsIntList
--
-- Return TRUE if val is a list of text int values
-- e.g. TT_IsIntList('{''val1'', ''val2'', ''val3''}')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsIntList(
  val text
)
RETURNS boolean AS $$
  DECLARE
    i text;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    ELSE
      FOREACH i IN ARRAY TT_ParseStringList(val, TRUE) LOOP
        IF NOT TT_IsInt(i) THEN
          RETURN FALSE;
        END IF;
      END LOOP;
    END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsCharList
--
-- Return TRUE if val is a list of text char values
-- e.g. TT_IsCharList('{''val1'', ''val2'', ''val3''}')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsCharList(
  val text
)
RETURNS boolean AS $$
  DECLARE
    i text;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    ELSE
      FOREACH i IN ARRAY TT_ParseStringList(val, TRUE) LOOP
        IF NOT TT_IsChar(i) THEN
          RETURN FALSE;
        END IF;
      END LOOP;
    END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ValidateParams
--
-- Validates parameters.
-- Generate an error if params are NULL or of the wrong type.
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_ValidateParams(
  fctName text,
  params text[]
) 
RETURNS void AS $$
  DECLARE
    i integer;
    paramName text;
    paramVal text;
    paramType text;
  BEGIN
    IF array_upper(params, 1) % 3 != 0 THEN
      RAISE EXCEPTION 'ERROR when calling TT_ValidateParams(): params ARRAY must have a multiple of 3 number of parameters';
    END IF;
    FOR i IN 1..array_upper(params, 1)/3 LOOP
      paramName = params[(i - 1) * 3 + 1];
      paramVal  = params[(i - 1) * 3 + 2];
      paramType = params[(i - 1) * 3 + 3];
      IF paramType != 'int' AND 
         paramType != 'numeric' AND 
         paramType != 'text' AND 
         paramType != 'char' AND 
         paramType != 'boolean' AND 
         paramType != 'stringlist' AND
         paramType != 'doublelist' AND
         paramType != 'intlist' AND
         paramType != 'charlist' THEN
        RAISE EXCEPTION 'ERROR when calling TT_ValidateParams(): paramType #% must be "int", "numeric", "text", "char", "boolean", "stringlist", "doublelist", "intlist", "charlist"', i;
      END IF;
      IF paramVal IS NULL THEN
        RAISE EXCEPTION 'ERROR in %(): % is NULL', fctName, paramName;
      END IF;
      IF paramType = 'int' AND NOT TT_IsInt(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a int value', fctName, paramName;
      ELSIF paramType = 'numeric' AND NOT TT_IsNumeric(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a numeric value', fctName, paramName;
      ELSIF paramType = 'boolean' AND NOT TT_IsBoolean(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a boolean value', fctName, paramName;
      ELSIF paramType = 'char' AND TT_Length(paramVal) != 1 THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a char value', fctName, paramName;
      ELSIF paramType = 'stringlist' AND NOT TT_IsStringList(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a stringlist value', fctName, paramName;
      ELSIF paramType = 'doublelist' AND NOT TT_IsDoubleList(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a doublelist value', fctName, paramName;
      ELSIF paramType = 'intlist' AND NOT TT_IsIntList(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a intlist value', fctName, paramName;
      ELSIF paramType = 'charlist' AND NOT TT_IsCharList(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a charlist value', fctName, paramName;
      END IF;
    END LOOP;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Between
--
-- val text - Value to test
-- min text - Minimum
-- max text - Maximum
-- includeMin - is min inclusive? Default True
-- includeMax - is max inclusive? Default True
--
-- Return TRUE if val is between min and max.
-- Return FALSE otherwise.
-- Return FALSE if val is NULL.
-- Return error if min, max, includeMin or includeMax are NULL.
-- e.g. TT_Between(5, 0, 100)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Between(
  val text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _min double precision;
    _max double precision;
    _includeMin boolean;
    _includeMax boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_Between',
                              ARRAY['min', min, 'numeric', 
                                    'max', max, 'numeric', 
                                    'includeMin', includeMin, 'boolean', 
                                    'includeMax', includeMax, 'boolean']);
    _min = min::double precision;
    _max = max::double precision;
    _includeMin = includeMin::boolean;
    _includeMax = includeMax::boolean;
    
    IF _min = _max THEN
      RAISE EXCEPTION 'ERROR in TT_Between(): min is equal to max';
    ELSIF _min > _max THEN
      RAISE EXCEPTION 'ERROR in TT_Between(): min is greater than max';
    END IF;
    
    -- validate source value (return FALSE)
    IF NOT TT_IsNumeric(val) THEN
      RETURN FALSE;
    END IF;
    _val = val::double precision;
    
    -- process
    IF _includeMin = FALSE AND _includeMax = FALSE THEN
      RETURN _val > _min AND _val < _max;
    ELSIF _includeMin = TRUE AND _includeMax = FALSE THEN
      RETURN _val >= _min AND _val < _max;
    ELSIF _includeMin = FALSE AND _includeMax = TRUE THEN
      RETURN _val > _min AND _val <= _max;
    ELSE
      RETURN _val >= _min AND _val <= _max;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_Between(val, min, max, TRUE::text, TRUE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GreaterThan
--
--  val text - Value to test.
--  lowerBound text - lower bound to test against.
--  inclusive text - is lower bound inclusive? Default TRUE.
--
--  Return TRUE if val >= lowerBound and inclusive = TRUE.
--  Return TRUE if val > lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if lowerBound or inclusive are NULL.
--  e.g. TT_GreaterThan(5, 0, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GreaterThan(
   val text,
   lowerBound text,
   inclusive text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _lowerBound double precision;
    _inclusive boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_GreaterThan',
                              ARRAY['lowerBound', lowerBound, 'numeric', 
                                    'inclusive', inclusive, 'boolean']);
    _lowerBound = lowerBound::double precision;
    _inclusive = inclusive::boolean;
   
    -- validate source value (return FALSE)
    IF NOT TT_IsNumeric(val) THEN
      RETURN FALSE;
    END IF;
    _val = val::double precision;

    -- process
    IF _inclusive = TRUE THEN
      RETURN _val >= _lowerBound;
    ELSE
      RETURN _val > _lowerBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GreaterThan(
  val text,
  lowerBound text
)
RETURNS boolean AS $$
  SELECT TT_GreaterThan(val, lowerBound, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LessThan
--
--  val text - Value to test.
--  upperBound text - upper bound to test against.
--  inclusive text - is upper bound inclusive? Default True.
--
--  Return TRUE if val <= upperBound and inclusive = TRUE.
--  Return TRUE if val < upperBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if upperBound or inclusive are NULL.
--  e.g. TT_LessThan(1, 5, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LessThan(
   val text,
   upperBound text,
   inclusive text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _upperBound double precision;
    _inclusive boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_LessThan',
                              ARRAY['upperBound', upperBound, 'numeric', 
                                    'inclusive', inclusive, 'boolean']);
    _upperBound = upperBound::double precision;
    _inclusive = inclusive::boolean;
    
    -- validate source value (return FALSE)
    IF NOT TT_IsNumeric(val) THEN
      RETURN FALSE;
    END IF;
    _val = val::double precision;

    -- process
    IF _inclusive = TRUE THEN
      RETURN _val <= _upperBound;
    ELSE
      RETURN _val < _upperBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LessThan(
  val text,
  upperBound text
)
RETURNS boolean AS $$
  SELECT TT_LessThan(val, upperBound, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsUnique
--
-- val text - value to test.
-- lookupSchemaName text - schema name holding lookup table.
-- lookupTableName text - lookup table name.
-- occurrences - text defaults to 1
--
-- if number of occurences of val in source_val of schema.table equals occurences, return true.
-- e.g. TT_IsUnique('BS', 'public', 'bc08', 1)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  occurrences text
)
RETURNS boolean AS $$
  DECLARE
    _lookupSchemaName name;
    _lookupTableName name;
    _occurrences int;
    query text;
    return boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsUnique',
                              ARRAY['lookupSchemaName', lookupSchemaName, 'text', 
                                    'lookupTableName', lookupTableName, 'text',
                                    'occurrences', occurrences, 'int']);
    _lookupSchemaName = lookupSchemaName::name;
    _lookupTableName = lookupTableName::name;
    _occurrences = occurrences::int;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;

    -- process
    query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ') = ' || _occurrences || ';';
    EXECUTE query INTO return;
    RETURN return;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, lookupSchemaName, lookupTableName, 1::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, 'public', lookupTableName, 1::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchTable
--
-- val text - value to test.
-- lookupSchemaName text - schema name holding lookup table.
-- lookupTableName text - lookup table.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
--
-- if val is present in source_val of schema.lookup table, returns TRUE.
-- e.g. TT_Match('BS', 'public', 'bc08', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  ignoreCase text
)
RETURNS boolean AS $$
  DECLARE
    _lookupSchemaName name;
    _lookupTableName name;
    _ignoreCase boolean;
    query text;
    return boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchTable',
                              ARRAY['lookupSchemaName', lookupSchemaName, 'text', 
                                    'lookupTableName', lookupTableName, 'text',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _lookupSchemaName = lookupSchemaName::name;
    _lookupTableName = lookupTableName::name;
    _ignoreCase = ignoreCase::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;
    
    -- process    
    IF _ignoreCase = FALSE THEN
      query = 'SELECT ' || quote_literal(val) || ' IN (SELECT source_val FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || quote_literal(upper(val)) || ' IN (SELECT upper(source_val::text) FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, lookupSchemaName, lookupTableName, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, 'public', lookupTableName, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchList
--
-- val text (stringList) - value to test.
-- lst text - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
--
-- Is val in lst?
-- val followed by string of test values
-- e.g. TT_Match('a', {'a','b','c'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  DECLARE
    _lst text[];
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _ignoreCase = ignoreCase::boolean;
    
    -- validate source value (return FALSE)
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;
    
    -- process
    IF _ignoreCase = FALSE THEN
      _lst = TT_ParseStringList(lst, TRUE, FALSE);
      RETURN val = ANY(_lst);
    ELSE
      _lst = TT_ParseStringList(upper(lst), TRUE, FALSE);
      RETURN upper(val) = ANY(_lst);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_False
--
-- Return false
-- e.g. TT_False()
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_False()
RETURNS boolean AS $$
  BEGIN
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_True
--
-- Return true
-- e.g. TT_True()
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_True()
RETURNS boolean AS $$
  BEGIN
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIsValid
--
-- the_geom text - the geometry value to validate
-- fix text - default true. Should invalid geometries be fixed
-- 
-- Return true if the geometry is valid
-- If invalid and fix is True, first try to fix with ST_MakeValid(), then with
-- ST_Buffer. If still invalid print the reason with ST_IsValidReason().
--
-- e.g. TT_GeoIsValid(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), True)

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GeoIsValid(
  the_geom text,
  fix text
)
RETURNS boolean AS $$
  DECLARE
    _the_geom geometry;
    _fix boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_GeoIsValid',
                              ARRAY['fix', fix, 'boolean']);
    _fix = fix::boolean;

    -- validate source value (return FALSE)
    IF NOT TT_IsGeometry(the_geom) THEN
      RETURN FALSE;
    END IF;
    _the_geom = the_geom::geometry;

    -- process
    IF ST_IsValid(_the_geom) THEN
      RETURN TRUE;
    ELSIF _fix AND ST_IsValid(ST_MakeValid(_the_geom)) THEN
      RETURN TRUE;
    ELSIF _fix AND ST_IsValid(ST_Buffer(_the_geom, 0)) THEN
      RETURN TRUE;
    ELSE
      RAISE NOTICE 'TT_GeoIsValid(): invalid geometry, reason: %', ST_IsValidReason(_the_geom);
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GeoIsValid(
  the_geom text
)
RETURNS boolean AS $$
  SELECT TT_GeoIsValid(the_geom, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersects
--
-- the_geom text - the geometry to be tested
-- intersectSchemaName text - schema for the intersect table
-- intersectTableName text - table to intersect
-- geoCol text - geometry column from intersect table
-- 
-- Return True if the test geometry intersects any polygons in the intersect table
--
-- e.g. TT_GeoIntersects(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'public', 'bc08', 'geom')

------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersects(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_GeoIntersects(
  the_geom text,
  intersectSchemaName text,
  intersectTableName text,
  geoCol text
)
RETURNS boolean AS $$
  DECLARE
    _intersectSchemaName name;
    _intersectTableName name;
    count int;
    query text;
    return boolean;
    _the_geom geometry;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_GeoIntersects',
                              ARRAY['intersectSchemaName', intersectSchemaName, 'text',
                                    'intersectTableName', intersectTableName, 'text',
                                    'geoCol', geoCol, 'text']);
    _intersectSchemaName = intersectSchemaName::name;
    _intersectTableName = intersectTableName::name;

    -- validate source value (return FALSE)
    IF NOT TT_IsGeometry(the_geom) THEN
      RETURN FALSE;
    END IF;
    _the_geom = the_geom::geometry;
  
    -- process
    IF NOT ST_IsValid(_the_geom) THEN
      IF ST_IsValid(ST_MakeValid(_the_geom)) THEN
        _the_geom = ST_MakeValid(_the_geom);
      ELSIF ST_IsValid(ST_Buffer(_the_geom, 0)) THEN
        _the_geom = ST_Buffer(_the_geom, 0);
      ELSE
        RAISE EXCEPTION 'Geometry cannot be validated: %', the_geom;
      END IF;
    END IF;

    -- query to get count of intersects
    query = 'SELECT count(*) FROM ' || TT_FullTableName(_intersectSchemaName, _intersectTableName) || ' WHERE ST_Intersects(''' || _the_geom::text || '''::geometry, ' || geoCol || ') LIMIT 1;';
    EXECUTE query INTO count;

    -- RAISE NOTICE 'count: %', count;

    -- return false if count = 0, true if > 0
    IF count = 0 THEN
      RETURN FALSE;
    ELSIF count > 0 THEN
      RETURN TRUE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-- DROP FUNCTION IF EXISTS TT_GeoIntersects(text, text, text);
CREATE OR REPLACE FUNCTION TT_GeoIntersects(
  the_geom text,
  intersectSchemaName text,
  intersectTableName text
)
RETURNS boolean AS $$
  SELECT TT_GeoIntersects(the_geom, intersectSchemaName, intersectTableName, 'geom')
$$ LANGUAGE sql VOLATILE;

-- DROP FUNCTION IF EXISTS TT_GeoIntersects(text, text);
CREATE OR REPLACE FUNCTION TT_GeoIntersects(
  the_geom text,
  intersectTableName text
)
RETURNS boolean AS $$
  SELECT TT_GeoIntersects(the_geom, 'public', intersectTableName, 'geom')
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotNULLEmptyOr
--
-- val text - comma separated list of values to test.
--
-- Return TRUE if at least one value is not NULL or empty strings.
-- Return FALSE if all values are NULL or empty strings.
-- e.g. TT_NotNULLEmptyOr({'a','b','c'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNULLEmptyOr(
  val text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
  BEGIN
    -- validate source value (return FALSE)
    IF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    END IF;

    -- process
    _vals = TT_ParseStringList(val, TRUE, FALSE);
    FOREACH val in ARRAY _vals LOOP
      IF TT_NotNULL(val) AND TT_NOTEmpty(val) THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsIntSubstring(text, text, text)
--
-- val text - input string
-- start_char - start character to take substring from
-- for_length - length of substring to take
--
-- Take substring and test isInt
-- e.g. TT_IsIntSubstring('2001-01-01', 1, 4)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsIntSubstring(
  val text,
  start_char text,
  for_length text
)
RETURNS boolean AS $$
  DECLARE
    _start_char int;
    _for_length int;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsIntSubstring',
                              ARRAY['start_char', start_char, 'int',
                                    'for_length', for_length, 'int']);
    _start_char = start_char::int;
    _for_length = for_length::int;
    
    -- validate source value (return FALSE)
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;

    -- process
    RETURN TT_IsInt(substring(val from _start_char for _for_length));
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Translation Function Definitions...
-- Translation functions return any kind of value (not only boolean).
-- Consist of a source value to be translated, and any parameters associated
-- with translation.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_CopyText
--
--  val text  - Value to return.
--
-- Return the value as text.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CopyText(
  val text
)
RETURNS text AS $$
  BEGIN
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CopyDouble
--
--  val text  - Value to return.
--
-- Return the value as double precision.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CopyDouble(
  val text
)
RETURNS double precision AS $$
  BEGIN
    RETURN val::double precision;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CopyInt
--
--  val text  - Value to return.
--
-- Return the value as an integer.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CopyInt(
  val text
)
RETURNS int AS $$
  BEGIN
    RETURN round(val::numeric)::int;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupText
--
-- val text - val to lookup
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupColumn text - column to return
-- ignoreCase text - default FALSE. Should upper/lower case be ignored?
--
-- Return text value from lookupColumn in lookupSchemaName.lookupTableName
-- that matches val in source_val column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
-- e.g. TT_Lookup('BS', 'public', 'bc08', 'species1', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  ignoreCase text,
  callerFctName text
)
RETURNS text AS $$
  DECLARE
    _lookupSchemaName name;
    _lookupTableName name;
    _ignoreCase boolean;
    query text;
    result text;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams(callerFctName,
                              ARRAY['lookupSchemaName', lookupSchemaName, 'text',
                                    'lookupTableName', lookupTableName, 'text',
                                    'lookupCol', lookupCol, 'text',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _lookupSchemaName = lookupSchemaName::name;
    _lookupTableName = lookupTableName::name;
    _ignoreCase = ignoreCase::boolean;

    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN NULL;
    END IF;
    
    -- process
    query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || 
            CASE WHEN _ignoreCase IS TRUE THEN
                   ' WHERE upper(source_val::text) = upper(' || quote_literal(val) || ')'
                 ELSE 
                   ' WHERE source_val = ' || quote_literal(val)
            END || ';';

    EXECUTE query INTO result;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  ignoreCase text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, ignoreCase, 'TT_LookupText')
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupTableName text,
  lookupCol text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, 'public', lookupTableName, lookupCol, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupDouble
--
-- val text - val to lookup
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupColumn text - column to return
-- ignoreCase text - default FALSE. Should upper/lower case be ignored?
--
-- Return double precision value from lookupColumn in lookupSchemaName.lookupTableName
-- that matches val in source_val column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
-- e.g. TT_Lookup('BS', 'public', 'bc08', 'species1_per')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  ignoreCase text
)
RETURNS double precision AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, ignoreCase, 'TT_LookupDouble')::double precision;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS double precision AS $$
  SELECT TT_LookupDouble(val, lookupSchemaName, lookupTableName, lookupCol, FALSE::text);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupTableName text,
  lookupCol text
)
RETURNS double precision AS $$
  SELECT TT_LookupDouble(val, 'public', lookupTableName, lookupCol, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupInt
--
-- val text - val to lookup
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupColumn text - column to return
-- ignoreCase text - default FALSE. Should upper/lower case be ignored?
--
-- Return int value from lookupColumn in lookupSchemaName.lookupTableName
-- that matches val in source_val column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
-- e.g. TT_Lookup('BS', 'public', 'bc08', 'species1_per')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  ignoreCase text
)
RETURNS int AS $$
  WITH inttxt AS (
    SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, ignoreCase, 'TT_LookupInt') val
  )
  SELECT CASE WHEN TT_IsINT(val) THEN
              val::int
         ELSE
              NULL
         END
  FROM inttxt;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS int AS $$
  SELECT TT_LookupInt(val, lookupSchemaName, lookupTableName, lookupCol, FALSE::text);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupTableName text,
  lookupCol text
)
RETURNS int AS $$
  SELECT TT_LookupInt(val, 'public', lookupTableName, lookupCol, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapText
--
-- val text - value to test.
-- mapVals text (stringList) - string list of mapping values
-- targetVals (stringList) text - string list of target values
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return value from targetVals that matches value index in mapVals
-- Return type is text
-- Error if val is NULL
-- e.g. TT_Map('A', '{''A'',''B'',''C''}', '{''1'',''2'',''3''}', 'TRUE')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapText(
  val text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS text AS $$
  DECLARE
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapText',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _ignoreCase = ignoreCase::boolean;

    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;
    
    -- process
    IF _ignoreCase = FALSE THEN
      _mapVals = TT_ParseStringList(mapVals, TRUE, FALSE);
      _targetVals = TT_ParseStringList(targetVals, TRUE, FALSE);
      RETURN (_targetVals)[array_position(_mapVals, val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE, FALSE);
      _targetVals = TT_ParseStringList(targetVals, TRUE, FALSE);
      RETURN (_targetVals)[array_position(_mapVals, upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapText(
  val text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MapText(val, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapDouble
--
-- val text - value to test.
-- mapVals text - string containing comma seperated vals
-- targetVals text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return double precision value from targetVals that matches value index in mapVals
-- Return type is double precision
-- Error if val is NULL, or if any targetVals elements cannot be cast to double precision, or if val is not in mapVals
-- e.g. TT_Map('A',{'A','B','C'},{'1.1','2.2','3.3'})

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapDouble(
  val text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS double precision AS $$
  DECLARE
    _mapVals text[];
    _targetVals text[];
    _i double precision;
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapDouble',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'doublelist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _ignoreCase = ignoreCase::boolean;
    _mapVals = TT_ParseStringList(mapVals, TRUE, FALSE);
    _targetVals = TT_ParseStringList(targetVals, TRUE, FALSE);

    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;
    
    -- process
    IF _ignoreCase = FALSE THEN
      RETURN (_targetVals)[array_position(_mapVals, val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE, FALSE);
      RETURN (_targetVals)[array_position(_mapVals,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapDouble(
  val text,
  mapVals text,
  targetVals text
)
RETURNS double precision AS $$
  SELECT TT_MapDouble(val, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapInt
--
-- val text - value to test.
-- mapVals text - string containing comma seperated vals
-- targetVals text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return int value from targetVals that matches value index in mapVals
-- Return type is int
-- Error if val is NULL, or if any targetVals elements are not int, or if val is not in mapVals
-- e.g. TT_MapInt('A',{'A','B','C'}, {'1','2','3'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapInt(
  val text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS int AS $$
  DECLARE
    _mapVals text[];
    _targetVals text[];
    _i int;
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapInt',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'intlist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _ignoreCase = ignoreCase::boolean;
    _mapVals = TT_ParseStringList(mapVals, TRUE, FALSE);
    _targetVals = TT_ParseStringList(targetVals, TRUE, FALSE);

    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN NULL;
    END IF;
    
    -- process
    IF _ignoreCase = FALSE THEN
      RETURN (_targetVals)[array_position(_mapVals, val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE, FALSE);
      RETURN (_targetVals)[array_position(_mapVals,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapInt(
  val text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$
  SELECT TT_MapInt(val, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Pad
--
-- val text - string to pad.
-- targetLength text - total characters of output string.
-- padChar text - character to pad with - Defaults to 'x'.
--
-- Pads if val length is smaller than target, trims if val 
-- length is longer than target.
-- padChar should always be a single character.
-- e.g. TT_Pad('tab1', 10, 'x')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  targetLength text,
  padChar text,
  trunc text
)
RETURNS text AS $$
  DECLARE
    _targetLength int;
    _trunc boolean;
    val_length int;
    pad_length int;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
     PERFORM TT_ValidateParams('TT_Pad',
                              ARRAY['targetLength', targetLength, 'int',
                                    'padChar', padChar, 'char',
                                    'trunc', trunc, 'boolean']);
    _targetLength = targetLength::int;
    _trunc = trunc::boolean;
    
    IF _targetLength < 0 THEN
      RAISE EXCEPTION 'ERROR in TT_Pad(): targetLength is smaller than 0';
    END IF;
    
    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN NULL;
    END If;
    
    -- process
    pad_length = _targetLength - TT_Length(val);
    IF pad_length > 0 THEN
      RETURN concat_ws('', repeat(padChar, pad_length), val);
    END IF;
    IF _trunc THEN
      RETURN substring(val from 1 for _targetLength);
    END IF;
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  targetLength text,
  padChar text
)
RETURNS text AS $$
  SELECT TT_Pad(val, targetLength, padChar, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Concat
--
--  val text (stringList) - comma separated string of strings to concatenate
--  sep text - Separator (e.g. '_'). If no sep required use '' as second argument.
--
-- Return the concatenated value.
-- e.g. TT_Concat({'a', 'b', 'c'}, '-')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val text,
  sep text
)
RETURNS text AS $$
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_Concat',
                             ARRAY['sep', sep, 'char']);

    -- validate source value (return NULL if not valid)
    IF NOT TT_IsStringList(val) THEN
      RETURN NULL;
    END IF;
    
    -- process
    RETURN array_to_string(TT_ParseStringList(val, TRUE, FALSE), sep);
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_PadConcat
--
--  val text - comma separated string of strings to concatenate
--  length text - comma separated lengths of padding for each element in val
--  pad text - comma separated pad character for each val
--  sep text  - Separator (e.g. '_'). If no sep required use '' as second argument.
--  upperCase text - should vals be uppercase
--  includeEmpty text - should empty vals be included or ignored? Default TRUE.
--
--  Return the concatenated values with the padding.
--  Error if number of val, length and pad values not equal.
--  Error if missing length or pad values
--
-- e.g. TT_PadConcatString({'a','b','c'}, {'5','5','5'}, {'x','x','x'}, '-', 'TRUE')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_PadConcat(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_PadConcat(
  val text,
  length text,
  pad text,
  sep text,
  upperCase text,
  includeEmpty text
)
RETURNS text AS $$
  DECLARE
    _upperCase boolean;
    _vals text[];
    _lengths text[];
    _pads text[];
    _result text;
    _includeEmpty boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_PadConcat',
                              ARRAY['length', length, 'intlist',
                                    'pad', pad, 'charlist',
                                    'sep', sep, 'char',
                                    'upperCase', upperCase, 'boolean',
                                    'includeEmpty', includeEmpty, 'boolean']);
    _upperCase = upperCase::boolean;
    _includeEmpty = includeEmpty::boolean;

    _lengths = TT_ParseStringList(length, TRUE, FALSE);
    _pads = TT_ParseStringList(pad, TRUE, FALSE);
    
    -- check length of _lengths matches and _pads match
    IF array_length(_vals, 1) != array_length(_pads, 1) THEN
      RAISE EXCEPTION 'ERROR in number TT_PadConcat(): length and pad elements do not match';
    END IF;

    -- validate source value (return NULL if not valid)
    IF NOT TT_IsStringList(val) THEN
      RETURN NULL;
    END IF;
    
    IF _upperCase = TRUE THEN
      _vals = TT_ParseStringList(upper(val), TRUE, FALSE);
    ELSE
      _vals = TT_ParseStringList(val, TRUE, FALSE);
    END IF;

    -- check length of _vals matches _lengths and _pads match
    IF (array_length(_vals, 1) != array_length(_lengths, 1)) THEN
      RETURN NULL;
    END IF;

    -- process
    -- for each val in array, pad and merge to comma separated string
    _result = '{';
    FOR i IN 1..array_length(_vals,1) LOOP
      IF _vals[i] = '' AND _includeEmpty = FALSE THEN 
        -- do nothing
      ELSE
        _result = _result || '''' || TT_Pad(_vals[i], _lengths[i], _pads[i]) || ''',';
      END IF;
    END LOOP;
    -- run comma separated string through concat with sep
    _result = left(_result, char_length(_result) - 1) || '}';
    --RAISE NOTICE '%',_result;
    RETURN TT_Concat(_result, sep);
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_PadConcat(
  val text,
  length text,
  pad text,
  sep text,
  upperCase text
)
RETURNS text AS $$
  SELECT TT_PadConcat(val, length, pad, sep, upperCase, 'TRUE'::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NothingText
--
-- Returns NULL, for text target attributes.
-- Note this function is designed only be used with validation function TT_False() 
-- and therefore should never be evaluated by the engine.
-- e.g. TT_NothingText()
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NothingText()
RETURNS text AS $$
    SELECT NULL::text;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NothingDouble
--
-- Returns NULL, for double precision target attributes.
-- Note this function is designed only be used with validation function TT_False() 
-- and therefore should never be evaluated by the engine.
-- e.g. TT_NothingDouble()
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NothingDouble()
RETURNS double precision AS $$
    SELECT NULL::double precision;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NothingInt
--
-- Returns NULL, for int target attributes.
-- Note this function is designed only be used with validation function TT_False() 
-- and therefore should never be evaluated by the engine.
-- e.g. TT_NothingText()
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NothingInt()
RETURNS int AS $$
    SELECT NULL::int;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersectionText
--
-- the_geom text - the geometry from the table that will receive the intersecting value
-- intersectSchemaName text - schema for the intersect table
-- intersectTableName text - table to intersect
-- geoCol text - geometry column from intersect table
-- returnCol text - column conatining the values to return
-- method text - intersect method if multiple intersecting polygons (only have area method for text)
--    GREATEST_AREA - return value from intersecting polygon with largest area
--    LOWEST_VALUE - return lowest value
--    HIGHEST_VALUE - return highest value
-- 
-- Return the text value from the intersecting polygon
--
-- e.g. TT_GeoIntersectionText(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'public', 'bc08', 'geom', 'YEAR', 'GREATEST_AREA')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersectionText(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_GeoIntersectionText(
  the_geom text,
  intersectSchemaName text,
  intersectTableName text,
  geoCol text,
  returnCol text,
  method text,
  callerFctName text
)
RETURNS text AS $$
  DECLARE
    _intersectSchemaName name;
    _intersectTableName name;
    count int;
    _the_geom geometry;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams(callerFctName,
                              ARRAY['intersectSchemaName', intersectSchemaName, 'text',
                                    'intersectTableName', intersectTableName, 'text',
                                    'geoCol', geoCol, 'text',
                                    'returnCol', returnCol, 'text',
                                    'method', method, 'text']);
    _intersectSchemaName = intersectSchemaName::name;
    _intersectTableName = intersectTableName::name;

    IF NOT method = any('{"GREATEST_AREA", "LOWEST_VALUE", "HIGHEST_VALUE"}') THEN
      RAISE EXCEPTION 'ERROR in TT_GeoIntersectionText(): method is not one of "GREATEST_AREA", "LOWEST_VALUE", or "HIGHEST_VALUE"';
    END IF;
    
    -- validate source value (return NULL if not valid)
    IF NOT TT_IsGeometry(the_geom) THEN
      RETURN NULL;
    END IF;
    _the_geom = TT_GeoMakeValid(the_geom);
    
    -- process
    -- get table of returnCol values and intersecting areas for all intersecting polygons
    -- this table will have columns return_value and int_area representing the values from returnCol and the intersect areas respectively
    EXECUTE 'DROP TABLE IF EXISTS int_temp; CREATE TEMP TABLE int_temp AS SELECT ' || returnCol || ' AS return_value, ST_Area(ST_Intersection(''' || _the_geom::text || '''::geometry, ' || geoCol || ')) AS int_area 
    FROM ' || TT_FullTableName(_intersectSchemaName, _intersectTableName) ||
    ' WHERE ST_Intersects(''' || the_geom::text || '''::geometry, ' || geoCol || ');';

    EXECUTE 'SELECT count(*) FROM int_temp;' INTO count;

    -- return value based on count and method
    IF count = 0 THEN
      RAISE NOTICE 'No intersecting polygons for geometry: %', the_geom;
      RETURN NULL;
    ELSIF count = 1 THEN
      -- return the value
      RETURN return_value FROM int_temp;
    ELSIF count > 1 AND method = 'GREATEST_AREA' THEN
      -- return val from intersect with largest area
      RETURN return_value FROM int_temp ORDER BY int_area DESC LIMIT 1;
    ELSIF count > 1 AND method = 'LOWEST_VALUE' THEN
      -- return lowest val
      RETURN return_value FROM int_temp ORDER BY return_value LIMIT 1;
    ELSIF count > 1 AND method = 'HIGHEST_VALUE' THEN
      -- return highest val
      RETURN return_value FROM int_temp ORDER BY return_value DESC LIMIT 1;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GeoIntersectionText(
  the_geom text,
  intersectSchemaName text,
  intersectTableName text,
  geoCol text,
  returnCol text,
  method text
)
RETURNS text AS $$
  SELECT TT_GeoIntersectionText(the_geom, intersectSchemaName, intersectTableName, geoCol, returnCol, method, 'TT_GeoIntersectionText')
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GeoIntersectionText(
  the_geom text,
  intersectTableName text,
  returnCol text,
  method text
)
RETURNS text AS $$
  SELECT TT_GeoIntersectionText(the_geom, 'public', intersectTableName, 'geom', returnCol, method)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersectionDouble
-- Same as text version but with integer error code
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersectionDouble(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_GeoIntersectionDouble(
  the_geom text,
  intersectSchemaName text,
  intersectTableName text,
  geoCol text,
  returnCol text,
  method text
)
RETURNS double precision AS $$
  SELECT TT_GeoIntersectionText(the_geom, intersectSchemaName, intersectTableName, geoCol, returnCol, method, 'TT_GeoIntersectionDouble')::double precision;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GeoIntersectionDouble(
  the_geom text,
  intersectTableName text,
  returnCol text,
  method text
)
RETURNS double precision AS $$
  SELECT TT_GeoIntersectionDouble(the_geom, 'public', intersectTableName, 'geom', returnCol, method)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersectionInt
-- int wrapper for TT_GeoIntersectionDouble
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersectionInt(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_GeoIntersectionInt(
  the_geom text,
  intersectSchemaName text,
  intersectTableName text,
  geoCol text,
  returnCol text,
  method text
)
RETURNS integer AS $$
  SELECT TT_GeoIntersectionText(the_geom, intersectSchemaName, intersectTableName, geoCol, returnCol, method, 'TT_GeoIntersectionInt')::int;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GeoIntersectionInt(
  the_geom text,
  intersectTableName text,
  returnCol text,
  method text
)
RETURNS int AS $$
  SELECT TT_GeoIntersectionInt(the_geom, 'public', intersectTableName, 'geom', returnCol, method)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoMakeValid
--
-- the_geom text - the geometry value to validate
-- 
-- If geometry valid, returns geometry
-- If geometry invalid, returns fixed geometry
-- If geometry cannot be fixed, returns NULL
--
-- If invalid, first try to fix with ST_MakeValid(), then with
-- ST_Buffer. If still invalid print the reason with ST_IsValidReason().
--
-- e.g. TT_GeoMakeValid(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), True)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GeoMakeValid(
  the_geom text
)
RETURNS geometry AS $$
  DECLARE
    _the_geom geometry;
    _the_geom_makeValid geometry;
    _the_geom_buffer geometry;
  BEGIN
    -- validate source value (return NULL if not valid)
    IF NOT TT_IsGeometry(the_geom) THEN
      RETURN NULL;
    END IF;
    _the_geom = the_geom::geometry;

    -- if already valid, return the geometry
    IF ST_IsValid(_the_geom) THEN 
      RETURN _the_geom;
    END IF;

    -- attempt to fix with ST_MakeValid()
    _the_geom_makeValid = ST_MakeValid(_the_geom);
    IF ST_IsValid(_the_geom_makeValid) THEN
      RETURN _the_geom_makeValid;
    END IF;

    -- attempt to fix with buffer
    _the_geom_buffer = ST_Buffer(_the_geom, 0);
    IF ST_IsValid(_the_geom_buffer) THEN
      RETURN _the_geom_buffer;
    END IF;

    -- if attempts fail, return NULL and report the issue
    RAISE NOTICE 'Geometry cannot be validated: %', the_geom;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;