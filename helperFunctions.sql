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
      RETURN CASE WHEN rule = 'translation_error'       THEN '-3333'
                  WHEN rule = 'notnull'                 THEN '-8888'
                  WHEN rule = 'notempty'                THEN '-8889'
                  WHEN rule = 'isint'                   THEN '-9995'
                  WHEN rule = 'isnumeric'               THEN '-9995'
                  WHEN rule = 'isbetween'               THEN '-9999'
                  WHEN rule = 'isgreaterthan'           THEN '-9999'
                  WHEN rule = 'islessthan'              THEN '-9999'
                  WHEN rule = 'haslength'               THEN '-9997'
                  WHEN rule = 'matchtable'              THEN '-9998'
                  WHEN rule = 'matchlist'               THEN '-9998'
                  WHEN rule = 'sumintmatchlist'         THEN '-9998'
                  WHEN rule = 'lengthmatchlist'         THEN '-9998'
                  WHEN rule = 'notmatchlist'            THEN '-9998'
                  WHEN rule = 'false'                   THEN '-8887'
                  WHEN rule = 'true'                    THEN '-8887'
                  WHEN rule = 'hascountofnotnull'       THEN '-9997'
                  WHEN rule = 'hascountofnotnullorzero' THEN '-9997'
                  WHEN rule = 'isintsubstring'          THEN '-9997'
                  WHEN rule = 'isbetweensubstring'      THEN '-9999'
                  WHEN rule = 'matchlistsubstring'      THEN '-9998'
                  WHEN rule = 'minindexnotnull'         THEN '-8888'
                  WHEN rule = 'maxindexnotnull'         THEN '-8888'
                  WHEN rule = 'minindexnotempty'        THEN '-8889'
                  WHEN rule = 'maxindexnotempty'        THEN '-8889'
                  WHEN rule = 'minindexisint'           THEN '-9995'
                  WHEN rule = 'maxindexisint'           THEN '-9995'
                  WHEN rule = 'minindexisbetween'       THEN '-9999'
                  WHEN rule = 'maxindexisbetween'       THEN '-9999'
                  WHEN rule = 'minindexmatchlist'       THEN '-9998'
                  WHEN rule = 'maxindexmatchlist'       THEN '-9998'
                  WHEN rule = 'minindexmatchtable'      THEN '-9998'
                  WHEN rule = 'maxindexmatchtable'      THEN '-9998'
                  WHEN rule = 'isxminusybetween'        THEN '-9999'
                  WHEN rule = 'matchlisttwice'          THEN '-9998'
                  WHEN rule = 'lookuptextmatchlist'     THEN '-9998'
                  WHEN rule = 'geoisvalid'              THEN '-7779'
                  WHEN rule = 'geointersects'           THEN '-7778'
                  WHEN rule = 'geointersectiongreaterthan' THEN '-9999'
                  WHEN rule = 'matchtablesubstring'     THEN '-9998'
                  WHEN rule = 'coalesceisint'           THEN '-9995'
                  WHEN rule = 'coalesceisbetween'       THEN '-9999'
                  WHEN rule = 'islessthanlookupdouble'  THEN '-9999'
				  WHEN rule = 'hascountofmatchlist'     THEN '-9997'
                  ELSE 'NO_DEFAULT_ERROR_CODE' END;
    ELSIF targetType = 'geometry' THEN
      RETURN CASE WHEN rule = 'translation_error'       THEN NULL
                  WHEN rule = 'notnull'                 THEN NULL
                  WHEN rule = 'notempty'                THEN NULL
                  WHEN rule = 'isint'                   THEN NULL
                  WHEN rule = 'isnumeric'               THEN NULL
                  WHEN rule = 'isbetween'               THEN NULL
                  WHEN rule = 'isgreaterthan'           THEN NULL
                  WHEN rule = 'islessthan'              THEN NULL
                  WHEN rule = 'haslength'               THEN NULL
                  WHEN rule = 'matchtable'              THEN NULL
                  WHEN rule = 'matchlist'               THEN NULL
                  WHEN rule = 'sumintmatchlist'         THEN NULL
                  WHEN rule = 'lengthmatchlist'         THEN NULL
                  WHEN rule = 'notmatchlist'            THEN NULL
                  WHEN rule = 'false'                   THEN NULL
                  WHEN rule = 'true'                    THEN NULL
                  WHEN rule = 'hascountofnotnull'       THEN NULL
                  WHEN rule = 'hascountofnotnullorzero' THEN NULL
                  WHEN rule = 'isintsubstring'          THEN NULL
                  WHEN rule = 'isbetweensubstring'      THEN NULL
                  WHEN rule = 'matchlistsubstring'      THEN NULL
                  WHEN rule = 'minindexnotnull'         THEN NULL
                  WHEN rule = 'maxindexnotnull'         THEN NULL
                  WHEN rule = 'minindexnotempty'        THEN NULL
                  WHEN rule = 'maxindexnotempty'        THEN NULL
                  WHEN rule = 'minindexisint'           THEN NULL
                  WHEN rule = 'maxindexisint'           THEN NULL
                  WHEN rule = 'minindexisbetween'       THEN NULL
                  WHEN rule = 'maxindexisbetween'       THEN NULL
                  WHEN rule = 'minindexmatchlist'       THEN NULL
                  WHEN rule = 'maxindexmatchlist'       THEN NULL
                  WHEN rule = 'minindexmatchtable'      THEN NULL
                  WHEN rule = 'maxindexmatchtable'      THEN NULL
                  WHEN rule = 'isxminusybetween'        THEN NULL
                  WHEN rule = 'lookuptextmatchlist'     THEN NULL
                  WHEN rule = 'matchlisttwice'          THEN NULL
                  WHEN rule = 'geoisvalid'              THEN NULL
                  WHEN rule = 'geointersects'           THEN NULL
                  WHEN rule = 'geointersectiongreaterthan' THEN NULL
                  WHEN rule = 'matchtablesubstring'     THEN NULL
                  WHEN rule = 'coalesceisint'           THEN NULL
                  WHEN rule = 'coalesceisbetween'       THEN NULL
                  WHEN rule = 'islessthanlookupdouble'  THEN NULL
				  WHEN rule = 'hascountofmatchlist'     THEN NULL
                  ELSE 'NO_DEFAULT_ERROR_CODE' END;
    ELSE
      RETURN CASE WHEN rule = 'translation_error'       THEN 'TRANSLATION_ERROR'
                  WHEN rule = 'notnull'                 THEN 'NULL_VALUE'
                  WHEN rule = 'notempty'                THEN 'EMPTY_STRING'
                  WHEN rule = 'isint'                   THEN 'WRONG_TYPE'
                  WHEN rule = 'isnumeric'               THEN 'WRONG_TYPE'
                  WHEN rule = 'isbetween'               THEN 'OUT_OF_RANGE'
                  WHEN rule = 'isgreaterthan'           THEN 'OUT_OF_RANGE'
                  WHEN rule = 'islessthan'              THEN 'OUT_OF_RANGE'
                  WHEN rule = 'haslength'               THEN 'INVALID_VALUE'
                  WHEN rule = 'isunique'                THEN 'NOT_UNIQUE'
                  WHEN rule = 'matchtable'              THEN 'NOT_IN_SET'
                  WHEN rule = 'matchlist'               THEN 'NOT_IN_SET'
                  WHEN rule = 'lengthmatchlist'         THEN 'NOT_IN_SET'
                  WHEN rule = 'sumintmatchlist'         THEN 'NOT_IN_SET'
                  WHEN rule = 'notmatchlist'            THEN 'NOT_IN_SET'
                  WHEN rule = 'false'                   THEN 'NOT_APPLICABLE'
                  WHEN rule = 'true'                    THEN 'NOT_APPLICABLE'
                  WHEN rule = 'hascountofnotnull'       THEN 'INVALID_VALUE'
                  WHEN rule = 'hascountofnotnullorzero' THEN 'INVALID_VALUE'
                  WHEN rule = 'isintsubstring'          THEN 'INVALID_VALUE'
                  WHEN rule = 'isbetweensubstring'      THEN 'OUT_OF_RANGE'
                  WHEN rule = 'matchlistsubstring'      THEN 'NOT_IN_SET'
                  WHEN rule = 'minindexnotnull'         THEN 'NULL_VALUE'
                  WHEN rule = 'maxindexnotnull'         THEN 'NULL_VALUE'
                  WHEN rule = 'minindexnotempty'        THEN 'EMPTY_STRING'
                  WHEN rule = 'maxindexnotempty'        THEN 'EMPTY_STRING'
                  WHEN rule = 'minindexisint'           THEN 'WRONG_TYPE'
                  WHEN rule = 'maxindexisint'           THEN 'WRONG_TYPE'
                  WHEN rule = 'minindexisbetween'       THEN 'OUT_OF_RANGE'
                  WHEN rule = 'maxindexisbetween'       THEN 'OUT_OF_RANGE'
                  WHEN rule = 'minindexmatchlist'       THEN 'NOT_IN_SET'
                  WHEN rule = 'maxindexmatchlist'       THEN 'NOT_IN_SET'
                  WHEN rule = 'minindexmatchtable'      THEN 'NOT_IN_SET'
                  WHEN rule = 'maxindexmatchtable'      THEN 'NOT_IN_SET'
                  WHEN rule = 'isxminusybetween'        THEN 'OUT_OF_RANGE'
                  WHEN rule = 'matchlisttwice'          THEN 'NOT_IN_SET'
                  WHEN rule = 'lookuptextmatchlist'     THEN 'NOT_IN_SET'
                  WHEN rule = 'geoisvalid'              THEN 'INVALID_VALUE'
                  WHEN rule = 'geointersects'           THEN 'NO_INTERSECT'
                  WHEN rule = 'geointersectiongreaterthan' THEN 'OUT_OF_RANGE'
                  WHEN rule = 'matchtablesubstring'     THEN 'NOT_IN_SET'
                  WHEN rule = 'coalesceisint'           THEN 'WRONG_TYPE'
                  WHEN rule = 'coalesceisbetween'       THEN 'OUT_OF_RANGE'
                  WHEN rule = 'islessthanlookupdouble'  THEN 'OUT_OF_RANGE'
				  WHEN rule = 'hascountofmatchlist'     THEN 'INVALID_VALUE'
                  ELSE 'NO_DEFAULT_ERROR_CODE' END;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Internal functions used in helper functions
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_min_internal(int[])
-- TT_max_internal(int[])
--
-- vals int[] - array of integer values.
-- min and max calculation for internal use. Not a helper function.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_min_internal(double precision[]);
CREATE OR REPLACE FUNCTION TT_min_internal(
  vals double precision[]
)
RETURNS double precision AS $$
  BEGIN
    RETURN min(a) FROM unnest(vals) a;
  END;
$$ LANGUAGE plpgsql;

-- DROP FUNCTION IF EXISTS TT_max_internal(double precision[]);
CREATE OR REPLACE FUNCTION TT_max_internal(
  vals double precision[]
)
RETURNS double precision AS $$
  BEGIN
    RETURN max(a) FROM unnest(vals) a;
  END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------
