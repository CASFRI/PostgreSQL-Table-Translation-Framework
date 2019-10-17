# Introduction
The PostgreSQL Table Translation Framework allows PostgreSQL users to validate and translate a source table into a new target table  using validation and translation rules. This framework simplifies the writing of complex SQL queries attempting to achieve the same goal. It serves as an in-database transform engine in an Extract, Load, Transform (ELT) process (a variant of the popular ETL process) where most of the transformation is done inside the database. Future versions should provide logging and resuming allowing a fast workflow to create, edit, test, and generate translation tables.

The primary components of the framework are:
* The translation engine, implemented as a set of PL/pgSQL functions.
* A set of validation and translation helper functions implementing a general set of validation and translation rules.
* A user produced translation table defining the structure of the target table and all validation and the translation rules.
* Optionally, some user produced value lookup tables that accompany the translation table.

# Directory Structure
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
  5. if required, the helperFunctionsGIS.sql file.
  6. If required, the helperFunctionsGISTest.sql file. All tests should pass.
  
* **Uninstallation -** You can uninstall all the functions by running the helperFunctionsUninstall.sql, the the helperFunctionsGISUninstall.sql and the engineUninstall.sql files.

# Vocabulary
*Translation engine/function* - The PL/pgSQL code implementing the PostgreSQL Table Translation Framework. Can also refer more precisely to the translation function TT_Translate() which is the core of the translation process.

*Helper function* - A set of PL/pgSQL functions used in the translation table to facilitate validation of source values and their translation to target values.

*Source table* - The table to be validated and translated.

*Target table* - The table created by the translation process.

*Source attribute/value* - The attribute or value stored in the source table.

*Target attribute/value* - The attribute or value to be stored in the translated target table.

*Translation table* - User created table read by the translation engine and defining the structure of the target table, the validation rules and the translation rules.

*Translation row* - One row of the translation table.

*Validation rule* - The set of validation helper functions used to validating the sources values of an attribute. There is one set of validation rule per row in the translation table.

*Translation rule* - The translation helper functions used to translate the sources values to the target attribute. There is only one translation rule per translation row in the translation table.

*Lookup table* - User created table of lookup values used by some helper functions to convert source values into target values.


# What are translation tables and how to write them?

A translation table is a normal PostgreSQL table defining the structure of the target table (one row per target attribute), how to validate source values to be translated, and how to translate source values into target attributes. It also provides a way to document the validation and translation rules and to flag rules that are not yet in sync with their description (in the case where rules are written as a second step or by different people).

The translation table implements two very different steps:

1. **Validation -** The source values are first validated by a set of validation rules separated by a semicolon. Each validation rule defines an error code that is returned if the rule is not fulfilled. The next step (translation) happens only if all the validation rules pass. A boolean flag (TRUE or FALSE) can make a failing validation rule stop the engine. This flag is set to false by default, allowing the engine to report errors without stopping.

2. **Translation -** The source values are translated to the target values by the translation rule (one per target attribute).

Translation tables have one row per target attribute and they must contain these seven columns:

 1. **rule_id** - Incremental unique integer identifier used for ordering target attributes in target table.
 2. **targetAttribute** - The name of the target attribute to be created in the target table.
 3. **targetAttributeType** - The data type of the target attribute.
 4. **validationRules** - A semicolon separated list of validation rules needed to validate the source values before translating.
 5. **translationRules** - The translation rule to convert source values to target values.
 6. **description** - A text description of the translation taking place.
 7. **descUpToDateWithRules** - A boolean describing whether the translation rules are up to date with the description. This allows non-technical users to propose translations using the description column. Once the described translation has been applied throughout the table this attribute should be set to TRUE.
 
* Multiple validation rules can be seperated with a semi-colon.
* Error codes, to be returned by the engine if validation rules return FALSE, should follow a vertical bar ('|') after the list of helper function parameters (e.g. notNull(sp1_per|-8888)). Validation error codes are always required and must be of the same type as the target attribute. Error codes can optionally be provided for translation functions too. If the translation helper function returns NULL following a processing error, the engine will return the user provided error code, or the default values of 'TRANSLATION_ERROR' for text types or -3333 for numeric types.
* It is possible to configure the engine to stop on any validation or translation error. 

Translation tables are themselves validated by the translation engine while processing the first source row. Any error in the translation table stops the validation/translation process with a message explaining the problem. The engine checks that:

* no null values exists (all cells must have a value),
* target attribute names do not contain invalid characters (e.g. spaces or accents),
* target attribute types are valid PostgreSQL types (integer, text, boolean, etc...),
* helper functions for validation and translation rules exist and have the propre number of parameters and types,
* the flag indicating if the description is in sync with the validation/translation rules is set to TRUE,
* the return type of the translation functions match the targetAttributeType specified in the translation table.

