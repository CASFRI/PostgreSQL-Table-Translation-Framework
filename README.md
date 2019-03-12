# Intro
The Post Translation Engine allows PostgreSQL users to translate tables into new specifications using translation rules. The primary components are:
* The engine, implemented as a set of pl/pgsql scripts.
* A set of helper functions to facilitate translation.
* A translation table that uses helper functions to validate the source data and define the translation rules.
* Optionally, a set of lookup tables that accompany the translation table.

# Directory structure
<pre>
./                    .sql files for loading, testing, and uninstalling the engine and helper functions

./docs                Documentation including engine specifications
</pre>

# Requirements - software versions
The Post Translation Engine uses PostgreSQL 9.6 and PostGIS v2.3.7.

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
*Translation engine* - The [Post Translation Engine](https://github.com/edwardsmarc/postTranslationEngine).

*Helper function* - A set of functions used in the translation table to facilitate translation.

*Source table* - Raw FRI table in PostgreSQL.

*Target table* - Translated FRI table in PostgreSQL.

*Translation table* - User created table detailing the translation rules and read by the translation engine.

*Lookup table* - User created table used in conjunction with the translation tables.

*Source attribute/value* - The attribute or value contained in the source table.

*Target attribute/value* - The attribute or value in the translated target table.

# Helper Functions
1. NotNull(val[])
    * Returns TRUE if vals are not NULL. Returns FALSE if any vals are NULL.
    * e.g. NotNull('a', 'b', 'c')
    * Signatures:
      * NotNull(text[])
      * NotNull(boolean[])
      * NotNull(double precision[])
      * NotNull(int[])
2. NotEmpty(val[])
    * val[] text - list of values to test
    * Returns TRUE if vals are not an empty string. Returns FALSE if any val is empty string or padded spaces (e.g. '' or '  ') or Null.
    * e.g. NotEmpty('a', 'b', 'c')
    * Signatures:
      * NotEmpty(val[])
 3. IsInt(val[])
    * Returns TRUE if vals represent integers. Returns FALSE if any values are Null. Strings with numeric characters and '.' will be passed to IsInt. Strings with anything else (e.g. letter characters) return FALSE.
    * e.g. IsInt(1,2,3,4,5)
    * Signatures:
      * IsInt(text[])
      * IsInt(double precision[])
      * IsInt(int[])
 4. IsNumeric(val[])
    * Returns TRUE if vals can be cast to double precision. Null values return FALSE.
    * e.g. IsNumeric('1.1', '1.2', '1.3')
    * Signatures:
      * IsNumeric(text[])
      * IsNumeric(double precision[])
      * IsNumeric(int[])
 5. Between(val, min, max)
    * Returns TRUE is val is between min and max.
    * e.g. Between(5, 0, 100)
    * Signatures
      * Between(double precision, double precision, double precision)
      * Between(int, double precision, double precision)
      * Between(text, double precision, double precision)
      * Between(int, double precision, text)
      * Between(int, text, double precision)
      * Between(text, double precision, text)
      * Between(text, text, double precision)
 6. GreaterThan(val, lowerBound, inclusive\[default TRUE\])
    * Returns TRUE if val >= lowerBound and inclusive = TRUE. Returns TRUE if val > lowerBound and inclusive = FALSE. Returns FALSE otherwise or if val is Null.
    * e.g. GreaterThan(5, 0, TRUE)
    * Signatures:
      * GreaterThan(double precision, double precision, boolean)
      * GreaterThan(int, double precision, boolean)
 7. LessThan(val, upperBound, inclusive\[default TRUE\])
    * Returns TRUE if val <= lowerBound and inclusive = TRUE. Returns TRUE if val < lowerBound and inclusive = FALSE. Returns FALSE otherwise or if val is Null.
    * e.g. LessThan(1, 5, TRUE)
    * Signatures:
      * LessThan(double precision, double precision, boolean)
      * LessThan(int, double precision, boolean)
 8. HasUniqueValues(val, lookupSchemaName, lookupTableName, occurences\[default 1\])
    * Returns TRUE if number of occurences of val in first column of schema.table equals occurences.
    * e.g. HasUniqueValues(TA, public, species_lookup, 1)
    * Signatures:
      * HasUniqueValues(text, name, name, int)
      * HasUniqueValues(double precision, name, name, int)
      * HasUniqueValues(int, name, name, int)
 9. Match (val, lookupSchemaName, lookupTableName, ignoreCase\[default TRUE\]) - table version
    * Returns TRUE if val is present in first column of schema.lookup table.
    * e.g. TT_Match(TA, public, species_lookup, TRUE)
    * Signatures:
      * Match(text, name, name, boolean)
      * Match(double precision, name, name, boolean)
      * Match(int, name, name, boolean)
 10.
 
# How to write a lookup table
* Some helper functions allow the use of lookup tables describing the source and target attributes for translation.
* An example is a list of species source attributes and a corresponding list of target attributes.
* Helper functions using lookup tables will always look for the source values in the first column on the table.

Example lookup table. Source values for species codes in the sourceSp column are matched to their target values in the targetSp column.

|sourceSp|targetSp|
|:-------|:-------|
|TA      |PopuTrem|
|LP      |PinuCont|

# How to write a translation table
* Translation tables must contain these six columns:
  1. targetAttribute - The name of the target attribute to be created in the target table.
  2. targetAttributeType - The PostgreSQL type of the target attribute.
  3. validationRules - Any validation rules needed to validate the source values before translating.
  4. translationRules - The translation rule to convert source values to target values.
  5. description - A text description of the translation taking place.
  6. descUpToDateWithRules - A boolean describing whether the translation rules are up to date with the description. This allows non-technical users to propose translations using the description column. Once the described translation has been applied throughout the table this attribute should be set to TRUE.
* Multiple validationRules can be seperated with a semi-colon.
* Error codes to be returned by the engine if validation rules return FALSE should follow a '|' at the end of the helper function parameters.

Example translation table. Source attribute sp1 is validated by checking it is not a null, and that it matches a species in the lookup table. It is then translated into a target attribute called SPECIES_1 using the lookup table. Source attribute sp1_per is validated by cecking it is not null, and that it falls between 0 and 100. It is then translated by simply copying the value to the target attribute SPECISE_1_PER.

| targetAttribute | targetAttributeType | validationRules | translationRules | description | descUpToDateWithRules |
|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|SPECIES_1        |text                 |notNull(sp1\|NULL); match(sp1,public,species_lookup\|NOT_IN_SET)|lookup(sp1, public, species_lookup, targetSp)|Maps source value to SPECIES_1 using lookup table|TRUE|
|SPECIES_1_PER|integer|notNull(sp1_per\|NULL); between(sp1_per,0,100\|-9999)|copy(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|

# Code example - example of running engine.
* Use test tables to write examples



# Adding custom helper functions

# Known issues
1. Single quotes in the translation file are not allowed
2. tt.debug must be set to TRUE of FALSE in the SQL session before using the engine API

# Credit
