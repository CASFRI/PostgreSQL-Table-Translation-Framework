# Introduction
The PostgreSQL Table Translation Framework allows PostgreSQL users to validate and translate a source table into a new target table  using validation and translation rules. This framework simplifies the writing of complex SQL queries attempting to achieve the same goal. It serves as an in-database transform engine in an Extract, Load, Transform (ELT) process (a variant of the popular ETL process where most of the transformation is done inside the database). Future versions should provide logging and resuming allowing a fast workflow to create, edit, test, and generate translation tables.

The primary components of the framework are:
* The translation engine, implemented as a set of PL/pgSQL functions.
* A set of validation and translation helper functions implementing a general set of validation and translation rules.
* A user produced translation table defining the structure of the target table and all validation and the translation rules.
* Optionally, some user produced value lookup tables that accompany the translation table.

# Directory structure
<pre>
./             .sql files for loading, testing, and uninstalling the engine and helper functions.

./docs         Mostly development specifications.
</pre>

# Requirements
PostgreSQL 9.6+ and PostGIS 2.3+.

# Version Releases

The framework follows the [Semantic Versioning 2.0.0](https://semver.org/) versioning scheme (major.minor.revision). Increments in revision version numbers are for bug fixes. Increments in minor version numbers are for new features, changes to the helper functions (our API) and bug fixes. Minor version increments will not break backward compatibility with existing translation files. Increments in major version numbers are for changes that break backward compatibility in the helper functions (meaning users have to make some changes in their translation tables).

The current version is 0.0.2-beta and is available for download at https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/releases/tag/v0.0.2-beta

# Installation/Uninstallation
* **Installation -** In a PostgreSQL query window, or using the PSQL client, run, in this order:

  1. the engine.sql file,
  2. the helperFunctions.sql file,
  3. the helperFunctionsTest.sql file. All tests should pass (the "passed" column should be TRUE for all tests).
  4. the engineTest.sql file. All tests should pass.
  
* **Uninstallation -** You can uninstall all the functions by running the helperFunctionsUninstall.sql and the engineUninstall.sql files.

# Vocabulary
*Translation engine* - The PL/pgSQL code implementing the PostgreSQL Table Translation Framework.

*Helper function* - A set of PL/pgSQL functions used in the translation table to facilitate validation of source values and their translation to target values.

*Source table* - The table to be validated and translated.

*Target table* - The table created by the translation process.

*Translation table* - User created table read by the translation engine and defining the structure of the target table, the validation rules and the translation rules.

*Lookup table* - User created table of lookup values used by some helper functions to convert source values into target values.

*Source attribute/value* - The attribute or value stored in the source table.

*Target attribute/value* - The attribute or value to be stored in the translated target table.

# What are translation tables and how to write them?

A translation table is a normal PostgreSQL table defining the structure of the target table (one row per target attribute), how to validate source values to be translated, and how to translate source values into target attributes. It also provides a way to document the validation and translation rules and to flag rules that are not yet in synch with their description (in the case where rules are written as a second step or by different people).

The translation table implements two very different steps:

1. **Validation -** The source values are first validated by a set of validation rules separated by a semicolon. Each validation rule defines an error code that is returned if the rule is not fulfilled. The next step (translation) happens only if all the validation rules pass. A boolean flag (TRUE or FALSE) can make a failing validation rule stop the engine. This flag is set to false by default, allowing the engine to report errors without stopping.

2. **Translation -** The source values are translated to the target values by the translation rule (one per target attribute).

Translation tables have one row per target attribute and they must contain these seven columns:

 1. **rule_id** - Incrementing unique integer identifier used for ordering target attributes in target table.
 2. **targetAttribute** - The name of the target attribute to be created in the target table.
 3. **targetAttributeType** - The data type of the target attribute.
 4. **validationRules** - A semicolon separated list of validation rules needed to validate the source values before translating.
 5. **translationRules** - The translation rules to convert source values to target values.
 6. **description** - A text description of the translation taking place.
 7. **descUpToDateWithRules** - A boolean describing whether the translation rules are up to date with the description. This allows non-technical users to propose translations using the description column. Once the described translation has been applied throughout the table this attribute should be set to TRUE.
 
* Multiple validation rules can be seperated with a semi-colon.
* Error codes to be returned by the engine if validation rules return FALSE should follow a '|' at the end of the helper function parameters (e.g. notNull(sp1_per|-8888)).

Translation tables are themselves validated by the translation engine while processing the first source row. Any error in the translation table stops the validation/translation process. The engine checks that:

* no null values exists (all cells must have a value)
* target attribute names do not contain invalid characters (e.g. spaces or accents)
* target attribute types are valid PostgreSQL types (integer, text, boolean, etc...)
* helper functions for validation and translation rules exist and have the propre number of parameters and types
* the flag indicating if the description is in sync with the validation/translation rules is set to TRUE
* the return type of the translation functions match the targetAttributeType specified in the translation table

**Example translation table**

The following translation table defines a target table composed of two columns: "SPECIES_1" of type text and "SPECIES_1_PER" of type integer.

The source attribute "sp1" is validated by checking it is not null, and that it matches a value in the specified lookup table. This is done using the notNull() and the matchTab() [helper functions](#helper-functions) described further in this document. If all validation tests pass, "sp1" is then translated into the target attribute "SPECIES_1" using the lookup table named "species_lookup". If the first validation rules fails, the "NULL" string is returned instead. If the first rule passes but the second validation rule fails, the "NOT_IN_SET" string is returned.

Similarly, the source attribute "sp1_per" is validated by checking it is not null, and that it falls between 0 and 100. It is then translated by simply copying the value to the target attribute "SPECISE_1_PER". "-8888", an integer error code, is returned if the first rule fails. "-9999" is returned if the second validation rule fails.

A textual description of the rules is provided and the flag indicating that the description is in sync with the rules is set to TRUE.

| rule_id | targetAttribute | targetAttributeType | validationRules | translationRules | description | descUpToDateWithRules |
|:--------|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|1        |SPECIES_1        |text                 |notNull(sp1\|NULL); matchTable(sp1,public,species_lookup\|NOT_IN_SET)|lookupText(sp1, public, species_lookup, targetSp)|Maps source value to SPECIES_1 using lookup table|TRUE|
|2        |SPECIES_1_PER    |integer              |notNull(sp1_per\|-8888); between(sp1_per,0,100\|-9999)|copyInt(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|

# How to actually translate a source table?

The translation is done in two steps:

**1. Prepare the translation function**

```sql
SELECT TT_Prepare(translationTableSchema, translationTable);
```

It is necessary to dynamically prepare the actual translation function because PostgreSQL does not allow a function to return an arbitrary number of columns of arbitrary types. The translation function has to explicitly declare what it is going to return at declaration time. Since every translation table can get the translation function to return a different set of columns, it is necessary to define a new translation function for every translation table. This step is necessary only when a new translation table is being used, when a new attribute is defined in the translation table, or when a target attribute type is changed.

**2. Translate the table with the prepared function**

```sql
CREATE TABLE target_table AS
SELECT * FROM TT_Translate(sourceTableSchema, sourceTable);
```

The TT_Translate() function returns the translated target table. It is designed to be used in place of any table in an SQL statement.

By default the prepared function will always be named TT_Translate(). If you are dealing with many tranlation tables at the same time, you might want to prepare a translation function for each of them. You can do this by adding a suffix as the third parameter of the TT_Prepare() function (e.g. TT_Prepare('public', 'translation_table', '02') will prepare the TT_Translate02() function). You would normally provide a different suffix for each of your translation tables.

If your source table is very big, we suggest developing and testing your translation table on a random sample of the source table to speed up the create, edit, test, generate process. Future releases of the framework will provide a logging and a resuming mechanism which will ease the development of translation tables. 

# How to write a lookup table?
* Some helper functions (e.g. matchTable(), lookupText()) allow the use of lookup tables to support mapping between source and target values.
* An example is a list of source value species codes and a corresponding list of target value species names.
* Helper functions using lookup tables will always look for the source values in the column named 'source_val'. The lookupText() function will return the corresponding value in the specified column.

Example lookup table. Source values for species codes in the "source_val" column are matched to their target values in the "targetSp1"  or the "targetSp2" column.

|source_val|targetSp1|targetSp2|
|:---------|:--------|:--------|
|TA        |PopuTrem |POPTRE   |
|LP        |PinuCont |PINCON   |

# Complete Example
Create an example lookup table:
```sql
CREATE TABLE species_lookup AS
SELECT 'TA' AS source_val, 
       'PopuTrem' AS targetSp
UNION ALL
SELECT 'LP', 'PinuCont';
```

Create an example translation table:
```sql
CREATE TABLE translation_table AS
SELECT 1 AS rule_id, 
       'SPECIES_1' AS targetAttribute, 
       'text' AS targetAttributeType, 
       'notNull(sp1|NULL);matchTable(sp1,public,species_lookup|NOT_IN_SET)' AS validationRules, 
       'lookupText(sp1, public, species_lookup, targetSp)' AS translationRules, 
       'Maps source value to SPECIES_1 using lookup table' AS description, 
       TRUE AS descUpToDateWithRules
UNION ALL
SELECT 2, 'SPECIES_1_PER', 
          'integer', 
          'notNull(sp1_per|-8888);between(sp1_per,0,100|-9999)', 
          'copyInt(sp1_per)', 
          'Copies source value to SPECIES_PER_1', 
          TRUE;
```

Create an example source table:
```sql
CREATE TABLE source_example AS
SELECT 1 AS ID, 
      'TA' AS sp1, 
      10 AS sp1_per
UNION ALL
SELECT 2, 'LP', 60;
```

Run the translation engine by providing the schema and translation table names to TT_Prepare, and the source table schema, source table name, translation table schema and translation table name to TT_Translate.
```sql
SELECT TT_Prepare('public', 'translation_table');

CREATE TABLE target_table AS
SELECT * FROM TT_Translate('public', 'source_example', 'public', 'translation_table');
```

# Provided Helper Functions
Helper functions are used in translation tables to validate and translate source values. When the translation engine encounters a helper function in the translation table, it runs that function with the given parameters.

Helper functions are of two types: validation helper functions are used in the **validationRules** column of the translation table. They validate the source values and always return TRUE or FALSE. If the validation fails, an error code is returned, otherwise the translation helper function in the **translationRules** column is run. Translation helper functions take a source value as input and return a translated target value for the target table.

Helper functions are generally called with the name of the source value attribute to validate or translate as the first argument, and some other fixed arguments controling others aspects of the validation and translation process. Attribute names are replaced with the actual values by the translation engine when the current row is being processed. If names do not match a column name in the source table, the source value is simply passed to the helper function as a string. Some helper functions accept a variable number of input parameters by using comma separated strings of values as arguments (e.g. 'col1,col2,col3').

One feature of the translation engine is that the return type of a translation function must be of the same type as the target attribute type defined in the **targetAttributeType** column of the translation table. This means some translation functions have multiple versions that each return a different type (e.g. CopyText, CopyDouble, CopyInt).

## Validation Functions

1. **NotNull**(any srcVal)
    * Returns TRUE if srcVal is not NULL. Returns FALSE if srcVal is NULL. Paired with most translation functions to make sure input values are available.
    * e.g. NotNull('a')

2. **NotEmpty**(text srcVal)
    * Returns TRUE if srcVal is not empty string. Returns FALSE if srcVal is an empty string or padded spaces (e.g. '' or '  ') or NULL. Paired with translation functions accepting text strings (e.g. CopyText())
    * e.g. NotEmpty('a')

3. **IsInt**(text srcVal)
    * Returns TRUE if srcVal represents an integer (e.g. '1.0', '1'). Returns FALSE is srcVal does not represent an integer (e.g. '1.1', '1a'), or if srcVal is NULL. Paired with translation functions that require integer inputs (e.g. CopyInt).
    * e.g. IsInt('1')

4. **IsNumeric**(text srcVal) 
    * Returns TRUE if srcVal can be cast to double precision (e.g. '1', '1.1'). Returns FALSE if srcVal cannot be cast to double precision (e.g. '1.1.1', '1a'), or if srcVal is NULL. Paired with translation functions that require numeric inputs (e.g. CopyDouble()).
    * e.g. IsNumeric('1.1')
   
5. **IsString**(text srcVal) 
    * Returns TRUE if srcVal cannot be cast to double precision (e.g. '1', '1.1').
    * e.g. IsString('1a')
          
6. **Between**(numeric srcVal, numeric min, numeric max, boolean includeMin\[default TRUE\], boolean includeMax\[default TRUE\])
    * Returns TRUE if srcVal is between min and max. FALSE otherwise.
    * includeMin and includeMax default to TRUE and indicate whether the acceptable range of values should include the min and max values. Must include both or neither includeMin and includeMax.
    * e.g. Between(5, 0, 100, TRUE, TRUE)
          
7. **GreaterThan**(numeric srcVal, numeric lowerBound, boolean inclusive\[default TRUE\])
    * Returns TRUE if srcVal >= lowerBound and inclusive = TRUE or if srcVal > lowerBound and inclusive = FALSE. Returns FALSE otherwise or if srcVal is NULL.
    * e.g. GreaterThan(5, 0, TRUE)

8. **LessThan**(numeric srcVal, numeric upperBound, boolean inclusive\[default TRUE\])
    * Returns TRUE if srcVal <= lowerBound and inclusive = TRUE or if srcVal < lowerBound and inclusive = FALSE. Returns FALSE otherwise or if srcVal is NULL.
    * e.g. LessThan(1, 5, TRUE)

9. **HasUniqueValues**(text srcVal, text lookupSchemaName, text lookupTableName, int occurences\[default 1\])
    * Returns TRUE if number of occurences of srcVal in source_val column of lookupSchemaName.lookupTableName equals occurences. Useful for validating lookup tables to make sure srcVal only occurs once for example. Often paired with LookupText(), LookupInt(), and LookupDouble().
    * e.g. HasUniqueValues(TA, public, species_lookup, 1)

10. **MatchTable**(text srcVal, text lookupSchemaName, text lookupTableName, boolean ignoreCase\[default TRUE\])
    * Returns TRUE if srcVal is present in the source_val column of lookupSchemaName.lookupTableName. Ignores letter case if ignoreCase = TRUE.
    * e.g. TT_MatchTable(sp1,public,species_lookup, TRUE)

11. **MatchList**(text srcVal, text lst, boolean ignoreCase\[default TRUE\])
    * Returns TRUE if srcVal is in lst. Ignores letter case if ignoreCase = TRUE.
    * e.g. Match('a', 'a,b,c', TRUE)

12. **False**()
    * Returns FALSE. Useful if all rows should contain an error value. All rows will fail so translation function will never run. Often paired with translation functions NothingText(), NothingInt(), and NothingDouble().
    * e.g. False()

13. **True**()
    * Returns TRUE. Useful if no validation function is required. The validation step will pass for every row and move on to the translation function.
    * e.g. True()
    
14. **GeoIsValid**(geometry the_geom, boolean fix)
    * Returns True if geometry is valid. If fix is True and geometry is invalid, function will attempt to make a valid geometry and return True if successful. If geometry is invalid returns False. Note that using fix=True does not fix the geometry in the source table, it only tests to see if the geometry can be fixed.
    * e.g. GeoIsValid(source_geo, TRUE)
    
15. **GeoIntersects**(geometry the_geom, text intersectSchemaName, text intersectTableName, geometry geoCol)
    * Returns True if the_geom intersects with any features in the intersect table. Otherwise returns False. Invalid geometries are validated before running the intersection test.
    * e.g. GeoIntersects(source_geo, public, intersect_tab, intersect_geo)
      
## Translation Functions

1. **CopyText**(text srcVal)
    * Returns srcVal as text without any transformation.
    * e.g. Copy('sp1')
      
2. **CopyDouble**(numeric srcVal)
    * Returns srcVal as double precision without any transformation.
    * e.g. Copy(1.1)

3. **CopyInt**(integer srcVal)
    * Returns srcVal as integer without any transformation.
    * e.g. Copy(1)
      
4. **LookupText**(text srcVal, text lookupSchemaName, text lookupTableName, text lookupCol, boolean ignoreCase\[default TRUE\])
    * Returns text value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column. If multiple matches, first row is returned.
    * e.g. Lookup(sp1, public, species_lookup, targetSp, TRUE)
      
5. **LookupDouble**(text srcVal, text lookupSchemaName, text lookupTableName, text lookupCol, boolean ignoreCase\[default TRUE\])
    * Returns double precision value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column. If multiple matches, first row is returned.
    * e.g. Lookup(percent, public, species_lookup, sp_percent, TRUE)

6. **LookupInt**(text srcVal, text lookupSchemaName, text lookupTableName, text lookupCol, boolean ignoreCase\[default TRUE\])
    * Returns integer value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column. If multiple matches, first row is returned.
    * e.g. Lookup(percent, public, species_lookup, sp_percent, TRUE)

7. **MapText**(text srcVal, text lst1, text lst2, boolean ignoreCase\[default TRUE\])
    * Return text value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','A,B,C','D,E,F', TRUE)
      
8. **MapDouble**(text srcVal, text lst1, text lst2, boolean ignoreCase\[default TRUE\])
    * Return double precision value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','A,B,C','1.1,1.2,1.3', TRUE)
      
9. **MapInt**(text srcVal, text lst1, text lst2, boolean ignoreCase\[default TRUE\])
    * Return integer value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','A,B,C','1,2,3', TRUE)
      
10. **Length**(text srcVal)
    * Returns the length of the srcVal string.
    * e.g. Length('12345')

11. **Pad**(text srcVal, int targetLength, text padChar\[default x\])
    * Returns a string of length targetLength made up of srcVal preceeded with padChar if source value length < targetLength. Returns srcVal trimmed to targetLength if srcVal length > targetLength.
    * e.g. Pad(tab1, 10, x)

12. **Concat**(text srcVal, text separator)
    * Returns a string of concatenated values, interspersed with a separator. srcVal takes a comma separated string of column names and/or values. Column names will return the value from the column, non-column names will simply return the input value. 
    * e.g. Concat('column1,column2,1', '-')

13. **PadConcat**(text srcVals, text lengths, text pads, text separator, boolean upperCase, boolean includeEmpty\[default TRUE\])
    * Returns a string of concatenated values, where each value is padded using **Pad()**. Inputs for srcVals, lengths, and pads are comma separated strings where the ith length and pad values correspond to the ith srcVal. If upperCase is TRUE, all characters are converted to upper case, if includeEmpty is FALSE, any empty strings in the srcVals are dropped from the concatenation. 
    * e.g. PadConcat('column1,column2,1', '5,5,7', 'x,x,0', '-', TRUE, TRUE)

14. **NothingText**()
    * Returns NULL of type text. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **targetAttributeType**.
    * e.g. NothingText()

15. **NothingDouble**()
    * Returns NULL of type double precision. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **targetAttributeType**.
    * e.g. NothingDouble()

16. **NothingInt**()
    * Returns NULL of type integer. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **targetAttributeType**.
    * e.g. NothingInt()

17. **GeoIntersectionText**(geometry the_geom, text intersectSchemaName, text intersectTableName, geometry geoCol, text returnCol, text method)
    * Returns a text value from an intersecting polygon. If multiple polygons intersect, the value from the polygon with the largest area can be returned by specifying method='area'; the lowest intersecting value can be returned using method='lowestVal', or the highest value can be returned using method='highestVal'. The 'lowestVal' and 'highestVal' methods only work when returnCol is numeric.
    * e.g. GeoIntersectionText(source_geo, public, intersect_tab, intersect_geo, TYPE, area)
    
18. **GeoIntersectionDouble**(geometry the_geom, text intersectSchemaName, text intersectTableName, geometry geoCol, numeric returnCol, text method)
    * Returns a double precision value from an intersecting polygon. Parameters are the same as **GeoIntersectionText**.
    * e.g. GeoIntersectionText(source_geo, public, intersect_tab, intersect_geo, LENGTH, highestVal)

19. **GeoIntersectionInt**
    * Returns an integer value from an intersecting polygon. Parameters are the same as **GeoIntersectionText**.
    * e.g. GeoIntersectionText(source_geo, public, intersect_tab, intersect_geo, YEAR, lowestVal)

# Adding Custom Helper Functions
Additional helper functions can be written in PL/pgSQL. They must follow the following conventions:

  * **Namespace -** All helper function names must be prefixed with "TT_". The prefix must not be used in the translation file. This is necessary to create a restricted namespace for helper functions so that no standard PostgreSQL functions (which do not necessarily comply to these conventions) can be used.
  * **Input Types -** All helper functions (validation and translation) must accept only text parameters (the engine converts everything to text before calling the function). This greatly simplify the development of helper functions and the parsing and validation of translation files.
  * **Variable number of parameters -** Helper function should NOT be implemented as VARIADIC functions accepting an arbitrary number of parameters. If an arbitrary number of parameters must be supported, it should be implemented as a list of text values separated by a comma or a semicolon. This is to avoid the hurdle of finding, when validating the translation file, if the function exists in the PostgreSQL catalog.
  * **Default value -** Helper functions should NOT use DEFAULT parameter values. The catalog needs to contain explicit helper function signatures for all functions it could receive. If default parameter values are required, a separate function signature should be created that calls the full function. This is to avoid the hurdle of finding, when validating the translation file, if the function exists in the PostgreSQL catalog.
  * **Polymorphic translation functions -** If a translation helper functions must be written to return different types (e.g. int and text), as many different different functions with corresponding names must be written (e.g. TT_CopyInt() and TT_CopyText()). The use of the generic "any" PostgreSQL type is forbidden. This ensure that the engine can explicitly know that the translation function returns the right type.
  * **Error handling -** 1) All helper functions (validation and translation) must raise an exception when parameters other than the source value are NULL or of an invalid type. This is to avoid badly written translation files. 2) Translation functions should handle any type of source data values (always passed as text) without crashing. This is to avoid crashing of the engine when translating big source file. 3) Translation functions should always validate that passed source values are of the right type and return a standard CASFRI error otherwise. This is to ensure that the targetAttributeType is consistent with the translation return value.
  * **Return value -** 1) Validation functions must always return a boolean. They must handle NULL and empty values and in those cases return the appropriate boolean value. Error codes are provided in the translation file when source values don not fulfill the validation test. 2) Translation functions must return a specific type. For now only "int", "numeric", "text" and "boolean" are supported.

If you think some of your custom helper functions could be of general interest to other users of the framework, you can submit them to the project team. They could be integrated in the helper funciton file.

# Known issues
1. Single quotes in the translation file are not yet allowed.

# Credit
**Pierre Racine** - Center for forest research, University Laval.

**Pierre Vernier** - Database designer.

**Marc Edwards** - SQL programmer.
