# Introduction
The PostgreSQL Table Translation Framework allows PostgreSQL users to validate and translate a source table into a new target table  using validation and translation rules. This framework simplifies the writing of complex SQL queries attempting to achieve the same goal. It serves as an in-database transform engine in an Extract, Load, Transform (ELT) process (a variant of the popular ETL process) where most of the transformation is done inside the database. 

The primary components of the framework are:
* The translation engine, implemented as a set of PL/pgSQL functions.
* A set of validation and translation helper functions implementing a general set of validation and translation rules.
* A user produced translation table defining the structure of the target table and all the validation and translation rules.
* Optionally, some user produced value lookup tables that accompany the translation table.

# Citation
CASFRI Project Team (2021). PostgreSQL Table Translation Framework. Université Laval, QC, Canada. URL https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework. DOI: 

# Directory Structure
<pre>
./             .sql files for loading, testing, and uninstalling the engine and helper functions.

./docs         Mostly development specifications.
</pre>

# Requirements
Recommended versions are PostgreSQL 13.1+ and PostGIS 3.1+, or PostgreSQL 11.3+ or 12 and PostGIS 2.3+.

# Version Number Scheme

The framework follows the [Semantic Versioning 2.0.0](https://semver.org/) versioning scheme (major.minor.revision). Increments in revision version numbers are for bug fixes. Increments in minor version numbers are for new features, changes to the helper functions (the API) and bug fixes. Minor version increments will not break backward compatibility with existing translation tables. Increments in major version numbers are for changes that break backward compatibility in the helper functions (meaning users have to make some changes in their translation tables).

The current version is v2.0.0 and is available for download at https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/releases/tag/v2.0.0

# Installation/Test/Uninstallation
**Installation** 

  1. Copy the configSample.bat (or the configSample.sh) file to config.bat (or config.sh) and edit it to set the path to your version of PostgreSQL.
  2. Open a shell and CD to this folder.
  3. Run install.bat (or install.sh). This will install the framework as a PostgreSQL extension.
  4. In a postgreSQL query tool window do: CREATE EXTENSION table_translation_framework;
  
  Alternatively, the engine can be loaded manually. In a PostgreSQL query window, or using the PSQL client, run, in this order:

  1. the engine.sql file,
  2. the helperFunctions.sql file,
  3. the helperFunctionsGIS.sql file,
  4. the engineTest.sql file. All tests should pass (an empty table indicates all tests passed).
  5. the helperFunctionsTest.sql file. All tests should pass.
  6. the helperFunctionsGISTest.sql file. All tests should pass.
  
**Uninstallation**

  In a postgreSQL query tool window do: DROP EXTENSION table_translation_framework;
  
  Alternatively the engineUninstall.sql, helperFunctionsUninstall.sql and helperFunctionsGISUninstall.sql can be run manually.


# Vocabulary
*Translation engine/function* - The PL/pgSQL code implementing the PostgreSQL Table Translation Framework. Can also refer more precisely to the translation function TT_Translate() which is the core of the translation process.

*Helper function* - A set of PL/pgSQL functions used in the translation table to facilitate validation of source values and their translation to target values.

*Source table* - The table to be validated and translated.

*Target table* - The table created by the translation process.

*Source attribute/value* - The attribute or value stored in the source table.

*Target attribute/value* - The attribute or value to be stored in the translated target table.

*Translation table* - User created table read by the translation engine and defining the structure of the target table, the validation rules and the translation rules.

*Translation row* - One row of the translation table.

*Validation rule* - The set of validation helper functions used to validate the source values of an attribute. There is one set of validation rules per row in the translation table.

*Translation rule* - The translation helper function used to translate the source values to the target values. There is only one translation rule per translation row in the translation table.

*Lookup table* - User created table of lookup values used by some helper functions to convert source values into target values.


# What are translation tables and how to write them?

A translation table is a normal PostgreSQL table defining the structure of the target table (one row per target attribute), how to validate source values to be translated, and how to translate source values into target attributes. It also provides a way to document the validation and translation rules and to flag rules that are not yet in sync with their description (in the case where rules are written as a second step or by different people).

A translation table implements two very different steps:

1. **Validation -** Source values are first validated by a set of validation rules which establish the condition for a value to be translated. Translation happens only if all validation rules pass. When a validation rule returns FALSE, the translation engine sets the target value to the error code associated with the validation rule instead of the translated value.

2. **Translation -** Source values are then translated to the target values by the translation rule (one per target attribute).

Translation tables have one row per target attribute describing the generic validation and translation process. They must contain these seven columns:

 1. **rule_id** - An incremental unique integer identifier used for ordering target attributes in the target table.
 2. **target_attribute** - The name of the target attribute to be created in the target table.
 3. **target_attribute_type** - The data type of the target attribute (text, integer, double precision).
 4. **validation_rules** - A semicolon separated list of validation rules needed to validate the source values before translating.
 5. **translation_rules** - The translation rule to convert source values to target values.
 6. **description** - A text description of the translation taking place.
 7. **desc_uptodate_with_rules** - A boolean describing whether the translation rules are up to date with the description. This allows non-technical users to propose translations using the description column. Once the described translation has been applied throughout the table this attribute should be set to TRUE.

Validation and translation rules are helper function calls of the form "rule(src_attribute, 'parameter1', 'parameter2')". Available helper functions are listed below with a description of each parameter.

Each rule defines a default error code to be returned when the rule fails. These default error codes are listed in the "Provided Helper Functions" section below. You can overwrite some or all default error codes by providing a TT_DefaultProjectErrorCode() function in your project. You can also overwrite the default error code for a specific validation and translation rule directly in the translation table by setting a value preceded by a vertical bar ('|') after the list of parameters (e.g. notNull(sp1_per|-8888)). Validation error codes are always required and must be of the same type as the target attribute.

A special optional row in the translation table can be defined to determine which rows from the source table should be included in the translation. This row is identified by setting 'target_attribute' to 'ROW_TRANSLATION_RULE'. A row will be translated if and only if at least one of the ROW_TRANSLATION_RULE 'validation_rules' is validated (like if there was a OR operator between them). Rows not fulfilling any rules from the ROW_TRANSLATION_RULE 'validation_rules' are skipped by the engine and hence, not translated. If no ROW_TRANSLATION_RULE is provided, all rows from the source table are translated. The 'target_attribute_type' and the 'translation_rules' of a ROW_TRANSLATION_RULE line should be set to NA.

Translation tables are themselves validated by the translation engine while processing the first source row. Any error in the translation table stops the validation/translation process with a message explaining the problem. The engine checks that:

* No NULL values exist in the table (all cells must have a value),
* Target attribute names do not contain invalid characters (e.g. spaces or accents),
* Target attribute types are valid PostgreSQL types (text, integer, double precision, boolean, etc...),
* Helper functions for validation and translation rules exist and have the proper number of parameters and types,
* The return type of the translation functions match the target_attribute_type specified in the translation table,
* The flag indicating if the description is in sync with the validation/translation rules is set to TRUE.


**Example translation table**

The following translation table defines a target table composed of two columns: "SPECIES_1" of type text and "SPECIES_1_PER" of type integer.

The ROW_TRANSLATION_RULE special row specifies that only source rows for which the "sp1" attribute is not NULL must be translated. Other source rows (where "sp1" is NULL) will be ignored.

The source attribute "sp1" is validated by checking it is not NULL and that it matches a value in the specified lookup table. This is done using the notNull() and the matchTable() [helper functions](#helper-functions) described further in this document. If all validation tests pass, "sp1" is then translated into the target attribute "SPECIES_1" using the lookupText() helper function. This function uses the "species_lookup" column from the "species_lookup" lookup table located in the "public" schema to map the source value to the target value.

If the first notNull() rule fails, this function's default text error code ('NULL_VALUE') is returned instead of the translated value. If the first rule passes but the second validation rule fails, the 'INVALID_SPECIES' error code is returned, overwriting the matchTable() default error code (NOT_IN_SET). 

Similarly, in the second row of the translation table, the source attribute "sp1_per" is validated by checking it is not NULL and that it falls between 0 and 100. It is then translated by simply copying the value to the target attribute "SPECIES_1_PER". -8888, the default integer error code for notNull(), equivalent to 'NULL_VALUE' for text attributes, is returned if the first rule fails. -9999 is returned if the second validation rule fails.

A textual description of the rules is provided and the flag indicating that the description is in sync with the rules is set to TRUE.

| rule_id | target_attribute | target_attribute_type | validation_rules | translation_rules | description | desc_uptodate_with_rules |
|:--------|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|0        |ROW_TRANSLATION_RULE        |NA                 |notNull(sp1) |NA |Translate row only when sp1 is not NULL|TRUE|
|1        |SPECIES_1        |text                 |notNull(sp1\); matchTable(sp1,'public','species_lookup', 'lookup_col'\|INVALID_SPECIES)|lookupText(sp1, 'public', 'species_lookup', 'source_val', 'target_sp')|Maps source value to SPECIES_1 using lookup table|TRUE|
|2        |SPECIES_1_PER    |integer              |notNull(sp1_per\); between(sp1_per,0,100)|copyInt(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|
 
# How to actually translate a source table?

The translation is done in two steps:

**1. Prepare the translation function**

```sql
SELECT TT_Prepare(translationTableSchema, translationTable);
```

It is necessary to dynamically prepare the actual translation function because PostgreSQL does not allow a function to return an arbitrary number of columns of arbitrary types. The translation function prepared by TT_Prepare() has to explicitly declare what it is going to return at declaration time. Since every translation table can get the translation function to return a different set of columns, it is necessary to define a new translation function for every translation table.

When you have many tables to translate into a common table, and hence many translation tables, you normally want all the target tables to have the same schema (same number of attributes, same attribute names, same attribute types). To make sure your translation tables all produce the same schema, you can reference another translation table (generally the first one) when preparing them. TT_Prepare() will compare all attributes from the current translation table with the attributes of the reference translation table and fail if there is any differences. Here is how to reference another translation table when invoking TT_Prepare():

```sql
SELECT TT_Prepare(translationTableSchema, translationTable, fctNameSuffix, refTranslationTableSchema, refTranslationTable);
```


**2. Translate the table with the prepared function**

```sql
CREATE TABLE target_table AS
SELECT * FROM TT_Translate(sourceTableSchema, sourceTable);
```

The TT_Translate() function returns the translated target table. It is designed to be used in place of any table in an SQL statement.

By default the prepared function will always be named TT_Translate(). If you are dealing with many translation tables at the same time, you might want to prepare a translation function for each of them. You can do this by adding a suffix as the third parameter of the TT_Prepare() function (e.g. TT_Prepare('public', 'translation_table', '_02') will prepare the TT_Translate_02() function). You would normally provide a different suffix for each of your translation tables.

If your source table is very big, you should develop and test your translation table on a random sample of the source table to speed up the create, edit, test, generate process.

# How to fix errors?

Two types of error can stop the engine during a translation process:

**1) Translation table syntax errors -** Any syntax error in the translation table will stop the engine at the very beginning of a translation process with a meaningful error message. This could be due to the translation table refering to a non-existing helper function, specifying an incorrect number of parameters, refering to a non-existing source attribute, passing a badly formed parameter (e.g. '1a' as integer), or using a helper function returning a type different than what is specified as the 'target_attribute_type'. It is up to the writer of the translation table to avoid and fix these errors. 

**2) Helper function errors -**  The second type of error is usually due to source values that are not handled properly by translation helper functions (e.g. a NULL value). These errors might happen at any moment during the translation, even after hours. It is therefore important to use robust helper functions able to handle all kind of values. All translation helper functions should be written so that they never fail and produce a PostgreSQL exception. They should always return NULL instead. Normally any invalid value that could cause an error in a translation helper function should be trapped by a validation function so that invalid values never reach a translation function. Any translation helper function returning NULL will output the generic translation error code values to the target table (TRANSLATION_ERROR or -3333 depending on the type of the target attribute). Once translation is complete the user can review the target table for any TRANSLATION_ERROR or -3333 error code and either 1) fix the translation helper functions that generated it, or 2) modify the set of validation rules in order to catch the invalid value before it is passed to the translation rule. For large translations project, translation tables should be tested on a random subset of data to identify as many errors as possible before running the full translation.