**Example translation table**

The following translation table defines a target table composed of two columns: "SPECIES_1" of type text and "SPECIES_1_PER" of type integer.

The source attribute "sp1" is validated by checking it is not null, and that it matches a value in the specified lookup table. This is done using the notNull() and the matchTab() [helper functions](#helper-functions) described further in this document. If all validation tests pass, "sp1" is then translated into the target attribute "SPECIES_1" using the lookup table named "species_lookup". If the first validation rules fails, the "NULL" string is returned instead. If the first rule passes but the second validation rule fails, the "NOT_IN_SET" string is returned.

Similarly, the source attribute "sp1_per" is validated by checking it is not null, and that it falls between 0 and 100. It is then translated by simply copying the value to the target attribute "SPECISE_1_PER". "-8888", an integer error code, is returned if the first rule fails. "-9999" is returned if the second validation rule fails.

A textual description of the rules is provided and the flag indicating that the description is in sync with the rules is set to TRUE.

| rule_id | targetAttribute | targetAttributeType | validationRules | translationRules | description | descUpToDateWithRules |
|:--------|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|1        |SPECIES_1        |text                 |notNull(sp1\|NULL); matchTable(sp1,'public','species_lookup'\|NOT_IN_SET)|lookupText(sp1, 'public', 'species_lookup', 'targetSp')|Maps source value to SPECIES_1 using lookup table|TRUE|
|2        |SPECIES_1_PER    |integer              |notNull(sp1_per\|-8888); between(sp1_per,'0','100'\|-9999)|copyInt(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|
 
# How to actually translate a source table?

The translation is done in two steps:

**1. Prepare the translation function**

```sql
SELECT TT_Prepare(translationTableSchema, translationTable);
```

It is necessary to dynamically prepare the actual translation function because PostgreSQL does not allow a function to return an arbitrary number of columns of arbitrary types. The translation function prepared by TT_Prepare() has to explicitly declare what it is going to return at declaration time. Since every translation table can get the translation function to return a different set of columns, it is necessary to define a new translation function for every translation table. This step is necessary only when a new translation table is being used, when a new attribute is defined in the translation table, or when a target attribute type is changed.

When you have many tables to translate into a commun table, and hence many translation tables, you normally want all the target tables to have the same schema (same number of attributes, same attribute names, same attribute types). To make sure your translation tables all produce the same schema, you can reference another translation table (generally the first one) when preparing them. TT_Prepare() will compare all attributes from the current translation table with the attributes of the reference translation table and report any difference. Here is how to reference another translation table when invoquing TT_Prepare():

```sql
SELECT TT_Prepare(translationTableSchema, translationTable, fctNameSuffix, refTranslationTableSchema, refTranslationTable);
```


**2. Translate the table with the prepared function**

```sql
CREATE TABLE target_table AS
SELECT * FROM TT_Translate(sourceTableSchema, sourceTable);
```

The TT_Translate() function returns the translated target table. It is designed to be used in place of any table in an SQL statement.

By default the prepared function will always be named TT_Translate(). If you are dealing with many tranlation tables at the same time, you might want to prepare a translation function for each of them. You can do this by adding a suffix as the third parameter of the TT_Prepare() function (e.g. TT_Prepare('public', 'translation_table', '_02') will prepare the TT_Translate_02() function). You would normally provide a different suffix for each of your translation tables.

If your source table is very big, we suggest developing and testing your translation table on a random sample of the source table to speed up the create, edit, test, generate process. Future releases of the framework will provide a logging and a resuming mechanism which will ease the development of translation tables.

# How to control errors, warnings and logging?

**Errors -** Two types of error can stop the engine: 1) invalid translation rules in the translation table and 2) errors generated during helper function execution. The first case will always happen at the very beginning of a translation and will unconditionally stop the engine with a meaningful error message. This could be due to the translation table refering a helper function that doesn't exist, specifying an incorrect number of parameters, passing a badly formed parameter (e.g. '1a' as integer) or using a helper function returning a type different than what is specified as the targetAttributeType. It is up to the writer of the translation file to fix the translation table to avoid these errors. The second case is usually due to source value that cannot be or are badly handled by the specified translation helper function (e.g. a NULL value). It might happen at any moment during the translation, even after hours. This is why you can control if the engine should stop or not with the 'stopOnTranslationError' TT_Translate() parameter. If 'stopOnTranslationError' is set to FALSE (default behavior), the engine will log this type of error every time it encounters one, but will not stop the engine. These errors can often be avoided by catching them with a proper validation rule (e.g. notNull()).

