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
-- inclusive - are min and max inclusive? Default True.
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
  inclusive text
)
RETURNS boolean AS $$
  DECLARE
    _val double precision := val::double precision;
    _min double precision := min::double precision;
    _max double precision := max::double precision;
    _inclusive boolean := inclusive::boolean;
  BEGIN
    IF min IS NULL OR max IS NULL THEN
      RAISE EXCEPTION 'min or max is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF _inclusive = TRUE THEN
      RETURN _val >= _min and _val <= _max;
    ELSE
      RETURN _val > _min and _val < _max;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val text,
  min text,
  max text
)
RETURNS boolean AS $$
  SELECT TT_Between(val, min, max, TRUE::text);
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
-- occurences - text defaults to 1
--
-- if number of occurences of val in source_val of schema.table equals occurences, return true.
-- e.g. TT_HasUniqueValues('BS', 'public', 'bc08', 1)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasUniqueValues(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  occurences text
)
RETURNS boolean AS $$
  DECLARE
    _lookupSchemaName name := lookupSchemaName::name;
    _lookupTableName name := lookupTableName::name;
    _occurences int := occurences::int;
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF occurences IS NULL THEN
      RAISE EXCEPTION 'occurences is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ') = ' || _occurences || ';';
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
-- TT_MatchTable (table version)
--
-- val text - value to test.
-- lookupSchemaName text - schema name holding lookup table.
-- lookupTableName text - lookup table.
-- ignoreCase - text default TRUE. Should upper/lower case be ignored?
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
  SELECT TT_MatchTable(val, lookupSchemaName, lookupTableName, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_MatchList (list version)
--
-- val text - value to test.
-- lst text - string containing comma separated vals.
-- ignoreCase - text default TRUE. Should upper/lower case be ignored?
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
  SELECT TT_MatchList(val, lst, TRUE::text)
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
-- TT_Copy
--
--  val text  - Value to return.
--
-- Return the value as text. Engine will cast output to the correct type.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Copy(
  val text
)
RETURNS text AS $$
  BEGIN
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Lookup
--
-- val text - val to lookup
-- lookupSchemaName text - schema name containing lookup table
-- lookupTableName text - lookup table name
-- lookupColumn text - column to return
-- ignoreCase text - default TRUE. Should upper/lower case be ignored?
--
-- Return value from lookupColumn in lookupSchemaName.lookupTableName
-- that matches val in source_val column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
-- e.g. TT_Lookup('BS', 'public', 'bc08', 'species1', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Lookup(
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
      query = 'SELECT ' || quote_ident(lookupCol) || ' FROM ' || TT_FullTableName(_lookupSchemaName, _lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || quote_ident(lookupCol) || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE upper(source_val::text) = upper(' || quote_literal(val) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Lookup(
  val text,
  lookupSchemaName text,
  lookupTableName text,
  lookupCol text
)
RETURNS text AS $$
  SELECT TT_Lookup(val, lookupSchemaName, lookupTableName, lookupCol, TRUE::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Map
--
-- val text - value to test.
-- lst1 text - string containing comma seperated vals
-- lst2 text - string containing comma seperated vals
-- ignoreCase - default TRUE. Should upper/lower case be ignored?
--
-- Return value from lst2 that matches value index in lst1
-- Error if val is NULL
-- e.g. TT_Map('A','A,B,C','1,2,3', TRUE)

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Map(
  val text,
  lst1 text,
  lst2 text,
  ignoreCase text
)
RETURNS text AS $$
  DECLARE
    var1 text[];
    var2 text[];
    _ignoreCase boolean := ignoreCase::boolean;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF _ignoreCase = FALSE THEN
      var1 = string_to_array(lst1, ',');
      var2 = string_to_array(lst2, ',');
      RETURN (var2)[array_position(var1,val)];
    ELSE
      var1 = string_to_array(upper(lst1), ',');
      var2 = string_to_array(upper(lst2), ',');
      RETURN (var2)[array_position(var1,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Map(
  val text,
  lst1 text,
  lst2 text
)
RETURNS text AS $$
  SELECT TT_Map(val, lst1, lst2, TRUE::text)
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
--  val1 text - first val to concat
--  val2 - text - second val to concat
--  sep text  - Separator (e.g. '_'). If no sep required use '' as second argument.
--  processNulls - if true, concat is run and nulls ignored. If false, nulls raise error.
--               - Defaults to FALSE.
-- Return the concatenated value.

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val1 text,
  val2 text,
  sep text,
  processNulls text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF _processNulls = FALSE AND (val1 IS NULL OR val2 IS NULL) THEN 
      RAISE EXCEPTION 'a val is null';
    ELSE
      RETURN concat_ws(sep, val1, val2);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val1 text,
  val2 text,
  val3 text,
  sep text,
  processNulls text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF _processNulls = FALSE AND (val1 IS NULL OR val2 IS NULL OR val3 IS NULL) THEN 
      RAISE EXCEPTION 'a val is null';
    ELSE
      RETURN concat_ws(sep, val1, val2, val3);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val1 text,
  val2 text,
  val3 text,
  val4 text,
  sep text,
  processNulls text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF _processNulls = FALSE AND (val1 IS NULL OR val2 IS NULL OR val3 IS NULL OR val4 IS NULL) THEN 
      RAISE EXCEPTION 'a val is null';
    ELSE
      RETURN concat_ws(sep, val1, val2, val3, val4);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  val1 text,
  val2 text,
  val3 text,
  val4 text,
  val5 text,
  sep text,
  processNulls text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF _processNulls = FALSE AND (val1 IS NULL OR val2 IS NULL OR val3 IS NULL OR val4 IS NULL OR val5 IS NULL) THEN 
      RAISE EXCEPTION 'a val is null';
    ELSE
      RETURN concat_ws(sep, val1, val2, val3, val4, val5);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_PadConcat
--
--  val1...val5 text - vals to concat
--  length1...length5 text - length of padding for each val
--  pad1...pad5 - pad character for each val
--  sep text  - Separator (e.g. '_'). If no sep required use '' as second argument.
--  processNulls text - if true, concat is run and nulls ignored. If false, nulls raise error.
--               - Defaults to FALSE.
--  upperCase text - should vals be uppercase
--
--  Return the concatenated values with the padding.
--  Different signatures for up to 5 val, length and pad values.
--  Must be equal number of val, length and pad values.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_PadConcat(
  val1 text,
  length1 text,
  pad1 text,
  sep text,
  processNulls text,
  upperCase text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
    _upperCase boolean := upperCase::boolean;
  BEGIN
    IF length1 IS NULL THEN
      RAISE EXCEPTION 'length is null';
    ELSIF pad1 IS NULL THEN
      RAISE EXCEPTION 'pad is null';
    ELSIF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF val1 IS NULL AND _processNulls = FALSE THEN
      RAISE EXCEPTION 'val is null';  
    ELSIF _upperCase = TRUE THEN
      RETURN concat_ws(sep, TT_Pad(upper(val1), length1, pad1));
    ELSE
      RETURN concat_ws(sep, TT_Pad(val1, length1, pad1));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_PadConcat(
  val1 text, val2 text,
  length1 text, length2 text,
  pad1 text, pad2 text,
  sep text,
  processNulls text,
  upperCase text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
    _upperCase boolean := upperCase::boolean;
  BEGIN
    IF length1 IS NULL OR length2 IS NULL THEN
      RAISE EXCEPTION 'a length is null';
    ELSIF pad1 IS NULL OR pad2 IS NULL THEN
      RAISE EXCEPTION 'a pad is null';
    ELSIF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF (val1 IS NULL OR val2 IS NULL) AND _processNulls = FALSE THEN
      RAISE EXCEPTION 'a val is null';  
    ELSIF _upperCase = TRUE THEN
      RETURN concat_ws(sep, TT_Pad(upper(val1), length1, pad1), TT_Pad(upper(val2), length2, pad2));
    ELSE
      RETURN concat_ws(sep, TT_Pad(val1, length1, pad1), TT_Pad(val2, length2, pad2));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_PadConcat(
  val1 text, val2 text, val3 text,
  length1 text, length2 text, length3 text,
  pad1 text, pad2 text, pad3 text,
  sep text,
  processNulls text,
  upperCase text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
    _upperCase boolean := upperCase::boolean;
  BEGIN
    IF length1 IS NULL OR length2 IS NULL OR length3 IS NULL THEN
      RAISE EXCEPTION 'a length is null';
    ELSIF pad1 IS NULL OR pad2 IS NULL OR pad3 IS NULL THEN
      RAISE EXCEPTION 'a pad is null';
    ELSIF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF (val1 IS NULL OR val2 IS NULL OR val3 IS NULL) AND _processNulls = FALSE THEN
      RAISE EXCEPTION 'a val is null';  
    ELSIF _upperCase = TRUE THEN
      RETURN concat_ws(sep, TT_Pad(upper(val1), length1, pad1), TT_Pad(upper(val2), length2, pad2), TT_Pad(upper(val3), length3, pad3));
    ELSE
      RETURN concat_ws(sep, TT_Pad(val1, length1, pad1), TT_Pad(val2, length2, pad2), TT_Pad(val3, length3, pad3));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_PadConcat(
  val1 text, val2 text, val3 text, val4 text,
  length1 text, length2 text, length3 text, length4 text,
  pad1 text, pad2 text, pad3 text, pad4 text,
  sep text,
  processNulls text,
  upperCase text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
    _upperCase boolean := upperCase::boolean;
  BEGIN
    IF length1 IS NULL OR length2 IS NULL OR length3 IS NULL OR length4 IS NULL THEN
      RAISE EXCEPTION 'a length is null';
    ELSIF pad1 IS NULL OR pad2 IS NULL OR pad3 IS NULL OR pad4 IS NULL THEN
      RAISE EXCEPTION 'a pad is null';
    ELSIF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF (val1 IS NULL OR val2 IS NULL OR val3 IS NULL OR val4 IS NULL) AND _processNulls = FALSE THEN
      RAISE EXCEPTION 'a val is null';  
    ELSIF _upperCase = TRUE THEN
      RETURN concat_ws(sep, TT_Pad(upper(val1), length1, pad1), TT_Pad(upper(val2), length2, pad2), TT_Pad(upper(val3), length3, pad3), TT_Pad(upper(val4), length4, pad4));
    ELSE
      RETURN concat_ws(sep, TT_Pad(val1, length1, pad1), TT_Pad(val2, length2, pad2), TT_Pad(val3, length3, pad3), TT_Pad(val4, length4, pad4));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_PadConcat(
  val1 text, val2 text, val3 text, val4 text, val5 text,
  length1 text, length2 text, length3 text, length4 text, length5 text,
  pad1 text, pad2 text, pad3 text, pad4 text, pad5 text,
  sep text,
  processNulls text,
  upperCase text
)
RETURNS text AS $$
  DECLARE
    _processNulls boolean := processNulls::boolean;
    _upperCase boolean := upperCase::boolean;
  BEGIN
    IF length1 IS NULL OR length2 IS NULL OR length3 IS NULL OR length4 IS NULL OR length5 IS NULL THEN
      RAISE EXCEPTION 'a length is null';
    ELSIF pad1 IS NULL OR pad2 IS NULL OR pad3 IS NULL OR pad4 IS NULL OR pad5 IS NULL THEN
      RAISE EXCEPTION 'a pad is null';
    ELSIF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF (val1 IS NULL OR val2 IS NULL OR val3 IS NULL OR val4 IS NULL OR val5 IS NULL) AND _processNulls = FALSE THEN
      RAISE EXCEPTION 'a val is null';  
    ELSIF _upperCase = TRUE THEN
      RETURN concat_ws(sep, TT_Pad(upper(val1), length1, pad1), TT_Pad(upper(val2), length2, pad2), TT_Pad(upper(val3), length3, pad3), TT_Pad(upper(val4), length4, pad4), TT_Pad(upper(val5), length5, pad5));
    ELSE
      RETURN concat_ws(sep, TT_Pad(val1, length1, pad1), TT_Pad(val2, length2, pad2), TT_Pad(val3, length3, pad3), TT_Pad(val4, length4, pad4), TT_Pad(val5, length5, pad5));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