**Overwriting default error codes -** Default error codes for the provided helper functions are defined in the TT_DefaultErrorCode() function in the helperFunctions.sql file. This function is itself called by the engine TT_DefaultProjectErrorCode() function. You can redefine all default error codes by overwritting the TT_DefaultErrorCode() function or you can redefine only some of them by overwritting the TT_DefaultProjectErrorCode() function (other error codes will still be defined by TT_DefaultErrorCode()). Simply copy the TT_DefaultErrorCode() or the TT_DefaultProjectErrorCode() function in your project and define an error code for each possible type (text, integer, double precision, geometry) for every helper function for which you want to redefine the error code.

# How to write a lookup table?
* Some helper functions (e.g. MatchTable(), LookupText()) allow the use of lookup tables to support mapping between source and target values.
* An example is a list of source value species codes and a corresponding list of target value species names.
* Helper functions using lookup tables will look for the source values in the column specified in the function call. The LookupText() function will return the corresponding value in the specified return column.
* Lookup tables can include geometries for use in functions such as GeoIntersects() and GeoIntersectionInt() described below.
* All lookup table must be validated before use. For example no source values can be duplicated, and any geometries must be valid.

Example lookup table. Source values for species codes in the "source_val" column are matched to their target values in the "target_sp_1"  or the "target_sp_2" column.

|source_val|target_sp_1|target_sp_2|
|:---------|:--------|:--------|
|TA        |PopuTrem |POPTRE   |
|LP        |PinuCont |PINCON   |

# Complete Example
Create an example lookup table:
```sql
CREATE TABLE species_lookup AS
SELECT 'TA' AS source_val, 
       'PopuTrem' AS target_sp
UNION ALL
SELECT 'LP', 'PinuCont';
```

Create an example translation table:
```sql
CREATE TABLE translation_table AS
SELECT 1 AS rule_id, 
       'SPECIES_1' AS target_attribute, 
       'text' AS target_attribute_type, 
       'notNull(sp1);matchTable(sp1,''public'',''species_lookup'', ''source_val''|INVALID_SPECIES)' AS validation_rules, 
       'lookupText(sp1, ''public'', ''species_lookup'', ''source_val'', ''target_sp'')' AS translation_rules, 
       'Maps source value to SPECIES_1 using lookup table' AS description, 
       TRUE AS desc_uptodate_with_rules
UNION ALL
SELECT 2, 'SPECIES_1_PER', 
          'integer', 
          'notNull(sp1_per);isBetween(sp1_per,''0'',''100'')', 
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

Run the translation engine by providing the schema and translation table names to TT_Prepare, and the source table schema and source table name to TT_Translate.
```sql
SELECT TT_Prepare('public', 'translation_table');

