# Intro
The PostgreSQL Translation Engine allows PostgreSQL users to translate tables into new specifications using translation rules. The primary components are:
* The engine, implemented as a set of pl/pgsql scripts.
* A set of helper functions to facilitate translation.
* A translation table that uses helper functions to validate the source data and define the translation rules.
* Optionally, a set of lookup tables that accompany the translation table.

# Directory structure
<pre>
./             .sql files for loading, testing, and uninstalling the engine and helper functions

./docs         Documentation including engine specifications
</pre>

# Requirements - software versions
The PostgreSQL Translation Engine requires PostgreSQL 9.6 and PostGIS v2.3.7.

# Version releases
* PostTranslationEngine v0.1beta

# Installation/uninstallation
* In a PostgreSQL query window, run, in this order:
  1. the engine.sql file,
  2. the helperFunctions.sql file,
  3. the helperFunctionsTest.sql file. All tests should pass.
  4. the engineTest.sql file. All tests should pass.
* You can uninstall all the functions by running the helperFunctionsUninstall.sql and the engineUninstall.sql files.

# Vocabulary
*Translation engine* - The [PostgreSQL Translation Engine](https://github.com/edwardsmarc/postTranslationEngine).

*Helper function* - A set of functions used in the translation table to facilitate translation.

*Source table* - Raw FRI table in PostgreSQL.

*Target table* - Translated FRI table in PostgreSQL.

*Translation table* - User created table detailing the translation rules and read by the translation engine.

*Lookup table* - User created table used in conjunction with the translation tables.

*Source attribute/value* - The attribute or value contained in the source table.

*Target attribute/value* - The attribute or value in the translated target table.

# Helper Functions
1. **NotNull**(val[]) - validation function
    * Returns TRUE if source values are not NULL. Returns FALSE if any vals are NULL.
    * e.g. NotNull('a', 'b', 'c')
    * Signatures:
      * NotNull(text[])
      * NotNull(boolean[])
      * NotNull(double precision[])
      * NotNull(int[])
2. **NotEmpty**(val[]) - validation function
    * Returns TRUE if source values are not an empty string. Returns FALSE if any source value is empty string or padded spaces (e.g. '' or '  ') or Null.
    * e.g. NotEmpty('a', 'b', 'c')
    * Signatures:
      * NotEmpty(val[])
3. **IsInt**(val[]) - validation function
    * Returns TRUE if source values represent integers. Returns FALSE if any source values are Null. Strings with numeric characters and '.' will be passed to IsInt. Strings with anything else (e.g. letter characters) return FALSE.
    * e.g. IsInt(1,2,3,4,5)
    * Signatures:
      * IsInt(text[])
      * IsInt(double precision[])
      * IsInt(int[])
4. **IsNumeric**(val[]) - validation function
    * Returns TRUE if source values can be cast to double precision. Null source values return FALSE.
    * e.g. IsNumeric('1.1', '1.2', '1.3')
    * Signatures:
      * IsNumeric(text[])
      * IsNumeric(double precision[])
      * IsNumeric(int[])
5. **Between**(val, min, max) - validation function
    * Returns TRUE if source value is between min and max.
    * e.g. Between(5, 0, 100)
    * Signatures
      * Between(double precision, double precision, double precision)
      * Between(int, double precision, double precision)
      * Between(text, double precision, double precision)
      * Between(int, double precision, text)
      * Between(int, text, double precision)
      * Between(text, double precision, text)
      * Between(text, text, double precision)
6. **GreaterThan**(val, lowerBound, inclusive\[default TRUE\]) - validation function
    * Returns TRUE if source value >= lowerBound and inclusive = TRUE. Returns TRUE if source value > lowerBound and inclusive = FALSE. Returns FALSE otherwise or if source value is Null.
    * e.g. GreaterThan(5, 0, TRUE)
    * Signatures:
      * GreaterThan(double precision, double precision, boolean)
      * GreaterThan(int, double precision, boolean)
7. **LessThan**(val, upperBound, inclusive\[default TRUE\]) - validation function
    * Returns TRUE if source value <= lowerBound and inclusive = TRUE. Returns TRUE if source value < lowerBound and inclusive = FALSE. Returns FALSE otherwise or if source value is Null.
    * e.g. LessThan(1, 5, TRUE)
    * Signatures:
      * LessThan(double precision, double precision, boolean)
      * LessThan(int, double precision, boolean)
8. **HasUniqueValues**(val, lookupSchemaName, lookupTableName, occurences\[default 1\]) - validation function
    * Returns TRUE if number of occurences of source value in source_val column of schema.table equals occurences.
    * e.g. HasUniqueValues(TA, public, species_lookup, 1)
    * Signatures:
      * HasUniqueValues(text, name, name, int)
      * HasUniqueValues(double precision, name, name, int)
      * HasUniqueValues(int, name, name, int)
9. **Match**(val, lookupSchemaName, lookupTableName, ignoreCase\[default TRUE\]) - table version - validation function
    * Returns TRUE if source value is present in source_val column of lookupSchemaName.lookupTableName. Ignores letter case if ignoreCase = TRUE.
    * e.g. TT_Match(sp1,public,species_lookup, TRUE)
    * Signatures:
      * Match(text, name, name, boolean)
      * Match(double precision, name, name, boolean)
      * Match(int, name, name, boolean)
10. **Match**(val, lst, ignoreCase\[default TRUE\]) - list version - validation function
    * Returns TRUE if source value is in lst. Ignores letter case if ignoreCase = TRUE.
    * e.g. Match('a', 'a,b,c', TRUE)
    * Signatures:
      * Match(text, text)
      * Match(double precision, text)
      * Match(int, text)
11. **False**() - validation function
    * Returns FALSE.
    * e.g. False()
    * Signatures:
      * False()
12. **IsString**(val[]) - validation function
    * Returns TRUE if source values are strings.
    * e.g. IsString('a', 'b', 'c')
    * Signatures:
      * IsString(text[])
      * IsString(double precision[])
      * IsString(int[])
13. **Copy**(val) - translation function
    * Returns source value.
    * e.g. Copy(sp1)
    * Signatures:
      * Copy(text)
      * Copy(double precision)
      * Copy(int)
      * Copy(boolean)
14. **Concat**(sep, processNulls, val[])
    * Returns the concatenated source values separated by sep. Nulls are ignored if processNulls = TRUE. An error is raised if processNulls = FALSE and source values contain Null.
    * e.g. Concat('_', FALSE, 'a', 'b', 'c')
    * Signatures:
      * Concat(text, boolean, text[])
15. **Lookup**(val, lookupSchemaName, lookupTableName, lookupCol, ignoreCase\[default TRUE\])
    * Returns value from lookupColumn in lookupSchemaName.lookupTableName that matches source value in source_val column. If multiple matches, first row is returned.
    * e.g. Lookup(sp1, public, species_lookup, targetSp)
    * Signatures:
      * Lookup(text, name, name, text, boolean)
      * Lookup(double precision, name, name, text, boolean)
      * Lookup(int, name, name, text, boolean)
16. **Length**(val)
    * Returns length of source value string
    * e.g. Length('12345')
    * Signatures:
      * Length(text)
      * Length(double precision)
      * Length(int)
17. **Pad**(val, targetLength, padChar\[default x\])
    * Returns a string of length targetLength made up of source value preceeded with padChar if source value length < targetLength. Returns source value trimmed to targetLength if source value length > targetLength.
    * e.g. Pad(tab1, 10, x)
    * Signatures:
      * Pad(text, int, text)
      * Pad(double precision, int, text)
      * Pad(int, int, text)
18. **Map**(val, lst1, lst2, ignoreCase\[default TRUE\])
    * Return value in lst2 that matches index of source value in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','A,B,C','1,2,3', TRUE)
    * Signatures:
      * Map(text, text, text, boolean)
      * Map(double precision, text, text, boolean)
      * Map(int, text, text, boolean)
 
# How to write a lookup table?
* Some helper functions allow the use of lookup tables describing the source and target attributes for translation.
* An example is a list of species source values and a corresponding list of target values.
* Helper functions using lookup tables will always look for the source values in the column named "source_val".

Example lookup table. Source values for species codes in the sourceSp column are matched to their target values in the targetSp column.

|source_val|targetSp|
|:---------|:-------|
|TA        |PopuTrem|
|LP        |PinuCont|

# How to write a translation table?
* Translation tables must contain these six columns:
 1. **targetAttribute** - The name of the target attribute to be created in the target table.
 2. **targetAttributeType** - The PostgreSQL type of the target attribute.
 3. **validationRules** - Any validation rules needed to validate the source values before translating.
 4. **translationRules** - The translation rule to convert source values to target values.
 5. **description** - A text description of the translation taking place.
 6. **descUpToDateWithRules** - A boolean describing whether the translation rules are up to date with the description. This allows non-technical users to propose translations using the description column. Once the described translation has been applied throughout the table this attribute should be set to TRUE.
* Multiple validation rules can be seperated with a semi-colon.
* Error codes to be returned by the engine if validation rules return FALSE should follow a '|' at the end of the helper function parameters.

Example translation table. Source attribute sp1 is validated by checking it is not null, and that it matches a value in the lookup table. It is then translated into a target attribute called SPECIES_1 using the lookup table named species_lookup. Source attribute sp1_per is validated by checking it is not null, and that it falls between 0 and 100. It is then translated by simply copying the value to the target attribute SPECISE_1_PER.

| targetAttribute | targetAttributeType | validationRules | translationRules | description | descUpToDateWithRules |
|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|SPECIES_1        |text                 |notNull(sp1\|NULL); match(sp1,public,species_lookup\|NOT_IN_SET)|lookup(sp1, public, species_lookup, targetSp)|Maps source value to SPECIES_1 using lookup table|TRUE|
|SPECIES_1_PER|integer|notNull(sp1_per\|-8888); between(sp1_per,0,100\|-9999)|copy(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|

# Code example
Create an example lookup table:
```sql
CREATE TABLE species_lookup AS
SELECT 'TA' AS sourceSp, 'PopuTrem' AS targetSp
UNION ALL
SELECT 'LP', 'PinuCont';
```

Create an example translation table:
```sql
-- DROP TABLE IF EXISTS translate;
CREATE TABLE translate AS
SELECT 1 AS ogc_fid, 'SPECIES_1' AS targetAttribute, 'text' AS targetAttributeType, 'notNull(sp1|NULL);match(sp1,public,species_lookup|NOT_IN_SET)' AS validationRules, 'lookup(sp1, public, species_lookup, targetSp)' AS translationRules, 'Maps source value to SPECIES_1 using lookup table' AS description, 'TRUE' AS descUpToDateWithRules
UNION ALL
SELECT 2, 'SPECIES_1_PER', 'integer', 'notNull(sp1_per|-8888);between(sp1_per,0,100|-9999)', 'copy(sp1_per)', 'Copies source value to SPECIES_PER_1', 'TRUE';
```

Create an example source table:
```sql
CREATE TABLE sourceExample AS
SELECT 1 AS ID, 'TA' AS sp1, 10 AS sp1_per
UNION ALL
SELECT 2, 'LP', 60;
```

Run the translation engine by providing the schema and translation table names to TT_Prepare, and the source table schema, source table name, translation table schema and translation table name to TT_Translate.
```sql
SELECT TT_Prepare('public', 'translate');
SELECT * FROM TT_Translate('public', 'sourceexample', 'public', 'translate');
```

# Adding custom helper functions
* Additional helper functions can be written in PL/PGSQL and must obey the following conventions:
  * Validation functions must return type boolean.
  * All helper functions should raise an exception when any parameter (other than the source value) is null or of an invalid type.
  * All helper functions should have a variant minimally accepting a text source value.
  * All helper functions should test for NULL and return FALSE when the the source value is NULL.
  * No helper function should be implemented as VARIADIC accepting an arbitrary number of parameters. If an arbitrary number of parameters must be supported, it should be supported as list of value passed as a text value separated by a comma or a semicolon.

# Known issues
1. Single quotes in the translation file are not allowed
2. tt.debug must be set to TRUE of FALSE in the SQL session before using the engine API
3. Helper functions contain VARIADIC parameters.

# Credit