**Invalidation warnings -** Invalidation warnings happen when a source value gets invalidated by a validation rule. You can control if the engine should stop as soon as this happens with the 'stopOnInvalidSource' TT_Translate() parameter. If 'stopOnInvalidSource' is set to FALSE (default behavior), the engine will log these warnings in the log table. You can therefore translate a source table in its entirety (which can takes hours or days) without errors and get a final report of invalidated values only at the end of the whole process. You can then fix the source table or the translation table accordingly and restart the translation process.

At the beginning of the process of writing a translation table, you can also set 'stopOnTranslationError' or 'stopOnInvalidSource' to TRUE in order to implement a faster "write, test, fix, retest" cycle. Two translation scenarios are possible in this case:

**Scenario 1: Fixing values directly at the source  -** In a scenario where you are fixing the source data, you would repeat this cycle until all source values pass the validation rules and you could hence leave the 'stopOnTranslationError' and the 'stopOnInvalidSource' TT_Translate() parameters to TRUE until completion of the translation. When all source values are fixed and pass every validation rules, the engine would not stop anymore.

**Scenario 2: Fixing the translation file -** In an alternative scenario in which you do not want to modify the source table and prefer the engine to replace invalid values with custom error values (defined in the translation table), leaving TT_Translate() 'stopOnInvalidSource' to TRUE would stop the engine every time a source value is invalidated and prevent you to move forward with the translation table. This is not optimal. In this scenario it is preferable to keep the TT_Translate() 'stopOnInvalidSource' parameter to FALSE and to set 'stopOnInvalid' directly in the translation table by adding 'TRUE' right after the validation rule error code. e.g. "notNull(attribute|ERROR_CODE, TRUE)". When you are happy with the validation rules and error codes set for an attribute, you can just remove the 'TRUE' for this attribute and the engine will not stop anymore when invalidation occurs. It will replace the value with the error code instead and log the invalidation in the log table. You can then set 'TRUE' for a next attribute validation rule and go on until you are happy with all the validation rules and error codes.

**Logging -** Logging is activated as soon as you provide the name of a unique ID column for the source table as the third parameter to your TT_Translate() function:

```sql
CREATE TABLE target_table AS
SELECT * FROM TT_Translate(sourceTableSchema, sourceTable, sourceRowIdColumn);
```

A logging table has the following attributes:

1. **logid** - Incremental unique integer identifier of the log entry.
2. **logtime** - Date and hour stamp  of the log entry.
3. **logtype** - 'PROGRESS', 'INVALID_VALUE' or 'TRANSLATION_ERROR'.
4. **firstrowid** - In the case of a group of matching entries, the first source row ID of the group.
5. **message** - Detailed logging message.
6. **currentrownb** - Number of the row being processed when this log entry was created. Different from 'firstrowid' which is an identifier.
7, **count** - Number of rows pertaining to this log entry group. Equal to logFrequecy for 'PROGRESS' entries. Equal to the number of identical invalidations or errors for 'INVALID_VALUE' and 'TRANSLATION_ERROR' entries.

The 'sourceRowIdColumn' parameter is necessary for logging to be enabled. It is used by the logging system to identify, in the 'firstrowid' column, the first source table row having triggered this type of log entry. If 'sourceRowIdColumn' is not provided, logging is disabled.

Invalidation and translation errors can happen millions of time in some translation projects. Log entries of of the same type are grouped together in order to avoid generating a huge number of identical rows in the log table. The 'count' attribute of the logging table reflects the number of time an identical error has happened during the translation process. By default the logging system will log only the first 100 entries of the same type. You can change this behavior by adding the 'dupLogEntriesHandling' parameter to TT_Translate() specifying how to handle duplicate log entries. "ALL_GROUPED" will log all entries (not only the first 100 ones) grouped together. It is the slowest option. "ALL_OWN_ROW" will log each entry into its own row. It is the fastest option but it might result in a huge number of rows in the logging table. Between these two options, you can instead specify a maximum number of entries per similar invalid rows as a single quoted integer. The default value for 'dupLogEntriesHandling' is '100'.

Logging tables are created beside the translation table for which the translation function was created (with TT_Prepare()). They have the same name as the translation table but with the '_log_00X' suffix.

By default, every time you execute the translation function, a new log table is created with an incremental name. You can change this behavior by settting the TT_Translate() 'incrementLog' parameter to FALSE. In this case the log table number '001' will be created or overwritten if it already exists. When 'incrementLog' is set to TRUE, it's default value, and you execute TT_Translate() often, you will end up with many log tables. You can list the last one using the TT_ShowLastLog() function:

```sql
SELECT * FROM TT_ShowLastLog(translationTableSchema, translationTable);
```

