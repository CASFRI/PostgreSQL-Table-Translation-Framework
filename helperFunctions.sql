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
-- TT_DefaultErrorCode
--
--   rule text - Name of the rule.
--   targetType text - Required type.
--
--   RETURNS text - Default error code for this rule.
--
-- Return a default error code of the specified type for the specified rule.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DefaultErrorCode(text, text);
CREATE OR REPLACE FUNCTION TT_DefaultErrorCode(
  rule text, 
  targetType text
)
RETURNS text AS $$
  DECLARE
  BEGIN
    IF targetType = 'integer' OR targetType = 'int' OR targetType = 'double precision' THEN 
      RETURN CASE WHEN rule = 'translation_error'  THEN '-3333'
                  WHEN rule = 'notnull'            THEN '-8888'
                  WHEN rule = 'notempty'           THEN '-8889'
                  WHEN rule = 'isint'              THEN '-9995'
                  WHEN rule = 'isnumeric'          THEN '-9995'
                  WHEN rule = 'isbetween'          THEN '-9999'
                  WHEN rule = 'isgreaterthan'      THEN '-9999'
                  WHEN rule = 'islessthan'         THEN '-9999'
                  WHEN rule = 'haslength'          THEN '-9997'
                  WHEN rule = 'matchtable'         THEN '-9998'
                  WHEN rule = 'matchlist'          THEN '-9998'
                  WHEN rule = 'sumintmatchlist'    THEN '-9998'
                  WHEN rule = 'matchlengthlist'    THEN '-9998'
                  WHEN rule = 'notmatchlist'       THEN '-9998'
                  WHEN rule = 'false'              THEN '-8887'
                  WHEN rule = 'true'               THEN '-8887'
                  WHEN rule = 'hascountofnotnull'  THEN '-9997'
                  WHEN rule = 'isintsubstring'     THEN '-9997'
                  WHEN rule = 'isbetweensubstring' THEN '-9997'
                  WHEN rule = 'matchlistsubstring' THEN '-9998'
                  WHEN rule = 'geoisvalid'         THEN '-7779'
                  WHEN rule = 'geointersects'      THEN '-7778'
                  ELSE 'NO_DEFAULT_ERROR_CODE' END;
    ELSIF targetType = 'geometry' THEN
      RETURN CASE WHEN rule = 'translation_error'  THEN NULL
                  WHEN rule = 'notnull'            THEN NULL
                  WHEN rule = 'notempty'           THEN NULL
                  WHEN rule = 'isint'              THEN NULL
                  WHEN rule = 'isnumeric'          THEN NULL
                  WHEN rule = 'isbetween'          THEN NULL
                  WHEN rule = 'isgreaterthan'      THEN NULL
                  WHEN rule = 'islessthan'         THEN NULL
                  WHEN rule = 'haslength'          THEN NULL
                  WHEN rule = 'matchtable'         THEN NULL
                  WHEN rule = 'matchlist'          THEN NULL
                  WHEN rule = 'sumintmatchlist'    THEN NULL
                  WHEN rule = 'matchlengthlist'    THEN NULL
                  WHEN rule = 'notmatchlist'       THEN NULL
                  WHEN rule = 'false'              THEN NULL
                  WHEN rule = 'true'               THEN NULL
                  WHEN rule = 'hascountofnotnull'  THEN NULL
                  WHEN rule = 'isintsubstring'     THEN NULL
                  WHEN rule = 'isbetweensubstring' THEN NULL
                  WHEN rule = 'matchlistsubstring' THEN NULL
                  WHEN rule = 'geoisvalid'         THEN NULL
                  WHEN rule = 'geointersects'      THEN NULL
                  ELSE 'NO_DEFAULT_ERROR_CODE' END;
    ELSE
      RETURN CASE WHEN rule = 'translation_error'  THEN 'TRANSLATION_ERROR'
                  WHEN rule = 'notnull'            THEN 'NULL_VALUE'
                  WHEN rule = 'notempty'           THEN 'EMPTY_STRING'
                  WHEN rule = 'isint'              THEN 'WRONG_TYPE'
                  WHEN rule = 'isnumeric'          THEN 'WRONG_TYPE'
                  WHEN rule = 'isbetween'          THEN 'OUT_OF_RANGE'
                  WHEN rule = 'isgreaterthan'      THEN 'OUT_OF_RANGE'
                  WHEN rule = 'islessthan'         THEN 'OUT_OF_RANGE'
                  WHEN rule = 'haslength'          THEN 'INVALID_VALUE'
                  WHEN rule = 'isunique'           THEN 'NOT_UNIQUE'
                  WHEN rule = 'matchtable'         THEN 'NOT_IN_SET'
                  WHEN rule = 'matchlist'          THEN 'NOT_IN_SET'
                  WHEN rule = 'matchlengthlist'    THEN 'NOT_IN_SET'
                  WHEN rule = 'sumintmatchlist'    THEN 'NOT_IN_SET'
                  WHEN rule = 'notmatchlist'       THEN 'NOT_IN_SET'
                  WHEN rule = 'false'              THEN 'NOT_APPLICABLE'
                  WHEN rule = 'true'               THEN 'NOT_APPLICABLE'
                  WHEN rule = 'hascountofnotnull'  THEN 'INVALID_VALUE'
                  WHEN rule = 'isintsubstring'     THEN 'INVALID_VALUE'
                  WHEN rule = 'isbetweensubstring' THEN 'INVALID_VALUE'
                  WHEN rule = 'matchlistsubstring' THEN 'NOT_IN_SET'
                  WHEN rule = 'geoisvalid'         THEN 'INVALID_VALUE'
                  WHEN rule = 'geointersects'      THEN 'NO_INTERSECT'
                  ELSE 'NO_DEFAULT_ERROR_CODE' END;
    END IF;
  END;
