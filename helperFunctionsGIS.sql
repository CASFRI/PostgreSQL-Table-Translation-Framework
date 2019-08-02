------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - GIS helper functions installation file
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
-- TT_GeoIntersectionText
--
-- the_geom text - the geometry from the table that will receive the intersecting value
-- intersectSchemaName text - schema for the intersect table
-- intersectTableName text - table to intersect
-- geoCol text - geometry column from intersect table
-- returnCol text - column containing the values to return
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
    _the_geom geometry;
    query text;
    geoRow RECORD;
    maxArea double precision = 0;
    maxAreaVal text;
    maxVal text;
    minVal text;
    count int = 0;
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
    query = 'SELECT ' || returnCol || ' AS return_value, ST_Area(ST_Intersection($1, ' || geoCol || ')) AS int_area 
    FROM ' || TT_FullTableName(_intersectSchemaName, _intersectTableName) ||
    ' WHERE ST_Intersects($1, ' || geoCol || ');';
    
    FOR geoRow IN EXECUTE query USING _the_geom LOOP
      IF geoRow.int_area > maxArea THEN
        maxArea = geoRow.int_area;
        maxAreaVal = geoRow.return_value::text;
      END IF;
      IF maxVal IS NULL OR geoRow.return_value::text > maxVal THEN
        maxVal = geoRow.return_value::text;
      END IF;
      IF minVal IS NULL OR geoRow.return_value::text < minVal THEN
        minVal = geoRow.return_value::text;
      END IF;
      count = count + 1;
    END LOOP;
    
    -- return value based on count and method
    RETURN CASE WHEN count = 0 THEN
                     NULL
                WHEN method = 'GREATEST_AREA' THEN
                     maxAreaVal
                WHEN method = 'LOWEST_VALUE' THEN
                     minVal
                ELSE
                     maxVAl
           END;
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
  SELECT CASE WHEN TT_IsNumeric(txtVal) THEN txtVal::double precision ELSE NULL END
  FROM (SELECT TT_GeoIntersectionText(the_geom, intersectSchemaName, intersectTableName, geoCol, returnCol, method, 'TT_GeoIntersectionDouble') txtVal) foo;
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
  SELECT CASE WHEN TT_IsInt(txtVal) THEN txtVal::int ELSE NULL END
  FROM (SELECT TT_GeoIntersectionText(the_geom, intersectSchemaName, intersectTableName, geoCol, returnCol, method, 'TT_GeoIntersectionInt') txtVal) foo;
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