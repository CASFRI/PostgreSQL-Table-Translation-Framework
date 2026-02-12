------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - GIS helper functions uninstallation file
-- Version 0.1 for PostgreSQL 9.x
-- https://github.com/CASFRI/postTranslationEngine
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>,
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
-------------------------------------------------------------------------------

-- validation helper functions
DROP FUNCTION IF EXISTS TT_IsGeometry(text);
DROP FUNCTION IF EXISTS TT_GeoIsValid(text, text);
DROP FUNCTION IF EXISTS TT_GeoIsValid(text);
DROP FUNCTION IF EXISTS TT_GeoIntersects(text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersects(text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersects(text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionGreaterThan(text, text, text, text, text, text, text);

-- translation helper functions
DROP FUNCTION IF EXISTS TT_GeoIntersectionText(text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionText(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionText(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionDouble(text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionDouble(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionInt(text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoIntersectionInt(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS TT_GeoMakeValid(text);
DROP FUNCTION IF EXISTS TT_GeoMakeValidMultiPolygon(text);
DROP FUNCTION IF EXISTS TT_GeoArea(text);
DROP FUNCTION IF EXISTS TT_GeoPerimeter(text);