CREATE TABLE target_table AS
SELECT * FROM TT_Translate('public', 'source_example');
```

# Main Translation Functions Reference

* **TT_Prepare(**  
                 *name* **translationTableSchema**,  
                 *name* **translationTable**,  
                 *text* **fctNameSuf**[default ''],  
                 *name* **refTranslationTableSchema**[default NULL],  
                 *name* **refTranslationTable**[default NULL]  
                 **)**
    * Prepare a translation function based on attributes found in the provided translation table and cross validated with an optional reference translation table. The default name of the prepared funtion can be altered by providing a 'fctNameSuf' suffix.
    * e.g. SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr', 'translation', 'ab06_avi01_lyr');

* **TT_TranslateSuffix(**  
                         *name* **sourceTableSchema**,  
                         *name* **sourceTable** 
                         **)**
    * Prepared translation function translating a source table according to the content of a translation table.
    * e.g. SELECT TT_TranslateSuffix('source', 'ab16');

* **TT_DropAllTranslateFct**()
    * Delete all translation functions prepared with TT_Prepare().
    * e.g. SELECT TT_DropAllTranslateFct();

# Helper Function Syntax and Reference
Helper functions are used in translation tables to validate and translate source values. When the translation engine encounters a helper function in the translation table, it runs that function with the given parameters.

Helper functions are of two types: validation helper functions are used in the **validation_rules** column of the translation table. They validate the source values and always return TRUE or FALSE. Multiple validation helper functions can be provided by separating them with semi colons. They will run in order from left to right. If a validation fails, an error code is returned. If all validations pass, the translation helper function in the **translation_rules** column is run. Only one translation function can be provided per row. Translation helper functions take a source value as input and return a translated target value for the target table.

Helper functions are generally called with the names of the source value attributes to validate or translate as the first argument, and some other optional arguments controlling  aspects of the validation and translation process. 

Helper function parameters are grouped into three classes, each of which have a different syntax in the translation table:

**1. Basic types: string, int, numeric and boolean**
  * Any arguments wrapped in single or double quotes is interpreted by the engine as a string and passed as-is to the helper function.
    * e.g. CopyText('a string')
    * This would simply return the string 'a string' for every row in the translation.
  * Strings can contain any characters, and escaping of single quotes is supported using \\'.
    * e.g. CopyText('string\\'s')
  * Empty strings can be passed as arguments using '' or "".
  * int, numeric and boolean are passed as is without quotes.

**2. Source table column names**
  * Any word not wrapped in quotes is interpreted as a column name.
  * Column names can include "\_" and "-" but no other special characters and no spaces are allowed. Invalid column names stop the engine.
  * When the engine encounters a valid column name, it searches the source table for that column and returns the corresponding value for the row being processed. This value is then passed as an argument to the helper function.
    * e.g. CopyText(column_A)
    * This would return the text value from column_A in the source table for each row being translated.
  * Note that the column name syntax only applies to columns in the source table. Any arguments specifying columns in lookup tables for example should be provided as strings.

**3. String lists**
  * Some helper functions can take a variable number of inputs. Concatenation functions are an example.
  * Since the helper functions need to receive a fixed number of arguments, when variable numbers of input values are required they are provided as a comma separated string list of values wrapped in '{}'.
  * String lists can contain both basic types and column names following the rules described above.
  * e.g. Concat({column_A, column_B, 'joined'}, '-')
    * This Concat function call takes two arguments, a comma separated list of values provided inside {}, and a separator character.
    * This example would concatenate the values from column_A and column_B, followed by the string 'joined' and separated with '-'. If row 1 had values of 'one' and 'two' for column_A and column_B, the string 'one-two-joined' would be returned.

One feature of the translation engine is that the return type of a translation function must be of the same type as the target attribute type defined in the **target_attribute_type** column of the translation table. This means some translation functions have multiple versions that each return a different type (e.g. CopyText, CopyDouble, CopyInt). More specific versions (e.g. CopyDouble, CopyInt) are generally implemented as wrappers around more generic versions (e.g. CopyText).

**Nested helper functions**

Helper functions can be nested within other helper functions, this reduces the need to write many different helper functions that call each other internally. Note that this is a new feature ([#243](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/issues/243)) and many of the included helper functions will be deprecated in future versions. For example, the function ```MatchListSubstring(srcVal, startChar, forLength, matchList)``` can now be replaced in a translation table with ```MatchList(SubstringText(srcVal, startChar, forLength), matchList)```.

Some validation helper functions have an optional 'acceptNull' parameter that returns TRUE if the source value is NULL. This allows multiple validation functions to be strung together in cases where the value to be evaluated could occur in one of multiple columns (Note this feature may also be deprecated following [#243](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/issues/243), see [#247](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/issues/247)).

# Provided Helper Functions
## Validation Functions

* **False**()
    * Returns FALSE. Useful if all rows should contain an error value. All rows will fail so translation function will never run. Often paired with translation functions NothingText(), NothingInt() and NothingDouble().
    * Default error codes are 'NOT_APPLICABLE' for text attributes, -8887 for numeric attributes and NULL for other types.
    * e.g. False() returns FALSE.

* **True**()
    * Returns TRUE. Useful if no validation function is required. The validation step will pass for every row and move on to the translation function.
    * Default error codes are 'NOT_APPLICABLE' for text attributes and -8887 for numeric attributes but are never used since the function always return TRUE.
    * e.g. True() returns TRUE.

* **NotNull**(*stringList* **srcValList**, *boolean* **any**\[default FALSE\])
    * Returns TRUE if all values in the **srcValList** string list are not NULL. 
    * Paired with most translation functions to make sure input values are available.
    * When **any** is TRUE, returns TRUE if any value in **srcValList** is not NULL.
    * Default error codes are 'NULL_VALUE' for text attributes, -8888 for numeric attributes and NULL for other types.
    * Variants are:
      * NotNull(srcValList, any)
      * NotNull(srcValList)
    * e.g. NotNull('a') returns TRUE.
    * e.g. NotNull({'a', 'b', NULL}) returns FALSE.
    * e.g. NotNull({'a', 'b', NULL}, TRUE) returns TRUE.
 
* **NotEmpty**(*stringList* **srcValList**, *boolean* **any**\[default FALSE\])
    * Returns TRUE if all values in the **srcValList** string list are not empty strings, padded spaces (e.g. '' or '  ') or NULL. 
    * Paired with translation functions accepting text strings (e.g. CopyText()).
    * When **any** is TRUE, returns TRUE if any **srcValList** value is not an empty strings. 
    * Default error codes are 'EMPTY_STRING' for text attributes, -8889 for numeric attributes and NULL for other types.
    * Variants are:
      * NotEmpty(srcValList, any)
      * NotEmpty(srcValList)
    * e.g. NotEmpty('a') returns TRUE.
    * e.g. NotEmpty({'a', 'b', ''}) returns FALSE.
    * e.g. NotEmpty({'a', 'b', ''}, TRUE) returns TRUE.

* **IsInt**(*text* **srcVal**, *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** represents an integer (e.g. '1.0', '1'). Returns FALSE is **srcVal** does not represent an integer (e.g. '1.1', '1a'), or if **srcVal** is NULL. Paired with translation functions that require integer inputs (e.g. CopyInt).
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsInt() return TRUE.
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * Variants are:
      * IsInt(srcVal, acceptNull)
      * IsInt(srcVal)
    * e.g. IsInt('1') returns TRUE.

* **IsNumeric**(*text* **srcVal**, *boolean* **acceptNull**\[default FALSE\]) 
    * Returns TRUE if **srcVal** can be cast to double precision (e.g. '1', '1.1'). Returns FALSE if **srcVal** cannot be cast to double precision (e.g. '1.1.1', '1a'), or if **srcVal** is NULL. Paired with translation functions that require numeric inputs (e.g. CopyDouble()).
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsNumeric() return TRUE.
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * Variants are:
      * IsNumeric(srcVal, acceptNull)
      * IsNumeric(srcVal)
    * e.g. IsNumeric('1.1') returns TRUE.
   
* **IsBetween**(*numeric* **srcVal**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** is between **min** and **max**. FALSE otherwise.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max**. Must include both or neither **includeMin** and **includeMax** parameters.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsBetween() return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * IsBetween(srcVal, min, max, includeMin, includeMax, acceptNull)
      * IsBetween(srcVal, min, max, includeMin, includeMax)
      * IsBetween(srcVal, min, max)
    * e.g. IsBetween(5, 0, 100) returns TRUE.

* **IsXMinusYBetween**(*numeric* **x**, *numeric* **y**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **x** minus **y** is between **min** and **max**. FALSE otherwise.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max**. Must include both or neither **includeMin** and **includeMax** parameters.
    * When **acceptNull** is TRUE, NULL x minus y values make IsBetween() return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * IsXMinusYBetween(x, y, min, max, includeMin, includeMax, acceptNull)
      * IsXMinusYBetween(x, y, min, max, includeMin, includeMax)
      * IsXMinusYBetween(x, y, min, max) 
    * e.g. IsXMinusYBetween(50, 5, 0, 100) returns TRUE.
          
* **IsGreaterThan**(*numeric* **srcVal**, *numeric* **lowerBound**, *boolean* **inclusive**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** >= **lowerBound** and **inclusive** = TRUE or if **srcVal** > **lowerBound** and **inclusive** = FALSE. Returns FALSE otherwise or if **srcVal** is NULL.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsGreaterThan() return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * IsGreaterThan(srcVal, lowerBound, inclusive, acceptNull)
      * IsGreaterThan(srcVal, lowerBound, inclusive)
      * IsGreaterThan(srcVal, lowerBound)
    * e.g. IsGreaterThan(5, 4) returns TRUE.

* **IsLessThan**(*numeric* **srcVal**, *numeric* **upperBound**, *boolean* **inclusive**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** <= **lowerBound** and **inclusive** = TRUE or if **srcVal** < **lowerBound** and **inclusive** = FALSE. Returns FALSE otherwise or if **srcVal** is NULL.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsLessThan() to return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * IsLessThan(srcVal, upperBound, inclusive, acceptNull)
      * IsLessThan(srcVal, upperBound, inclusive)
      * IsLessThan(srcVal, upperBound)
    * e.g. IsLessThan(1, 5) returns TRUE.

* **IsUnique**(*text* **srcVal**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *int* **occurrences**\[default 1\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if number of occurrences of **srcVal** in "source_val" column of **lookupSchemaName**.**lookupTableName** equals **occurrences**. Useful for validating lookup tables to make sure **srcVal** only occurs once for example. Often paired with LookupText(), LookupInt(), and LookupDouble().
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsUnique() return TRUE.
    * Default error code is 'INVALID_VALUE' for text attributes and NULL for other types.
    * Variants are:
      * IsUnique(srcVal, lookupSchemaName, lookupTableName, occurrences, acceptNull)
      * IsUnique(srcVal, lookupSchemaName, lookupTableName, occurrences)
      * IsUnique(srcVal, lookupSchemaName, lookupTableName)
      * IsUnique(srcVal, lookupTableName)
    * e.g. IsUnique('TA', public, species_lookup, 1) returns TRUE if there is only one 'TA' value in the lookup table source_val column. 

* **HasLength**(*text* **srcVal**, *int* **length**, *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the number of characters in **srcVal** matches **length**.
    * When **acceptNull** is TRUE, NULL **srcVal** values make HasLength() return TRUE.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * Variants are:
      * HasLength(srcVal, length, acceptNull)
      * HasLength(srcVal, length)
    * e.g. HasLength('123', 3) returns TRUE.

* **HasCountOfNotNull**(*stringList* **srcVal1/2/3/4/5/6/7/8/9/10/11/12/13/14/15**, *int* **count**, *exact* **boolean**)
    * Counts the number of non-NULL results in the **srcVals[1-15]** string lists using the CountOfNotNull() helper function.
    * Can take between 1 and 15 **srcVal** string lists of input values.
    * When **exact** is TRUE, the number of non-NULLs must matche **count** exactly.
    * When **exact** is FALSE, the number of non-NULLs can be greater than or equal to **count**.
    * Empty strings are treated as NULL.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * Variants are:
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, vals15, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, vals14, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, vals13, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, vals12, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, vals11, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, vals10, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, vals9, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, vals8, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, vals7, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, vals6, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, vals5, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, vals4, count, exact)
      * HasCountOfNotNull(vals1, vals2, vals3, count, exact)
      * HasCountOfNotNull(vals1, vals2, count, exact)
      * HasCountOfNotNull(vals1, count, exact)
    * e.g. HasCountOfNotNull({'a','b','c'}, {NULL, NULL}, 1, TRUE) returns TRUE.
    * There is also a variant of this function called **HasCountOfNotNullOrZero()** which is exactly the same but counts zero values as NULL.

* **MatchTable**(*text* **srcVal**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *text* **lookupColumnName**\[default 'source_val'\], *boolean* **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** is present in the **lookupColumnName** column of the **lookupSchemaName**.**lookupTableName** table.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchTable() return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MatchTable(srcVal, lookupSchemaName, lookupTableName, lookupColumnName, ignoreCase, acceptNull)
      * MatchTable(srcVal, lookupSchemaName, lookupTableName, lookupColumnName, ignoreCase)
      * MatchTable(srcVal, lookupSchemaName, lookupTableName, lookupColumnName)
    * e.g. MatchTable('sp1', public, species_lookup, lookup_column) returns TRUE is value 'sp1' is in the lookup_column.

* **MatchList**(*stringList* **srcVal**, *stringList* **matchList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\], *boolean* **matches**\[default TRUE\], *boolean* **removeSpaces**\[default FALSE\])
    * Returns TRUE if **srcVal** is in **matchList**.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchList() return TRUE.
    * When **matches** is FALSE, returns FALSE in the case of a match.
    * When **removeSpaces** is TRUE, removes any spaces from **srcVal** before testing matches.
    * When multiple input values are provided as a string list, they are concatenated before testing for matches.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MatchList(srcVal, matchList, ignoreCase, acceptNull, matches, removeSpaces)
      * MatchList(srcVal, matchList, ignoreCase, acceptNull, matches)
      * MatchList(srcVal, matchList, ignoreCase, acceptNull)
      * MatchList(srcVal, matchList, ignoreCase)
      * MatchList(srcVal, matchList)
    * e.g. MatchList('a', {'a','b','c'}) returns TRUE.
    * e.g. MatchList({'a', 'b'}, {'ab','bb','cc'}) returns TRUE.

* **MatchListTwice**(*stringList* **srcVal1**, *stringList* **matchList1**, *stringList* **srcVal2**, *stringList* **matchList2**)
    * Runs matchList with default arguments for **srcVal1** and **matchList1**, then for **srcVal2** and **matchList2**. If either return TRUE, return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MatchListTwice(srcVal1, matchList1, srcVal2, matchList2)
    * e.g. MatchListTwice('a', {'a','b','c'}, 'x', {'a','b','c'}) returns TRUE.
    * e.g. MatchListTwice('x', {'a','b','c'}, 'y', {'a','b','c'}) returns FALSE.
    
* **NotMatchList**(*text* **srcVal**, *stringList* **matchList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * A wrapper around MatchList() that sets **matches** to FALSE.
    * Mostly used to catch values that require a specific error code to be returned (e.g. NotMatchList(species1, 'x'|NULL_VALUE))
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * NotMatchList(srcVal, matchList, ignoreCase, acceptNull, removeSpaces)
      * NotMatchList(srcVal, matchList, ignoreCase, acceptNull)
      * NotMatchList(srcVal, matchList, ignoreCase)
      * NotMatchList(srcVal, matchList)
    * e.g. NotMatchList('d', '{'a','b','c'}') returns TRUE.

* **SumIntMatchList**(*stringList* **srcValList**, *stringList* **matchValList**, *boolean* **acceptNull**\[default FALSE\], *boolean* **matches**\[default TRUE\])
    * Returns TRUE if the sums of the values in the **srcValList** string list matches one of the value provided in the **matchValList** string list using the MatchList() helper function.
    * When **acceptNull** is TRUE, NULL values in **srcValList** make SumIntMatchList() to return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * SumIntMatchList(srcValList, matchValList, acceptNull, matches)
      * SumIntMatchList(srcValList, matchValList, acceptNull)
      * SumIntMatchList(srcValList, matchValList)
    * e.g. SumIntMatchList({1,2}, {3, 4, 5}) returns TRUE.

* **HasCountOfMatchList**(*text* **val1**, *stringList* **matchList1**, *text* **val2**, *stringList* **matchList2**, *text* **val3**, *stringList* **matchList3**, *text* **val4**, *stringList* **matchList4**, *text* **val5**, *stringList* **matchList5**, *text* **val6**, *stringList* **matchList6**, *text* **val7**, *stringList* **matchList7**, *text* **val8**, *stringList* **matchList8**, *text* **val9**, *stringList* **matchList9**, *text* **val10**, *stringList* **matchList10**, *int* **count**, *boolean* **exact**)
    * Runs matchList() for each set of val and matchList.
    * Counts the number of TRUE values returned and compares to the **count**.
    * If exact is TRUE and the number of TRUE matchList results is equal to the **count**, returns TRUE.
    * If exact is FALSE and the number of TRUE matchList results is greater than or equal to the **count**, returns TRUE.
    * Variants are:
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, val5, matchList5, val6, matchList6, val7, matchList7, val8, matchList8, val9, matchList9, val10, matchList10, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, val5, matchList5, val6, matchList6, val7, matchList7, val8, matchList8, val9, matchList9, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, val5, matchList5, val6, matchList6, val7, matchList7, val8, matchList8, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, val5, matchList5, val6, matchList6, val7, matchList7, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, val5, matchList5, val6, matchList6, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, val5, matchList5, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, val4, matchList4, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, val3, matchList3, count, exact)
      * HasCountOfMatchList(val1, matchList1, val2, matchList2, count, exact)
    * e.g. HasCountOfMatchList(a, {a,b}, b, {a,b}, c, {a,c}, 3) returns TRUE.
    
 * **IsIntSubstring**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the substring of **srcVal** starting at character **startChar** for **forLength** is an integer.
    * When **removeSpaces** is TRUE, spaces are removed from the string before calculating the substring.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsIntSubstring() return TRUE.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * Variants are:
      * IsIntSubstring(srcVal, startChar, forLength, removeSpaces, acceptNull)
      * IsIntSubstring(srcVal, startChar, forLength, removeSpaces)
      * IsIntSubstring(srcVal, startChar, forLength)
    * e.g. IsIntSubstring('2001-01-01', 1, 4) returns TRUE.

* **AlphaNumericMatchList**(*stringList* **srcVal**, *stringList* **matchList**, *boolean* **acceptNull**\[default FALSE\], *boolean* **matches**\[default TRUE\], *boolean* **removeSpaces**\[default FALSE\])
    * Creates an alpha numeric code by converting all **srcVal** letters to 'x' and all integers to '0'. Then tests if the resulting code is in the **matchList** using MatchList. Also passes **acceptNull**, **matches** and **removeSpaces** to MatchList.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * AlphaNumericMatchList(srcVal, matchList, acceptNull, matches, removeSpaces)
      * AlphaNumericMatchList(srcVal, matchList, matches, removeSpaces)
      * AlphaNumericMatchList(srcVal, matchList, removeSpaces)
      * AlphaNumericMatchList(srcVal, matchList)
    * e.g. AlphaNumericMatchList('bf50ws50', {'xx00xx00'}) returns TRUE.

* **IsBetweenSubstring**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the **srcVal** substring starting at character **startChar** for **forLength** is between **min** and **max**.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max**. Must include both or neither **includeMin** and **includeMax** parameters.  
    * When **removeSpaces** is TRUE, removes any spaces from string before testing in IsBetween.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsBetweenSubstring() to return TRUE.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * Variants are:
      * IsBetweenSubstring(srcVal, startChar, forLength, min, max, includeMin, includeMax, removeSpaces, acceptNull)
      * IsBetweenSubstring(srcVal, startChar, forLength, min, max, includeMin, includeMax, removeSpaces)
      * IsBetweenSubstring(srcVal, startChar, forLength, min, max, includeMin, includeMax)
      * IsBetweenSubstring(srcVal, startChar, forLength, min, max)
    * e.g. IsBetweenSubstring('2001-01-01', 1, 4, 1900, 2100) returns TRUE.
    
* **MatchListSubstring**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *stringList* **matchList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the **srcVal** substring starting at character **startChar** for **forLength** is in **matchList**.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchListSubstring() return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MatchListSubstring(srcVal, startChar, forLength, matchList, ignoreCase, removeSpaces, acceptNull)
      * MatchListSubstring(srcVal, startChar, forLength, matchList, ignoreCase, removeSpaces)
      * MatchListSubstring(srcVal, startChar, forLength, matchList, ignoreCase)
      * MatchListSubstring(srcVal, startChar, forLength, matchList)
    * e.g. MatchListSubstring('2001-01-01', 1, 4, '{'2000', '2001'}') returns TRUE.
    
* **LengthMatchList**(*text* **srcVal**, *stringList* **matchList**, *boolean* **trim**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\], **matches**\[default TRUE\], )
    * Calculates length of **srcVal** and checks that it matches one of the value in **matchList**.
    * When **removeSpaces** is TRUE, removes any spaces before calculating length.
    * When **trim** is TRUE, leading and trailing spaces are removed before calculating length.
    * When **acceptNull** is TRUE, NULL **srcVal** values make LengthMatchList() to return TRUE.
    * When **matches** is FALSE, returns FALSE in the case of a match.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * LengthMatchList(srcVal, matchList, trim, removeSpaces, acceptNull, matches)
      * LengthMatchList(srcVal, matchList, trim, removeSpaces, acceptNull)
      * LengthMatchList(srcVal, matchList, trim, removeSpaces)
      * LengthMatchList(srcVal, matchList, trim)
      * LengthMatchList(srcVal, matchList)
    * e.g. LengthMatchList('12345', {5}) returns TRUE.
    
* **MinIndexNotNull**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the lowest integer in **intList**. Pass it to NotNull(). 
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested. This behaviour matches MinIndexCopyText() and MinIndexMapText().
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs are ignored when calculating the min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * Default error codes are 'NULL_VALUE' for text attributes, -8888 for numeric attributes and NULL for other types.
    * Variants are:
      * MinIndexNotNull(intList, testList, setNullTo, setZeroTo)
      * MinIndexNotNull(intList, testList)
    * e.g. MinIndexNotNull({1990, 2000}, {burn, NULL}) returns TRUE.
    
* **MaxIndexNotNull**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the highest integer in **intList**. Pass it to NotNull(). 
    * When there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested. This behaviour matches MaxIndexCopyText() and MaxIndexMapText(). 
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs are ignored when calculating max value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * Default error codes are 'NULL_VALUE' for text attributes, -8888 for numeric attributes and NULL for other types.
    * Variants are:
      * MaxIndexNotNull(intList, testList, setNullTo, setZeroTo)
      * MaxIndexNotNull(intList, testList)
    * e.g. MaxIndexNotNull({1990, 2000}, {burn, NULL}) returns FALSE.

* **GetIndexNotNull**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Reorder the **testList** by the **intList**, matching values in **intList** stay in the original order.
    * Pass the value from the reordered **testList** that matches the index of **indexToReturn** to notNull().
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs are ignored when calculating max value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * Default error codes are 'NULL_VALUE' for text attributes, -8888 for numeric attributes and NULL for other types.
    * Variants are:
      * GetIndexNotNull(intList, testList, setNullTo, setZeroTo, indexToReturn)
      * GetIndexNotNull(intList, testList, indexToReturn)
    * e.g. GetIndexNotNull({1990, 2000, 2005}, {NULL, burn, NULL}, 2) returns TRUE.

* **MinIndexNotEmpty**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MinIndexNotNull() but tests the value with NotEmpty().
    * Default error codes are 'EMPTY_STRING' for text attributes, -8889 for numeric attributes and NULL for other types.
    * Variants are:
      * MinIndexNotEmpty(intList, testList, setNullTo, setZeroTo)
      * MinIndexNotEmpty(intList, testList)
    * e.g. MinIndexNotEmpty({1990, 2000}, {burn, ''}) returns TRUE.

* **MaxIndexNotEmpty**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MaxIndexNotNull() but tests the value with NotEmpty().
    * Default error codes are 'EMPTY_STRING' for text attributes, -8889 for numeric attributes and NULL for other types.
    * Variants are:
      * MaxIndexNotEmpty(intList, testList, setNullTo, setZeroTo)
      * MaxIndexNotEmpty(intList, testList)
    * e.g. MaxIndexNotEmpty({1990, 2000}, {burn, ''}) returns FALSE.

* **GetIndexNotEmpty**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Same as GetIndexNotNull() but tests the value with NotEmpty().
    * Default error codes are 'EMPTY_STRING' for text attributes, -8889 for numeric attributes and NULL for other types.
    * Variants are:
      * GetIndexNotEmpty(intList, testList, setNullTo, setZeroTo, indexToReturn)
      * GetIndexNotEmpty(intList, testList, indexToReturn)
    * e.g. GetIndexNotEmpty({1990, 2000, 2005}, {'', burn, ''}, 2) returns TRUE.

* **MinIndexIsInt**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MinIndexNotNull() but tests the value with IsInt().
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * Variants are:
      * MinIndexIsInt(intList, testList, setNullTo, setZeroTo)
      * MinIndexIsInt(intList, testList)
    * e.g. MinIndexIsInt({1990, 2000}, {111, xxx}) returns TRUE.
    
* **MaxIndexIsInt**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MaxIndexNotNull but tests the value with IsInt().
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * Variants are:
      * MaxIndexIsInt(intList, testList, setNullTo, setZeroTo)
      * MaxIndexIsInt(intList, testList)
    * e.g. MaxIndexIsInt({1990, 2000}, {111, xxx}) returns FALSE.

* **GetIndexIsInt**(*stringList* **intList**, *stringList* **testList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Same as GetIndexNotNull but tests the value with IsInt().
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * Variants are:
      * GetIndexIsInt(intList, testList, setNullTo, setZeroTo, indexToReturn)
      * GetIndexIsInt(intList, testList, indexToReturn)
    * e.g. GetIndexNotNull({1990, 2000, 2005}, {111, 222, 333}) returns TRUE.

* **MinIndexIsBetween**(*stringList* **intList**, *stringList* **testList**, *numeric* **min**, *numeric* **max**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MinIndexNotNull but tests the value with IsBetween along with **min** and **max** which are considered inclusive (i.e. the default behavior of isBetween()). 
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * MinIndexIsBetween(intList, testList, min, max, setNullTo, setZeroTo)
      * MinIndexIsBetween(intList, testList, min, max)
    * e.g. MinIndexIsBetween({1990, 2000}, {1000, 3000}, 0, 2000) returns TRUE.
    * e.g. MinIndexIsBetween({1990, 2000}, {3000, 1000}, 0, 2000) returns FALSE.

* **MaxIndexIsBetween**(*stringList* **intList**, *stringList* **testList**, *numeric* **min**, *numeric* **max**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MaxIndexNotNull but tests the value with IsBetween along with **min** and **max** which are considered inclusive (i.e. the default behavior of isBetween()).
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * MaxIndexIsBetween(intList, testList, min, max, setNullTo, setZeroTo)
      * MaxIndexIsBetween(intList, testList, min, max)
    * e.g. MaxIndexIsBetween({1990, 2000}, {1000, 3000}, 0, 2000) returns FALSE.
    * e.g. MaxIndexIsBetween({1990, 2000}, {3000, 1000}, 0, 2000) returns TRUE.

* **GetIndexIsBetween**(*stringList* **intList**, *stringList* **testList**, *numeric* **min**, *numeric* **max**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Same as GetIndexNotNull but tests the value with IsBetween along with **min** and **max** which are considered inclusive (i.e. the default behavior of isBetween()).
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * GetIndexIsBetween(intList, testList, min, max, setNullTo, setZeroTo, indexToReturn)
      * GetIndexIsBetween(intList, testList, min, max, indexToReturn)
    * e.g. GetIndexIsBetween({1990, 1995, 2000}, {0, 1000, 3000}, 0, 2000, 2) returns TRUE.
    * e.g. GetIndexIsBetween({1990, 1995, 2000}, {0, 3000, 1000}, 0, 2000, 2) returns FALSE.

* **MinIndexMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **matchList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MinIndexNotNull but tests the value with MatchList along with the **matchList**.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MinIndexMatchList(intList, testList, matchList, setNullTo, setZeroTo)
      * MinIndexMatchList(intList, testList, matchList)
    * e.g. MinIndexMatchList({1990, 2000}, {'a', 'b'}, {'a','c','d','g'}) returns TRUE.
    
* **MaxIndexMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **matchList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MaxIndexNotNull but tests the value with MatchList along with the **matchList**.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MaxIndexMatchList(intList, testList, matchList, setNullTo, setZeroTo)
      * MaxIndexMatchList(intList, testList, matchList)   
    * e.g. MaxIndexMatchList({1990, 2000}, {'a', 'b'}, {'a','c','d','g'}) returns FALSE.

* **GetIndexMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **matchList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Same as GetIndexNotNull but tests the value with MatchList along with the **matchList**.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * GetIndexMatchList(intList, testList, matchList, setNullTo, setZeroTo, indexToReturn)
      * GetIndexMatchList(intList, testList, matchList, indexToReturn)
    * e.g. GetIndexMatchList({1990, 2000, 2010}, {'a', 'b', 'c}, {'c','d','e','f','g'}, 3) returns TRUE.

* **MinIndexNotMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **matchList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MinIndexNotNull but tests the value with NotMatchList along with the **matchList**.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MinIndexNotMatchList(intList, testList, matchList, setNullTo, setZeroTo)
      * MinIndexNotMatchList(intList, testList, matchList)  
    * e.g. MinIndexNotMatchList({1990, 2000}, {'a', 'b'}, {'a','c','d','g'}) returns FALSE.
    
* **MaxIndexNotMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **matchList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Same as MaxIndexNotNull but tests the value with NotMatchList along with the **matchList**.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * MaxIndexNotMatchList(intList, testList, matchList, setNullTo, setZeroTo)
      * MaxIndexNotMatchList(intList, testList, matchList)   
    * e.g. MaxIndexNotMatchList({1990, 2000}, {'a', 'b'}, {'a','c','d','g'}) returns TRUE.

* **GetIndexNotMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **matchList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Same as GetIndexNotNull but tests the value with NotMatchList along with the **matchList**.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * Variants are:
      * GetIndexNotMatchList(intList, testList, matchList, setNullTo, setZeroTo, indexToReturn)
      * GetIndexNotMatchList(intList, testList, matchList, indexToReturn)
    * e.g. GetIndexNotMatchList({1990, 2000, 2010}, {'a', 'b', 'c}, {'c','d','e','f','g'}, 3) returns FALSE.
    
* **CoalesceIsInt**(*stringList* **srcValList**, *boolean* **zeroAsNull**\[default FALSE\])
    * Return TRUE if the first non-NULL value in the **srcValList** string list is an integer.
    * If **zeroAsNull** is set to TRUE, strings evaluating to zero ('0', '00', '0.0') are treated as NULL.
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * Variants are:
      * CoalesceIsInt(srcValList, zeroAsNull)
      * CoalesceIsInt(srcValList)
    * e.g. CoalesceIsInt({NULL, 0, 2000}, TRUE) returns TRUE.

* **CoalesceIsBetween**(*stringList* **srcValList**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], , *boolean* **zeroAsNull**\[default FALSE\])
    * Returns TRUE if the first non-NULL value in the **srcValList** string list is between **min** and **max**.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max**. Must include both or neither **includeMin** and **includeMax** parameters.
    * If **zeroAsNull** is set to TRUE, strings evaluating to zero ('0', '00', '0.0') are treated as NULL.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * CoalesceIsBetween(srcValList, min, max, includeMin, mincludeMax, zeroAsNull)
      * CoalesceIsBetween(srcValList, min, max, includeMin, mincludeMax)
      * CoalesceIsBetween(srcValList, min, max)
    * e.g. CoalesceIsBetween({NULL, 0, 5}, 0, 100) returns TRUE because 0 is between 0 and 100 and 0 which are both included in the valid interval.
    * e.g. CoalesceIsBetween({NULL, 0, 5}, 0, 100, FALSE, FALSE) returns FALSE because 0 is not included in the valid interval.
    * e.g. CoalesceIsBetween({NULL, 0, 5}, 0, 100, FALSE, FALSE, TRUE) returns TRUE because 0 is ignored and 5 is between 0 and 100.

* **GeoIsValid**(*geometry* **geom**, *boolean* **fixable**\[default TRUE\])
    * Returns TRUE if **geom** is a valid geometry.
    * When **fixable** is TRUE and **geom** is invalid, will attempt to make a valid geometry and return TRUE if successful. If geometry is invalid returns FALSE. Note that setting **fixable** to TRUE does not actually fix the geometry, it only tests to see if the geometry can be fixed.
    * Default error codes are 'INVALID_VALUE' for text attributes, -7779 for numeric attributes and NULL for other types (including geometry).
    * Variants are:
      * GeoIsValid(geom, fixable)
      * GeoIsValid(geom)
    * e.g. GeoIsValid(POLYGON, TRUE) returns TRUE is geom is fixable to a valid geometry.
    
* **GeoIntersects**(*geometry* **geom**, *text* **intersectSchemaName**\[default public\], *text* **intersectTableName**, *geometry* **geomCol**\[default geom\])
    * Returns TRUE if **geom** intersects with any features in the **geomCol** column of the **intersectSchemaName**.**intersectTableName** table. Otherwise returns FALSE. Invalid geometries are validated before running the intersection test.
    * Default error codes are 'NO_INTERSECT' for text attributes, -7778 for numeric attributes and NULL for other types (including geometry).
    * Variants are:
      * GeoIntersects(geom, intersectSchemaName, intersectTableName, geomCol)
      * GeoIntersects(geom, intersectSchemaName, intersectTableName)
      * GeoIntersects(geom, intersectTableName)
    * e.g. GeoIntersects(POLYGON, public, intersect_tab, intersect_geo) returns TRUE is POLYGON intersects with the intersect_geo.
  
* **GeoIntersectionGreaterThan**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geomCol**, *text* **returnCol**, *text* **method**, *numeric* **lowerBound**)
    * Runs GeoIntersection and passes the **returnCol** from the intersecting polygon to IsGreaterThan. See GeoIntersectionText for full details.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * Variants are:
      * GeoIntersectionGreaterThan(geom, intersectSchemaName, intersectTableName, geomCol, returnCol, method, lowerBound)
    * GeoIntersectionGreaterThan(POLYGON, public, intersect_tab, intersect_geo, NUMBER, GREATEST_AREA, 10) returns TRUE if the intersecting polygon has a value greater than 10.
      
## Translation Functions

Default error codes for translation functions are 'TRANSLATION_ERROR' for text attributes, -3333 for numeric attributes and NULL for others.

* **NothingText**()
    * Returns NULL of type text. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **target_attribute_type**.
    * e.g. NothingText().

* **NothingDouble**()
    * Returns NULL of type double precision. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **target_attribute_type**.
    * e.g. NothingDouble().

* **NothingInt**()
    * Returns NULL of type integer. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **target_attribute_type**.
    * e.g. NothingInt().

* **CopyText**(*text* **srcVal**)
    * Returns **srcVal** as text without any transformation.
    * Return type is text.
    * Variants are:
      * CopyText(srcVal)
    * e.g. CopyText('sp1') returns 'sp1'.
      
* **CopyDouble**(*numeric* **srcVal**)
    * Returns **srcVal** as double precision without any transformation.
    * Return type is double precision
    * Variants are:
      * CopyDouble(srcVal)
    * e.g. CopyDouble(1.1) returns 1.1.

* **CopyInt**(*integer* **srcVal**)
    * Returns **srcVal** as integer without any transformation.
    * Return type is integer
    * Variants are:
      * CopyInt(srcVal)
    * e.g. CopyInt(1) returns 1.
      
* **LookupText**(*text* **srcVal**, *text* **lookupSchemaName**, *text* **lookupTableName**, *text* **lookupColName**, *text* **retrieveColName**, *boolean* **ignoreCase**\[default FALSE\])
    * Returns text value from the **retrieveColName** column in **lookupSchemaName**.**lookupTableName** that matches **srcVal** in the **lookupColName** column.
    * When **ignoreCase** is TRUE, case is ignored.
    * Return type is text.
    * Variants are:
      * LookupText(srcVal, lookupSchemaName, lookupTableName, lookupColName, retrieveColName, ignoreCase)
      * LookupText(srcVal, lookupSchemaName, lookupTableName, lookupColName, retrieveColName)
    * e.g. LookupText('sp1', 'public', 'species_lookup', 'lookupCol', 'returnCol', TRUE) returns the returnCol value matching the sp1 value in the lookupCol.
      
* **LookupDouble**(*text* **srcVal**, *text* **lookupSchemaName**, *text* **lookupTableName**, *text* **lookupColName**, *text* **retrieveColName**, *boolean* **ignoreCase**\[default FALSE\])
    * Returns double precision value from the **retrieveColName** column in **lookupSchemaName**.**lookupTableName** that matches **srcVal** in the **lookupColName** column.
    * When **ignoreCase** is TRUE, case is ignored.
    * Return type is double precision.
    * Variants are:
      * LookupDouble(srcVal, lookupSchemaName, lookupTableName, lookupColName, retrieveColName, ignoreCase)
      * LookupDouble(srcVal, lookupSchemaName, lookupTableName, lookupColName, retrieveColName)
    * e.g. LookupDouble('sp1', 'public', 'species_lookup', 'lookupCol', 'returnCol', TRUE) returns the returnCol value matching the 'sp1' value in the lookupCol.

* **LookupInt**(*text* **srcVal**, *text* **lookupSchemaName**, *text* **lookupTableName**, *text* **lookupColName**, *text* **retrieveColName**, boolean **ignoreCase**\[default FALSE\])
    * Returns integer value from the **retrieveColName** column in **lookupSchemaName**.**lookupTableName** that matches **srcVal** in the **lookupColName** column.
    * When **ignoreCase** is TRUE, case is ignored.
    * Return type is integer.
    * Variants are:
      * LookupInt(srcVal, lookupSchemaName, lookupTableName, lookupColName, retrieveColName, ignoreCase)
      * LookupInt(srcVal, lookupSchemaName, lookupTableName, lookupColName, retrieveColName)
    * e.g. LookupDouble('sp1', 'public', 'species_lookup', 'lookupCol', 'returnCol', TRUE) returns the returnCol value matching the 'sp1' value in the lookupCol.

* **MapText**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Return text value from **returnList** that matches index of **srcVal** in **matchList**. 
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * Return type is text.
    * Variants are:
      * MapText(srcVal, matchList, returnList, ignoreCase, removeSpaces)
      * MapText(srcVal, matchList, returnList, ignoreCase)
      * MapText(srcVal, matchList, returnList)
    * e.g. MapText('A','{'A','B','C'}','{'D','E','F'}', TRUE) returns 'D'.
    
* **MapSubstringText**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Calculates substring of **srcVal** and passes to MapText() using **matchList** and **returnList**.
    * Return type is text.
    * Variants are:
      * MapSubstringText(srcVal, startChar, forLength, matchList, returnList, ignoreCase, removeSpaces)
      * MapSubstringText(srcVal, startChar, forLength, matchList, returnList, ignoreCase)
      * MapSubstringText(srcVal, startChar, forLength, matchList, returnList)
    * e.g. MapSubstringText('ABC',1,1,'{'A','B','C'}','{'D','E','F'}') returns 'D'.
    
* **SumIntMapText**(*stringList* **srcValList**, *stringList* **matchList**, *stringList* **returnList**)
    * Calculates the sum  of the values in the **srcValList** string list and passes the sum to MapText() with **matchList** amd **returnList**.
    * Return type is text.
    * Variants are:
      * SumIntMapText(srcValList, matchList, returnList)
    * e.g. SumIntMapText({1, 2},{3, 4, 5},{'three','four','five'}) returns 'three'.
    
* **MapTextNotNullIndex**(*text* **srcVal1**, *stringList* **matchList1**, *stringList* **returnList1**, *text* **srcVal2**, *stringList* **matchList2**, *stringList* **returnList2**, *text* **srcVal3**, *stringList* **matchList3**, *stringList* **returnList3**, *text* **srcVal4**, *stringList* **matchList4**, *stringList* **returnList4**, *text* **srcVal5**, *stringList* **matchList5**, *stringList* **returnList5**, *text* **srcVal6**, *stringList* **matchList6**, *stringList* **returnList6**, *text* **srcVal7**, *stringList* **matchList7**, *stringList* **returnList7**, *text* **srcVal8**, *stringList* **matchList8**, *stringList* **returnList8**, *text* **srcVal9**, *stringList* **matchList9**, *stringList* **returnList9**, *text* **srcVal10**, *stringList* **matchList10**, *stringList* **returnList10**, *integer* indexToReturn)
    * Runs MapText for each set of val, matchList and returnList, then returns the ith non-null result where i = indexToReturn.
    * Null srcVals and null results from MapText are dropped when selecting the ith non-null result.
    * If indexToReturn > the count of results, NULL is returned.
    * Works with between two and ten sets of srcVal, matchList, and returnList.
    * Return type is text.
    * Variants are:
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, srcVal5, matchList5, returnList5, srcVal6, matchList6, returnList6, srcVal7, matchList7, returnList7, srcVal8, matchList8, returnList8, srcVal9, matchList9, returnList9, srcVal10, matchList10, returnList10, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, srcVal5, matchList5, returnList5, srcVal6, matchList6, returnList6, srcVal7, matchList7, returnList7, srcVal8, matchList8, returnList8, srcVal9, matchList9, returnList9, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, srcVal5, matchList5, returnList5, srcVal6, matchList6, returnList6, srcVal7, matchList7, returnList7, srcVal8, matchList8, returnList8, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, srcVal5, matchList5, returnList5, srcVal6, matchList6, returnList6, srcVal7, matchList7, returnList7, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, srcVal5, matchList5, returnList5, srcVal6, matchList6, returnList6, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, srcVal5, matchList5, returnList5, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, srcVal4, matchList4, returnList4, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, srcVal3, matchList3, returnList3, indexToReturn)
      * MapTextNotNullIndex(srcVal1, matchList1, returnList1, srcVal2, matchList2, returnList2, indexToReturn)
    * e.g. MapTextNotNullIndex(a,{a,b},{A,B}, b,{a,b},{A,B}, 1) returns 'A'.
    * e.g. MapTextNotNullIndex(NULL,{a,b},{A,B}, NULL,{a,b},{A,B}, c,{c,d},{C,D}, d,{c,d},{C,D}, e,{e,f},{E,F}, f,{e,f},{E,F}, g,{g,h},{G,H}, h,{g,h},{G,H}, i,{i,j},{I,J}, j,{i,j},{I,J}, 5) returns 'G' because the NULL srcVals are ignored.
      
* **MapDouble**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Return double precision value in **returnList** that matches index of **srcVal** in **matchList**. 
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * Return type is double precision.
    * Variants are:
      * MapDouble(srcVal, matchList, returnList, ignoreCase, removeSpaces)
      * MapDouble(srcVal, matchList, returnList, ignoreCase)
      * MapDouble(srcVal, matchList, returnList)
    * e.g. MapDouble('A',{'A','B','C'},{1.1,1.2,1.3}, TRUE) returns 1.1.
      
* **MapInt**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Return integer value in **returnList** that matches index of **srcVal** in **matchList**. 
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * Return type is integer.
    * Variants are:
      * MapInt(srcVal, matchList, returnList, ignoreCase, removeSpaces)
      * MapInt(srcVal, matchList, returnList, ignoreCase)
      * MapInt(srcVal, matchList, returnList)
    * e.g. Map('A',{'A','B','C'},{1,2,3}) returns 1.
      
* **Length**(*text* **srcVal**, *boolean* **trimSpaces**)
    * Returns the length of the **srcVal** string.
    * When **trimSpaces** is TRUE, removes any leading or trailing spaces before calculating length.
    * Return type is integer.
    * Variants are:
      * Length(srcVal, trimSpaces)
      * Length(srcVal)
    * e.g. Length('12345') returns 5.

* **LengthMapInt**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **removeSpaces**\[default FALSE\])
    * Calculates length of string then pass the length to MapInt().
    * When **removeSpaces** is TRUE, removes any spaces before calculating length.
    * Return type is integer.
    * Variants are:
      * LengthMapInt(srcVal, matchList, returnList, removeSpaces)
      * LengthMapInt(srcVal, matchList, returnList)
    * e.g. Length('12345', {5, 6, 7}, {1, 2, 3}) returns 1.
    
* **Multiply**(*numeric* **val1**, *numeric* **val2**)
    * Multiplies val1 by val2.
    * Return type is double precision.
    * Variants are:
      * Multiply(val1, val2)
    * e.g. Multiply(2.5, 2) returns 5.

* **MultiplyInt**(*numeric* **val1**, *numeric* **val2**)
    * Calls **Multiply** and casts to integer.
    * Return type is integer.
    * Variants are:
      * MultiplyInt(val1, val2)
    * e.g. Multiply(2, 3) returns 6.

* **SubstringMultiplyInt**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *numeric* **val2**)
    * Runs Substring using **srcVal**, **startChar** and **forLength**, then multiplies the result by **val2** and casts to an integer.
    * Return type is integer.
    * Variants:
      * SubstringMultiplyInt(srcVal, startChar, forLength, vals)
    * e.g. SubstringMultiplyInt('xx2', 3, 1, 2) returns 4.

* **DivideDouble**(*numeric* **srcVal**, *numeric* **divideBy**)
    * Divides **srcVal** by **divideBy**.
    * Return type is double precision.
    * Variants are:
      * DivideDouble(srcVal, divideBy)
    * e.g. DivideDouble(10, 4) returns 2.5.

* **DivideInt**(*numeric* **srcVal**, *numeric* **divideBy**)
    * A wrapper around DivideDouble() that returns an integer.
    * Return type is integer.
    * Variants are:
      * DivideInt(srcVal, divideBy)
    * e.g. DivideInt(2.2, 1.1) returns 2.

* **XMinusYDouble**(*numeric* **x**, *numeric* **y**)
    * Returns the result of **x** minus **y**.
    * Return type is double precision.
    * Variants are:
      * XMinusYDouble(x, y)
    * e.g. XMinusYDouble(2.2, 1.1) returns 1.1.

* **XMinusYInt**(*numeric* **x**, *numeric* **y**)
    * Casts the result of **x** minus **y** to an integer.
    * Return type is integer.
    * Variants are:
      * XMinusYInt(x, y)
    * e.g. XMinusYInt(2, 1) returns 1.

* **Pad**(*text* **srcVal**, *int* **targetLength**, *text* **padChar**, *boolean* **trunc**\[default TRUE\])
    * Returns a string of length **targetLength** made up of **srcVal** preceeded with **padChar**.
    * When **trunc** is TRUE and **srcVal** length > **targetLength**, truncate **srcVal** to **targetLength**. Returns **srcVal** otherwise. 
    * Return type is text.
    * Variants are:
      * Pad(srcVal, targetLength, padChar, trunc)
      * Pad(srcVal, targetLength, padChar)
    * e.g. Pad('tab1', 10, 'x') returns 'xxxxxxtab1'.
    * e.g. Pad('tab1', 2, 'x', TRUE) returns 'ta'.
    * e.g. Pad('tab1', 2, 'x', FALSE) returns 'tab1'.

* **Concat**(*stringList* **srcValList**, *text* **separator**, *boolean* **nullToEmpty**\[default FALSE\])
    * Concatenate all values in the **srcValList** string list, interspersed with **separator**.
    * If **nullToEmpty** is TRUE, NULLs are converted to empty strings ('').
    * Return type is text.
    * Variants are:
      * Concat(srcValList, separator, nullToEmpty)
      * Concat(srcValList, separator)
    * e.g. Concat('{'str1','str2','str3'}', '-') returns 'str1-str2-str3'.

* **PadConcat**(*stringList* **srcValList**, *stringList* **lengthList**, *stringList* **padList**, *text* **separator**, *boolean* **upperCase**, *boolean* **includeEmpty**\[default TRUE\])
    * Pad all values in the **srcValList** string list according to the respective **lengthList** and **padList** values and then concatenate them with the **separator**. 
    * If **upperCase** is TRUE, all characters are converted to upper case.
    * If **includeEmpty** is FALSE, any empty strings in **srcValList** are dropped from the concatenation.
    * Return type is text.
    * Variants are:
      *  PadConcat(srcValList, lengthList, padList, separator, upperCase, includeEmpty)
      *  PadConcat(srcValList, lengthList, padList, separator, upperCase)
    * e.g. PadConcat({'str1','str2','str3'}, {'5','5','7'}, {'x','x','0'}, '-', TRUE, TRUE) returns 'xstr1-xstr2-000str3'.

* **CountOfNotNull**(*stringList* **scrVals1/2/3/4/5/6/7/8/9/10/11/12/13/14/15**, *int* **maxRankToConsider**, *boolean* **zeroIsNull**)
    * Returns the number of string list input arguments that have at least one list element that is not NULL or an empty string. Up to a maximum of 15.
    * Between 1 and 15 string lists can be provided.
    * Only the first **maxRankToConsider** string lists will be considered for the calculation. For example, if **maxRankToConsider** is 1, only the first string list will be considered and the maximum values that could be returned would be 1.
    * When **zeroIsNull** is TRUE, zero values are counted as NULLs.
    * **maxRankToConsider** and **zeroIsNull** always need to provided.
    * Return type is integer.
    * Variants are:
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, srcVals10, srcVals11, srcVals12, srcVals13, srcVals14, srcVals15, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, srcVals10, srcVals11, srcVals12, srcVals13, srcVals14, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, srcVals10, srcVals11, srcVals12, srcVals13, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, srcVals10, srcVals11, srcVals12, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, srcVals10, srcVals11, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, srcVals10, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, srcVals9, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, srcVals8, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, srcVals7, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, srcVals6, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, srcVals5, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, srcVals4, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, srcVals3, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, srcVals2, maxRankToConsider, zeroIsNull)
      * CountOfNotNull(srcVals1, maxRankToConsider, zeroIsNull)
    * e.g. CountOfNotNull({'a', 'b'}, {'c', 'd'}, {'e', 'f'}, {'g', 'h'}, {'i', 'j'}, {'k', 'l'}, {'m', 'n'}, 7, FALSE) returns 7.
    * e.g. CountOfNotNull({'a', 'b'}, {'c', 'd'}, {'e', 'f'}, {'g', 'h'}, {'i', 'j'}, {'k', 'l'}, {'m', 'n'}, 2, FALSE) returns 2.
 
* **IfElseCountOfNotNullText**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *int* **count**, *text* **returnIf**, *text* **returnElse**)
    * Calls CountOfNotNull() and tests if the returned value matches **count**. Up to a maximum of 7 **val** string lists.
    * If returned value is less than or equal to **count**, returns **returnIf**, else returns **returnElse**.
    * zeroIsNull in countOfNotNull is set to FALSE.
    * Return type is text.
    * Variants are:
      * IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, vals6, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, vals5, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullText(vals1, vals2, vals3, vals4, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullText(vals1, vals2, vals3, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullText(vals1, vals2, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullText(vals1, maxRankToConsider, count, returnIf, returnElse)
    * e.g. IfElseCountOfNotNullText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, 8, 'S', 'M') returns 'S'.

* **IfElseCountOfNotNullInt**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *int* **count**, *text* **returnIf**, *text* **returnElse**)
    * Simple wrapper around IfElseCountOfNotNullText() that returns an int.
    * Return type is integer.
    * Variants are:
      * IfElseCountOfNotNullInt(vals1, vals2, vals3, vals4, vals5, vals6, vals7, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullInt(vals1, vals2, vals3, vals4, vals5, vals6, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullInt(vals1, vals2, vals3, vals4, vals5, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullInt(vals1, vals2, vals3, vals4, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullInt(vals1, vals2, vals3, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullInt(vals1, vals2, maxRankToConsider, count, returnIf, returnElse)
      * IfElseCountOfNotNullInt(vals1, maxRankToConsider, count, returnIf, returnElse)
    * * e.g. IfElseCountOfNotNullInt({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, 8, 1, 2) returns '1.
    
* **CountOfNotNullMapText**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *stringList* **resultList**, *stringList* **mappingList**)
    * Calls CountOfNotNull() and passes the returned value to MapText using the **resultList** and **mappingList**.
    * zeroIsNull in countOfNotNull is set to FALSE.
    * Return type is text.
    * Variants are:
      * CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, vals6, vals7, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, vals6, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapText(vals1, vals2, vals3, vals4, vals5, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapText(vals1, vals2, vals3, vals4, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapText(vals1, vals2, vals3, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapText(vals1, vals2, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapText(vals1, maxRankToConsider, resultList, mappingList)
    * e.g. CountOfNotNullMapText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, {1,2,3,4,5,6,7}, {'a','b','c','d','e','f','g'}) returns 'g'.

* **CountOfNotNullMapInt**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *stringList* **resultList**, *stringList* **mappingList**)
    * Simple wrapper around CountOfNotNullMapText returning int.
    * Return type is integer.
    * Variants are:
      * CountOfNotNullMapInt(vals1, vals2, vals3, vals4, vals5, vals6, vals7, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapInt(vals1, vals2, vals3, vals4, vals5, vals6, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapInt(vals1, vals2, vals3, vals4, vals5, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapInt(vals1, vals2, vals3, vals4, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapInt(vals1, vals2, vals3, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapInt(vals1, vals2, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapInt(vals1, maxRankToConsider, resultList, mappingList)
    * e.g. CountOfNotNullMapInt({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, {1,2,3,4,5,6,7}, {10,20,30,40,50,60,70}) returns 70.
    
* **CountOfNotNullMapDouble**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *stringList* **resultList**, *stringList* **mappingList**)
    * Simple wrapper around CountOfNotNullMapText returning double precision.
    * Return type is double precision.
    * Variants are:
      * CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, vals5, vals6, vals7, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, vals5, vals6, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, vals5, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapDouble(vals1, vals2, vals3, vals4, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapDouble(vals1, vals2, vals3, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapDouble(vals1, vals2, maxRankToConsider, resultList, mappingList)
      * CountOfNotNullMapDouble(vals1, maxRankToConsider, resultList, mappingList)
    * e.g. CountOfNotNullMapDouble({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, {1,2,3,4,5,6,7}, {1.0,2.0,3.0,4.0,5.0,6.0,7.0}) returns 7.0.
    
* **SubstringText**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *boolean* **removeSpaces**\[default FALSE\])
    * Returns a substring of **srcVal** from **startChar** for **forLength**.
    * When **removeSpaces** is TRUE, spaces are removed from **srcVal** before taking the substring.
    * Return type is text.
    * Variants are:
      * SubstringText(srcVal, startChar, forLength, removeSpaces)
      * SubstringText(srcVal, startChar, forLength)
    * e.g. SubstringText('abcd', 2, 2) returns 'bc'.

* **SubstringInt**(*text* **srcVal**, *int* **startChar**, *int* **forLength**)
    * Simple wrapper around **SubstringText** that returns an int.
    * Return type is text.
    * Variants are:
      * SubstringInt(srcVal, startChar, forLength, removeSpaces)
      * SubstringInt(srcVal, startChar, forLength)
    * e.g. SubstringInt('a55d', 2, 2) returns 55.
    
* **MinInt**(*stringList* **srcValList**)
    * Return the lowest integer in the **srcValList** string list. 
    * Return type is integer.
    * Variants are:
      * MinInt(srcValList)
    * e.g. MinInt({1990, 2000}) returns 1990.

* **MaxInt**(*stringList* **srcValList**)
    * Return the highest integer in the **srcValList** string list. 
    * Return type is integer.
    * Variants are:
      * MaxInt(srcValList)
    * e.g. MaxInt({1990, 2000}) returns 2000.

* **MinIndexCopyText**(*stringList* **intList**, *stringList* **returnList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Returns value from **returnList** matching the index of the lowest value in **intList**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested.
    * Return type is text.
    * Variants are:
      * MinIndexCopyText(intList, returnList, setNullTo, setZeroTo)
      * MinIndexCopyText(intList, returnList)
    * e.g. MinIndexCopyText({1990, 2000}, {burn, wind}) returns 'burn'.
    * e.g. MinIndexCopyText({1990, NULL}, {burn, wind}, 1000, 'NULL') returns 'wind'.

* **MaxIndexCopyText**(*stringList* **intList**, *stringList* **returnList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Returns value from **returnList** matching the index of the highest value in **intList**.
    * If setNullTo is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating max value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * If there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested.
    * Return type is text.
    * Variants are:
      * MaxIndexCopyText(intList, returnList, setNullTo, setZeroTo)
      * MaxIndexCopyText(intList, returnList)
    * e.g. MaxIndexCopyText({1990, 2000}, {burn, wind}) returns 'wind'.
    * e.g. MaxIndexCopyText({0, 2000}, {burn, wind}, 'NULL', 2001) returns 'burn'.

* **GetIndexCopyText**(*stringList* **intList**, *stringList* **returnList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Reorder the **returnList** by the **intList**, matching values in **intList** stay in the original order.
    * Return the value from the reordered **returnList** that matches the index of **indexToReturn**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs are ignored when calculating max value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.    
    * Return type is text.
    * Variants are:
      * GetIndexCopyText(intList, returnList, setNullTo, setZeroTo, indexToReturn)
      * GetIndexCopyText(intList, returnList, indexToReturn)
    * e.g. GetIndexCopyText({1990, 2000, 2020}, {burn, wind, insect}, 2) returns 'wind'.

* **MinIndexCopyInt**(*stringList* **intList**, *stringList* **returnList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
  * Same as MinIndexCopyText() but returns an integer.
  * Return type is integer.
  * Variants are:
    * MinIndexCopyInt(intList, returnList, setNullTo, setZeroTo)
    * MinIndexCopyInt(intList, returnList)
  * e.g. MinIndexCopyInt({1990, 2000}, {1, 2}) returns 1.
  
* **MaxIndexCopyInt**(*stringList* **intList**, *stringList* **returnList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
  * Same as MaxIndexCopyText() but returns an integer.
  * Return type is integer.
  * Variants are:
    * MaxIndexCopyInt(intList, returnList, setNullTo, setZeroTo)
    * MaxIndexCopyInt(intList, returnList)
  * e.g. MaxIndexCopyInt({1990, 2000}, {1, 2}) returns 2.

* **GetIndexCopyInt**(*stringList* **intList**, *stringList* **returnList**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
  * Same as GetIndexCopyText() but returns an integer.
  * Return type is integer.
  * * Variants are:
    * GetIndexCopyInt(intList, returnList, setNullTo, setZeroTo, indexToReturn)
    * GetIndexCopyInt(intList, returnList, indexToReturn)
  * e.g. GetIndexCopyInt({1990, 2000, 2010}, {1, 2, 3}, 2) returns 2.

* **MinIndexMapText**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Passes value from **returnList** matching the index of the lowest value in **intList** to MapText(). Runs MapText() using **mapVals** and **targetVals**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested.
    * Return type is text.
    * Variants are:
      * MinIndexMapText(intList, returnList, mapVals, targetVals, setNullTo, setZeroTo)
      * MinIndexMapText(intList, returnList, mapVals, targetVals, setNullTo)
    * e.g. MinIndexMapText({1990, 2000}, {burn, wind}, {burn, wind}, {BU, WT}) returns 'BU'.

* **MaxIndexMapText**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
    * Passes value from returnList matching the index of the highest value in intList to MapText(). Runs MapText() with **mapVals** and **targetVals**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating max value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested.
    * Return type is text.
    * Variants are:
      * MaxIndexMapText(intList, returnList, mapVals, targetVals, setNullTo, setZeroTo)
      * MaxIndexMapText(intList, returnList, mapVals, targetVals, setNullTo)
    * e.g. MaxIndexMapText({1990, 2000}, {burn, wind}, {burn, wind}, {BU, WT}) returns WT.

* **GetIndexMapText**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
    * Reorder the **returnList** by the **intList**, matching values in **intList** stay in the original order.
    * Pass the value from the reordered **returnList** that matches the index of **indexToReturn** to MapText along with **mapVals** and **targetVals**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating max value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * Return type is text.
    * Variants are:
      * GetIndexMapText(intList, returnList, mapVals, targetVals, setNullTo, setZeroTo, indexToReturn)
      * GetIndexMapText(intList, returnList, mapVals, targetVals, setNullTo, indexToReturn)
    * e.g. GetIndexMapText({1990, 1995, 2000}, {burn, wind, insect}, {burn, wind, insect}, {BU, WT, IN}, 2) returns WT.

* **MinIndexMapInt**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
  * Same as MinIndexMapText() but returning an integer.
  * Return type is integer.
  * Variants are:
    * MinIndexMapInt(intList, returnList, mapVals, targetVals, setNullTo, setZeroTo)
    * MinIndexMapInt(intList, returnList, mapVals, targetVals, setNullTo)
  * e.g. MinIndexMapInt({1990, 2000}, {burn, wind}, {burn, wind}, {22, 23}) returns 22.

* **MaxIndexMapInt**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\])
  * Same as MaxIndexMapText() but returning an integer.
  * Return type is integer.
  * Variants are:
    * MaxIndexMapInt(intList, returnList, mapVals, targetVals, setNullTo, setZeroTo)
    * MaxIndexMapInt(intList, returnList, mapVals, targetVals, setNullTo)
  * e.g. MaxIndexMapInt({1990, 2000}, {burn, wind}, {burn, wind}, {22, 23}) returns 23.

* **GetIndexMapInt**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *numeric* **setNullTo**\[default NULL\], *numeric* **setZeroTo**\[default NULL\], *int* **indexToReturn**)
  * Same as GetIndexMapText() but returns an integer.
  * Return type is integer.
  * Variants are:
    * GetIndexMapInt(intList, returnList, mapVals, targetVals, setNullTo, setZeroTo, indexToReturn)
    * GetIndexMapInt(intList, returnList, mapVals, targetVals, setNullTo, indexToReturn)
  * e.g. GetIndexMapInt({1990, 2000, 2001}, {burn, wind, insect}, {burn, wind, insect}, {22, 23, 24}, 3) returns 24.

* **CoalesceText**(*text* **srcValList**, *boolean* **zeroAsNull**\[default FALSE\])
    * Returns the first non-NULL value in the **srcValList** string list.
    * When **zeroAsNull** is set to TRUE, strings evaluated to zero ('0', '00', '0.0') are treated as NULL.
    * Return type is text.
    * Variants are:
      * CoalesceText(srcValList, zeroAsNull)
      * CoalesceText(srcValList)
    * e.g. CoalesceText({NULL, '0.0', 'abcd'}, TRUE) returns 'abcd'.

* **CoalesceInt**(*text* **srcValList**, *boolean* **zeroAsNull**\[default FALSE\])
    * Simple wrapper around CoalesceText() that returns an int.
    * Return type is integer.
    * Variants are:
      * CoalesceInt(srcValList, zeroAsNull)
      * CoalesceInt(srcValList)
    * e.g. CoalesceInt({NULL, 7, 5}) returns 7.

* **AlphaNumeric**(*stringList* **srcVal**)
    * Creates an alpha numeric code by converting all **srcVal** letters to 'x' and all integers to '0'.
    * Return type is text.
    * Variants are:
      * AlphaNumeric(srcVal)
    * e.g. AlphaNumeric('bf50ws50') returns 'xx00xx00'.

* **GeoIntersectionText**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *text* **returnCol**, *text* **method**)
    * Returns the value of the **returnCol** column of the **intersectSchemaName**.**intersectTableName** table where the geometry in the **geoCol** column intersects **geom**.
    * When multiple polygons intersect, the value from the polygon with the largest area can be returned by setting **method** to 'GREATEST_AREA'; the lowest intersecting value can be returned by setting **method** to'LOWEST_VALUE', or the highest value can be returned by setting method to 'HIGHEST_VALUE'. The 'LOWEST_VALUE' and 'HIGHEST_VALUE' methods only work when **returnCol** is numeric.
    * Return type is text.
    * Variants are:
      * GeoIntersectionText(geom, intersectSchemaName, intersectTableName, geCol, returnCol, method)
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, TYPE, GREATEST_AREA).
    
* **GeoIntersectionDouble**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *numeric* **returnCol**, *text* **method**)
    * Returns a double precision value from an intersecting polygon. Parameters are the same as GeoIntersectionText.
    * Return type is double precision.
    * Variants are:
      * GeoIntersectionDouble(geom, intersectSchemaName, intersectTableName, geCol, returnCol, method)
    * e.g. GeoIntersectionDouble(POLYGON, public, intersect_tab, intersect_geo, TYPE, GREATEST_AREA).

* **GeoIntersectionInt**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *numeric* **returnCol**, *text* **method**)
    * Returns an integer value from an intersecting polygon. Parameters are the same as GeoIntersectionText.
    * Return type is integer.
    * Variants are:
      * GeoIntersectionInt(geom, intersectSchemaName, intersectTableName, geCol, returnCol, method)
    * e.g. GeoIntersectionInt(POLYGON, public, intersect_tab, intersect_geo, TYPE, GREATEST_AREA).

* **GeoMakeValid**(*geometry* **geom**)
    * Returns a valid version of **geom**. If **geom** cannot be validated, returns NULL.
    * Return type is geometry.
    * Variants are:
      * GeoMakeValid(geom)
    * e.g. GeoMakeValid(POLYGON).
    
* **GeoMakeValidMultiPolygon**(*geometry* **geom**)
    * Returns a valid version of **geom** of type ST_MultiPolygon. If **geom** cannot be validated, returns NULL.
    * Return type is geometry.
    * Variants are:
      * GeoMakeValidMultiPolygon(geom)
    * e.g. GeoMakeValidMultiPolygon(POLYGON).


# Adding Custom Helper Functions
Additional helper functions can be written in PL/pgSQL. They must follow the following conventions:

  * **Namespace -** All helper function names must be prefixed with "TT_". This is necessary to create a restricted namespace for helper functions so that no standard PostgreSQL functions (which do not necessarily comply to the following conventions) can be used. This prefix must not be used when referring to the function in the translation table.
  * **Parameter Types -** All helper functions (validation and translation) must accept only text parameters (the engine converts everything to text before calling the function). This greatly simplifies the development of helper functions and the parsing and validation of translation tables.
  * **Variable number of parameters -** Helper functions should NOT be implemented as VARIADIC functions accepting an arbitrary number of parameters. If an arbitrary number of parameters must be supported, it should be implemented as a list of text values separated by a comma. This is to avoid the hurdle of finding, when validating the translation table, if the function exists in the PostgreSQL catalog. Note that when passing arguments from the translation table to the helper functions, the engine strips the '{}' from any argument lists. So helper functions of this type need only process the comma separated list of values.
  * **Default value -** Helper functions should NOT use DEFAULT parameter values. The catalog needs to contain explicit helper function signatures for all functions it could receive. If signatures with default parameters are required, a separate function signature should be created as a wrapper around the function supporting all the parameters. This is to avoid the hurdle of finding, when validating the translation table, if the function exists in the PostgreSQL catalog.
  * **Polymorphic translation functions -** If a translation helper function must be written to return different types (e.g. int and text), as many different functions with corresponding names must be written (e.g. TT_CopyInt() and TT_CopyText()). The use of the generic "any" PostgreSQL type is forbidden. This ensures that the engine can explicitly know that the translation function returns the correct type.
  * **Error handling -** All helper functions (validation and translation) must raise an exception when parameters other than the source value are NULL or of an invalid type. This is to avoid badly written translation tables. All helper functions (validation and translation) should handle any source data values (always passed as text) without failing. This is to avoid crashing of the engine when translating big source files. 
  * **Return value -** 1) Validation functions must always return a boolean. They must handle NULL and empty values and in those cases return the appropriate boolean value. When they return FALSE, an error code will be set as target value in the translated table. Default error codes are provided for each validation helper function in the TT_DefaultErrorCode() function or directly after the rule in the translation table. 2) Translation functions must return a specific type. For now only "int", "numeric", "text", "boolean" and "geometry" are supported. If any errors happen during translation, the translation function must return NULL and the engine will translate the value to the generic "TRANSLATION_ERROR" (-3333) code, or a user defined error code if one is provided directly after the rule in the tranlation table.

If you think some of your custom helper functions could be of general interest to other users of the framework, you can submit them to the project team. They could be integrated in the helper function file.

# Credit
**Pierre Racine** - Center for forest research, University Laval.

**Marc Edwards** - database design, programming.

**Pierre Vernier** - database design.