$$ LANGUAGE plpgsql;
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
--  val text (string list) - Value(s) to test. Can be one or many.
--
-- Return TRUE if all vals are not NULL.
-- Return FALSE if any val is NULL.
-- e.g. TT_NotNULL('a')
-- e.g. TT_NotNull({'a', 'b', 'c'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNULL(
  val text
)
RETURNS boolean AS $$
  DECLARE
    _val text[];
  BEGIN
    -- validate source value (return FALSE)
    IF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    END IF;

    _val = TT_ParseStringList(val, TRUE);
    RETURN array_position(_val, NULL) IS NULL;
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
-- trim_spaces boolean - trim spaces from start and end before calculating length?
--
-- Count characters in string
-- e.g. TT_Length('12345')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Length(
  val text,
  trim_spaces text
)
RETURNS int AS $$
  DECLARE
    _trim_spaces boolean;
  BEGIN
    _trim_spaces = trim_spaces::boolean;
    
    IF _trim_spaces THEN
      RETURN coalesce(char_length(trim(val)), 0);
    ELSE
      RETURN coalesce(char_length(val), 0);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Length(
  val text
)
RETURNS int AS $$
  SELECT TT_Length(val, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_HasLength
--
-- val text - value to test.
-- length - Length to test against
--
-- Count characters in string and compare to length_test 
-- e.g. TT_HasLength('12345', 5)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasLength(
  val text,
  length_test text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _length_test int;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_HasLength',
                              ARRAY['acceptNull', acceptNull, 'boolean',
                                   'length_test', length_test, 'int']);
    _acceptNull = acceptNull::boolean;
    _length_test = length_test::int;
    
    IF TT_Length(val) = _length_test THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_HasLength(
  val text,
  length_test text
)
RETURNS boolean AS $$
  SELECT TT_HasLength(val, length_test, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsInt
--
--  val text - value to test.
--  acceptNull text - should NULL value return TRUE? Default FALSE.
--
--  Does value represent integer? (e.g. 1 or 1.0)
--  NULL values return FALSE unless acceptNull = TRUE
--  Strings with numeric characters and '.' will be evaluated
--  Strings with anything else (e.g. letter characters) return FALSE.
--  e.g. TT_IsInt('1.0')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
  val text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsInt',
                              ARRAY['acceptNull', acceptNull, 'boolean']);
    _acceptNull = acceptNull::boolean;
    
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
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

CREATE OR REPLACE FUNCTION TT_IsInt(
  val text
)
RETURNS boolean AS $$
  SELECT TT_IsInt(val, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNumeric
--
--  val text - Value to test.
--  acceptNull text - should NULL value return TRUE? Default FALSE.
--
--  Can value be cast to double precision? (e.g. 1.1, 1, '1.5')
--  NULL values return FALSE unless acceptNull = TRUE
--  e.g. TT_IsNumeric('1.1')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val text,
   acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsNumeric',
                              ARRAY['acceptNull', acceptNull, 'boolean']);
    _acceptNull = acceptNull::boolean;

    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
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

CREATE OR REPLACE FUNCTION TT_IsNumeric(
  val text
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(val, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsBoolean
--
-- Return TRUE if val is boolean
-- e.g. TT_IsBoolean('TRUE')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsBoolean(
  val text)
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
-- TT_IsName
--
-- Return TRUE if val is a PostGreSQL name
-- e.g. TT_IsName('val')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsName(
  argStr text
)
RETURNS boolean AS $$
  SELECT CASE WHEN argStr IS NULL OR 
                   upper(argStr) = 'TRUE' OR 
                   upper(argStr) = 'FALSE' THEN FALSE 
              ELSE argStr ~ '^([[:alpha:]_][[:alnum:]_]*|("[^"]*")+)$' 
         END
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsStringList
--
-- Return TRUE if val is a stringlist (or a simple string if strict = TRUE)
-- e.g. TT_IsStringList('{''val1'', ''val2'', ''val3''}')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsStringList(
  argStr text,
  strict boolean DEFAULT FALSE
)
RETURNS boolean AS $$
  DECLARE
    args text[];
  BEGIN
    IF argStr IS NULL THEN
      RETURN FALSE;
    ELSE
      BEGIN
        args = TT_ParseStringList(argStr);
        IF strict AND cardinality(args) = 1 THEN
          RETURN FALSE;
        END IF;
        RETURN TRUE;
      EXCEPTION WHEN OTHERS THEN
        -- if parsing failed with an error return false
        RETURN FALSE;
      END;
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
      ELSIF paramType = 'char' AND NOT TT_IsChar(paramVal) AND NOT paramVal = '' THEN -- char needs to support empty string so concat function can use sep = ''.
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
-- TT_IsBetween
--
-- val text - Value to test
-- min text - Minimum
-- max text - Maximum
-- includeMin - is min inclusive? Default True
-- includeMax - is max inclusive? Default True
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- Return TRUE if val is between min and max.
-- Return FALSE otherwise.
-- Return FALSE if val is NULL unless acceptNull = TRUE.
-- Return error if min, max, includeMin or includeMax are NULL.
-- e.g. TT_IsBetween(5, 0, 100)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsBetween(
  val text,
  min text,
  max text,
  includeMin text,
  includeMax text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _min double precision;
    _max double precision;
    _includeMin boolean;
    _includeMax boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsBetween',
                              ARRAY['min', min, 'numeric',
                                    'max', max, 'numeric',
                                    'includeMin', includeMin, 'boolean',
                                    'includeMax', includeMax, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _min = min::double precision;
    _max = max::double precision;
    _includeMin = includeMin::boolean;
    _includeMax = includeMax::boolean;
    _acceptNull = acceptNull::boolean;

    IF _min = _max THEN
      RAISE EXCEPTION 'ERROR in TT_IsBetween(): min is equal to max';
    ELSIF _min > _max THEN
      RAISE EXCEPTION 'ERROR in TT_IsBetween(): min is greater than max';
    END IF;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    ELSIF NOT TT_IsNumeric(val) THEN
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

CREATE OR REPLACE FUNCTION TT_IsBetween(
  val text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  SELECT TT_IsBetween(val, min, max, includeMin, includeMax, FALSE::text);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsBetween(
  val text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_IsBetween(val, min, max, TRUE::text, TRUE::text, FALSE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsGreaterThan
--
--  val text - Value to test.
--  lowerBound text - lower bound to test against.
--  inclusive text - is lower bound inclusive? Default TRUE.
--  acceptNull text - should NULL value return TRUE? Default FALSE.
--
--  Return TRUE if val >= lowerBound and inclusive = TRUE.
--  Return TRUE if val > lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL unless acceptNull = TRUE.
--  Return error if lowerBound or inclusive are NULL.
--  e.g. TT_IsGreaterThan(5, 0, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsGreaterThan(
   val text,
   lowerBound text,
   inclusive text,
   acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _lowerBound double precision;
    _inclusive boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsGreaterThan',
                              ARRAY['lowerBound', lowerBound, 'numeric',
                                    'inclusive', inclusive, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _lowerBound = lowerBound::double precision;
    _inclusive = inclusive::boolean;
    _acceptNull = acceptNull::boolean;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    ELSIF NOT TT_IsNumeric(val) THEN
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

CREATE OR REPLACE FUNCTION TT_IsGreaterThan(
  val text,
  lowerBound text,
  inclusive text
)
RETURNS boolean AS $$
  SELECT TT_IsGreaterThan(val, lowerBound, inclusive, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsGreaterThan(
  val text,
  lowerBound text
)
RETURNS boolean AS $$
  SELECT TT_IsGreaterThan(val, lowerBound, TRUE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsLessThan
--
--  val text - Value to test.
--  upperBound text - upper bound to test against.
--  inclusive text - is upper bound inclusive? Default True.
--  acceptNull text - should NULL value return TRUE? Default FALSE.
--
--  Return TRUE if val <= upperBound and inclusive = TRUE.
--  Return TRUE if val < upperBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL unless acceptNull = TRUE.
--  Return error if upperBound or inclusive are NULL.
--  e.g. TT_IsLessThan(1, 5, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsLessThan(
   val text,
   upperBound text,
   inclusive text,
   acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision;
    _upperBound double precision;
    _inclusive boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsLessThan',
                              ARRAY['upperBound', upperBound, 'numeric',
                                    'inclusive', inclusive, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _upperBound = upperBound::double precision;
    _inclusive = inclusive::boolean;
    _acceptNull = acceptNull::boolean;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    ELSIF NOT TT_IsNumeric(val) THEN
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

CREATE OR REPLACE FUNCTION TT_IsLessThan(
  val text,
  upperBound text,
  inclusive text
)
RETURNS boolean AS $$
  SELECT TT_IsLessThan(val, upperBound, inclusive, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsLessThan(
  val text,
  upperBound text
)
RETURNS boolean AS $$
  SELECT TT_IsLessThan(val, upperBound, TRUE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsUnique
--
-- val text - value to test.
-- lookupSchemaName text - schema name holding lookup table.
-- lookupTableName text - lookup table name.
-- occurrences - text defaults to 1
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- if number of occurences of val in source_val of schema.table equals occurences, return true.
-- e.g. TT_IsUnique('BS', 'public', 'bc08', 1)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  occurrences text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _lookupSchemaName name;
    _lookupTableName name;
    _occurrences int;
    query text;
    return boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsUnique',
                              ARRAY['lookupSchemaName', lookupSchemaName, 'text',
                                    'lookupTableName', lookupTableName, 'text',
                                    'occurrences', occurrences, 'int',
                                    'acceptNull', acceptNull, 'boolean']);
    _lookupSchemaName = lookupSchemaName::name;
    _lookupTableName = lookupTableName::name;
    _occurrences = occurrences::int;
    _acceptNull = acceptNull::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
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
  lookupTableName text,
  occurrences text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, lookupSchemaName, lookupTableName, occurrences, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, lookupSchemaName, lookupTableName, 1::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, 'public', lookupTableName, 1::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchTable
--
-- val text - value to test.
-- lookupSchemaName text - schema name holding lookup table.
-- lookupTableName text - lookup table.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- if val is present in source_val of schema.lookup table, returns TRUE.
-- e.g. TT_Match('BS', 'public', 'bc08', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  ignoreCase text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _lookupSchemaName name;
    _lookupTableName name;
    _ignoreCase boolean;
    query text;
    return boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchTable',
                              ARRAY['lookupSchemaName', lookupSchemaName, 'text',
                                    'lookupTableName', lookupTableName, 'text',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _lookupSchemaName = lookupSchemaName::name;
    _lookupTableName = lookupTableName::name;
    _ignoreCase = ignoreCase::boolean;
    _acceptNull = acceptNull::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
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
  lookupTableName text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, lookupSchemaName, lookupTableName, ignoreCase, FALSE::text)
$$ LANGUAGE sql VOLATILE;

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
  SELECT TT_MatchTable(val, 'public', lookupTableName, FALSE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchList
--
-- val text or string list - value to test. If string list, the list members are concatenated before testing.
-- lst text (stringList) - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- matches text - default TRUE. Should a match return true or false?
--
-- Is val in lst?
-- val followed by string of test values
-- e.g. TT_Match('a', {'a','b','c'})
-- e.g. TT_Match({'a', 'b'}, {'aa','ab','ac'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text,
  matches text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _val text;
    _lst text[];
    _ignoreCase boolean;
    _acceptNull boolean;
    _matches boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'acceptNull', acceptNull, 'boolean',
                                    'matches', matches, 'boolean']);
    _ignoreCase = ignoreCase::boolean;
    _acceptNull = acceptNull::boolean;
    _matches = matches::boolean;
    
    -- prepare vals
    -- if not already a string list, surround with {}. This ensures correct behaviour when parsing
    IF left(val, 1) = '{'  AND right(val, 1) = '}' THEN
      _vals = TT_ParseStringList(val, TRUE);  
    ELSE
      _vals = TT_ParseStringList('{'|| '''' || val || '''' || '}', TRUE);
    END IF;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;
    
    -- get val
    _val = array_to_string(_vals, '');

    -- process
    IF _ignoreCase = FALSE THEN
      _lst = TT_ParseStringList(lst, TRUE);
      IF _matches THEN
        RETURN _val = ANY(_lst);
      ELSE
        RETURN NOT _val = ANY(_lst);
      END IF;
    ELSE
      _lst = TT_ParseStringList(upper(lst), TRUE);
      IF _matches THEN
        RETURN upper(_val) = ANY(_lst);
      ELSE
        RETURN NOT upper(_val) = ANY(_lst);
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, acceptNull, TRUE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, FALSE::text, TRUE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, FALSE::text, FALSE::text, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotMatchList
--
-- val text - value to test.
-- lst text (stringList) - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- If val in list, return false?
-- simple wrapper arounf TT_MatchList() with matches = FALSE. 
-- e.g. TT_NotMatchList('d', {'a','b','c'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_NotMatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _acceptNull = acceptNull::boolean;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    SELECT TT_MatchList(val, lst, ignoreCase, acceptNull, FALSE::text);
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, FALSE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, FALSE::text, FALSE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SumIntMatchList
--
-- vals string list - integers to sum.
-- lst text (stringList) - string containing comma separated vals.
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- matches text - default TRUE. Should a match return true or false?
--
-- Is sum of vals in lst?
--
-- e.g. TT_SumIntMatchList({1, 1}, {2, 3, 4})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_SumIntMatchList(
  vals text,
  lst text,
  acceptNull text,
  matches text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _acceptNull boolean;
    _valSum int := 0;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_SumIntMatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'acceptNull', acceptNull, 'boolean',
                                    'matches', matches, 'boolean']);
     
    _acceptNull = acceptNull::boolean;
    
    -- validate source value
    IF vals IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;
    
    -- prepare vals
    _vals = TT_ParseStringList(vals, TRUE);
    
    -- check all source vals are int
    -- sum vals
    FOR i IN 1..array_length(_vals,1) LOOP
      IF NOT TT_isInt(_vals[i]) THEN
        RETURN FALSE;
      ELSE
        _valSum = _valSum + _vals[i]::int; -- sum vals
      END IF;
    END LOOP;
    
    -- run summed vals through tt_matchlist
    RETURN TT_Matchlist(_valSum::text, lst, acceptNull, matches);
    
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_SumIntMatchList(
  vals text,
  lst text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_SumIntMatchList(vals, lst, acceptNull, TRUE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_SumIntMatchList(
  vals text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_SumIntMatchList(vals, lst, FALSE::text, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LengthMatchList
--
-- val text - string to test length.
-- lst text (stringList) - list of integers to test against.
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- matches text - default TRUE. Should a match return true or false?
--
-- Is length of val in lst?
--
-- e.g. TT_LengthMatchList('abcd', {2, 3, 4, 5})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  val text,
  lst text,
  trim_spaces text,
  acceptNull text,
  matches text
)
RETURNS boolean AS $$
  DECLARE
    _valLength text;
    _trim_spaces boolean;
    _acceptNull boolean;
    _valSum int := 0;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_LengthMatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'trim_spaces', trim_spaces, 'boolean',
                                    'acceptNull', acceptNull, 'boolean',
                                    'matches', matches, 'boolean']);
     
    _acceptNull = acceptNull::boolean;
    _trim_spaces = trim_spaces::boolean;
    
    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;
    
    -- calculate length and cast to text
    IF _trim_spaces THEN
      _valLength = TT_Length(trim(val))::text;
    ELSE
      _valLength = TT_Length(val)::text;
    END IF;
    
    -- run summed vals through tt_matchlist
    RETURN TT_Matchlist(_valLength, lst, acceptNull, matches);
    
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text,
  trim_spaces text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, trim_spaces, acceptNull, TRUE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text,
  trim_spaces text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, trim_spaces, FALSE::text, TRUE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, FALSE::text, FALSE::text, TRUE::text)
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
-- HasCountOfNotNull()
--
-- val text - string list of values to test.
-- count int - number of notNulls to test against
-- exact boolean - should number of notNulls match count exactly?
-- testEmpty boolean - should we test for empty strings as well?
--
-- Return TRUE if exact = TRUE and number of notNulls matches count exactly.
-- Return FALSE if exact = FALSE and number of notNulls is greater than or 
-- equal to count.
-- If testEmpty = TRUE, it counts both the NULL values and any empty strings
-- in val.
--
-- e.g. TT_HasCountOfNotNull({'a','b','c'}, 3, TRUE, FALSE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  val text,
  count text,
  exact text,
  testEmpty text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _count int;
    _exact boolean;
    _testEmpty boolean;
  BEGIN
    -- validate source value (return FALSE)
    IF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    END IF;
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_HasCountOfNotNull',
                              ARRAY['count', count, 'int',
                                    'exact', exact, 'boolean',
                                   'testEmpty', testEmpty, 'boolean']);
    _count = count::int;
    _exact = exact::boolean;
    _testEmpty = testEmpty::boolean;

    -- process
    _vals = TT_ParseStringList(val, TRUE);
    IF _testEmpty THEN -- note tt_notempty returns false for both NULL and ''
      IF _exact THEN
        RETURN (SELECT count(*) FROM unnest(_vals) x WHERE TT_NotEmpty(x)) = _count;
      ELSE
        RETURN (SELECT count(*) FROM unnest(_vals) x WHERE TT_NotEmpty(x)) >= _count;
      END IF;
    ELSE
      IF _exact THEN
        RETURN (SELECT count(*) FROM unnest(_vals) x WHERE TT_NotNull(x)) = _count;
      ELSE
        RETURN (SELECT count(*) FROM unnest(_vals) x WHERE TT_NotNull(x)) >= _count;
      END IF;
    END IF;
    RETURN _notNullCount;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  val text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(val, count, exact, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  val text,
  count text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(val, count, TRUE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------
-- TT_IsIntSubstring(text, text, text)
--
-- val text - input string
-- start_char - start character to take substring from
-- for_length - length of substring to take
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- Take substring and test isInt
-- e.g. TT_IsIntSubstring('2001-01-01', 1, 4)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsIntSubstring(
  val text,
  start_char text,
  for_length text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _start_char int;
    _for_length int;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsIntSubstring',
                              ARRAY['start_char', start_char, 'int',
                                    'for_length', for_length, 'int',
                                    'acceptNull', acceptNull, 'boolean']);
    _start_char = start_char::int;
    _for_length = for_length::int;
    _acceptNull = acceptNull::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    -- process
    RETURN TT_IsInt(substring(val from _start_char for _for_length));
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsIntSubstring(
  val text,
  start_char text,
  for_length text
)
RETURNS boolean AS $$
  SELECT TT_IsIntSubstring(val, start_char, for_length, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------
-- TT_IsBetweenSubstring(text, text, text, text, text, text, text, text)
--
-- val text - input string
-- start_char text - start character to take substring from
-- for_length text - length of substring to take
-- min text - lower between bound
-- max text - upper between bound
-- includeMin text - boolean for including lower bound
-- includeMax text - boolean for including upper bound
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- Take substring and test with TT_IsBetween()
-- e.g. TT_IsBetweenSubstring('2001-01-01', 1, 4, 1900, 2100, TRUE, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  start_char text,
  for_length text,
  min text,
  max text,
  includeMin text,
  includeMax text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _start_char int;
    _for_length int;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsBetweenSubstring',
                              ARRAY['start_char', start_char, 'int',
                                    'for_length', for_length, 'int',
                                    'min', min, 'numeric',
                                    'max', max, 'numeric',
                                    'includeMin', includeMin, 'boolean',
                                    'includeMax', includeMax, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _start_char = start_char::int;
    _for_length = for_length::int;
    _acceptNull = acceptNull::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    -- process
    RETURN TT_IsBetween(substring(val from _start_char for _for_length), min, max, includeMin, includeMax);
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  start_char text,
  for_length text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  SELECT TT_IsBetweenSubstring(val, start_char, for_length, min, max, includeMin, includeMin, FALSE::text);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  start_char text,
  for_length text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_IsBetweenSubstring(val, start_char, for_length, min, max, TRUE::text, TRUE::text);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_MatchListSubstring(text, text, text)
--
-- val text or string list - value to test.
--
-- start_char - start character to take substring from
-- for_length - length of substring to take
--
-- lst text (stringList) - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- matches text - default TRUE. Should a match return true or false?
--
-- Take substring and test matchList
-- e.g. TT_MatchListSubstring('2001-01-01', 1, 4, {2001, 2002})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  start_char text,
  for_length text,
  lst text,
  ignoreCase text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _val text;
    _start_char int;
    _for_length int;    
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchListSubstring',
                              ARRAY['lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'start_char', start_char, 'int',
                                    'for_length', for_length, 'int',
                                    'acceptNull', acceptNull, 'boolean']);
    _start_char = start_char::int;
    _for_length = for_length::int;
    _acceptNull = acceptNull::boolean;

    -- prepare vals
    -- if not already a string list, surround with {}. This ensures correct behaviour when parsing
    IF left(val, 1) = '{'  AND right(val, 1) = '}' THEN
      _vals = TT_ParseStringList(val, TRUE);  
    ELSE
      _vals = TT_ParseStringList('{'|| '''' || val || '''' || '}', TRUE);
    END IF;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;
    
    -- run substring on each element of array, then concatenate
    -- Here we are doing the substring and the concatenation (if >1 string list element), then passing
    -- the concatenated value into matchList. So this matchList wrapper will only ever receive a single
    -- string.
    _val = array_to_string(ARRAY(SELECT substring(unnest(_vals) from _start_char for _for_length)), '');
    
    -- process
    RETURN TT_MatchList(_val, lst, ignoreCase, acceptNull);
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  start_char text,
  for_length text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchListSubstring(val, start_char, for_length, lst, ignoreCase, FALSE::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  start_char text,
  for_length text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchListSubstring(val, start_char, for_length, lst, FALSE::text, FALSE::text)
$$ LANGUAGE sql VOLATILE;

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
--
-- NULL source values are converted to empty strings. This allows NULLs to be
-- translated into a target value by using an empty string in the lookup table.
-- For csv tables this is just a blank cell.
--
-- Any source val (including empty strings, aka NULLs) that is not included in the lookup table returns NULL.
--
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
    _val text;
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

    -- convert source NULLs into empty strings. This allows NULL source values to be translated into target
    -- values by using an empty string in the lookup table. If no empty string translation is provided, function
    -- returns NULL as usual.
    IF val IS NULL THEN
      _val = '';
    ELSE
      _val = val;
    END IF;

    -- process
    query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) ||
            CASE WHEN _ignoreCase IS TRUE THEN
                   ' WHERE upper(source_val::text) = upper(' || quote_literal(_val) || ')'
                 ELSE
                   ' WHERE source_val = ' || quote_literal(_val)
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
-- vals text - string list containing values to test. Or a single value to test.-- mapVals text (stringList) - string list of mapping values
-- targetVals (stringList) text - string list of target values
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return value from targetVals that matches value index in mapVals
-- If multiple vals provided they are concatenated before testing.
-- Return type is text
-- Error if val is NULL
-- e.g. TT_Map('A', '{''A'',''B'',''C''}', '{''1'',''2'',''3''}', 'TRUE')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapText(
  vals text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS text AS $$
  DECLARE
    _vals text[];
    _val text;
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapText',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _vals = TT_ParseStringList(vals, TRUE);
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);

    -- validate source value (return NULL if not valid)
    IF vals IS NULL THEN
      RETURN NULL;
    END IF;

    -- prepare vals
    -- if not already a string list, surround with {}. This ensures correct behaviour when parsing
    IF left(vals, 1) = '{'  AND right(vals, 1) = '}' THEN
      _vals = TT_ParseStringList(vals, TRUE);  
    ELSE
      _vals = TT_ParseStringList('{' || '''' || vals || '''' || '}', TRUE);
    END IF;
    
    -- get val
    _val = array_to_string(_vals, '');

    -- process
    IF _ignoreCase = FALSE THEN
      _mapVals = TT_ParseStringList(mapVals, TRUE);
      RETURN (_targetVals)[array_position(_mapVals, _val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE);
      RETURN (_targetVals)[array_position(_mapVals, upper(_val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapText(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MapText(vals, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapSubstringText
--
-- vals text - string list containing values to test. Or a single value to test.-- mapVals text (stringList) - string list of mapping values
--
-- start_char - start character to take substring from
-- for_length - length of substring to take
--
-- targetVals (stringList) text - string list of target values
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- get substring of val and test mapText
-- e.g. TT_MapSubstringText('ABC', 2, 1, '{''A'',''B'',''C''}', '{''1'',''2'',''3''}', 'TRUE')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapSubstringText(
  vals text,
  start_char text,
  for_length text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS text AS $$
  DECLARE
    _vals text[];
    _val text;
    _start_char int;
    _for_length int;
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapSubstringText',
                              ARRAY['start_char', start_char, 'int',
                                    'for_length', for_length, 'int',
                                    'mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    _vals = TT_ParseStringList(vals, TRUE);
    _start_char = start_char::int;
    _for_length = for_length::int;
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);

    -- validate source value (return NULL if not valid)
    IF vals IS NULL THEN
      RETURN NULL;
    END IF;

    -- prepare vals
    -- if not already a string list, surround with {}. This ensures correct behaviour when parsing
    IF left(vals, 1) = '{'  AND right(vals, 1) = '}' THEN
      _vals = TT_ParseStringList(vals, TRUE);  
    ELSE
      _vals = TT_ParseStringList('{' || '''' || vals || '''' || '}', TRUE);
    END IF;
    
    -- run substring on each element of array, then concatenate
    -- Here we are doing the substring and the concatenation (if >1 string list element), then passing
    -- the concatenated value into matchList. So this matchList wrapper will only ever receive a single
    -- string.
    _val = array_to_string(ARRAY(SELECT substring(unnest(_vals) from _start_char for _for_length)), '');
    
    -- process
    RETURN TT_MapText(_val, mapVals, targetVals, ignoreCase);
    
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapSubstringText(
  vals text,
  start_char text,
  for_length text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MapSubstringText(vals, start_char, for_length, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SumIntMapText
--
-- vals string list - integers to sum.
-- mapVals text (stringList) - string list of mapping values
-- targetVals (stringList) text - string list of target values
--
-- Map sum of vals from mapVals to targetVals
--
-- Return value from targetVals that matches summed value index in mapVals
-- Return type is text
-- Error if vals is NULL or sum of vals is not in mapVals. 
-- e.g. TT_SumIntMapText('{1,2}', '{3,4,5}', '{A, B, C}')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_SumIntMapText(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  DECLARE
    _vals text[];
    _valSum int := 0;   
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_SumIntMapText',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist']);
                                    
    _vals = TT_ParseStringList(vals, TRUE);

    -- validate source value (return NULL if not valid)
    IF vals IS NULL THEN
      RETURN NULL;
    END IF;

    -- check all source vals are int
    -- sum vals
    FOR i IN 1..array_length(_vals,1) LOOP
      IF NOT TT_isInt(_vals[i]) THEN
        RETURN NULL;
      ELSE
        _valSum = _valSum + _vals[i]::int; -- sum vals
      END IF;
    END LOOP;

    -- run TT_MapText with summed vals
    RETURN TT_MapText(_valSum::text, mapVals, targetVals);
    
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapDouble
--
-- vals text - string list containing values to test. Or a single value to test.
-- mapVals text - string containing comma seperated vals
-- targetVals text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return double precision value from targetVals that matches value index in mapVals
-- If multiple vals provided they are concatenated before testing.
-- Return type is double precision
-- Error if val is NULL, or if any targetVals elements cannot be cast to double precision, or if val is not in mapVals
-- e.g. TT_Map('A',{'A','B','C'},{'1.1','2.2','3.3'})

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapDouble(
  vals text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS double precision AS $$
  DECLARE
    _vals text[];
    _val text;
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapDouble',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'doublelist',
                                    'ignoreCase', ignoreCase, 'boolean']);
    
    _vals = TT_ParseStringList(vals, TRUE);
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);

    -- validate source value (return NULL if not valid)
    IF vals IS NULL THEN
      RETURN NULL;
    END IF;

    -- prepare vals
    -- if not already a string list, surround with {}. This ensures correct behaviour when parsing
    IF left(vals, 1) = '{'  AND right(vals, 1) = '}' THEN
      _vals = TT_ParseStringList(vals, TRUE);  
    ELSE
      _vals = TT_ParseStringList('{' || '''' || vals || '''' || '}', TRUE);
    END IF;
    
    -- get val
    _val = array_to_string(_vals, '');
    
    -- process
    IF _ignoreCase = FALSE THEN
      _mapVals = TT_ParseStringList(mapVals, TRUE);  
      RETURN (_targetVals)[array_position(_mapVals, _val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE);
      RETURN (_targetVals)[array_position(_mapVals,upper(_val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapDouble(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS double precision AS $$
  SELECT TT_MapDouble(vals, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapInt
--
-- vals text - string list containing values to test. Or a single value to test.
-- mapVals text - string containing comma seperated vals
-- targetVals text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
--
-- Return int value from targetVals that matches value index in mapVals
-- If multiple vals provided they are concatenated before testing.
-- Return type is int
-- Error if val is NULL, or if any targetVals elements are not int, or if val is not in mapVals
-- e.g. TT_MapInt('A',{'A','B','C'}, {'1','2','3'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapInt(
  vals text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS int AS $$
  DECLARE
    _vals text[];
    _val text;
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
    
    _vals = TT_ParseStringList(vals, TRUE);
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);

    -- validate source value (return NULL if not valid)
    IF vals IS NULL THEN
      RETURN NULL;
    END IF;

    -- prepare vals
    -- if not already a string list, surround with {}. This ensures correct behaviour when parsing
    IF left(vals, 1) = '{'  AND right(vals, 1) = '}' THEN
      _vals = TT_ParseStringList(vals, TRUE);  
    ELSE
      _vals = TT_ParseStringList('{' || '''' || vals || '''' || '}', TRUE);
    END IF;
    
    -- get val
    _val = array_to_string(_vals, '');
    
    -- process
    IF _ignoreCase = FALSE THEN
      _mapVals = TT_ParseStringList(mapVals, TRUE);
      RETURN (_targetVals)[array_position(_mapVals, _val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE);
      RETURN (_targetVals)[array_position(_mapVals,upper(_val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_MapInt(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$
  SELECT TT_MapInt(vals, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LengthMapInt
--
-- val string list - string to calculate length.
-- mapVals text (stringList) - string list of mapping values
-- targetVals (stringList) text - string list of target values
--
-- Map length of val from mapVals to targetVals
-- return type is int
--
-- Return NULL if val is NULL or length of val is not in mapVals. 
-- e.g. TT_LengthMapInt('1234', '{3,4,5}', '{1, 1, 2}')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LengthMapInt(
  val text,
  mapVals text,
  targetVals text,
  trim_spaces text
)
RETURNS int AS $$
  DECLARE
    _valLength text;
    _trim_spaces text;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_LengthMapInt',
                              ARRAY['trim_spaces', trim_spaces, 'boolean',
                                    'mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist']);

    _trim_spaces = trim_spaces::boolean;

    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN NULL;
    END IF;
    
    IF _trim_spaces THEN
      _valLength = TT_Length(val, TRUE::text)::text;
    ELSE
      _valLength = TT_Length(val)::text;
    END IF;

    -- run TT_MapText with summed vals
    RETURN TT_MapText(_valLength, mapVals, targetVals)::int;
    
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LengthMapInt(
  val text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$
  SELECT TT_LengthMapInt(val, mapVals, targetVals, FALSE::text)
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
    RETURN array_to_string(TT_ParseStringList(val, TRUE), sep);
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

    _lengths = TT_ParseStringList(length, TRUE);
    _pads = TT_ParseStringList(pad, TRUE);

    -- check length of _lengths matches and _pads match
    IF array_length(_vals, 1) != array_length(_pads, 1) THEN
      RAISE EXCEPTION 'ERROR in number TT_PadConcat(): length and pad elements do not match';
    END IF;

    -- validate source value (return NULL if not valid)
    IF TT_NotNull(val) AND NOT TT_IsStringList(val) THEN
      RETURN NULL;
    END IF;

    IF _upperCase = TRUE THEN
      _vals = TT_ParseStringList(upper(val), TRUE);
    ELSE
      _vals = TT_ParseStringList(val, TRUE);
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
-- TT_CountOfNotNull()
--
-- vals1/2/3/4/5/6/7 text - string lists of values to test.
-- max_rank_to_consider int - only consider the first x string lists.
-- i.e. if max_rank_to_consider = 3, only vals1, vals2 and vals3 are condsidered.
--
-- Returns the number of vals lists where at least one element in the vals list 
-- is not null.
--
-- e.g. TT_CountOfNotNull({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  max_rank_to_consider text
)
RETURNS int AS $$
  DECLARE
    _vals1 text[];
    _vals2 text[];
    _vals3 text[];
    _vals4 text[];
    _vals5 text[];
    _vals6 text[];
    _vals7 text[];
    _max_rank_to_consider int;
    _count int;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_CountOfNotNull',
                              ARRAY['max_rank_to_consider', max_rank_to_consider, 'int']);

    -- Validate source values (return NULL)
    IF TT_NotNull(vals1) AND NOT TT_IsStringList(vals1) OR
       TT_NotNull(vals2) AND NOT TT_IsStringList(vals2) OR
       TT_NotNull(vals3) AND NOT TT_IsStringList(vals3) OR
       TT_NotNull(vals4) AND NOT TT_IsStringList(vals4) OR
       TT_NotNull(vals5) AND NOT TT_IsStringList(vals5) OR
       TT_NotNull(vals6) AND NOT TT_IsStringList(vals6) OR
       TT_NotNull(vals7) AND NOT TT_IsStringList(vals7) THEN
      RETURN NULL;
    END IF;
    
    -- Parse them
    _vals1 = TT_ParseStringList(vals1, TRUE);
    _vals2 = TT_ParseStringList(vals2, TRUE);
    _vals3 = TT_ParseStringList(vals3, TRUE);
    _vals4 = TT_ParseStringList(vals4, TRUE);
    _vals5 = TT_ParseStringList(vals5, TRUE);
    _vals6 = TT_ParseStringList(vals6, TRUE);
    _vals7 = TT_ParseStringList(vals7, TRUE);
    _max_rank_to_consider = max_rank_to_consider::int;

    -- Get count of not null vals lists
    IF _max_rank_to_consider = 0 THEN
      RETURN 0;
    ELSEIF _max_rank_to_consider = 1 THEN 
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;
    
    ELSEIF _max_rank_to_consider = 2 THEN
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;
      
    ELSEIF _max_rank_to_consider = 3 THEN
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;
      
    ELSIF _max_rank_to_consider = 4 THEN
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;

    ELSIF _max_rank_to_consider = 5 THEN
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;

    ELSIF _max_rank_to_consider = 6 THEN
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;
    
    ELSE
      WITH a AS (
        SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x)) > 0 as y
        UNION ALL
        SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x)) > 0 as y
      )
      SELECT sum(y::int) FROM a INTO _count;
    END IF;

    -- Return count
    RETURN _count;
    
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  max_rank_to_consider text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, '{NULL}', max_rank_to_consider)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  max_rank_to_consider text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, '{NULL}', '{NULL}', max_rank_to_consider)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  max_rank_to_consider text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  max_rank_to_consider text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, '{NULL}', '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  max_rank_to_consider text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  max_rank_to_consider text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IfElseCountOfNotNullText()
--
-- vals1/2/3/4/5/6/7 text - string lists of values to test. Same as TT_IfElseCountOfNotNullText().
-- max_rank_to_consider int - only consider the first x string lists. Same as TT_IfElseCountOfNotNullText().
-- cutoff_val - value to use in ifelse
-- str_1 - if TT_CountOfNotNull() returns less than or equal to cutoffVal, return this string
-- str_2 - if TT_CountOfNotNull() returns greater than cutoffVal, return this string
--
-- e.g. TT_IfElseCountOfNotNullText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, 1, 'S', 'M')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  DECLARE
    _cutoff_val int;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IfElseCountOfNotNullText',
                              ARRAY['cutoff_val', cutoff_val, 'int',
                                   'str_1', str_1, 'text',
                                   'str_2', str_2, 'text']);
    _cutoff_val = cutoff_val::int;
    
    IF TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, max_rank_to_consider) <= _cutoff_val THEN
      RETURN str_1;
    ELSE
      RETURN str_2;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, '{NULL}', max_rank_to_consider, cutoff_val, str_1, str_2)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, '{NULL}', '{NULL}', max_rank_to_consider, cutoff_val, str_1, str_2)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider, cutoff_val, str_1, str_2)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, '{NULL}', '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider, cutoff_val, str_1, str_2)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider, cutoff_val, str_1, str_2)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  max_rank_to_consider text,
  cutoff_val text,
  str_1 text,
  str_2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', max_rank_to_consider, cutoff_val, str_1, str_2)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SubstringText()
--
-- val text - input string
-- start_char text - start character to take substring from
-- for_length text - length of substring to take
--
-- basic wrapper around postgresql substring(), returning text
-- e.g. TT_SubstringText('abcd', 1, 1)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_SubstringText(text, text, text);
CREATE OR REPLACE FUNCTION TT_SubstringText(
  val text,
  start_char text,
  for_length text
)
RETURNS text AS $$
  DECLARE
    _start_char int;
    _for_length int;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_SubstringText',
                              ARRAY['start_char', start_char, 'int',
                                   'for_length', for_length, 'int']);
    _start_char = start_char::int;
    _for_length = for_length::int;

    -- process
    RETURN substring(val from _start_char for _for_length);
    
   END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SubstringInt()
--
-- val text - input string
-- start_char text - start character to take substring from
-- for_length text - length of substring to take
--
-- basic wrapper around postgresql substring(), returning int
-- e.g. TT_SubstringText('124', 1, 1)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_SubstringInt(text, text, text);
CREATE OR REPLACE FUNCTION TT_SubstringInt(
  val text,
  start_char text,
  for_length text
)
RETURNS int AS $$
  DECLARE
    _start_char int;
    _for_length int;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_SubstringInt',
                              ARRAY['start_char', start_char, 'int',
                                   'for_length', for_length, 'int']);
    _start_char = start_char::int;
    _for_length = for_length::int;

    -- process
    RETURN substring(val from _start_char for _for_length)::int;
    
   END;
$$ LANGUAGE plpgsql VOLATILE;