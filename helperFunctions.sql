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
--
--
--
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
-- TT_NotNull
--
--  val text - Value to test.
--
-- Return TRUE if val is not NULL.
-- Return FALSE if val is NULL.
-- e.g. TT_NotNull('a')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNull(
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
-- Return FALSE if val is empty string or padded spaces (e.g. '' or '  ') or Null.
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
-- TT_IsInt
--
--  val text - value to test.
--
--  Does value represent integer? (e.g. 1 or 1.0)
--  Null values return FALSE
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
--  Null values return FALSE
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
-- TT_IsString
--
-- Return TRUE if val is string (i.e. not numeric)
-- e.g. TT_IsString('a')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsString(
  val text
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TT_IsNumeric(val) IS FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Between
--
-- val text - Value to test.
-- min text - Minimum.
-- max text - Maximum.
-- includeMin - is min inclusive? Default True.
-- includeMax - is max inclusive? Default True.
--
-- Return TRUE if val is between min and max.
-- Return FALSE otherwise.
-- Return FALSE if val is NULL.
-- Return error if min or max are null.
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
    _val double precision := val::double precision;
    _min double precision := min::double precision;
    _max double precision := max::double precision;
    _includeMin boolean := includeMin::boolean;
    _includeMax boolean := includeMax::boolean;
  BEGIN
    IF min IS NULL OR max IS NULL THEN
      RAISE EXCEPTION 'min or max is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF _includeMin = FALSE AND _includeMax = FALSE THEN
      RETURN _val > _min and _val < _max;
    ELSIF _includeMin = TRUE AND _includeMax = FALSE THEN
      RETURN _val >= _min and _val < _max;
    ELSIF _includeMin = FALSE AND _includeMax = TRUE THEN
      RETURN _val > _min and _val <= _max;
    ELSE
      RETURN _val >= _min and _val <= _max;
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
--  Return error if lowerBound or inclusive are null.
--  e.g. TT_GreaterThan(5, 0, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GreaterThan(
   val text,
   lowerBound text,
   inclusive text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision := val::double precision;
    _lowerBound double precision := lowerBound::double precision;
    _inclusive boolean := inclusive::boolean;
  BEGIN
    IF lowerBound IS NULL OR inclusive IS NULL THEN
      RAISE EXCEPTION 'lowerBound or inclusive is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF _inclusive = TRUE THEN
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
--  Return error if upperBound or inclusive are null.
--  e.g. TT_LessThan(1, 5, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LessThan(
   val text,
   upperBound text,
   inclusive text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision := val::double precision;
    _upperBound double precision := upperBound::double precision;
    _inclusive boolean := inclusive::boolean;
  BEGIN
    IF upperBound IS NULL OR inclusive IS NULL THEN
      RAISE EXCEPTION 'upperBound or inclusive is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF _inclusive = TRUE THEN
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
-- TT_HasUniqueValues
--
-- val text - value to test.
-- lookupSchemaName text - schema name holding lookup table.
-- lookupTableName text - lookup table name.
-- occurrences - text defaults to 1
--
-- if number of occurences of val in source_val of schema.table equals occurences, return true.
-- e.g. TT_HasUniqueValues('BS', 'public', 'bc08', 1)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasUniqueValues(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  occurrences text
)
RETURNS boolean AS $$
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    _occurrences int := occurrences::int;
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF occurrences IS NULL THEN
      RAISE EXCEPTION 'occurrences is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ') = ' || _occurrences || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_HasUniqueValues(
  val text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_HasUniqueValues(val, lookupSchemaName, lookupTableName, 1::text)
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
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    _ignoreCase boolean := ignoreCase::boolean;
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF _ignoreCase = FALSE THEN
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
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchList
--
-- val text - value to test.
-- lst text - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
--
-- Is val in lst?
-- val followed by string of test values
-- e.g. TT_Match('a', 'a,b,c')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  DECLARE
    _lst text[];
    _ignoreCase boolean := ignoreCase::boolean;
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF _ignoreCase = FALSE THEN
      _lst = string_to_array(lst, ',');
      RETURN val = ANY(array_remove(_lst, NULL));
    ELSE
      _lst = string_to_array(upper(lst), ',');
      RETURN upper(val) = ANY(array_remove(_lst, NULL));
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
-- TT_GeoIntersects
--
-- the_geom text - the geometry value to validate
-- fix text - default true. Should invalid geometries be fixed
-- 
-- Return true if the geometry is valid
-- If invalid and fix is True, first try to fix with ST_MakeValid(), then with
-- ST_Buffer. If still invalid print the reason with ST_IsValidReason().
--
-- e.g. TT_GeoIntersects(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), True)

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GeoIntersects(
  the_geom text,
  fix text
)
RETURNS boolean AS $$
  DECLARE
    _the_geom geometry := the_geom::geometry;
    _fix boolean := fix::boolean;
  BEGIN
    IF the_geom IS NULL THEN
      RETURN FALSE;
    ELSIF ST_IsValid(_the_geom) THEN
      RETURN TRUE;
    ELSIF _fix AND ST_IsValid(ST_MakeValid(_the_geom)) THEN
      RETURN TRUE;
    ELSIF _fix AND ST_IsValid(ST_Buffer(_the_geom, 0)) THEN
      RETURN TRUE;
    ELSE
      RAISE NOTICE 'invalid geometry, reason: %', ST_IsValidReason(_the_geom);
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GeoIntersects(
  the_geom text
)
RETURNS boolean AS $$
  SELECT TT_GeoIntersects(the_geom, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

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
  ignoreCase text
)
RETURNS text AS $$
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    _ignoreCase boolean := ignoreCase::boolean;
    query text;
    return text;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR lookupCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol is NULL';
    ELSIF _ignoreCase = FALSE THEN
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE upper(source_val::text) = upper(' || quote_literal(val) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, FALSE::text)
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
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    _ignoreCase boolean := ignoreCase::boolean;
    query text;
    return text;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR lookupCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol is NULL';
    ELSIF _ignoreCase = FALSE THEN
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE upper(source_val::text) = upper(' || quote_literal(val) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS double precision AS $$
  SELECT TT_LookupDouble(val, lookupSchemaName, lookupTableName, lookupCol, FALSE::text)
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
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    _ignoreCase boolean := ignoreCase::boolean;
    query text;
    return text;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR lookupCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol is NULL';
    ELSIF _ignoreCase = FALSE THEN
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE upper(source_val::text) = upper(' || quote_literal(val) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS int AS $$
  SELECT TT_LookupInt(val, lookupSchemaName, lookupTableName, lookupCol, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapText
--
-- val text - value to test.
-- lst1 text - string containing comma seperated vals
-- lst2 text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return text value from lst2 that matches value index in lst1
-- Return type is text
-- Error if val is NULL
-- e.g. TT_Map('A','A,B,C','1,2,3', TRUE)

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapText(
  val text,
  lst1 text,
  lst2 text,
  ignoreCase text
)
RETURNS text AS $$
  DECLARE
    _lst1 text[];
    _lst2 text[];
    _ignoreCase boolean := ignoreCase::boolean;
  BEGIN
    
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF _ignoreCase = FALSE THEN
      _lst1 = string_to_array(lst1, ',');
      _lst2 = string_to_array(lst2, ',');
      RETURN (_lst2)[array_position(_lst1,val)];
    ELSE
      _lst1 = string_to_array(upper(lst1), ',');
      _lst2 = string_to_array(lst2, ',');
      RETURN (_lst2)[array_position(_lst1,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapText(
  val text,
  lst1 text,
  lst2 text
)
RETURNS text AS $$
  SELECT TT_MapText(val, lst1, lst2, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapDouble
--
-- val text - value to test.
-- lst1 text - string containing comma seperated vals
-- lst2 text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return double precision value from lst2 that matches value index in lst1
-- Return type is double precision
-- Error if val is NULL, or if any lst2 elements cannot be cast to double precision, or if val is not in lst1
-- e.g. TT_Map('A','A,B,C','1.1,2.2,3.3')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapDouble(
  val text,
  lst1 text,
  lst2 text,
  ignoreCase text
)
RETURNS double precision AS $$
  DECLARE
    _lst1 text[];
    _lst2 text[];
    _i double precision;
    _ignoreCase boolean := ignoreCase::boolean;
  BEGIN
    _lst1 = string_to_array(lst1, ',');
    _lst2 = string_to_array(lst2, ',');

    BEGIN
      FOREACH _i in ARRAY _lst2 LOOP  
        -- no need to do anything inside loop, we just want to test if all _i's are double precision
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      RAISE EXCEPTION 'lst2 value cannot be cast to double precision';
    END;

    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF _ignoreCase = FALSE THEN
      RETURN (_lst2)[array_position(_lst1,val)];
    ELSE
      _lst1 = string_to_array(upper(lst1), ',');
      RETURN (_lst2)[array_position(_lst1,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapDouble(
  val text,
  lst1 text,
  lst2 text
)
RETURNS double precision AS $$
  SELECT TT_MapDouble(val, lst1, lst2, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapInt
--
-- val text - value to test.
-- lst1 text - string containing comma seperated vals
-- lst2 text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return int value from lst2 that matches value index in lst1
-- Return type is int
-- Error if val is NULL, or if any lst2 elements are not int, or if val is not in lst1
-- e.g. TT_MapInt('A','A,B,C','1,2,3')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapInt(
  val text,
  lst1 text,
  lst2 text,
  ignoreCase text
)
RETURNS int AS $$
  DECLARE
    _lst1 text[];
    _lst2 text[];
    _i int;
    _ignoreCase boolean := ignoreCase::boolean;
  BEGIN
    _lst1 = string_to_array(lst1, ',');
    _lst2 = string_to_array(lst2, ',');

    BEGIN
      FOREACH _i in ARRAY _lst2 LOOP  
        -- no need to do anything inside loop, we just want to test if all _i's are int
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      RAISE EXCEPTION 'lst2 value is not int';
    END;
    
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF _ignoreCase = FALSE THEN
      RETURN (_lst2)[array_position(_lst1,val)];
    ELSE
      _lst1 = string_to_array(upper(lst1), ',');
      RETURN (_lst2)[array_position(_lst1,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapInt(
  val text,
  lst1 text,
  lst2 text
)
RETURNS int AS $$
  SELECT TT_MapInt(val, lst1, lst2, FALSE::text)
$$ LANGUAGE sql VOLATILE;
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
  BEGIN
    IF val IS NULL THEN
      RETURN 0;
    ELSE
      RETURN char_length(val);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Pad
--
-- val text - string to pad.
-- targetLength text - total characters of output string.
-- padChar text - character to pad with - Defaults to 'x'.
--
-- Pads if val shorter than target, trims if val longer than target.
-- padChar should always be a single character.
-- e.g. TT_Pad('tab1', 10, 'x')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  targetLength text,
  padChar text
)
RETURNS text AS $$
  DECLARE
    _targetLength int := targetLength::int;
    val_length int;
    pad_length int;
  BEGIN
    IF targetLength IS NULL OR padChar IS NULL THEN
      RAISE EXCEPTION 'targetLength or padChar is NULL';
    ELSIF TT_Length(padChar) != 1 THEN
      RAISE EXCEPTION 'padChar length is not 1';
    ELSE
      val_length = TT_Length(val);
      pad_length = _targetLength - val_length;
      IF pad_length > 0 THEN
        RETURN concat_ws('', repeat(padChar,pad_length), val);
      ELSE
        RETURN substring(val from 1 for _targetLength);
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  targetLength text
)
RETURNS text AS $$
  SELECT TT_Pad(val, targetLength, 'x'::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Concat
--
--  val text - comma separated string of strings to concatenate
--  sep text  - Separator (e.g. '_'). If no sep required use '' as second argument.
--
-- Return the concatenated value.
-- e.g. TT_Concat('a,b,c', '-')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val text,
  sep text
)
RETURNS text AS $$
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSE
      RETURN array_to_string(string_to_array(replace(val,' ',''), ','), sep);
    END IF;
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
-- e.g. TT_PadConcatString('a,b,c', '5,5,5', 'x,x,x', '-', 'TRUE')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_PadConcat(text,text,text,text,text,text);
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
    _upperCase boolean := upperCase::boolean;
    _vals text[];
    _lengths text[];
    _pads text[];
    _result text;
    _includeEmpty boolean := includeEmpty::boolean;
  BEGIN
    IF length IS NULL THEN
      RAISE EXCEPTION 'length is null';
    ELSIF pad IS NULL THEN
      RAISE EXCEPTION 'pad is null';
    ELSIF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';  
    END IF;
    
    IF _upperCase = TRUE THEN
      _vals = string_to_array(replace(upper(val),' ',''), ',');
      -- RETURN concat_ws(sep, TT_Pad(upper(val1), length1, pad1));
    ELSE
      _vals = string_to_array(replace(val,' ',''), ',');
      -- RETURN concat_ws(sep, TT_Pad(val1, length1, pad1));
    END IF;

    _lengths = string_to_array(replace(length,' ',''), ',');
    _pads = string_to_array(replace(pad,' ',''), ',');

    -- check length of _vals, _lengths, and _pads match
    IF (array_length(_vals,1) != array_length(_lengths,1)) OR (array_length(_vals,1) != array_length(_pads,1)) THEN
      RAISE EXCEPTION 'number of val, length and pad elments do not match';
    END IF;

    -- for each val in array, pad and merge to comma separated string
    _result = '';
    FOR i IN 1..array_length(_vals,1) LOOP
      IF _lengths[i] = '' THEN
        RAISE EXCEPTION 'length is empty';
      ELSIF _pads[i] = '' THEN
        RAISE EXCEPTION 'pad is empty';
      ELSIF _vals[i] = '' AND _includeEmpty = FALSE THEN 
        -- do nothing
      ELSE
        _result = _result || TT_Pad(_vals[i], _lengths[i], _pads[i]) || ',';
      END IF;
    END LOOP;
    -- run comma separated string through concat with sep
    RETURN TT_Concat(left(_result, char_length(_result) - 1), sep);
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
  BEGIN
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

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
  BEGIN
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

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
  BEGIN
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersectText
--
-- the_geom text - the geometry from the table that will receive the intersecting value
-- lookupSchemaName text - schema for the intersect table
-- lookupTableName text - table to intersect
-- geoCol text - geometry column from intersect table
-- lookupCol text - column conatining the values to return
-- method text - intersect method if multiple intersecting polygons (only have area method for text)
--    area - return value from intersecting polygon with largest area
-- 
-- Return the text value from the intersecting polygon
--
-- e.g. TT_GeoIntersectText(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'public', 'bc08', 'geom', 'YEAR', 'area')

------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersectText(text,text,text,text,text,text);
CREATE OR REPLACE FUNCTION TT_GeoIntersectText(
  the_geom text,
  lookupSchemaName text,
  lookupTableName text,
  geoCol text,
  returnCol text,
  method text
)
RETURNS text AS $$
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    count int;
    query text;
    return text;
  BEGIN
    IF the_geom IS NULL THEN
      RAISE EXCEPTION 'geometry is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR geoCol IS NULL OR returnCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol or returnCol is NULL';
    ELSIF NOT method = any('{"area"}') OR method IS NULL THEN
      RAISE EXCEPTION 'method not one of: "area"';
    ELSE      
      -- get count of intersects
      query = 'SELECT count(*) AS count FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ');';
      EXECUTE query INTO count;
      --RAISE NOTICE 'Count: %', count;

      -- return value based on count and method
      IF count = 0 THEN
        RAISE EXCEPTION 'No intersecting polygons for geometry: %', the_geom;
      ELSIF count = 1 THEN
        -- return the value
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ');';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'area' THEN
        -- return val from intersect with largest area
	query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ST_Area(''' || the_geom || '''::geometry) DESC LIMIT 1;';
	EXECUTE query INTO return;
	RETURN return;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersectInt
--
-- the_geom text - the geometry from the table that will receive the intersecting value
-- lookupSchemaName text - schema for the intersect table
-- lookupTableName text - table to intersect
-- geoCol text - geometry column from intersect table
-- lookupCol text - column conatining the values to return
-- method text - intersect method if multiple intersecting polygons
--    area - return value from intersecting polygon with largest area
--    lowestVal - return lowest value
--    highestVal - return highest value
-- 
-- Return the integer value from the intersecting polygon
--
-- e.g. TT_GeoIntersectint(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'public', 'bc08', 'geom', 'YEAR', 'area')

------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersectInt(text,text,text,text,text,text);
CREATE OR REPLACE FUNCTION TT_GeoIntersectInt(
  the_geom text,
  lookupSchemaName text,
  lookupTableName text,
  geoCol text,
  returnCol text,
  method text
)
RETURNS integer AS $$
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    count int;
    query text;
    return integer;
  BEGIN
    IF the_geom IS NULL THEN
      RAISE EXCEPTION 'geometry is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR geoCol IS NULL OR returnCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol or returnCol is NULL';
    ELSIF NOT method = any('{"area","lowestVal","highestVal"}') OR method IS NULL THEN
      RAISE EXCEPTION 'method not one of: "area", "lowestVal", or "higestVal"';
    ELSE      
      -- get count of intersects
      query = 'SELECT count(*) AS count FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ');';
      EXECUTE query INTO count;
      --RAISE NOTICE 'Count: %', count;

      -- return value based on count and method
      IF count = 0 THEN
        RAISE EXCEPTION 'No intersecting polygons for geometry: %', the_geom;
      ELSIF count = 1 THEN
        -- return the value
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ');';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'lowestVal' THEN
        -- return lowest val
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ' || returnCol || ' LIMIT 1;';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'highestVal' THEN
        -- return highest val
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ' || returnCol || ' DESC LIMIT 1;';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'area' THEN
        -- return val from intersect with largest area
	query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ST_Area(''' || the_geom || '''::geometry) DESC LIMIT 1;';
	EXECUTE query INTO return;
	RETURN return;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoIntersectDouble
--
-- the_geom text - the geometry from the table that will receive the intersecting value
-- lookupSchemaName text - schema for the intersect table
-- lookupTableName text - table to intersect
-- geoCol text - geometry column from intersect table
-- lookupCol text - column conatining the values to return
-- method text - intersect method if multiple intersecting polygons
--    area - return value from intersecting polygon with largest area
--    lowestVal - return lowest value
--    highestVal - return highest value
-- 
-- Return the double precision value from the intersecting polygon
--
-- e.g. TT_GeoIntersectDouble(ST_GeometryFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'), 'public', 'bc08', 'geom', 'YEAR', 'area')

------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoIntersectDouble(text,text,text,text,text,text);
CREATE OR REPLACE FUNCTION TT_GeoIntersectDouble(
  the_geom text,
  lookupSchemaName text,
  lookupTableName text,
  geoCol text,
  returnCol text,
  method text
)
RETURNS double precision AS $$
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    count int;
    query text;
    return double precision;
  BEGIN
    IF the_geom IS NULL THEN
      RAISE EXCEPTION 'geometry is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR geoCol IS NULL OR returnCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol or returnCol is NULL';
    ELSIF NOT method = any('{"area","lowestVal","highestVal"}') OR method IS NULL THEN
      RAISE EXCEPTION 'method not one of: "area", "lowestVal", or "higestVal"';
    ELSE      
      -- get count of intersects
      query = 'SELECT count(*) AS count FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ');';
      EXECUTE query INTO count;
      --RAISE NOTICE 'Count: %', count;

      -- return value based on count and method
      IF count = 0 THEN
        RAISE EXCEPTION 'No intersecting polygons for geometry: %', the_geom;
      ELSIF count = 1 THEN
        -- return the value
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ');';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'lowestVal' THEN
        -- return lowest val
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ' || returnCol || ' LIMIT 1;';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'highestVal' THEN
        -- return highest val
        query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ' || returnCol || ' DESC LIMIT 1;';
        EXECUTE query INTO return;
        RETURN return;
      ELSIF count > 1 AND method = 'area' THEN
        -- return val from intersect with largest area
	query = 'SELECT ' || returnCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE ST_Intersects(''' || the_geom || '''::geometry, ' || geoCol || ') ORDER BY ST_Area(''' || the_geom || '''::geometry) DESC LIMIT 1;';
	EXECUTE query INTO return;
	RETURN return;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