If you produced many log tables but are still interested in listing a specific one, you can provide it's number with the 'logNb' argument to TT_ShowLastLog().

You can delete all log tables associated with a translation table with the TT_DeleteAllLogs() function:

```sql
SELECT TT_DeleteAllLogs(translationTableSchema, translationTable);
```

You can delete all log tables in the schema if you omit the 'translationTable' parameter.

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
       'notNull(sp1|NULL);matchTable(sp1,'public','species_lookup'|NOT_IN_SET)' AS validationRules, 
       'lookupText(sp1, 'public', 'species_lookup', 'targetSp')' AS translationRules, 
       'Maps source value to SPECIES_1 using lookup table' AS description, 
       TRUE AS descUpToDateWithRules
UNION ALL
SELECT 2, 'SPECIES_1_PER', 
          'integer', 
          'notNull(sp1_per|-8888);between(sp1_per,'0','100'|-9999)', 
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

Run the translation engine by providing the schema and translation table names to TT_Prepare, and the source table schema, source table name and source column ID name to TT_Translate.
```sql
SELECT TT_Prepare('public', 'translation_table');

CREATE TABLE target_table AS
SELECT * FROM TT_Translate('public', 'source_example', 'ID');
```

Since you provided a unique identifier column name, a log was generated. You can then check this log like this:

```sql
SELECT * FROM TT_ShowLastLog('public', 'translation_table');
```

# Main Translation Functions Reference
Two groups of function are of interest here:

* functions associated with the translation process: TT_Prepare(), TT_Translate() and TT_DropAllTranslateFct().
* functions useful to work with logging tables: TT_ShowLastLog() and TT_DeleteAllLogs().

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
                         *name* **sourceTable**,  
                         *name* **sourceRowIdColumn**[default NULL],  
                         *boolean* **stopOnInvalidSource**[default FALSE],  
                         *boolean* **stopOnTranslationError**[default FALSE],  
                         *text* **dupLogEntriesHandling**[default '100'],  
                         *int* **logFrequency**[default 500],  
                         *boolean* **incrementLog**[default TRUE],  
                         *boolean* **resume**[default FALSE],  
                         *boolean* **ignoreDescUpToDateWithRules**[default FALSE]  
                         **)**
    * Prepared translation function translating a source table according to the content of a translation table. Logging is activated by providing a 'sourceRowIdColumn'. Log entries of type 'PROGRESS' happen every 'logFrequency' rows. Log entries of type 'INVALID_VALUES' and 'TRANSLATION_ERROR' are grouped according to 'dupLogEntriesHandling' which can be 'ALL_GROUPED', 'ALL_OWN_ROW' or an single quoted integer specifying the maximum nomber of similar entry to log in the same row. Logging table name can be incremented or overwrited by setting 'incrementLog' to TRUE or FALSE. Translation can be stopped by setting 'stopOnInvalidSource' or 'stopOnTranslationError' to TRUE. When 'ignoreDescUpToDateWithRules' is set to FALSE, the translation engine will stop as soon as one attribute's 'descUpToDateWithRules' is marked as FALSE in the translation table. 'resume' is yet to be implemented.
    * e.g. SELECT TT_TranslateSuffix('source', 'ab16', 'ogc_fid', FALSE, FALSE, 200);

* **TT_DropAllTranslateFct**()
    * Delete all translation functions prepared with TT_Prepare().
    * e.g. SELECT TT_DropAllTranslateFct();

* **TT_ShowLastLog(**  
                 *name* **schemaName**,  
                 *name* **tableName**,  
                 *text* **logNb**[default NULL]  
                 **)**
    * Display the last log table generated after using the provided translation table or the one corresponding to the provided 'logNb'.
    * e.g. SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_lyr', 1); 

* **TT_DeleteAllLogs(**  
                      *name* **schemaName**,  
                      *name* **tableName**  
                      **)**
    * Delete all logging table associated with the specified translation table.
    * e.g. SELECT TT_DeleteAllLog('translation', 'ab06_avi01_lyr');

# Helper Function Syntax and Reference
Helper functions are used in translation tables to validate and translate source values. When the translation engine encounters a helper function in the translation table, it runs that function with the given parameters.

Helper functions are of two types: validation helper functions are used in the **validationRules** column of the translation table. They validate the source values and always return TRUE or FALSE. If multiple validation helper functions are provided they should be seperated by semi colons, they will run in order from left to right. If a validation fails, an error code is returned. If all validations pass, the translation helper function in the **translationRules** column is run. Only one translation function can be provided per row. Translation helper functions take a source value as input and return a translated target value for the target table. Translation helper functions can optionally include a user defined error code.