-- TT_min_max_indexes(int[], text, text)
--
-- vals int[] - array of integer values.
-- min_max text - return index of 'min' or 'max' value?
--
-- internal function returning an array of all indexes of the min or max value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_min_max_indexes_internal(int[], text);
CREATE OR REPLACE FUNCTION TT_min_max_indexes_internal(
  vals double precision[],
  min_max text
)
RETURNS integer[] AS $$
  DECLARE
    test_val double precision;
  BEGIN
    IF min_max = 'min' THEN
      test_val = tt_min_internal(vals);
    END IF;
    IF min_max = 'max' THEN
      test_val = tt_max_internal(vals);
    END IF;
    
    RETURN array_positions(vals, test_val);
    
  END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- TT_minIndex_getTestVal(text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to pass to other functions
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
--
-- Find the target values from the testList with a matching 
-- index to the smallest integer in the intList.
--
-- If there are multiple occurences of the smallest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
--
-- This function avoids repeating code many times
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_minIndex_getTestVal(text, text, text);
CREATE OR REPLACE FUNCTION TT_minIndex_getTestVal(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  DECLARE
    _intList double precision[];
    _testList text[];
    _indexes int[];
    _returnVals text[];
    _setNullTo double precision;
    _setZeroTo double precision;
    i int;
  BEGIN
    -- parse lists to arrays
    _intList = TT_ParseStringList(intList, TRUE);
    _testList = TT_ParseStringList(testList, TRUE);
    
    -- if setNullTo is provided, replace any nulls with it
    IF upper(setNullTo) != 'NULL' THEN
      _setNullTo = setNullTo::double precision;
      _intList = array_replace(_intList, null::double precision, _setNullTo);
    END IF;
    
    -- if setZeroTo is provided, replace any zeros with it
    IF upper(setZeroTo) != 'NULL' THEN
      _setZeroTo = setZeroTo::double precision;
      _intList = array_replace(_intList, 0::double precision, _setZeroTo);
    END IF;
    
    -- get indexes of all min values
    _indexes = tt_min_max_indexes_internal(_intList, 'min');
    
    -- get values from returnList matching the _indexes
      -- for each index, add the returnList value with that index to _returnVals
    FOREACH i IN ARRAY _indexes
    LOOP
      _returnVals = array_append(_returnVals, _testList[i]);
    END LOOP;
        
    -- remove any null values from _returnVals
    -- _testVal is now the first element in the list.
    -- i.e. the first non-null value matching the index of the min value.
    _returnVals = array_remove(_returnVals, NULL);
    RETURN _returnVals[1];
     
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_maxIndex_getTestVal(text, text)
--
-- Same as above but returning the value matching the max index
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_maxIndex_getTestVal(text, text, text);
CREATE OR REPLACE FUNCTION TT_maxIndex_getTestVal(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  DECLARE
    _intList double precision[];
    _testList text[];
    _indexes int[];
    _returnVals text[];
    _setNullTo double precision;
    _setZeroTo double precision;
    i int;
  BEGIN
    -- parse lists to arrays
    _intList = TT_ParseStringList(intList, TRUE);
    _testList = TT_ParseStringList(testList, TRUE);
    
    -- if setNullTo is provided, replace any nulls with it
    IF upper(setNullTo) != 'NULL' THEN
      _setNullTo = setNullTo::double precision;
      _intList = array_replace(_intList, null::double precision, _setNullTo);
    END IF;
    
     -- if setZeroTo is provided, replace any zeros with it
    IF upper(setZeroTo) != 'NULL' THEN
      _setZeroTo = setZeroTo::double precision;
      _intList = array_replace(_intList, 0::double precision, _setZeroTo);
    END IF;
    
    -- get indexes of all max values
    _indexes = tt_min_max_indexes_internal(_intList, 'max');
    
    -- get values from returnList matching the _indexes
    -- for each index, add the returnList value with that index to _returnVals
    FOREACH i IN ARRAY _indexes
    LOOP
      _returnVals = array_append(_returnVals, _testList[i]);
    END LOOP;
        
    -- remove any null values from _returnVals
    -- _srcVal is now the last element in the list.
    -- i.e. the last non-null value matching the index of the max value.
    _returnVals = array_remove(_returnVals, NULL);
    RETURN _returnVals[array_length(_returnVals, 1)];        
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-- Validation functions return only boolean values (TRUE or FALSE).
-- Consist of a source value to be validated, and any parameters associated
-- with validation.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Validation function template
--
-- Validation functions:
--
--    - must begin with "TT_"
--    - can only accept text parameters
--    - always return a boolean
--    - raise an exception on invalid parameters (with the help of the TT_ValidateParams() function)
--    - never fail on invalid values
--    - must properly handle NULL and empty values
--    - must not define DEFAULT parameters (use separate function signatures instead)
--    - if referring to another table, should be STABLE
-------------------------------------------------------------------------------
-- TT_ValidationFctTemplate
--
--  valList text (stringList) - Values to test. Can be a single value or a stringList.
--  param1 text (integer) - First perameter description. Default to 1.
--  param2 text (boolean) - Second parameter description (e.g. When TRUE, ignore case). Default to TRUE.
--
-- Description. e.g. Return TRUE if all vals are not NULL.
-- Return FALSE if any val is NULL.
-- e.g. TT_ValidationFctTemplate('a', 5, FALSE)
-- e.g. TT_ValidationFctTemplate({'a', 'b', 'c'}, 6)
------------------------------------------------------------

-- CREATE OR REPLACE FUNCTION TT_ValidationFctTemplate(
--   valList text,
--   param1 text,
--   param2 text
-- )
-- RETURNS boolean AS $$
--   DECLARE
--     _param1 int;
--     _param2 boolean;
--     _val text;
--   BEGIN
--     -- Validate parameters (trigger EXCEPTION)
--     PERFORM TT_ValidateParams('TT_ValidationFctTemplate',
--                               ARRAY['param1', param1, 'int',
--                                     'param2', param2, 'boolean']);
--
--     -- cast all parameters not of type text
--     _param1 = param1::int;
--     _param2 = param2::boolean;
--
--     -- More specific parameter validation
--     IF _param1 < 0 OR _param1 > 10 THEN
--       RAISE EXCEPTION 'ERROR in TT_ValidationFctTemplate(): param1 should be greater than 0 and smaller than 10';
--     END IF;
--
--     -- Validate values (val are not NULL and is a string list)
--     IF valList IS NULL OR NOT TT_IsStringList(valList) THEN
--       RETURN FALSE;
--     END IF;
--
--     -- Process value validity taking param1 and param2 into account
--     FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
--       IF whatever condition determining values invalidity THEN
--          RETURN FALSE;
--       END IF;
--     END LOOP;
--     RETURN TRUE;
--   END
-- $$ LANGUAGE plpgsql IMMUTABLE; -- IMMUTABLE because the function always returns the same value given the same input
--
-- -- Variant with default last parameter values
-- CREATE OR REPLACE FUNCTION TT_ValidationFctTemplate(
--   valList text,
--   param1 text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_ValidationFctTemplate(valList, param1, FALSE::text);
-- $$ LANGUAGE sql IMMUTABLE;
--
-- -- Variant with all default parameter values
-- CREATE OR REPLACE FUNCTION TT_ValidationFctTemplate(
--   valList text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_ValidationFctTemplate(valList, 1::text, FALSE::text);
-- $$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotNULL
--
--  val text (string list) - Value(s) to test. Can be one or many.
--  any_ text - default FALSE - if TRUE, return true if any inputs are not null.
--
-- Return TRUE if all vals are not NULL.
-- Return FALSE if any val is NULL.
-- e.g. TT_NotNULL('a')
-- e.g. TT_NotNull({'a', 'b', 'c'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNULL(
  val text,
  any_ text
)
RETURNS boolean AS $$
  DECLARE
    _val text[];
    _null_count int;
    _any boolean := any_::boolean;
  BEGIN
    -- validate source value (return FALSE)
    IF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    END IF;

    _val = TT_ParseStringList(val, TRUE);
    _null_count = array_length(array_positions(_val, NULL), 1); -- counts number of NULLs, if no nulls, returns NULL.

    -- if all values are not null, always return true
    IF _null_count IS NULL THEN
      RETURN TRUE;
    END IF;

    -- if any is TRUE, return TRUE if null_count is less than length of string list. i.e. at least one val is not null
    IF _any THEN
      RETURN _null_count < array_length(_val, 1);
    END IF;
    
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val text
)
RETURNS boolean AS $$
  SELECT TT_NotNull(val, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotEmpty
--
--  val (stringList) text - value to test
--  any text - default FALSE - if TRUE, return true if any inputs are not null.
--
-- Return TRUE if val is not an empty string.
-- Return FALSE if val is empty string or padded spaces (e.g. '' or '  ') or NULL.
-- e.g. TT_NotEmpty('a')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   val text,
   any_ text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _not_empty_count int := 0;
    _any boolean := any_::boolean;
  BEGIN
  
    -- validate source value (return FALSE)
    IF NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    END IF;
    
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;

    _vals = TT_ParseStringList(val, TRUE);
  
    -- get count of not empty strings in array
    FOR i IN 1..array_length(_vals, 1) LOOP
      IF _vals[i] IS NOT NULL THEN
        IF replace(_vals[i], ' ', '') != '' THEN
          _not_empty_count = _not_empty_count + 1; -- only add count if val is not null or empty string
        END IF;
      END IF;
    END LOOP;
    
    -- return TRUE if any is TRUE and _not_empty_count >0
    -- return TRUE if any is FALSE and _not_empty_count = length of _vals array
    IF _any THEN
      RETURN _not_empty_count > 0; -- any
    ELSE
      RETURN _not_empty_count = array_length(_vals, 1); -- all
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_NotEmpty(
  val text
)
RETURNS boolean AS $$
  SELECT TT_NotEmpty(val, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Length
--
-- val text - values to test.
-- removeSpaces boolean - trim spaces from start and end before calculating length?
--
-- Count characters in string
-- e.g. TT_Length('12345')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Length(
  val text,
  removeSpaces text
)
RETURNS int AS $$
  DECLARE
    _removeSpaces boolean;
  BEGIN
    _removeSpaces = removeSpaces::boolean;
    
    IF _removeSpaces THEN
      RETURN coalesce(char_length(replace(val, ' ','')), 0);
    ELSE
      RETURN coalesce(char_length(val), 0);
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_Length(
  val text
)
RETURNS int AS $$
  SELECT TT_Length(val, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasLength(
  val text,
  length_test text
)
RETURNS boolean AS $$
  SELECT TT_HasLength(val, length_test, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsInt(
  val text
)
RETURNS boolean AS $$
  SELECT TT_IsInt(val, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
  val text
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(val, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
    IF val IS NULL OR NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    ELSE
      FOREACH i IN ARRAY TT_ParseStringList(val, TRUE) LOOP
        IF NOT TT_IsNumeric(i, TRUE::text) THEN
          RETURN FALSE;
        END IF;
      END LOOP;
    END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
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
    IF val IS NULL OR NOT TT_IsStringList(val) THEN
      RETURN FALSE;
    ELSE
      FOREACH i IN ARRAY TT_ParseStringList(val, TRUE) LOOP
        IF NOT TT_IsInt(i, TRUE::text) THEN
          RETURN FALSE;
        END IF;
      END LOOP;
    END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
         paramType != 'name' AND
         paramType != 'text' AND
         paramType != 'char' AND
         paramType != 'boolean' AND
         paramType != 'stringlist' AND
         paramType != 'doublelist' AND
         paramType != 'intlist' AND
         paramType != 'charlist' THEN
        RAISE EXCEPTION 'ERROR when calling TT_ValidateParams(): paramType #% must be "int", "numeric", "name", "text", "char", "boolean", "stringlist", "doublelist", "intlist", "charlist"', i;
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
      ELSIF paramType = 'name' AND NOT TT_IsName(paramVal) THEN
        RAISE EXCEPTION 'ERROR in %(): % is not a name value', fctName, paramName;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsBetween(
  val text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  SELECT TT_IsBetween(val, min, max, includeMin, includeMax, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsBetween(
  val text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_IsBetween(val, min, max, TRUE::text, TRUE::text, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsGreaterThan(
  val text,
  lowerBound text,
  inclusive text
)
RETURNS boolean AS $$
  SELECT TT_IsGreaterThan(val, lowerBound, inclusive, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsGreaterThan(
  val text,
  lowerBound text
)
RETURNS boolean AS $$
  SELECT TT_IsGreaterThan(val, lowerBound, TRUE::text, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsLessThan(
  val text,
  upperBound text,
  inclusive text
)
RETURNS boolean AS $$
  SELECT TT_IsLessThan(val, upperBound, inclusive, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsLessThan(
  val text,
  upperBound text
)
RETURNS boolean AS $$
  SELECT TT_IsLessThan(val, upperBound, TRUE::text, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;
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
                              ARRAY['lookupSchemaName', lookupSchemaName, 'name',
                                    'lookupTableName', lookupTableName, 'name',
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
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  occurrences text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, lookupSchemaName, lookupTableName, occurrences, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, lookupSchemaName, lookupTableName, 1::text, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_IsUnique(
  val text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_IsUnique(val, 'public', lookupTableName, 1::text, FALSE::text)
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchTable
--
-- val text - value to test.
-- lookupSchemaName text - Schema name holding lookup table.
-- lookupTableName text - Lookup table name.
-- lookupColumnName text - Lookup table column name.
-- ignoreCase text - Should upper/lower case be ignored? Default to FALSE. 
-- acceptNull text - Should NULL value return TRUE? Default to FALSE.
--
-- if val is present in source_val of lookupSchemaName.lookupTableName table, returns TRUE.
-- e.g. TT_Match('BS', 'public', 'bc08', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupColumnName text,
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
    -- Shift arguments if the fourth parameter is ignoreCase instead of lookupColumnName.
    -- This allows backward support for already used 4 arguments calls.
    IF upper(lookupColumnName) = 'FALSE' OR upper(lookupColumnName) = 'TRUE' THEN
      acceptNull = ignoreCase;
      ignoreCase = lookupColumnName;
      lookupColumnName = 'source_val'::name;   
    END IF;

    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchTable',
                              ARRAY['lookupSchemaName', lookupSchemaName, 'name',
                                    'lookupTableName', lookupTableName, 'name',
                                    'lookupColumnName', lookupColumnName, 'name',
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
      query = 'SELECT ' || quote_literal(val) || ' IN (SELECT ' || lookupColumnName || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || quote_literal(upper(val)) || ' IN (SELECT upper(' || lookupColumnName || '::text) FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupColumnName text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, lookupSchemaName, lookupTableName, lookupColumnName, ignoreCase, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, lookupSchemaName, lookupTableName, 'source_val'::text, ignoreCase, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, lookupSchemaName, lookupTableName, 'source_val'::text, FALSE::text, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTable(
  val text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_MatchTable(val, 'public', lookupTableName, 'source_val'::text, FALSE::text, FALSE::text)
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchList
--
-- val text or string list - value to test. If string list, the list members are concatenated before testing.
-- lst text (stringList) - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- matches text - default TRUE. Should a match return true or false?
-- removeSpaces text - remove all empty spaces? Default True.
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
  matches text,
  removeSpaces text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _val text;
    _lst text[];
    _ignoreCase boolean;
    _acceptNull boolean;
    _matches boolean;
    _removeSpaces boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'acceptNull', acceptNull, 'boolean',
                                    'matches', matches, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean']);
    
    _ignoreCase = ignoreCase::boolean;
    _acceptNull = acceptNull::boolean;
    _matches = matches::boolean;
    _removeSpaces = removeSpaces::boolean;
    
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
    IF removeSpaces THEN
      _val = replace(array_to_string(_vals, ''), ' ', '');
    ELSE
      _val = array_to_string(_vals, '');
    END IF;

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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text,
  matches text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, acceptNull, matches, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, acceptNull, TRUE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, FALSE::text, TRUE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchList(
  val text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, FALSE::text, FALSE::text, TRUE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotMatchList
--
-- val text - value to test.
-- lst text (stringList) - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- removeSpace text - remove spaces?
--
-- If val in list, return false?
-- simple wrapper arounf TT_MatchList() with matches = FALSE. 
-- e.g. TT_NotMatchList('d', {'a','b','c'})
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text,
  removeSpaces text
)
RETURNS boolean AS $$
  DECLARE
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_NotMatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'acceptNull', acceptNull, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean']);
    _acceptNull = acceptNull::boolean;

    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    SELECT TT_MatchList(val, lst, ignoreCase, acceptNull, FALSE::text, removeSpaces);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text,
  ignoreCase text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, acceptNull, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, ignoreCase, FALSE::text, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_NotMatchList(
  val text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchList(val, lst, FALSE::text, FALSE::text, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
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
      IF NOT TT_IsInt(_vals[i]) THEN
        RETURN FALSE;
      ELSE
        _valSum = _valSum + _vals[i]::int; -- sum vals
      END IF;
    END LOOP;
    
    -- run summed vals through tt_matchlist
    RETURN TT_Matchlist(_valSum::text, lst, acceptNull, matches);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_SumIntMatchList(
  vals text,
  lst text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_SumIntMatchList(vals, lst, acceptNull, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_SumIntMatchList(
  vals text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_SumIntMatchList(vals, lst, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LengthMatchList
--
-- val text - string to test length.
-- lst text (stringList) - list of integers to test against.
-- removeSpaces - remove leading and trailing spaces
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
  trim_ text,
  removeSpaces text,
  acceptNull text,
  matches text
)
RETURNS boolean AS $$
  DECLARE
    _valLength text;
    _trim boolean;
    _removeSpaces boolean;
    _acceptNull boolean;
    _valSum int := 0;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_LengthMatchList',
                              ARRAY['lst', lst, 'stringlist',
                                    'trim_', trim_, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean',
                                    'acceptNull', acceptNull, 'boolean',
                                    'matches', matches, 'boolean']);
     
    _acceptNull = acceptNull::boolean;
    _removeSpaces = removeSpaces::boolean;
    _trim = trim_::boolean;
    
    -- validate source value
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;
    
    -- calculate length and cast to text
    IF _trim THEN
      _valLength = TT_Length(trim(val))::text;
    END IF;
    
    IF _removeSpaces THEN
      _valLength = TT_Length(replace(val, ' ', ''))::text;
    END IF;
    
    IF _trim IS FALSE AND _removeSpaces IS FALSE THEN
      _valLength = TT_Length(val)::text;
    END IF;
    
    -- run summed vals through tt_matchlist
    RETURN TT_Matchlist(_valLength, lst, acceptNull, matches);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text,
  trim_ text,
  removeSpaces text,
  acceptNull text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, trim_, removeSpaces, acceptNull, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text,
  trim_ text,
  removeSpaces text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, trim_, removeSpaces, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text,
  trim_ text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, trim_, FALSE::text, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_LengthMatchList(
  vals text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_LengthMatchList(vals, lst, FALSE::text, FALSE::text, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchListTwice
--
-- val1 text - first value to test. Can be text or stringlist.
-- val2 text - second value to test. Can be text or stringlist.
-- lst1 text (stringList) - list of values to test val1 against
-- lst2 text (stringList) - list of values to test val2 against
--
-- If matchList(val1, lst1) is true return true,
-- else run matchList(val2, lst2)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchListTwice(
  val1 text,
  val2 text,
  lst1 text,
  lst2 text
)
RETURNS boolean AS $$
  DECLARE
    _return boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    -- Note that tests need to be done manually due to 2 source vals
    PERFORM TT_ValidateParams('TT_MatchListTwice',
                              ARRAY['lst1', lst1, 'stringlist',
                                    'lst2', lst2, 'stringlist']);
    
    _return = TT_MatchList(val1, lst1);
    
    IF _return THEN
      RETURN TRUE;
    ELSE
      RETURN TT_MatchList(val2, lst2);
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- HasCountOfNotNull()
--
-- val text - string list of values to test.
-- count int - number of notNulls to test against
-- exact boolean - should number of notNulls match count exactly?
--
-- Calls countOfNotNull() and test the result against count.
-- If exact = TRUE, count has to exactly match notNulls.
-- If exact is FALSE, notNulls need to be greater than or equal to count.
--
-- e.g. TT_HasCountOfNotNull({'a'},{'b'},{'c'}, 3, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  vals13 text, vals14 text, vals15 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _count int;
    _exact boolean;
    _counted_nulls int;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_HasCountOfNotNull',
                              ARRAY['count', count, 'int',
                                    'exact', exact, 'boolean']);
    _count = count::int;
    _exact = exact::boolean;

    -- process
    _counted_nulls = TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, vals15, '15', 'FALSE');

    IF _exact THEN
      RETURN _counted_nulls = _count;
    ELSE
      RETURN _counted_nulls >= _count;
    END IF;

  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  vals13 text, vals14 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  vals13 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, 
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text, vals2 text,
  vals3 text, vals4 text, 
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, vals4, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, vals3, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text,
  vals2 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, vals2, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNull(
  vals1 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNull(vals1, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- HasCountOfNotNullOrZero()
--
-- Same as HasCountOfNotNull() but zeroIsNull in countOfNotNull call is set to TRUE
-- Can't make this an argument in hasCountOfNotNull because we don't want to have to
-- write the zeroIsNull argument every time and we can't assign a defualt because
-- the signatures are already used up to allow for different numbers of vals.
--
-- e.g. TT_HasCountOfNotNullOrZero({'a'},{'b'},{'c'}, 3, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  vals13 text, vals14 text, vals15 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _count int;
    _exact boolean;
    _counted_nulls int;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_HasCountOfNotNullOrZero',
                              ARRAY['count', count, 'int',
                                    'exact', exact, 'boolean']);
    _count = count::int;
    _exact = exact::boolean;

    -- process
    _counted_nulls = TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, vals15, '15', 'TRUE');

    IF _exact THEN
      RETURN _counted_nulls = _count;
    ELSE
      RETURN _counted_nulls >= _count;
    END IF;

  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  vals13 text, vals14 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  vals13 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, vals12 text, 
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text, vals11 text, 
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  vals10 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text, vals9 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text, vals8 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  vals7 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, vals7, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text, vals6 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, vals6, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text, vals3 text,
  vals4 text, vals5 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, vals5, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text, vals2 text,
  vals3 text, vals4 text, 
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, vals4, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text,
  vals2 text,
  vals3 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, vals3, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text,
  vals2 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, vals2, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfNotNullOrZero(
  vals1 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfNotNullOrZero(vals1, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', count, exact)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_IsIntSubstring(text, text, text, text)
--
-- val text - input string
-- startChar - start character to take substring from
-- forLength - length of substring to take
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- Take substring and test isInt
-- e.g. TT_IsIntSubstring('2001-01-01', 1, 4)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsIntSubstring(
  val text,
  startChar text,
  forLength text,
  removeSpaces text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsIntSubstring',
                              ARRAY['startChar', startChar, 'int',
                                    'forLength', forLength, 'int',
                                    'removeSpaces', removeSpaces, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _acceptNull = acceptNull::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    -- process
    RETURN TT_IsInt(TT_SubstringText(val, startChar, forLength, removeSpaces));
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsIntSubstring(
  val text,
  startChar text,
  forLength text,
  removeSpaces text
)
RETURNS boolean AS $$
  SELECT TT_IsIntSubstring(val, startChar, forLength, removeSpaces, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsIntSubstring(
  val text,
  startChar text,
  forLength text
)
RETURNS boolean AS $$
  SELECT TT_IsIntSubstring(val, startChar, forLength, FALSE::text, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_IsBetweenSubstring(text, text, text, text, text, text, text, text, text)
--
-- val text - input string
-- start_char text - start character to take substring from
-- for_length text - length of substring to take
-- min text - lower between bound
-- max text - upper between bound
-- includeMin text - boolean for including lower bound
-- includeMax text - boolean for including upper bound
-- removeSpaces - default FALSE - remove spaces before doing substring
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- Take substring and test with TT_IsBetween()
-- e.g. TT_IsBetweenSubstring('2001-01-01', 1, 4, 1900, 2100, TRUE, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  startChar text,
  forLength text,
  min text,
  max text,
  includeMin text,
  includeMax text,
  removeSpaces text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _startChar int;
    _forLength int;
    _removeSpaces boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsBetweenSubstring',
                              ARRAY['startChar', startChar, 'int',
                                    'forLength', forLength, 'int',
                                    'min', min, 'numeric',
                                    'max', max, 'numeric',
                                    'includeMin', includeMin, 'boolean',
                                    'includeMax', includeMax, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _startChar = startChar::int;
    _forLength = forLength::int;
    _acceptNull = acceptNull::boolean;
    _removeSpaces = removeSpaces::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    -- process
    IF _removeSpaces THEN
      RETURN TT_IsBetween(substring(replace(val, ' ', '') from _startChar for _forLength), min, max, includeMin, includeMax);
    ELSE
      RETURN TT_IsBetween(substring(val from _startChar for _forLength), min, max, includeMin, includeMax);
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  startChar text,
  forLength text,
  min text,
  max text,
  includeMin text,
  includeMax text,
  removeSpaces text
)
RETURNS boolean AS $$
  SELECT TT_IsBetweenSubstring(val, startChar, forLength, min, max, includeMin, includeMin, removeSpaces, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  startChar text,
  forLength text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  SELECT TT_IsBetweenSubstring(val, startChar, forLength, min, max, includeMin, includeMin, FALSE::text, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsBetweenSubstring(
  val text,
  startChar text,
  forLength text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_IsBetweenSubstring(val, startChar, forLength, min, max, TRUE::text, TRUE::text, FALSE::text, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_MatchListSubstring(text, text, text, text, text, text, text)
--
-- val text or string list - value to test.
--
-- startChar - start character to take substring from
-- forLength - length of substring to take
--
-- lst text (stringList) - string containing comma separated vals.
-- ignoreCase - text default FALSE. Should upper/lower case be ignored?
-- acceptNull text - should NULL value return TRUE? Default FALSE.
-- matches text - default TRUE. Should a match return true or false?
--
-- Take substring and test matchList
-- e.g. TT_MatchListSubstring('2001-01-01', 1, 4, {2001, 2002})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MatchListSubstring(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  startChar text,
  forLength text,
  lst text,
  ignoreCase text,
  removeSpaces text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _vals text[];
    _val text;
    _startChar int;
    _forLength int;
    _removeSpaces boolean;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MatchListSubstring',
                              ARRAY['startChar', startChar, 'int',
                                    'forLength', forLength, 'int',
                                    'lst', lst, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _startChar = startChar::int;
    _forLength = forLength::int;
    _acceptNull = acceptNull::boolean;
    _removeSpaces = removeSpaces::boolean;

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
    IF _removeSpaces THEN
      _val = array_to_string(ARRAY(SELECT substring(replace(unnest(_vals), ' ', '') from _startChar for _forLength)), '');
    ELSE
      _val = array_to_string(ARRAY(SELECT substring(unnest(_vals) from _startChar for _forLength)), '');
    END IF;
    
    -- process
    RETURN TT_MatchList(_val, lst, ignoreCase, acceptNull, TRUE::text, removeSpaces);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  startChar text,
  forLength text,
  lst text,
  ignoreCase text,
  removeSpaces text
)
RETURNS boolean AS $$
  SELECT TT_MatchListSubstring(val, startChar, forLength, lst, ignoreCase, removeSpaces, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  startChar text,
  forLength text,
  lst text,
  ignoreCase text
)
RETURNS boolean AS $$
  SELECT TT_MatchListSubstring(val, startChar, forLength, lst, ignoreCase, FALSE::text, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MatchListSubstring(
  val text,
  startChar text,
  forLength text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MatchListSubstring(val, startChar, forLength, lst, FALSE::text, FALSE::text, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MinIndexNotNull(text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for notNull
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- Find the target values from the testList with a matching 
-- index to the smallest integer in the intList. Test it with
-- notNull().
-- If there are multiple occurences of the smallest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexNotNull(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexNotNull(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_NotNull()
    RETURN TT_NotNull(_testVal);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexNotNull(
  intList text,
  testList text
)
RETURNS boolean AS $$
  SELECT TT_MinIndexNotNull(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxIndexNotNull(text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for notNull
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- find the target values from the testList with a matching 
-- index to the largest integer in the intList. Test it with
-- notNull().
-- If there are multiple occurences of the largest value, the
-- last index is used.
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexNotNull(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexNotNull(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo); 
    
    -- test with TT_NotNull()
    RETURN TT_NotNull(_testVal);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexNotNull(
  intList text,
  testList text
)
RETURNS boolean AS $$
  SELECT TT_MaxIndexNotNull(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexNotEmpty(text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for notNull
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- Same as TT_MinIndexNotNull but instead tests notEmpty
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexNotEmpty(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexNotEmpty(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_NotEmpty()
    RETURN TT_NotEmpty(_testVal);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexNotEmpty(
  intList text,
  testList text
)
RETURNS boolean AS $$
  SELECT TT_MinIndexNotEmpty(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxIndexNotEmpty(text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for notNull
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- Same as TT_MaxIndexNotNull but tests with notEmpty
---------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexNotEmpty(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexNotEmpty(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo); 
    
    -- test with TT_NotEmpty()
    RETURN TT_NotEmpty(_testVal);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexNotEmpty(
  intList text,
  testList text
)
RETURNS boolean AS $$
  SELECT TT_MaxIndexNotEmpty(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexIsInt(text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- Find the target values from the testList with a matching 
-- index to the smallest integer in the intList. Test it with
-- isInt().
-- If there are multiple occurences of the smallest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexIsInt(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexIsInt(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_IsInt()
    RETURN TT_IsInt(_testVal);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexIsInt(
  intList text,
  testList text
)
RETURNS boolean AS $$
  SELECT TT_MinIndexIsInt(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MaxIndexIsInt(text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- Find the target values from the testList with a matching 
-- index to the largest integer in the intList. Test it with
-- isInt().
-- If there are multiple occurences of the largest value, the
-- last non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexIsInt(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexIsInt(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_IsInt()
    RETURN TT_IsInt(_testVal);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexIsInt(
  intList text,
  testList text
)
RETURNS boolean AS $$
  SELECT TT_MaxIndexIsInt(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexIsBetween(text, text, text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
-- lower_bound - test val lower bound
-- upper_bound - test val upper bound
--
-- Find the target values from the testList with a matching 
-- index to the smallest integer in the intList. Test it with
-- isBetween().
-- If there are multiple occurences of the smallest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexIsBetween(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexIsBetween(
  intList text,
  testList text,
  lower_bound text,
  upper_bound text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_IsBetween()
    RETURN TT_IsBetween(_testVal, lower_bound, upper_bound);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexIsBetween(
  intList text,
  testList text,
  lower_bound text,
  upper_bound text
)
RETURNS boolean AS $$
  SELECT TT_MinIndexIsBetween(intList, testList, lower_bound, upper_bound, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TT_MaxIndexIsBetween(text, text, text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
-- lower_bound - test val lower bound
-- upper_bound - test val upper bound
--
-- Find the target values from the testList with a matching 
-- index to the largest integer in the intList. Test it with
-- isBetween().
-- If there are multiple occurences of the largest value, the
-- last non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexIsBetween(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexIsBetween(
  intList text,
  testList text,
  lower_bound text,
  upper_bound text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_IsBetween()
    RETURN TT_IsBetween(_testVal, lower_bound, upper_bound);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexIsBetween(
  intList text,
  testList text,
  lower_bound text,
  upper_bound text
)
RETURNS boolean AS $$
  SELECT TT_MaxIndexIsBetween(intList, testList, lower_bound, upper_bound, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_IsXMinusYBetween(text, text, text, text, text, text, text, text, text)
--
-- x - input x numeric
-- y - input y numeric
-- for_length text - length of substring to take
-- min text - lower between bound
-- max text - upper between bound
-- includeMin text - boolean for including lower bound
-- includeMax text - boolean for including upper bound
-- removeSpaces - default FALSE - remove spaces before doing substring
-- acceptNull text - should NULL value return TRUE? Default FALSE.
--
-- Calculate x minus y using tt_xminusydouble and test with TT_IsBetween()
-- e.g. TT_IsXMinusYBetween(2001, 1, 1900, 2100, TRUE, TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsXMinusYBetween(
  x text,
  y text,
  min text,
  max text,
  includeMin text,
  includeMax text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _xMinusY text;
    _acceptNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IsXMinusYBetween',
                              ARRAY['min', min, 'numeric',
                                    'max', max, 'numeric',
                                    'includeMin', includeMin, 'boolean',
                                    'includeMax', includeMax, 'boolean',
                                    'acceptNull', acceptNull, 'boolean']);
    _acceptNull = acceptNull::boolean;
    _XMinusY = (x::double precision - y::double precision)::double precision::text;
    
    -- validate source value (return FALSE)
    IF _XMinusY IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    -- process
    RETURN TT_IsBetween(_XMinusY, min, max, includeMin, includeMax);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsXMinusYBetween(
  x text,
  y text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  SELECT TT_IsXMinusYBetween(x, y, min, max, includeMin, includeMax, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IsXMinusYBetween(
  x text,
  y text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_IsXMinusYBetween(x, y, min, max, TRUE::text, TRUE::text, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_LookupTextMatchList(text, text, text, text, text)
--
-- srcVal text
-- lookupSchema text
-- lookupTable text
-- lookupCol text
-- testVal text
--
-- run lookupText and pass the result to matchList
-- e.g. lookupTextMatchList(srcval, 'schema', 'lookuptable', 'lookupcol', 1)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupTextMatchList(
  srcVal text,
  lookupSchema text,
  lookupTable text,
  lookupCol text,
  testVal text
)
RETURNS boolean AS $$
  DECLARE
    lookup_val text;
  BEGIN
    lookup_val = TT_LookupText(srcVal, lookupSchema, lookupTable, 'source_val'::text, lookupCol);
    
    RETURN TT_MatchList(lookup_val, testVal, FALSE::text, FALSE::text, TRUE::text, FALSE::text); -- set removeSpaces to FALSE.
  END;
$$ LANGUAGE plpgsql STABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexMatchList(text, text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
-- lst - list to test against
--
-- Find the target values from the testList with a matching 
-- index to the smallest integer in the intList. Test it with
-- matchList().
-- If there are multiple occurences of the smallest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexMatchList(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexMatchList(
  intList text,
  testList text,
  lst text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_MatchList()
    RETURN TT_MatchList(_testVal, lst);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexMatchList(
  intList text,
  testList text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MinIndexMatchList(intList, testList, lst, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MaxIndexMatchList(text, text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
-- lst - list to test against
--
-- Find the target values from the testList with a matching 
-- index to the largest integer in the intList. Test it with
-- matchList().
-- If there are multiple occurences of the largest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText() and TT_MinIndexLookupText()
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexMatchList(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexMatchList(
  intList text,
  testList text,
  lst text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with TT_MatchList()
    RETURN TT_MatchList(_testVal, lst);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexMatchList(
  intList text,
  testList text,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_MaxIndexMatchList(intList, testList, lst, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexMatchTable(text, text, text, text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
-- lookupSchemaName text - Schema name holding lookup table.
-- lookupTableName text - Lookup table name.
-- lookupColumnName text - Lookup table column name.
--
-- Find the target values from the testList with a matching 
-- index to the smallest integer in the intList. Test it with
-- matchTable().
-- If there are multiple occurences of the smallest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText and TT_MinIndexLookupText
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexMatchTable(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexMatchTable(
  intList text,
  testList text,
  lookupSchemaName text, 
  lookupTableName text, 
  lookupColumnName text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with tt_matchList()
    RETURN tt_matchTable(_testVal, lookupSchemaName, lookupTableName, lookupColumnName, 'FALSE');
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexMatchTable(
  intList text,
  testList text,
  lookupSchemaName text, 
  lookupTableName text, 
  lookupColumnName text
)
RETURNS boolean AS $$
  SELECT TT_MinIndexMatchTable(intList, testList, lookupSchemaName, lookupTableName, lookupColumnName, null::text, null::text)
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------
-- TT_MaxIndexMatchTable(text, text, text, text, text, text, text)
--
-- intList stringList - list of integers to test with min()
-- testList stringList - list of target values to test for isInt
-- setNullTo text - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
-- lst - list to test against
--
-- Find the target values from the testList with a matching 
-- index to the largest integer in the intList. Test it with
-- matchTable().
-- If there are multiple occurences of the largest value, the
-- first non null value with a matching index is used. This is to
-- match the behaviour of TT_MinIndexMapText() and TT_MinIndexLookupText()
--
-- If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexMatchTable(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexMatchTable(
  intList text,
  testList text,
  lookupSchemaName text, 
  lookupTableName text, 
  lookupColumnName text,
  setNullTo text,
  setZeroTo text
)
RETURNS boolean AS $$
  DECLARE
    _testVal text;
  BEGIN
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
        
    -- test with tt_matchList()
    RETURN tt_matchTable(_testVal, lookupSchemaName, lookupTableName, lookupColumnName, 'FALSE');
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexMatchTable(
  intList text,
  testList text,
  lookupSchemaName text, 
  lookupTableName text, 
  lookupColumnName text
)
RETURNS boolean AS $$
  SELECT TT_MaxIndexMatchTable(intList, testList, lookupSchemaName, lookupTableName, lookupColumnName, null::text, null::text)
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------
-- TT_MatchTableSubstring
--
-- val text - value to test.
--
-- startChar - start character to take substring from
-- forLength - length of substring to take
--
-- lookupSchemaName text - Schema name holding lookup table.
-- lookupTableName text - Lookup table name.
-- lookupColumnName text - Lookup table column name.
-- ignoreCase text - Should upper/lower case be ignored? Default to FALSE. 
-- acceptNull text - Should NULL value return TRUE? Default to FALSE.
--
-- Take substring and pass to matchTable
-- e.g. TT_MatchTableSubstring('BS01', 1, 2, 'public', 'bc08', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MatchTableSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text,
  lookupColumnName text,
  ignoreCase text,
  removeSpaces text,
  acceptNull text
)
RETURNS boolean AS $$
  DECLARE
    _val text;
    _acceptNull boolean;
  BEGIN
    PERFORM TT_ValidateParams('TT_MatchTableSubstring',
                              ARRAY['acceptNull', acceptNull, 'boolean']);
    _acceptNull = acceptNull::boolean;

    -- validate source value (return FALSE)
    IF val IS NULL THEN
      IF _acceptNull THEN
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END IF;

    -- process
    _val = TT_SubstringText(val, startChar, forLength, removeSpaces);
    RETURN tt_MatchTable(_val, lookupSchemaName, lookupTableName, lookupColumnName, ignoreCase, acceptNull);
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTableSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text,
  lookupColumnName text,
  ignoreCase text,
  removeSpaces text
)
RETURNS boolean AS $$
  SELECT TT_MatchTableSubstring(val, startChar, forLength, lookupSchemaName, lookupTableName, lookupColumnName, ignoreCase, removeSpaces, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTableSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text,
  ignoreCase text,
  removeSpaces text
)
RETURNS boolean AS $$
  SELECT TT_MatchTableSubstring(val, startChar, forLength, lookupSchemaName, lookupTableName, 'source_val'::text, ignoreCase, removeSpaces, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTableSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_MatchTableSubstring(val, startChar, forLength, lookupSchemaName, lookupTableName, 'source_val'::text, FALSE::text, FALSE::text, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MatchTableSubstring(
  val text,
  startChar text,
  forLength text,
  lookupTableName text
)
RETURNS boolean AS $$
  SELECT TT_MatchTableSubstring(val, startChar, forLength, 'public', lookupTableName, 'source_val'::text, FALSE::text, FALSE::text, FALSE::text)
$$ LANGUAGE sql STABLE;

-------------------------------------------------------------------------------
-- TT_CoalesceIsInt
--
--  valList text (stringList) - Values to test. Can be a single value or a stringList.
--  zeroAsNull text (boolean) - When TRUE, treat all zeros as NULL. Default to FALSE.
--
-- Check that the first non-NULL value in the stringList is an integer.
-- e.g. TT_CoalesceIsInt({NULL, '0', 'a'}) -- returns TRUE
-- e.g. TT_CoalesceIsInt({NULL, '0', 'a'}, TRUE) -- returns FALSE
-- e.g. TT_CoalesceIsInt({NULL, '0', '1'}, TRUE) -- returns TRUE
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CoalesceIsInt(
  valList text,
  zeroAsNull text
)
RETURNS boolean AS $$
  DECLARE
    _zeroAsNull boolean;
    _val text;
  BEGIN
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_CoalesceIsInt',
                              ARRAY['zeroAsNull', zeroAsNull, 'boolean']);

    -- Cast all parameters not of type text
    _zeroAsNull = zeroAsNull::boolean;

    -- Validate values (val are not NULL and is a string list)
    IF valList IS NULL OR NOT TT_IsStringList(valList) THEN
      RETURN FALSE;
    END IF;

    -- Process value validity
    IF _zeroAsNull THEN
      FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
        IF NOT _val IS NULL AND TT_IsInt(_val) AND _val::int != 0 THEN
           RETURN TRUE;
        END IF;
      END LOOP;
    ELSE
      FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
        IF NOT _val IS NULL AND TT_IsInt(_val) THEN
           RETURN TRUE;
        END IF;
      END LOOP;
    END IF;
    RETURN FALSE;
  END
$$ LANGUAGE plpgsql IMMUTABLE;

-- Variant with default last parameter values
CREATE OR REPLACE FUNCTION TT_CoalesceIsInt(
  valList text
)
RETURNS boolean AS $$
  SELECT TT_CoalesceIsInt(valList, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_CoalesceIsBetween
--
--  valList text (stringList) - Values to test. Can be a single value or a stringList.
--  min text (numeric) - Minimal bound
--  max text (numeric) - Miximal bound
--  includeMin text (boolean) - When TRUE, min is included in the accepted interval. Default to TRUE.
--  includemax text (boolean) - When TRUE, max is included in the accepted interval. Default to TRUE.
--  zeroAsNull text (boolean) - When TRUE, treat all zeros (0, 0.0, 00) as NULL. Default to FALSE.
--
-- Check that the first non-NULL value in the stringList is between min and max.
-- e.g. TT_CoalesceIsBetween({NULL, '5'}, 0, 10) -- returns TRUE
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CoalesceIsBetween(
  valList text,
  min text,
  max text,
  includeMin text,
  includeMax text,
  zeroAsNull text
)
RETURNS boolean AS $$
  DECLARE
    _min double precision;
    _max double precision;
    _includeMin boolean;
    _includeMax boolean;
    _zeroAsNull boolean;
    _valList text[];
    _val text;
  BEGIN
    -- Validate parameters (trigger EXCEPTION)
   PERFORM TT_ValidateParams('TT_CoalesceIsBetween',
                              ARRAY['min', min, 'numeric',
                                    'max', max, 'numeric',
                                    'includeMin', includeMin, 'boolean',
                                    'includeMax', includeMax, 'boolean',
                                    'zeroAsNull', zeroAsNull, 'boolean']);
    -- Cast all parameters not of type text
    _min = min::double precision;
    _max = max::double precision;
    _includeMin = includeMin::boolean;
    _includeMax = includeMax::boolean;
    _zeroAsNull = zeroAsNull::boolean;

    -- More specific parameter validation
    IF _min = _max THEN
      RAISE EXCEPTION 'ERROR in TT_CoalesceIsBetween(): min is equal to max';
    ELSIF _min > _max THEN
      RAISE EXCEPTION 'ERROR in TT_CoalesceIsBetween(): min is greater than max';
    END IF;
    
    -- Replace zeros with NULLs if required
    IF _zeroAsNull THEN
      _valList = ARRAY[]::text[];
      FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
        IF NOT (TT_IsInt(_val) AND _val::double precision::int = 0) THEN
          _valList = array_append(_valList, _val);
        END IF;
      END LOOP;
    ELSE
      _valList = TT_ParseStringList(valList, TRUE);
    END IF;

    RETURN TT_IsBetween(TT_CoalesceText(_valList::text), min, max, includeMin, includeMax);
  END
$$ LANGUAGE plpgsql IMMUTABLE;

-- Variant with default last parameter values
CREATE OR REPLACE FUNCTION TT_CoalesceIsBetween(
  valList text,
  min text,
  max text,
  includeMin text,
  includeMax text
)
RETURNS boolean AS $$
  SELECT TT_CoalesceIsBetween(valList, min, max, includeMin, includeMax, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;

-- Variant with default last parameter values
CREATE OR REPLACE FUNCTION TT_CoalesceIsBetween(
  valList text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_CoalesceIsBetween(valList, min, max, TRUE::text, TRUE::text, FALSE::text);
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_IsLessThanLookupDouble(text, text, text, text, text, text)
--
-- srcVal text
-- lookupSrcVal text
-- lookupSchema text
-- lookupTable text
-- lookupCol text
-- retrieveCol text
-- inclusive text - is upper bound inclusive? Default True.
--
-- run lookupText and use the results as the upper bound in isLessThan
-- lookup table source column must be source_val
-- e.g. TT_IsLessThanLookupDouble(srcval, lookupSrcVal, 'schema', 'lookuptable', 'lookupcol')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsLessThanLookupDouble(
  srcVal text,
  lookupSrcVal text,
  lookupSchema text,
  lookupTable text,
  lookupCol text,
  retrieveCol text,
  inclusive text
)
RETURNS boolean AS $$   
  DECLARE
    _lookup_val text;
  BEGIN
  
    -- Validate parameters (trigger EXCEPTION)
   PERFORM TT_ValidateParams('TT_isLessThanLookupDouble',
                              ARRAY['lookupSchema', lookupSchema, 'name',
                                    'lookupTable', lookupTable, 'name',
                                    'lookupCol', lookupCol, 'name',
                                    'retrieveCol', retrieveCol, 'name',
                                    'inclusive', inclusive, 'boolean']);
  
    IF NOT TT_MatchTable(lookupSrcVal, lookupSchema, lookupTable, lookupCol, 'FALSE') THEN
      RETURN FALSE;
    ELSE
      _lookup_val = TT_LookupDouble(lookupSrcVal, lookupSchema, lookupTable, lookupCol, retrieveCol)::text;
      RETURN TT_IsLessThan(srcVal, _lookup_val, inclusive);
    END IF;
  END
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_IsLessThanLookupDouble(
  srcVal text,
  lookupSrcVal text,
  lookupSchema text,
  lookupTable text,
  retrieveCol text,
  inclusive text
)
RETURNS boolean AS $$   
  SELECT TT_IsLessThanLookupDouble(srcVal, lookupSrcVal, lookupSchema, lookupTable, 'source_val', retrieveCol, inclusive);
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_IsLessThanLookupDouble(
  srcVal text,
  lookupSrcVal text,
  lookupSchema text,
  lookupTable text,
  retrieveCol text
)
RETURNS boolean AS $$   
  SELECT TT_IsLessThanLookupDouble(srcVal, lookupSrcVal, lookupSchema, lookupTable, 'source_val', retrieveCol, 'TRUE');
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------
-- TT_HasCountOfMatchList()
--
-- val1
-- srcList1
-- targetList1
-- val2
-- srcList2
-- targetList2
-- etc.
-- etc.
-- etc.
-- indexToReturn
-- 
-- Run up to 10 matchList calls and count the number of TRUEs.
-- If count is equal to _count and exact is true, return TRUE.
-- If count is greater than or equal to _count, and exact is FALSE, return TRUE.
--
-- e.g. TT_HasCountOfMatchList(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, 
--       val4,srcList4,targetList4, val5,srcList5,targetList5, val6,srcList6,targetList6, val7,srcList7,
--       targetList7, val8,srcList8,targetList8, val9,srcList9,targetList9, val10,srcList10,targetList10, count)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_HasCountOfMatchList(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  val5 text, srcList5 text,
  val6 text, srcList6 text,
  val7 text, srcList7 text,
  val8 text, srcList8 text,
  val9 text, srcList9 text,
  val10 text, srcList10 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  DECLARE
    _count int;
	_exact boolean;
	_passes int;
  BEGIN
  -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_HasCountOfMatchList',
                              ARRAY['count', count, 'int',
								   'exact', exact, 'boolean']);
    _count = count::int;
	_exact = exact::boolean;
	
	_passes = count(*) 
				FROM(SELECT tt_matchlist(val1,srcList1) 
					UNION ALL 
					SELECT tt_matchlist(val2,srcList2) 
					UNION ALL
					SELECT tt_matchlist(val3,srcList3) 
					UNION ALL
					SELECT tt_matchlist(val4,srcList4) 
					UNION ALL
					SELECT tt_matchlist(val5,srcList5) 
					UNION ALL
					SELECT tt_matchlist(val6,srcList6) 
					UNION ALL
					SELECT tt_matchlist(val7,srcList7) 
					UNION ALL
					SELECT tt_matchlist(val8,srcList8) 
					UNION ALL
					SELECT tt_matchlist(val9,srcList9) 
					UNION ALL
					SELECT tt_matchlist(val10,srcList10) 
				)a
				WHERE tt_matchlist IS TRUE;
	
	IF _exact THEN
	  RETURN _passes = _count;
	ELSE
	  RETURN _passes >= _count;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  val5 text, srcList5 text,
  val6 text, srcList6 text,
  val7 text, srcList7 text,
  val8 text, srcList8 text,
  val9 text, srcList9 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, val4, srcList4, val5, srcList5, val6, srcList6, val7, srcList7, val8, srcList8, val9, srcList9, 'a', 'b', count, exact); -- can't use NULL here or the matchList call will throw an error. We just need it to be FALSE
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  val5 text, srcList5 text,
  val6 text, srcList6 text,
  val7 text, srcList7 text,
  val8 text, srcList8 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, val4, srcList4, val5, srcList5, val6, srcList6, val7, srcList7, val8, srcList8, 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  val5 text, srcList5 text,
  val6 text, srcList6 text,
  val7 text, srcList7 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, val4, srcList4, val5, srcList5, val6, srcList6, val7, srcList7, 'a', 'b', 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  val5 text, srcList5 text,
  val6 text, srcList6 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, val4, srcList4, val5, srcList5, val6, srcList6, 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  val5 text, srcList5 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, val4, srcList4, val5, srcList5, 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  val4 text, srcList4 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, val4, srcList4, 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  val3 text, srcList3 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, val3, srcList3, 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_HasCountOfMatchList(
  val1 text, srcList1 text,
  val2 text, srcList2 text,
  count text,
  exact text
)
RETURNS boolean AS $$
  SELECT TT_HasCountOfMatchList(val1, srcList1, val2, srcList2, 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', 'a', 'b', count, exact);
$$ LANGUAGE sql IMMUTABLE;

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
-- Translation function template
--
-- Translation functions:
--
--    - must begin with "TT_"
--    - can only accept text parameters
--    - raise an exception on invalid parameters (with the help of the 
--      TT_ValidateParams() function)
--    - must not fail on invalid values even if invalid values should be handled 
--      by preceding validation rules
--    - return NULL when encountering errors
--    - must not define DEFAULT parameters (use separate function signatures 
--      instead)
--    - must implement polymorphism (return of values of different types) using 
--      specific function names e.g. TT_TrFctText() returns a text value and
--      TT_TrFctInt() returns a int value
--    - If referring to other tables should be STABLE
-------------------------------------------------------------------------------
-- TT_TransationFctTemplateText
--
--   valList text (stringList) - Values to test. Can be a single value or a stringList.
--   param1 text (integer) - First perameter description. Default to 1.
--   param2 text (boolean) - Second parameter description (e.g. When TRUE, ignore case). Default to TRUE.
--
-- Description. e.g. Return TRUE if all vals are not NULL.
-- Return FALSE if any val is NULL.
-- e.g. TT_ValidationFctTemplate('a', 5, FALSE)
-- e.g. TT_ValidationFctTemplate({'a', 'b', 'c'}, 6)
------------------------------------------------------------
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateText(
--   valList text,
--   param1 text,
--   param2 text,
--   callerFctName text
-- )
-- RETURNS boolean AS $$
--   DECLARE
--     _param1 int;
--     _param2 boolean;
--     _val text;
--     _result text;
--   BEGIN
--     -- Validate parameters (trigger EXCEPTION)
--     PERFORM TT_ValidateParams(callerFctName,
--                               ARRAY['param1', param1, 'int',
--                                     'param2', param2, 'boolean']);
--
--     -- Cast all parameters not of type text
--     _param1 = param1::int;
--     _param2 = param2::boolean;
--
--     -- More specific parameter validation
--     IF _param1 < 0 OR _param1 > 10 THEN
--       RAISE EXCEPTION 'ERROR in TT_TransationFctTemplateText(): param1 should be greater than 0 and smaller than 10';
--     END IF;
--
--     -- Validate values (val are not NULL and is a string list)
--     IF valList IS NULL OR NOT TT_IsStringList(valList) THEN
--       RETURN NULL;
--     END IF;
--
--     -- Process to translation taking param1 and param2 into account
--     FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
--       IF _param2 THEN
--          _result = whatever translation code;
--       ELSE
--          _result = whatever translation code;
--       END IF;
--     END LOOP;
--     RETURN _result;
--   END
-- $$ LANGUAGE plpgsql IMMUTABLE; -- IMMUTABLE because the function always returns the same value given the same input
--
------------------------
-- -- Main variant with all paramaters
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateText(
--   valList text,
--   param1 text,
--   param2 text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_TransationFctTemplateText(val, param1, FALSE::text, 'TT_TransationFctTemplateText');
-- $$ LANGUAGE sql IMMUTABLE;
--
------------------------
-- -- Variant with default last parameter values
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateText(
--   valList text,
--   param1 text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_TransationFctTemplateText(val, param1, FALSE::text);
-- $$ LANGUAGE sql IMMUTABLE;
--
------------------------
-- -- Variant with all default parameter values
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateText(
--   valList text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_TransationFctTemplateText(valList, 1::text, FALSE::text);
-- $$ LANGUAGE sql IMMUTABLE;
--
------------------------
-- -- Main int variant
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateInt(
--   valList text,
--   param1 text,
--   param1 text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_TransationFctTemplateText(valList, param1, param2, 'TT_TransationFctTemplateInt');
-- $$ LANGUAGE sql IMMUTABLE;
--
------------------------
-- -- int variant with default last parameter values
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateInt(
--   valList text,
--   param1 text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_TransationFctTemplateInt(valList, param1, TRUE::text);
-- $$ LANGUAGE sql IMMUTABLE;
--
------------------------
-- -- int variant with all default parameter values
-- CREATE OR REPLACE FUNCTION TT_TransationFctTemplateInt(
--   valList text
-- )
-- RETURNS boolean AS $$
--   SELECT TT_TransationFctTemplateInt(valList, 1::text, TRUE::text);
-- $$ LANGUAGE sql IMMUTABLE;

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
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupText
--
-- val text - value to lookup for
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupCol text - column to look up for the value
-- retrieveCol - column from which to retrieve the matching value
-- ignoreCase text - default FALSE. Should upper/lower case be ignored?
--
-- Return text value from retrieveColumn in lookupSchemaName.lookupTableName
-- that matches val in the lookupColumn column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
--
-- NULL source values are converted to empty strings. This allows NULLs to be
-- translated into a target value by using an empty string in the lookup table.
-- For CSV tables this is just a blank cell.
--
-- Any source val (including empty strings, aka NULLs) that is not included in the lookup table returns NULL.
--
-- e.g. TT_LookupText('BS', 'translation', 'all_species', 'bc_species_codes', 'casfri_species_codes', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  retrieveCol text,
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
    -- Shift arguments if the retrieveCol parameter is the boolean ignoreCase instead of a column name.
    -- This allows backward support for already used arguments calls not providing lookupCol.
    IF TT_IsBoolean(retrieveCol) THEN
      ignoreCase = retrieveCol;
      retrieveCol = lookupCol;
      lookupCol = 'source_val';
    ELSEIF NOT TT_IsBoolean(ignoreCase) AND TT_IsName(ignoreCase) THEN
      lookupCol = retrieveCol;
      retrieveCol = ignoreCase;
      ignoreCase = 'FALSE';
    END IF;

    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams(callerFctName,
                              ARRAY['lookupSchemaName', lookupSchemaName, 'name',
                                    'lookupTableName', lookupTableName, 'name',
                                    'lookupCol', lookupCol, 'name',
                                    'retrieveCol', retrieveCol, 'name',
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
    query = 'SELECT ' || retrieveCol || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) ||
            CASE WHEN _ignoreCase IS TRUE THEN
                   ' WHERE upper(' || lookupCol || '::text) = upper(' || quote_literal(_val) || ')'
                 ELSE
                   ' WHERE ' || lookupCol || ' = ' || quote_literal(_val)
            END || ';';

    EXECUTE query INTO result;
    RETURN result;
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  retrieveCol text,
  ignoreCase text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, retrieveCol, ignoreCase, 'TT_LookupText')
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text,
  ignoreCase text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, ignoreCase, 'TT_LookupText')
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, FALSE::text, 'TT_LookupText')
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupText(
  val text,
  lookupTableName text,
  retrieveCol text
)
RETURNS text AS $$
  SELECT TT_LookupText(val, 'public', lookupTableName, 'source_val', retrieveCol, FALSE::text, 'TT_LookupText')
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupDouble
--
-- val text - val to lookup for
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupColumn text - column to look up for the value
-- retrieveCol - column from which to retrieve the matching value
-- ignoreCase text - default FALSE. Should upper/lower case be ignored?
--
-- Return double precision value from retrieveCol in lookupSchemaName.lookupTableName
-- that matches val in the lookupColumn column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
--
-- e.g. TT_LookupDouble('BS', 'translation', 'all_species', 'bc_species_codes', 'casfri_species_codes', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  retrieveCol text,
  ignoreCase text
)
RETURNS double precision AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, retrieveCol, ignoreCase, 'TT_LookupDouble')::double precision;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text,
  ignoreCase text
)
RETURNS double precision AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, ignoreCase, 'TT_LookupDouble')::double precision;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text
)
RETURNS double precision AS $$
  SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, FALSE::text, 'TT_LookupDouble')::double precision;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupDouble(
  val text,
  lookupTableName text,
  retrieveCol text
)
RETURNS double precision AS $$
  SELECT TT_LookupText(val, 'public', lookupTableName, 'source_val', retrieveCol, FALSE::text, 'TT_LookupDouble')::double precision;
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupInt
--
-- val text - val to lookup for
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupColumn text - column to look up for the value
-- retrieveCol - column from which to retrieve the matching value
-- ignoreCase text - default FALSE. Should upper/lower case be ignored?
--
-- Return int value from retrieveCol in lookupSchemaName.lookupTableName
-- that matches val in the lookupColumn column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
--
-- e.g. TT_LookupInt('BS', 'translation', 'all_species', 'bc_species_codes', 'casfri_species_codes', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  retrieveCol text,
  ignoreCase text
)
RETURNS int AS $$
  WITH inttxt AS (
    SELECT TT_LookupText(val, lookupSchemaName, lookupTableName, lookupCol, retrieveCol, ignoreCase, 'TT_LookupInt') val
  )
  SELECT CASE WHEN TT_IsINT(val) THEN
              val::int
         ELSE
              NULL
         END
  FROM inttxt;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text,
  ignoreCase text
)
RETURNS int AS $$
    SELECT TT_LookupInt(val, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, ignoreCase);
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text
)
RETURNS int AS $$
  SELECT TT_LookupInt(val, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, FALSE::text);
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupInt(
  val text,
  lookupTableName text,
  retrieveCol text
)
RETURNS int AS $$
  SELECT TT_LookupInt(val, 'public', lookupTableName, 'source_val', retrieveCol, FALSE::text);
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapText
--
-- vals text - string list containing values to test. Or a single value to test.-- mapVals text (stringList) - string list of mapping values
-- targetVals (stringList) text - string list of target values
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
-- removeSpaces text - remove all empty spaces? Default True.
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
  ignoreCase text,
  removeSpaces text
)
RETURNS text AS $$
  DECLARE
    _vals text[];
    _val text;
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
    _removeSpaces boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapText',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean']);
    _vals = TT_ParseStringList(vals, TRUE);
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);
    _removeSpaces = removeSpaces::boolean;

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
    IF _removeSpaces THEN
      _val = replace(array_to_string(_vals, ''), ' ', '');
    ELSE
      _val = array_to_string(_vals, '');
    END IF;
   
    -- prepare _mapVals so we can compare its length with _targetVals right away
    _mapVals = TT_ParseStringList(CASE WHEN _ignoreCase THEN upper(mapVals) ELSE mapVals END, TRUE);

    IF cardinality(_mapVals) != cardinality(_targetVals) THEN
      RAISE EXCEPTION 'ERROR in TT_MapText(): number of mapVals values (%) is different from number of targetVals values (%)...', cardinality(_mapVals), cardinality(_targetVals);
    END IF;

    -- process
    RETURN (_targetVals)[array_position(_mapVals, CASE WHEN _ignoreCase THEN upper(_val) ELSE _val END)];
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapText(
  vals text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS text AS $$
  SELECT TT_MapText(vals, mapVals, targetVals, ignoreCase, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapText(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MapText(vals, mapVals, targetVals, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapSubstringText
--
-- vals text - string list containing values to test. Or a single value to test.
-- startChar - start character to take substring from
-- forLength - length of substring to take
-- mapVals (stringList) text - string list of mapping values
-- targetVals (stringList) text - string list of target values
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
-- removeSpaces - passed to matchList, should spaces be removed
--
-- get substring of val and test mapText
-- e.g. TT_MapSubstringText('ABC', 2, 1, '{''A'',''B'',''C''}', '{''1'',''2'',''3''}', 'TRUE')

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MapSubstringText(
  vals text,
  startChar text,
  forLength text,
  mapVals text,
  targetVals text,
  ignoreCase text,
  removeSpaces text
)
RETURNS text AS $$
  DECLARE
    _vals text[];
    _val text;
    _startChar int;
    _forLength int;
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapSubstringText',
                              ARRAY['startChar', startChar, 'int',
                                    'forLength', forLength, 'int',
                                    'mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean']);
                                    
    _vals = TT_ParseStringList(vals, TRUE);
    _startChar = startChar::int;
    _forLength = forLength::int;
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
    _val = array_to_string(ARRAY(SELECT substring(unnest(_vals) from _startChar for _forLength)), '');
    
    -- process
    RETURN TT_MapText(_val, mapVals, targetVals, ignoreCase, removeSpaces);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapSubstringText(
  vals text,
  startChar text,
  forLength text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS text AS $$
  SELECT TT_MapSubstringText(vals, startChar, forLength, mapVals, targetVals, ignoreCase, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapSubstringText(
  vals text,
  startChar text,
  forLength text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MapSubstringText(vals, startChar, forLength, mapVals, targetVals, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
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
      IF NOT TT_IsInt(_vals[i]) THEN
        RETURN NULL;
      ELSE
        _valSum = _valSum + _vals[i]::int; -- sum vals
      END IF;
    END LOOP;

    -- run TT_MapText with summed vals
    RETURN TT_MapText(_valSum::text, mapVals, targetVals);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapDouble
--
-- vals text - string list containing values to test. Or a single value to test.
-- mapVals text - string containing comma seperated vals
-- targetVals text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
-- removeSpaces text - remove all empty spaces? Default True.
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
  ignoreCase text,
  removeSpaces text
)
RETURNS double precision AS $$
  DECLARE
    _vals text[];
    _val text;
    _mapVals text[];
    _targetVals text[];
    _ignoreCase boolean;
    _removeSpaces boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapDouble',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'doublelist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean']);
    
    _vals = TT_ParseStringList(vals, TRUE);
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);
    _removeSpaces = removeSpaces::boolean;

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
    IF _removeSpaces THEN
      _val = replace(array_to_string(_vals, ''), ' ', '');
    ELSE
      _val = array_to_string(_vals, '');
    END IF;
    
    -- process
    IF _ignoreCase = FALSE THEN
      _mapVals = TT_ParseStringList(mapVals, TRUE);  
      RETURN (_targetVals)[array_position(_mapVals, _val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE);
      RETURN (_targetVals)[array_position(_mapVals, upper(_val))];
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapDouble(
  vals text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS double precision AS $$
  SELECT TT_MapDouble(vals, mapVals, targetVals, ignoreCase, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapDouble(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS double precision AS $$
  SELECT TT_MapDouble(vals, mapVals, targetVals, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapInt
--
-- vals text - string list containing values to test. Or a single value to test.
-- mapVals text - string containing comma seperated vals
-- targetVals text - string containing comma seperated vals
-- ignoreCase - default FALSE. Should upper/lower case be ignored?
-- removeSpaces text - remove all empty spaces? Default True.
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
  ignoreCase text,
  removeSpaces text
)
RETURNS int AS $$
  DECLARE
    _vals text[];
    _val text;
    _mapVals text[];
    _targetVals text[];
    _i int;
    _ignoreCase boolean;
    _removeSpaces boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapInt',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'intlist',
                                    'ignoreCase', ignoreCase, 'boolean',
                                    'removeSpaces', removeSpaces, 'boolean']);
    
    _vals = TT_ParseStringList(vals, TRUE);
    _ignoreCase = ignoreCase::boolean;
    _targetVals = TT_ParseStringList(targetVals, TRUE);
    _removeSpaces = removeSpaces::boolean;

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
    IF _removeSpaces THEN
      _val = replace(array_to_string(_vals, ''), ' ', '');
    ELSE
      _val = array_to_string(_vals, '');
    END IF;
    
    -- process
    IF _ignoreCase = FALSE THEN
      _mapVals = TT_ParseStringList(mapVals, TRUE);
      RETURN (_targetVals)[array_position(_mapVals, _val)];
    ELSE
      _mapVals = TT_ParseStringList(upper(mapVals), TRUE);
      RETURN (_targetVals)[array_position(_mapVals,upper(_val))];
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapInt(
  vals text,
  mapVals text,
  targetVals text,
  ignoreCase text
)
RETURNS int AS $$
  SELECT TT_MapInt(vals, mapVals, targetVals, ignoreCase, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapInt(
  vals text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$
  SELECT TT_MapInt(vals, mapVals, targetVals, FALSE::text, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LengthMapInt
--
-- val string list - string to calculate length.
-- mapVals text (stringList) - string list of mapping values
-- targetVals (stringList) text - string list of target values
-- removeSpaces - remove leading and trainling spaces befores calculatin length
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
  removeSpaces text
)
RETURNS int AS $$
  DECLARE
    _valLength text;
    _removeSpaces text;
  BEGIN
    
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_LengthMapInt',
                              ARRAY['removeSpaces', removeSpaces, 'boolean',
                                    'mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist']);

    _removeSpaces = removeSpaces::boolean;

    -- validate source value (return NULL if not valid)
    IF val IS NULL THEN
      RETURN NULL;
    END IF;
    
    IF _removeSpaces THEN
      _valLength = TT_Length(val, TRUE::text)::text;
    ELSE
      _valLength = TT_Length(val)::text;
    END IF;

    -- run TT_MapText with summed vals
    RETURN TT_MapText(_valLength, mapVals, targetVals)::int;
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_LengthMapInt(
  val text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$
  SELECT TT_LengthMapInt(val, mapVals, targetVals, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  targetLength text,
  padChar text
)
RETURNS text AS $$
  SELECT TT_Pad(val, targetLength, padChar, TRUE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Concat
--
--  val text (stringList) - comma separated string of strings to concatenate
--  sep text - Separator (e.g. '_'). If no sep required use '' as second argument.
--  nullToEmpty - should null values be converted to empty strings? If FALSE, nulls
--    are dropped before concatenating. If TRUE, two sep characters will be printed
--    where the null was. Default is FALSE.
--
-- Return the concatenated value.
-- e.g. TT_Concat({'a', 'b', 'c'}, '-')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val text,
  sep text,
  nullToEmpty text
)
RETURNS text AS $$
  DECLARE
    _nullToEmpty boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_Concat',
                             ARRAY['sep', sep, 'char',
								  'nullToEmpty', nullToEmpty, 'boolean']);
                            
    _nullToEmpty = nullToEmpty::boolean;
	
    -- validate source value (return NULL if not valid)
    IF NOT TT_IsStringList(val) THEN
      RETURN NULL;
    END IF;

    -- process
	IF _nullToEmpty IS FALSE THEN
      RETURN array_to_string(TT_ParseStringList(val, TRUE), sep);
	ELSE
	  RETURN array_to_string(TT_ParseStringList(val, TRUE), sep, '');
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_Concat(
  val text,
  sep text
)
RETURNS text AS $$
  SELECT TT_Concat(val, sep, 'FALSE')
$$ LANGUAGE sql IMMUTABLE;
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
--  Remove and spaces before concatenating. 
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
	_trimmedVal text;
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
      _trimmedVal = replace(_vals[i], ' ', '');
	  IF _trimmedVal = '' AND _includeEmpty = FALSE THEN
        -- do nothing
      ELSE
        _result = _result || '''' || TT_Pad(_trimmedVal, _lengths[i], _pads[i]) || ''',';
      END IF;
    END LOOP;
    -- run comma separated string through concat with sep
    _result = left(_result, char_length(_result) - 1) || '}';
    --RAISE NOTICE '%',_result;
    RETURN TT_Concat(_result, sep);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_PadConcat(
  val text,
  length text,
  pad text,
  sep text,
  upperCase text
)
RETURNS text AS $$
  SELECT TT_PadConcat(val, length, pad, sep, upperCase, 'TRUE'::text)
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE sql IMMUTABLE;
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
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CountOfNotNull()
--
-- vals1/2/3/4/5/6/7/8/9/10/11/12/13/14/15 text - string lists of values to test.
-- maxRankToConsider int - only consider the first x string lists.
-- i.e. if maxRankToConsider = 3, only vals1, vals2 and vals3 are condsidered.
-- zeroIsNull = when TRUE zero values are treated as NULL
--
-- Returns the number of vals lists where at least one element in the vals list 
-- is not a null value or an empty string.
--
-- e.g. TT_CountOfNotNull({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, FALSE)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_CountOfNotNull(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  vals8 text,
  vals9 text,
  vals10 text,
  vals11 text,
  vals12 text,
  vals13 text,
  vals14 text,
  vals15 text,
  maxRankToConsider text,
  zeroIsNull text
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
    _vals8 text[];
    _vals9 text[];
    _vals10 text[];
    _vals11 text[];
    _vals12 text[];
    _vals13 text[];
    _vals14 text[];
    _vals15 text[];
    _maxRankToConsider int;
    _count int;
    _zeroIsNull boolean;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_CountOfNotNull',
                              ARRAY['maxRankToConsider', maxRankToConsider, 'int',
                                   'zeroIsNull', zeroIsNull, 'boolean']);

    -- Validate source values (return NULL)
    IF TT_NotNull(vals1) AND NOT TT_IsStringList(vals1) OR
       TT_NotNull(vals2) AND NOT TT_IsStringList(vals2) OR
       TT_NotNull(vals3) AND NOT TT_IsStringList(vals3) OR
       TT_NotNull(vals4) AND NOT TT_IsStringList(vals4) OR
       TT_NotNull(vals5) AND NOT TT_IsStringList(vals5) OR
       TT_NotNull(vals6) AND NOT TT_IsStringList(vals6) OR
	   TT_NotNull(vals7) AND NOT TT_IsStringList(vals7) OR
       TT_NotNull(vals8) AND NOT TT_IsStringList(vals8) OR
	   TT_NotNull(vals9) AND NOT TT_IsStringList(vals9) OR
       TT_NotNull(vals10) AND NOT TT_IsStringList(vals10) OR
       TT_NotNull(vals11) AND NOT TT_IsStringList(vals11) OR
       TT_NotNull(vals12) AND NOT TT_IsStringList(vals12) OR
       TT_NotNull(vals13) AND NOT TT_IsStringList(vals13) OR
	   TT_NotNull(vals14) AND NOT TT_IsStringList(vals14) OR
       TT_NotNull(vals15) AND NOT TT_IsStringList(vals15) THEN
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
    _vals8 = TT_ParseStringList(vals8, TRUE);
	_vals9 = TT_ParseStringList(vals9, TRUE);
    _vals10 = TT_ParseStringList(vals10, TRUE);
    _vals11 = TT_ParseStringList(vals11, TRUE);
    _vals12 = TT_ParseStringList(vals12, TRUE);
    _vals13 = TT_ParseStringList(vals13, TRUE);
    _vals14 = TT_ParseStringList(vals14, TRUE);
    _vals15 = TT_ParseStringList(vals15, TRUE);
    _maxRankToConsider = maxRankToConsider::int;
    _zeroIsNull = zeroIsNull::boolean;

    -- Run queries when zero_is_null = FALSE
    IF _zeroIsNull = FALSE THEN
      -- Get count of not null vals lists
      IF _maxRankToConsider = 0 THEN
        RETURN 0;
      ELSEIF _maxRankToConsider = 1 THEN 
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSEIF _maxRankToConsider = 2 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSEIF _maxRankToConsider = 3 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 4 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 5 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x)) > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 6 THEN
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
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 7 THEN
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
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 8 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 9 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 10 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 11 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 12 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 13 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals13) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 14 THEN
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals13) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals14) x WHERE TT_NotEmpty(x)) > 0 as y)
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
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals13) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals14) x WHERE TT_NotEmpty(x)) > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals15) x WHERE TT_NotEmpty(x)) > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      END IF;
      
    -- Run queries when zero_is_null = FALSE
    ELSE
      IF _maxRankToConsider = 0 THEN
        RETURN 0;
      ELSEIF _maxRankToConsider = 1 THEN 
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSEIF _maxRankToConsider = 2 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSEIF _maxRankToConsider = 3 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 4 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 5 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 6 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 7 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSIF _maxRankToConsider = 8 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 9 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 10 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 11 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 12 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 13 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals13) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
	  ELSIF _maxRankToConsider = 14 THEN
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals13) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals14) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      ELSE
        WITH a AS (
          SELECT(SELECT count(*) FROM unnest(_vals1) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals2) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals3) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals4) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals5) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
          UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals6) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals7) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals8) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals9) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals10) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals11) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals12) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals13) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals14) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y
		  UNION ALL
          SELECT(SELECT count(*) FROM unnest(_vals15) x WHERE TT_NotEmpty(x) AND x != '0') > 0 as y)
        SELECT sum(y::int) FROM a INTO _count;
      END IF;
    END IF;
    -- Return count
    RETURN _count;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text, vals9 text, vals10 text, 
  vals11 text, vals12 text, vals13 text, vals14 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text, vals9 text, vals10 text, 
  vals11 text, vals12 text, vals13 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text, vals9 text, vals10 text, 
  vals11 text, vals12 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text, vals9 text, vals10 text, 
  vals11 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text, vals9 text, vals10 text, 
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text, vals9 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text, vals8 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text, vals3 text, vals4 text, vals5 text, 
  vals6 text, vals7 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text,
  vals3 text, vals4 text, 
  vals5 text, vals6 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text,
  vals3 text, vals4 text, vals5 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text, vals2 text,
  vals3 text, vals4 text, 
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, vals4, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  vals3 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, vals3, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  vals2 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, vals2, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CountOfNotNull(
  vals1 text,
  maxRankToConsider text,
  zeroIsNull text
)
RETURNS int AS $$
  SELECT TT_CountOfNotNull(vals1, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, zeroIsNull)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IfElseCountOfNotNullText()
--
-- vals1/2/3/4/5/6/7 text - string lists of values to test. Same as TT_IfElseCountOfNotNullText().
-- maxRankToConsider int - only consider the first x string lists. Same as TT_IfElseCountOfNotNullText().
-- cutoffVal - value to use in ifelse
-- str1 - if TT_CountOfNotNull() returns less than or equal to cutoffVal, return this string
-- str2 - if TT_CountOfNotNull() returns greater than cutoffVal, return this string
--
-- e.g. TT_IfElseCountOfNotNullText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, 1, 'S', 'M')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullText(text, text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  vals8 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  DECLARE
    _cutoffVal int;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_IfElseCountOfNotNullText',
                              ARRAY['cutoffVal', cutoffVal, 'int',
                                   'str1', str1, 'text',
                                   'str2', str2, 'text']);
    _cutoffVal = cutoffVal::int;
    
    IF TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, maxRankToConsider, 'FALSE') <= _cutoffVal THEN
      RETURN str1;
    ELSE
      RETURN str2;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, '{NULL}', '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  vals3 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  vals2 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, vals2, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullText(
  vals1 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS text AS $$
  SELECT TT_IfElseCountOfNotNullText(vals1, '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', '{NULL}', maxRankToConsider, cutoffVal, str1, str2)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IfElseCountOfNotNullInt()
--
-- simple wrapper around TT_IfElseCountOfNotNullText()
--
-- e.g. TT_IfElseCountOfNotNullInt({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, 1, 'S', 'M')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_IfElseCountOfNotNullInt(text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  vals8 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  vals3 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, vals3, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  vals2 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, vals2, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_IfElseCountOfNotNullInt(
  vals1 text,
  maxRankToConsider text,
  cutoffVal text,
  str1 text,
  str2 text
)
RETURNS int AS $$
    SELECT TT_IfElseCountOfNotNullText(vals1, maxRankToConsider, cutoffVal, str1, str2)::int
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SubstringText()
--
-- val text - input string
-- startChar text - start character to take substring from
-- forLength text - length of substring to take
-- removeSpaces text - default FALSE - remove spaces before doing substring
--
-- basic wrapper around postgresql substring(), returning text
-- e.g. TT_SubstringText('abcd', 1, 1)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_SubstringText(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_SubstringText(
  val text,
  startChar text,
  forLength text,
  removeSpaces text
)
RETURNS text AS $$
  DECLARE
    _startChar int;
    _forLength int;
    _removeSpaces boolean;
  BEGIN    
    -- Validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_SubstringText',
                              ARRAY['startChar', startChar, 'int',
                                   'forLength', forLength, 'int',
                                   'removeSpaces', removeSpaces, 'boolean']);
    _startChar = startChar::int;
    _forLength = forLength::int;
    _removeSpaces = removeSpaces::boolean;

    -- process
    IF _removeSpaces THEN
      RETURN substring(replace(val, ' ', '') from _startChar for _forLength);
    ELSE
      RETURN substring(val from _startChar for _forLength);
    END IF;
    
   END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_SubstringText(
  val text,
  startChar text,
  forLength text
)
RETURNS text AS $$
    SELECT TT_SubstringText(val, startChar, forLength, FALSE::text)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SubstringInt()
--
-- val text - input string
-- startChar text - start character to take substring from
-- forLength text - length of substring to take
-- removeSpaces - remove any spaces before taking substring
--
-- basic wrapper around postgresql substring(), returning int
-- e.g. TT_SubstringText('124', 1, 1)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_SubstringInt(text, text, text);
CREATE OR REPLACE FUNCTION TT_SubstringInt(
  val text,
  startChar text,
  forLength text,
  removeSpaces text
)
RETURNS int AS $$
  SELECT TT_SubstringText(val, startChar, forLength, removeSpaces)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_SubstringInt(
  val text,
  startChar text,
  forLength text
)
RETURNS int AS $$
  SELECT TT_SubstringText(val, startChar, forLength, FALSE::text)::int
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_XMinusYInt()
--
-- x text - first value
-- y text - second value
--
-- calculates x - y and returns int.
-- e.g. TT_XMinusYInt('2', '1')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_XMinusYInt(text, text);
CREATE OR REPLACE FUNCTION TT_XMinusYInt(
  x text,
  y text
)
RETURNS int AS $$
  SELECT (x::double precision - y::double precision)::int
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_XMinusYDouble()
--
-- x text - first value
-- y text - second value
--
-- calculates x - y and returns double.
-- e.g. TT_XMinusYDouble('2', '1')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_XMinusYDouble(text, text);
CREATE OR REPLACE FUNCTION TT_XMinusYDouble(
  x text,
  y text
)
RETURNS double precision AS $$
  SELECT (x::double precision - y::double precision)::double precision
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxInt()
--
-- vals text - stringList of values to test
--
-- returns max value as int.
-- e.g. TT_MaxInt({1,2,3})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxInt(text);
CREATE OR REPLACE FUNCTION TT_MaxInt(
  vals text
)
RETURNS int AS $$
  DECLARE
    _vals int[];
  BEGIN
    _vals = TT_ParseStringList(vals, TRUE)::int[];
    RETURN TT_max_internal(_vals);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinInt()
--
-- vals text - stringList of values to test
--
-- returns min value as int.
-- e.g. TT_MaxInt({1,2,3})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinInt(text);
CREATE OR REPLACE FUNCTION TT_MinInt(
  vals text
)
RETURNS int AS $$
  DECLARE
    _vals int[];
  BEGIN
    _vals = TT_ParseStringList(vals, TRUE)::int[];
    RETURN TT_min_internal(_vals);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexCopyText()
--
-- intList text - stringList of values to test
-- returnList - stringList from which to select the return value
-- setNullTo - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- returns value from returnList matching the index of the lowest
-- value in intList. If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
-- If multiple occurences of the smallest value, the first non null value
-- with a matching index is used.
-- 
-- e.g. TT_MinIndexCopyText({1,2,3}, {a,b,c})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexCopyText(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexCopyText(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  SELECT TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexCopyText(
  intList text,
  testList text
)
RETURNS text AS $$
  SELECT TT_MinIndexCopyText(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MinIndexCopyInt()
--
-- Runs MinIndexCopyText and casts to integer
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexCopyInt(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexCopyInt(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS int AS $$
  SELECT TT_MinIndexCopyText(intList, testList, setNullTo, setZeroTo)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexCopyInt(
  intList text,
  testList text
)
RETURNS int AS $$
  SELECT TT_MinIndexCopyInt(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxIndexCopyText()
--
-- intList text - stringList of values to test
-- returnList - stringList from which to select the return value
-- setNullTo - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- returns value from returnList matching the index of the highest
-- value in intList. If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating max value.
-- If multiple occurences of the smallest value, the last non null value with
-- a matching index is used.
-- 
-- e.g. TT_MaxIndexCopyText({1,2,3}, {a,b,c})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexCopyText(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexCopyText(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  SELECT TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexCopyText(
  intList text,
  testList text
)
RETURNS text AS $$
  SELECT TT_MaxIndexCopyText(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxIndexCopyInt()
--
-- Runs MaxIndexCopyText and casts to integer
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexCopyInt(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexCopyInt(
  intList text,
  testList text,
  setNullTo text,
  setZeroTo text
)
RETURNS int AS $$
  SELECT TT_MaxIndexCopyText(intList, testList, setNullTo, setZeroTo)::int
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexCopyInt(
  intList text,
  testList text
)
RETURNS int AS $$
  SELECT TT_MaxIndexCopyInt(intList, testList, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MinIndexMapText()
--
-- intList text - stringList of values to test
-- returnList - stringList from which to select the value to pass to mapText
-- mapVals - list of source values for mapText
-- targetVals - list of target values for mapText
-- setNullTo - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- passes value from returnList matching the index of the smallest
-- value in intList to mapText. If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating max value.
-- If multiple occurences of the smallest value, the first non null value with a
-- matching index is used.
-- 
-- e.g. TT_MinIndexMapText({1,2,3}, {a,b,c}, {A,B,C}, {AA, BB, CC})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexMapText(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexMapText(
  intList text,
  testList text,
  mapVals text,
  targetVals text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  DECLARE
    _testVal text;
  BEGIN
  
    -- Note we can't validate setNullTo using TT_ValidateParams because null is an expected value
    -- which is not permitted by TT_ValidateParams. Need to make our own tests for NULL values 
    -- and valid arguments in the test script.
    PERFORM TT_ValidateParams('TT_MinIndexMapText',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist']);
                                   
    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
    
    -- pass _srcVal to mapText
    RETURN TT_MapText(_testVal, mapVals, targetVals);

  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexMapText(
  intList text,
  testList text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MinIndexMapText(intList, testList, mapVals, targetVals, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MinIndexMapInt()
--
-- Runs minIndexMaptText and casts the result to an integer
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexMapInt(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexMapInt(
  intList text,
  testList text,
  mapVals text,
  targetVals text,
  setNullTo text,
  setZeroTo text
)
RETURNS int AS $$
  SELECT TT_MinIndexMapText(intList, testList, mapVals, targetVals, setNullTo, setZeroTo)::int;
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexMapInt(
  intList text,
  testList text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$
  SELECT TT_MinIndexMapInt(intList, testList, mapVals, targetVals, null::text, null::text);
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxIndexMapText()
--
-- intList text - stringList of values to test
-- testList - stringList from which to select the value to pass to mapText
-- srcList - list of source values for mapText
-- targetList - list of target values for mapText
-- setNullTo - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- passes value from returnList matching the index of the largest
-- value in intList to mapText. If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating max value.
-- If multiple occurences of the smallest value, the last non null value with a 
-- matching index is used.
-- 
-- e.g. TT_MaxIndexMapText({1,2,3}, {a,b,c}, {A,B,C}, {AA, BB, CC})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexMapText(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexMapText(
  intList text,
  testList text,
  mapVals text,
  targetVals text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  DECLARE
    _testVal text;
  BEGIN
  
    -- Note we can't validate setNullTo using TT_ValidateParams because null is an expected value
    -- which is not permitted by TT_ValidateParams. Need to make our own tests for NULL values 
    -- and valid arguments in the test script.
    PERFORM TT_ValidateParams('TT_MaxIndexMapText',
                              ARRAY['mapVals', mapVals, 'stringlist',
                                    'targetVals', targetVals, 'stringlist']);
                                   
    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
    
    -- pass _testVal to mapText
    RETURN TT_MapText(_testVal, mapVals, targetVals);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexMapText(
  intList text,
  testList text,
  mapVals text,
  targetVals text
)
RETURNS text AS $$
  SELECT TT_MaxIndexMapText(intList, testList, mapVals, targetVals, null::text, null::text)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_MaxIndexMapInt()
--
-- Runs maxIndexMaptText and casts the result to an integer
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexMapInt(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexMapInt(
  intList text,
  testList text,
  mapVals text,
  targetVals text,
  setNullTo text,
  setZeroTo text
)
RETURNS int AS $$
  SELECT TT_MaxIndexMapText(intList, testList, mapVals, targetVals, setNullTo, setZeroTo)::int;
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexMapInt(
  intList text,
  testList text,
  mapVals text,
  targetVals text
)
RETURNS int AS $$  
  SELECT TT_MaxIndexMapInt(intList, testList, mapVals, targetVals, null::text, null::text);
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MinIndexLookupText()
--
-- intList text - stringList of values to test
-- testList - stringList from which to select the value to pass to mapText
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupCol text - column to look up for the value
-- retrieveCol - column from which to retrieve the matching value
-- setNullTo - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- passes value from returnList matching the index of the smallest
-- value in intList to  . If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
-- If multiple occurences of the smallest value, the first index representing a non-null return value is used.
-- 
-- e.g. TT_MinIndexLookupText({1,2,3}, {a,b,c}, 'lookupSchema', 'lookupTable', 'lookupCol', 'returnCol')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MinIndexLookupText(text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MinIndexLookupText(
  intList text,
  testList text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  retrieveCol text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  DECLARE
    _testVal text;
  BEGIN
  
    -- Note we can't validate setNullTo using TT_ValidateParams because null is an expected value
    -- which is not permitted by TT_ValidateParams. Need to make our own tests for NULL values 
    -- and valid arguments in the test script.
    PERFORM TT_ValidateParams('TT_MinIndexLookupText',
                          ARRAY['lookupSchemaName', lookupSchemaName, 'name',
                                'lookupTableName', lookupTableName, 'name',
                                'lookupCol', lookupCol, 'name',
                                'retrieveCol', retrieveCol, 'name']);

    _testVal = TT_minIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
    
    -- pass _srcVal to lookupText
    RETURN TT_LookupText(_testVal, lookupSchemaName, lookupTableName, lookupCol, retrieveCol, 'FALSE');
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexLookupText(
  intList text,
  testList text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  SELECT TT_MinIndexLookupText(intList, testList, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, setNullTo, setZeroTo)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MinIndexLookupText(
  intList text,
  testList text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text
)
RETURNS text AS $$
  SELECT TT_MinIndexLookupText(intList, testList, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, NULL::text, null::text)
$$ LANGUAGE sql STABLE;
-------------------------------------------------------------------------------
-- TT_MaxIndexLookupText()
--
-- intList text - stringList of values to test
-- testList - stringList from which to select the value to pass to mapText
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupCol text - column to look up for the value
-- retrieveCol - column from which to retrieve the matching value
-- setNullTo - defaults to null - optionally convert any nulls in intList to this value
-- setZeroTo text - defaults to null - optionally convert any zeros in intList to this value
--
-- passes value from returnList matching the index of the smallest
-- value in intList to lookupText. If setNullTo is provided as an integer, nulls
-- are replaced with the integer in intList. Otherwise nulls ignored 
-- when calculating min value.
-- If multiple occurences of the largest value, the last index representing a non-null return value is used.
-- 
-- e.g. TT_MaxIndexLookupText({1,2,3}, {a,b,c}, 'lookupSchema', 'lookupTable', 'lookupCol', 'returnCol')
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_MaxIndexLookupText(text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MaxIndexLookupText(
  intList text,
  testList text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text,
  retrieveCol text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  DECLARE
    _testVal text;
  BEGIN
  
    -- Note we can't validate setNullTo using TT_ValidateParams because null is an expected value
    -- which is not permitted by TT_ValidateParams. Need to make our own tests for NULL values 
    -- and valid arguments in the test script.
    PERFORM TT_ValidateParams('TT_MaxIndexLookupText',
                          ARRAY['lookupSchemaName', lookupSchemaName, 'name',
                                'lookupTableName', lookupTableName, 'name',
                                'lookupCol', lookupCol, 'name',
                                'retrieveCol', retrieveCol, 'name']);

    _testVal = TT_maxIndex_getTestVal(intList, testList, setNullTo, setZeroTo);
    
    -- pass _testVal to lookupText
    RETURN TT_LookupText(_testVal, lookupSchemaName, lookupTableName, lookupCol, retrieveCol, 'FALSE');
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexLookupText(
  intList text,
  testList text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text,
  setNullTo text,
  setZeroTo text
)
RETURNS text AS $$
  SELECT TT_MaxIndexLookupText(intList, testList, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, setNullTo, setZeroTo)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_MaxIndexLookupText(
  intList text,
  testList text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text
)
RETURNS text AS $$
  SELECT TT_MaxIndexLookupText(intList, testList, lookupSchemaName, lookupTableName, 'source_val', retrieveCol, null::text, null::text)
$$ LANGUAGE sql STABLE;

-------------------------------------------------------------------------------
-- TT_DivideDouble()
--
-- val text - source value
-- divideBy - value to divide by
--
-- Basic division function returning double
-- 
-- e.g. TT_DivideDouble(10, 3)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_DivideDouble(text, text);
CREATE OR REPLACE FUNCTION TT_DivideDouble(
  val text,
  divideBy text
)
RETURNS double precision AS $$
  DECLARE
    _divideBy double precision;
    _val double precision;
  BEGIN
  
    PERFORM TT_ValidateParams('TT_DivideDouble',
                              ARRAY['divideBy', divideBy, 'numeric']);     
    _val = val::double precision;                     
    _divideBy = divideBy::double precision;
    
    -- if dividing by zero, return null to avoid error
    IF _divideBy = 0 THEN
      RETURN NULL;
    END IF;
        
    RETURN _val/_divideBy::double precision;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_DivideInt()
--
-- val text - source value
-- divideBy - value to divide by
--
-- Wrapper around tt_DivideDouble returning int 
-- 
-- e.g. TT_DivideInt(10, 2)
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_DivideInt(text, text);
CREATE OR REPLACE FUNCTION TT_DivideInt(
  val text,
  divideBy text
)
RETURNS int AS $$        
    SELECT tt_DivideDouble(val, divideBy)::numeric::int
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Multiply()
--
-- val1 text - The first value to multiply.
-- val2 text - The second value to multiply.
--
-- returns val1 * val2
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Multiply(
  val1 text,
  val2 text
)
RETURNS double precision AS $$
  BEGIN
    IF val1::double precision = 0 OR val2::double precision = 0 THEN
      RETURN NULL;
    END IF;
  
    RETURN val1::double precision * val2::double precision;
  END    
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_MultiplyInt()
--
-- cast to int
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_MultiplyInt(
  val1 text,
  val2 text
)
RETURNS int AS $$
  SELECT TT_Multiply(val1, val2)::int    
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_SubstringMultiplyInt()
--
-- take substring, cast to int, multiply
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_SubstringMultiplyInt(
  srcVal text,
  _from text,
  _for text,
  val text
)
RETURNS int AS $$
  SELECT TT_Multiply(TT_SubstringInt(srcVal, _from, _for)::text, val)::int    
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LookupTextSubstring()
--
-- val text - value to test.
--
-- startChar - start character to take substring from
-- forLength - length of substring to take
--
-- lookupSchemaName text - Schema name holding lookup table.
-- lookupTableName text - Lookup table name.
-- lookupColumnName text - Lookup table column name.
-- ignoreCase text - Should upper/lower case be ignored? Default to FALSE. 
-- acceptNull text - Should NULL value return TRUE? Default to FALSE.
--
-- Take substring and pass to lookupText
-- e.g. TT_LookupTextSubstring('BS01', 1, 2, 'public', 'bc08', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LookupTextSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text,
  lookupColumnName text,
  retrieveCol text,
  ignoreCase text,
  removeSpaces text
)
RETURNS text AS $$
  DECLARE
    _val text;
  BEGIN

    -- convert source NULLs into empty strings. This allows NULL source values to be translated into target
    -- values by using an empty string in the lookup table. If no empty string translation is provided, function
    -- returns NULL as usual.
    IF val IS NULL THEN
      _val = '';
    ELSE
      _val = val;
    END IF;

    -- process
    _val = TT_SubstringText(val, startChar, forLength, removeSpaces);
    RETURN TT_LookupText(_val, lookupSchemaName, lookupTableName, lookupColumnName, retrieveCol, ignoreCase);
  END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupTextSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text,
  ignoreCase text,
  removeSpaces text
)
RETURNS text AS $$
  SELECT TT_LookupTextSubstring(val, startChar, forLength, lookupSchemaName, lookupTableName, 'source_val'::text, retrieveCol, ignoreCase, removeSpaces)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupTextSubstring(
  val text,
  startChar text,
  forLength text,
  lookupSchemaName text,
  lookupTableName text,
  retrieveCol text
)
RETURNS text AS $$
  SELECT TT_LookupTextSubstring(val, startChar, forLength, lookupSchemaName, lookupTableName, 'source_val'::text, retrieveCol, FALSE::text, FALSE::text)
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION TT_LookupTextSubstring(
  val text,
  startChar text,
  forLength text,
  lookupTableName text,
  retrieveCol text
)
RETURNS text AS $$
  SELECT TT_LookupTextSubstring(val, startChar, forLength, 'public', lookupTableName, 'source_val'::text, retrieveCol, FALSE::text, FALSE::text)
$$ LANGUAGE sql STABLE;

-------------------------------------------------------------------------------
-- TT_CoalesceText()
--
-- valList text - stringList of values to test
--
-- zeroAsNull text - boolean specifying if 0s are to be treated as NULL
--
-- Return the first non-NULL value
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CoalesceText(
  valList text,
  zeroAsNull text,
  callerFctName text
)
RETURNS text AS $$
  DECLARE
    _zeroAsNull boolean;
    _val text;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams(callerFctName,
                              ARRAY['zeroAsNull', zeroAsNull, 'boolean']);
                          
    _zeroAsNull = zeroAsNull::boolean;
    
    -- validate source value (return NULL if not valid)
    IF NOT TT_IsStringList(valList) THEN
      RETURN NULL;
    END IF;
    
    -- process
    IF _zeroAsNull THEN
      FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
        IF NOT _val IS NULL AND (NOT TT_IsNumeric(_val) OR _val::double precision != 0) THEN
          RETURN _val;
        END IF;
      END LOOP;
    ELSE
      FOREACH _val IN ARRAY TT_ParseStringList(valList, TRUE) LOOP
        IF NOT _val IS NULL THEN
          RETURN _val;
        END IF;
      END LOOP;
    END IF;

    RETURN NULL;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CoalesceText(
  valList text,
  zeroAsNull text
)
RETURNS text AS $$
  SELECT TT_CoalesceText(valList, zeroAsNull, 'TT_CoalesceText')
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CoalesceText(
  valList text
)
RETURNS text AS $$
  SELECT TT_CoalesceText(valList, FALSE::text, 'TT_CoalesceText')
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_CoalesceInt()
--
-- int returning version of TT_CoalesceText()
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_CoalesceInt(
  valList text,
  zeroAsNull text
)
RETURNS int AS $$
  DECLARE
    _zeroAsNull boolean;
  BEGIN
    -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_CoalesceInt',
                              ARRAY['zeroAsNull', zeroAsNull, 'boolean']);
                          
    _zeroAsNull = zeroAsNull::boolean;

    -- validate source value (return NULL if not valid)
    IF NOT TT_IsIntList(valList) THEN
      RETURN NULL;
    END IF;

    RETURN TT_CoalesceText(valList, zeroAsNull, 'TT_CoalesceInt')::double precision::int;
  END
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_CoalesceInt(
  valList text
)
RETURNS int AS $$
  SELECT TT_CoalesceInt(valList, FALSE::text)::int
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CountOfNotNullMapText()
--
-- vals1/2/3/4/5/6/7 text - string lists of values to test.
-- maxRankToConsider int - only consider the first x string lists.
-- resultList - list of values to match the results from countOfNotNull
-- mappingList - List of mappings to return
--
-- Run countofNotNull then pass result to mapText. zeroIsNull in countofnotnull is set to FALSE.
-- e.g. TT_CountOfNotNullMapText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, {1,2,3,4,5,6,7}, {a,b,c,d,e,f,g})
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  vals8 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_MapText(
	  TT_CountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, maxRankToConsider, 'FALSE')::text,
	  resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;


-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, vals6, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, vals4, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  vals3 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  vals2 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapText(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapText(
  vals1 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS text AS $$
    SELECT TT_CountOfNotNullMapText(vals1, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CountOfNotNullMapInt()
--
-- Wrapper around TT_CountOfNotNullMapText
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  vals8 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, maxRankToConsider, resultList, mappingList)::int
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, vals2, vals3, vals4, vals5, vals6, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, vals2, vals3, vals4, vals5, vals6, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, vals2, vals3, vals4, vals5, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, vals2, vals3, vals4, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  vals3 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, vals2, vals3, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  vals2 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, vals2, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapInt(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapInt(
  vals1 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS int AS $$
    SELECT TT_CountOfNotNullMapInt(vals1, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_CountOfNotNullMapDouble()
--
-- Wrapper around TT_CountOfNotNullMapText
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  vals8 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, maxRankToConsider, resultList, mappingList)::double precision
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  vals7 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, vals5, vals6, vals7, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  vals6 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, vals5, vals6, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  vals5 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, vals5, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  vals3 text,
  vals4 text, 
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  vals3 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, vals2, vals3, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  vals2 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, vals2, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;

-- DROP FUNCTION IF EXISTS TT_CountOfNotNullMapDouble(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_CountOfNotNullMapDouble(
  vals1 text,
  maxRankToConsider text,
  resultList text,
  mappingList text
)
RETURNS double precision AS $$
    SELECT TT_CountOfNotNullMapDouble(vals1, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, maxRankToConsider, resultList, mappingList)
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MapTextNotNullIndex()
--
-- val1
-- srcList1
-- targetList1
-- val2
-- srcList2
-- targetList2
-- etc.
-- etc.
-- etc.
-- indexToReturn
-- 
-- Run mapText for each set of val, srcList and targetList, then return the ith non-null result where i = indexToReturn.
-- If i > count of results NULL will be returned.
--
-- e.g. TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, 
--       val4,srcList4,targetList4, val5,srcList5,targetList5, val6,srcList6,targetList6, val7,srcList7,
--       targetList7, val8,srcList8,targetList8, val9,srcList9,targetList9, val10,srcList10,targetList10, indexToReturn)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_MapTextNotNullIndex(text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, 
--                                               text, text, text, text, text, text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  val5 text, srcList5 text, targetList5 text,
  val6 text, srcList6 text, targetList6 text,
  val7 text, srcList7 text, targetList7 text,
  val8 text, srcList8 text, targetList8 text,
  val9 text, srcList9 text, targetList9 text,
  val10 text, srcList10 text, targetList10 text,
  indexToReturn text
)
RETURNS text AS $$
  DECLARE
    res1 text;
	res2 text;
	res3 text;
	res4 text;
	res5 text;
	res6 text;
	res7 text;
	res8 text;
	res9 text;
	res10 text;
	_indexToReturn int;
	counter int := 0;
  BEGIN
  -- validate parameters (trigger EXCEPTION)
    PERFORM TT_ValidateParams('TT_MapTextNotNullIndex',
                              ARRAY['indexToReturn', indexToReturn, 'int']);
    _indexToReturn = indexToReturn::int;
	
    IF val1 IS NOT NULL THEN
	  res1 = tt_MapText(val1, srcList1, targetList1);
	  IF res1 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res1;
		END IF;
	  END IF;
	END IF;
	IF val2 IS NOT NULL THEN
	  res2 = tt_MapText(val2, srcList2, targetList2);
	  IF res2 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res2;
		END IF;
	  END IF;
	END IF;
	IF val3 IS NOT NULL THEN
	  res3 = tt_MapText(val3, srcList3, targetList3);
	  IF res3 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res3;
		END IF;
	  END IF;
	END IF;
	IF val4 IS NOT NULL THEN
	  res4 = tt_MapText(val4, srcList4, targetList4);
	  IF res4 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res4;
		END IF;
	  END IF;
	END IF;
	IF val5 IS NOT NULL THEN
	  res5 = tt_MapText(val5, srcList5, targetList5);
	  IF res5 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res5;
		END IF;
	  END IF;
	END IF;
	IF val6 IS NOT NULL THEN
	  res6 = tt_MapText(val6, srcList6, targetList6);
	  IF res6 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res6;
		END IF;
	  END IF;
	END IF;
	IF val7 IS NOT NULL THEN
	  res7 = tt_MapText(val7, srcList7, targetList7);
	  IF res7 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res7;
		END IF;
	  END IF;
	END IF;
	IF val8 IS NOT NULL THEN
	  res8 = tt_MapText(val8, srcList8, targetList8);
	  IF res8 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res8;
		END IF;
	  END IF;
	END IF;
	IF val9 IS NOT NULL THEN
	  res9 = tt_MapText(val9, srcList9, targetList9);
	  IF res9 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res9;
		END IF;
	  END IF;
	END IF;
	IF val10 IS NOT NULL THEN
	  res10 = tt_MapText(val10, srcList10, targetList10);
	  IF res10 IS NOT NULL THEN
	    counter = counter + 1;
		IF counter = _indexToReturn THEN
		  RETURN res10;
		END IF;
	  END IF;
	END IF;
	RETURN NULL;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  val5 text, srcList5 text, targetList5 text,
  val6 text, srcList6 text, targetList6 text,
  val7 text, srcList7 text, targetList7 text,
  val8 text, srcList8 text, targetList8 text,
  val9 text, srcList9 text, targetList9 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, val4,srcList4,targetList4, val5,srcList5,targetList5, 
						val6,srcList6,targetList6, val7,srcList7,targetList7, val8,srcList8,targetList8, val9,srcList9,targetList9, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  val5 text, srcList5 text, targetList5 text,
  val6 text, srcList6 text, targetList6 text,
  val7 text, srcList7 text, targetList7 text,
  val8 text, srcList8 text, targetList8 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, val4,srcList4,targetList4, val5,srcList5,targetList5, 
						val6,srcList6,targetList6, val7,srcList7,targetList7, val8,srcList8,targetList8, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  val5 text, srcList5 text, targetList5 text,
  val6 text, srcList6 text, targetList6 text,
  val7 text, srcList7 text, targetList7 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, val4,srcList4,targetList4, val5,srcList5,targetList5, 
						val6,srcList6,targetList6, val7,srcList7,targetList7, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  val5 text, srcList5 text, targetList5 text,
  val6 text, srcList6 text, targetList6 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, val4,srcList4,targetList4, val5,srcList5,targetList5, 
						val6,srcList6,targetList6, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  val5 text, srcList5 text, targetList5 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, val4,srcList4,targetList4, val5,srcList5,targetList5, 
						NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  val4 text, srcList4 text, targetList4 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, val4,srcList4,targetList4, NULL::text,NULL::text,NULL::text, 
						NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  val3 text, srcList3 text, targetList3 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, val3,srcList3,targetList3, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, 
						NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION TT_MapTextNotNullIndex(
  val1 text, srcList1 text, targetList1 text,
  val2 text, srcList2 text, targetList2 text,
  indexToReturn text
)
RETURNS text AS $$
  SELECT TT_MapTextNotNullIndex(val1,srcList1,targetList1, val2,srcList2,targetList2, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, 
						NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, NULL::text,NULL::text,NULL::text, indexToReturn)
$$ LANGUAGE sql IMMUTABLE;