Helper functions are generally called with the names of the source value attributes to validate or translate as the first arguments, and some other fixed arguments controling other aspects of the validation and translation process. 

Helper function parameters are grouped into three classes, each of which have a different syntax in the translation table:

**1. Strings**
  * Any arguments wrapped in single or double quotes is interpreted by the engine as a string and passed as-is to the helper function.
    * e.g. CopyText('a string')
    * This would simply return the string 'a string' for every row in the translation.
  * Strings can contain any characters, and escaping of single quotes is supported using \\'.
    * e.g. CopyText('string\\'s')
  * Empty strings can be passed as arguments using '' or "".
  * Since helper functions only accept arguments as type text, any numeric or boolean values should also be input as strings. The helper function will convert them to the correct type when it runs (e.g. Between(percent_column, '0', '100', 'TRUE', 'TRUE')).

**2. Source table column names**
  * Any word not wrapped in quotes is interpreted as a column name.
  * Column names can include "\_" and "-" but no other special characters and no spaces are allowed. Invalid column names stop the engine.
  * When the engine encounters a valid column name, it searches the source table for that column and returns the corresponding value for the row being processed. This value is then passed as an argument to the helper function.
    * e.g. CopyText(column_A)
    * This would return the text value from column_A in the source table for each row being translated.
  * If the column name is not found as a column in the source table, it is processed as a string.
  * Note that the column name syntax only applies to columns in the source table. Any arguments specifying columns in lookup tables for example should be provided as strings, as demonstrated in the example table above for lookupText(sp1, 'public', 'species_lookup', 'targetSp'). This function is using the row value from the source table column sp1, and returning the corresponding value from the targetSp column in the public.species_lookup table.

**3. String lists**
  * Some helper functions can take a variable number of inputs. Concatenation functions are an example.
  * Since the helper functions need to receive a fixed number of arguments, when variable numbers of input values are required they are provided as a comma separated string list of values wrapped in '{}'.
  * String lists can contain both strings and column names following the rules described above.
  * e.g. Concat({column_A, column_B, 'joined'}, '-')
    * the Concat function takes two arguments, a comma separated list of values that we provide inside {}, and a separator character.
    * This example would concatenate the values from column_A and column_B, followed by the string 'joined' and separated with '-'. If row 1 had values of 'one' and 'two' for column_A and column_B, the string 'one-two-joined' would be returned.

One feature of the translation engine is that the return type of a translation function must be of the same type as the target attribute type defined in the **targetAttributeType** column of the translation table. This means some translation functions have multiple versions that each return a different type (e.g. CopyText, CopyDouble, CopyInt). More specific versions (e.g. CopyDouble, CopyInt) are generally implemented as wrappers around more generic versions (e.g. CopyText).

Some validation helper functions have an optional 'acceptNull' parameter which returns TRUE if the source value is null. This allows multiple validation functions to be strung together in cases where the value to be evaluated could occur in one of multiple columns. For example, consider a translation that uses two text columns named col1 and col2. Only one of these columns should have a value, and the value should be either 'A' or 'B'. We can validate this using the following validation rules:

CountNotNull({col1, col2}, 1|NULL_ERROR); MatchList(col1, {'A', 'B'}, acceptNull=TRUE|NOT_IN_SET); MatchList(col2, {'A', 'B'}, acceptNull=TRUE|NOT_IN_SET)

  * CountNotNull checks that exactly one value is not null and returns the NULL_ERROR if the test fails.
    * Note that the order of these tests is important. We need to check for nulls before checking values are in the list.
  * Now we know that col1 and col2 contain one value and one null. We want to test the value using MatchList and ignore the null. We test col1 and col2 using MatchList. The column with the value will be evaluated by MatchList, the column with the NULL will be ignored (i.e. the acceptNull parameter will cause TRUE to be returned). Note that if acceptNull was set to FALSE, the null value would trigger a FALSE to be returned which would fail the validation and return the NOT_IN_SET error. This is not the desired behaviour for this case.

# Provided Helper Functions
## Validation Functions

* **NotNull**(*stringList* **srcVal**)
    * Returns TRUE if all srcVal's are not NULL. Returns FALSE if any srcVal is NULL. Paired with most translation functions to make sure input values are available. Can use single or multiple srcVal's.
    * e.g. NotNull('a')
    * e.g. NotNull({'a', 'b', 'c'})

* **IsNull**(*stringList* **srcVal**)
    * Returns TRUE if all srcVal's are NULL. Returns FALSE if any srcVal is not NULL. Paired with some complex translation functions dependant on multiple columns. Can use single or multiple srcVal's.
    * e.g. IsNull('a')
    * e.g. IsNull({'a', 'b', 'c'})

* **NotEmpty**(*text* **srcVal**)
    * Returns TRUE if srcVal is not empty string. Returns FALSE if srcVal is an empty string or padded spaces (e.g. '' or '  ') or NULL. Paired with translation functions accepting text strings (e.g. CopyText())
    * e.g. NotEmpty('a')

* **IsInt**(*text* **srcVal**, *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if srcVal represents an integer (e.g. '1.0', '1'). Returns FALSE is srcVal does not represent an integer (e.g. '1.1', '1a'), or if srcVal is NULL. Paired with translation functions that require integer inputs (e.g. CopyInt).
    * e.g. IsInt('1')

* **IsNumeric**(*text* **srcVal**, *boolean* **acceptNull**\[default TRUE\]) 
    * Returns TRUE if srcVal can be cast to double precision (e.g. '1', '1.1'). Returns FALSE if srcVal cannot be cast to double precision (e.g. '1.1.1', '1a'), or if srcVal is NULL. Paired with translation functions that require numeric inputs (e.g. CopyDouble()).
    * e.g. IsNumeric('1.1')
   
* **IsBetween**(*numeric* **srcVal**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if srcVal is between min and max. FALSE otherwise.
    * includeMin and includeMax default to TRUE and indicate whether the acceptable range of values should include the min and max values. Must include both or neither includeMin and includeMax.
    * e.g. IsBetween(5, 0, 100, TRUE, TRUE)
          
* **IsGreaterThan**(*numeric* **srcVal**, *numeric* **lowerBound**, *boolean* **inclusive**\[default TRUE\], *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if srcVal >= lowerBound and inclusive = TRUE or if srcVal > lowerBound and inclusive = FALSE. Returns FALSE otherwise or if srcVal is NULL.
    * e.g. IsGreaterThan(5, 0, TRUE)

* **IsLessThan**(*numeric* **srcVal**, *numeric* **upperBound**, *boolean* **inclusive**\[default TRUE\], *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if srcVal <= lowerBound and inclusive = TRUE or if srcVal < lowerBound and inclusive = FALSE. Returns FALSE otherwise or if srcVal is NULL.
    * e.g. IsLessThan(1, 5, TRUE)

* **IsUnique**(*text* **srcVal**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *int* **occurences**\[default 1\], *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if number of occurences of srcVal in source_val column of lookupSchemaName.lookupTableName equals occurences. Useful for validating lookup tables to make sure srcVal only occurs once for example. Often paired with LookupText(), LookupInt(), and LookupDouble().
    * e.g. IsUnique('TA', public, species_lookup, 1)

* **MatchTable**(*text* **srcVal**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *boolean* **ignoreCase**\[default TRUE\], *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if srcVal is present in the source_val column of lookupSchemaName.lookupTableName. Ignores letter case if ignoreCase = TRUE.
    * e.g. TT_MatchTable('sp1', public, species_lookup, TRUE)

* **MatchList**(*text* **srcVal**, *stringList* **lst**, *boolean* **ignoreCase**\[default TRUE\], *boolean* **acceptNull**\[default TRUE\])
    * Returns TRUE if srcVal is in lst. Ignores letter case if ignoreCase = TRUE.
    * e.g. Match('a', '{'a','b','c'}', TRUE)

* **False**()
    * Returns FALSE. Useful if all rows should contain an error value. All rows will fail so translation function will never run. Often paired with translation functions NothingText(), NothingInt(), and NothingDouble().
    * e.g. False()

* **True**()
    * Returns TRUE. Useful if no validation function is required. The validation step will pass for every row and move on to the translation function.
    * e.g. True()
    
* **NotNullEmptyOr**(*stringList* **srcVal**)
    * Return TRUE if at least one value is not NULL or empty strings.
    * Return FALSE if all values are NULL or empty strings.
    * e.g. NotNullEmptyOr('{'a','','NULL'}')
 
 * **IsIntSubstring**(*text* **srcVal**, *int* **star_char**, *int* **for_length**, *boolean* **acceptNull**\[default TRUE\])
    * Takes a substring of a text string and tests using IsInt().
    * e.g. IsIntSubstring('2001-01-01', 1, 4)
 
  * **IsBetweenSubstring**(*text* **srcVal**, *int* **star_char**, *int* **for_length**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **acceptNull**\[default TRUE\])
    * Takes a substring of a text string and tests using IsBetween().
    * e.g. IsBetweenSubstring('2001-01-01', 1, 4, 1900, 2100, TRUE, TRUE)
    
* **GeoIsValid**(*geometry* **geom**, *boolean* **fix**\[default TRUE\])
    * Returns TRUE if geometry is valid. If fix is TRUE and geometry is invalid, function will attempt to make a valid geometry and return TRUE if successful. If geometry is invalid returns FALSE. Note that using fix=TRUE does not fix the geometry in the source table, it only tests to see if the geometry can be fixed.
    * e.g. GeoIsValid(POLYGON, TRUE)
    
* **GeoIntersects**(*geometry* **geom**, *text* **intersectSchemaName**\[default public\], *text* **intersectTableName**, *geometry* **geomCol**\[default geom\])
    * Returns TRUE if geom intersects with any features in the intersect table. Otherwise returns FALSE. Invalid geometries are validated before running the intersection test.
    * e.g. GeoIntersects(POLYGON, public, intersect_tab, intersect_geo)
      
## Translation Functions

* **CopyText**(*text* **srcVal**)
    * Returns srcVal as text without any transformation.
    * e.g. CopyText('sp1')
      
* **CopyDouble**(*numeric* **srcVal**)
    * Returns srcVal as double precision without any transformation.
    * e.g. CopyDouble(1.1)

* **CopyInt**(*integer* **srcVal**)
    * Returns srcVal as integer without any transformation.
    * e.g. CopyInt(1)
      
* **LookupText**(*text* **srcVal**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupCol**, *boolean* **ignoreCase**\[default TRUE\])
    * Returns text value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column.
    * e.g. LookupText('sp1', public, species_lookup, targetSp, TRUE)
      
* **LookupDouble**(*text* **srcVal**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupCol**, *boolean* **ignoreCase**\[default TRUE\])
    * Returns double precision value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column.
    * e.g. LookupDouble(5.5, public, species_lookup, sp_percent, TRUE)

* **LookupInt**(*text* **srcVal**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupCol**, boolean **ignoreCase**\[default TRUE\])
    * Returns integer value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column.
    * e.g. Lookup(20, public, species_lookup, sp_percent, TRUE)

* **MapText**(*text* **srcVal**, *stringList* **lst1**, *stringList* **lst2**, *boolean* **ignoreCase**\[default TRUE\])
    * Return text value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','{'A','B','C'}','{'D','E','F'}', TRUE)
      
* **MapDouble**(*text* **srcVal**, *stringList* **lst1**, *stringList* **lst2**, *boolean* **ignoreCase**\[default TRUE\])
    * Return double precision value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. MapDouble('A','{'A','B','C'}','{'1.1','1.2','1.3'}', TRUE)
      
* **MapInt**(*text* **srcVal**, *stringList* **lst1**, *stringList* **lst2**, *boolean* **ignoreCase**\[default TRUE\])
    * Return integer value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','{'A','B','C'}','{'1','2','3'}', TRUE)
      
* **Length**(*text* **srcVal**)
    * Returns the length of the srcVal string.
    * e.g. Length('12345')

* **Pad**(*text* **srcVal**, *int* **targetLength**, *boolean* **trunc**\[default TRUE\])
    * Returns a string of length targetLength made up of srcVal preceeded with padChar if source value length < targetLength. Returns srcVal trimmed to targetLength if srcVal length > targetLength and trunc = TRUE. Returns srcVal if srcVal length > targetLength and trunc = FALSE. 
    * e.g. Pad('tab1', 10, x, TRUE)

* **Concat**(*stringList* **srcVal**, *text* **separator**)
    * Returns a string of concatenated values, interspersed with a separator. srcVal takes a string list of column names and/or values. 
    * e.g. Concat('{'str1','str2','str3'}', '-')

* **PadConcat**(*stringList* **srcVals**, *stringList* **lengths**, *stringList* **pads**, *text* **separator**, *boolean* **upperCase**, *boolean* **includeEmpty**\[default TRUE\])
    * Returns a string of concatenated values, where each value is padded using **Pad()**. Inputs for srcVals, lengths, and pads are comma separated strings where the ith length and pad values correspond to the ith srcVal. If upperCase is TRUE, all characters are converted to upper case, if includeEmpty is FALSE, any empty strings in the srcVals are dropped from the concatenation. 
    * e.g. PadConcat('str1,str2,str3', '5,5,7', 'x,x,0', '-', TRUE, TRUE)

* **NothingText**()
    * Returns NULL of type text. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **targetAttributeType**.
    * e.g. NothingText()

* **NothingDouble**()
    * Returns NULL of type double precision. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **targetAttributeType**.
    * e.g. NothingDouble()

* **NothingInt**()
    * Returns NULL of type integer. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **targetAttributeType**.
    * e.g. NothingInt()

* **GeoIntersectionText**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *text* **returnCol**, *text* **method**)
    * Returns a text value from an intersecting polygon. If multiple polygons intersect, the value from the polygon with the largest area can be returned by specifying method='GREATEST_AREA'; the lowest intersecting value can be returned using method='LOWEST_VALUE', or the highest value can be returned using method='HIGHEST_VALUE'. The 'LOWEST_VALUE' and 'HIGHEST_VALUE' methods only work when returnCol is numeric.
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, TYPE, GREATEST_AREA)
    
* **GeoIntersectionDouble**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *numeric* **returnCol**, *text* **method**)
    * Returns a double precision value from an intersecting polygon. Parameters are the same as **GeoIntersectionText**.
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, LENGTH, HIGHEST_VALUE)

* **GeoIntersectionInt**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *numeric* **returnCol**, *text* **method**)
    * Returns an integer value from an intersecting polygon. Parameters are the same as **GeoIntersectionText**.
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, YEAR, LOWEST_VALUE)

* **GeoMakeValid**(*geometry* **geom**)
    * Returns a valid geometry column. If geometry cannot be validated, returns NULL.
    * e.g. GeoMakeValid(POLYGON)

# Adding Custom Helper Functions
Additional helper functions can be written in PL/pgSQL. They must follow the following conventions:

  * **Namespace -** All helper function names must be prefixed with "TT_". This is necessary to create a restricted namespace for helper functions so that no standard PostgreSQL functions (which do not necessarily comply to the following conventions) can be used. This prefix must not be used when referring to the function in the translation file.
  * **Parameter Types -** All helper functions (validation and translation) must accept only text parameters (the engine converts everything to text before calling the function). This greatly simplifies the development of helper functions and the parsing and validation of translation files.
  * **Variable number of parameters -** Helper functions should NOT be implemented as VARIADIC functions accepting an arbitrary number of parameters. If an arbitrary number of parameters must be supported, it should be implemented as a list of text values separated by a comma. This is to avoid the hurdle of finding, when validating the translation file, if the function exists in the PostgreSQL catalog. Note that when passing arguments from the translation table to the helper functions, the engine strips the '{}' from any argument lists. So helper functions of this type need only process the comma separated list of values.
  * **Default value -** Helper functions should NOT use DEFAULT parameter values. The catalog needs to contain explicit helper function signatures for all functions it could receive. If signatures with default parameter are required, a separate function signature should be created as a wrapper around the function supporting all the parameters. This is to avoid the hurdle of finding, when validating the translation file, if the function exists in the PostgreSQL catalog.
  * **Polymorphic translation functions -** If a translation helper function must be written to return different types (e.g. int and text), as many different functions with corresponding names must be written (e.g. TT_CopyInt() and TT_CopyText()). The use of the generic "any" PostgreSQL type is forbidden. This ensures that the engine can explicitly know that the translation function returns the correct type.
  * **Error handling -** All helper functions (validation and translation) must raise an exception when parameters other than the source value are NULL or of an invalid type. This is to avoid badly written translation files. All helper functions (validation and translation) should handle any source data values (always passed as text) without failing. This is to avoid crashing of the engine when translating big source files. 
  * **Return value -** 1) Validation functions must always return a boolean. They must handle NULL and empty values and in those cases return the appropriate boolean value. Error codes are provided in the translation file when source values do not fulfill the validation test. 2) Translation functions must return a specific type. For now only "int", "numeric", "text", "boolean" and "geometry" are supported. If any errors happen during translation, the translation function must return NULL and the engine will translate to the generic "TRANSLATION_ERROR" (-3333) code, or a user defined error code if one is provided.

If you think some of your custom helper functions could be of general interest to other users of the framework, you can submit them to the project team. They could be integrated in the helper funciton file.

# Dependency Table Validation
Some helper functions use dependency tables to facilitate validation or translations. Examples include lookup tables for functions such as MatchTable() and LookupText(), and intersect tables for spatial functions such as GeoIntersects() and GeoIntersectionText(). These dependency tables need to be valid in order for the helper functions to work correctly. We can use the validation functionality of the translation engine to achieve this by creating validation-only translation tables. Each row of the validation-only translation table implement one validation rule to be run on the dependency table. For example a validation of an intersect table may be to check that all the geometries are valid. The validation rule for this row would use GeoIsValid(). Since we only care about the validation, we can simply use a translation rule such as copyText('PASS') for each row. When we run the validation-only translation table on the dependency table through the engine, any rows failing a validation will produce an error code, all passing rows will return 'PASS'. We can then fix any invalid rows before running the main translation using the dependency table. An example of a validation-only translation table can be seen in the [CASFRI v5](https://github.com/edwardsmarc/CASFRI/blob/master/dependencyvalidation/tables/ab_photoyear_validation.csv) project.

# Credit
**Pierre Racine** - Center for forest research, University Laval.

**Pierre Vernier** - Database designer.

**Marc Edwards** - SQL programmer.
