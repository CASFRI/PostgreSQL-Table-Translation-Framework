# Introduction
The PostgreSQL Table Translation Framework allows PostgreSQL users to validate and translate a source table into a new target table  using validation and translation rules. This framework simplifies the writing of complex SQL queries attempting to achieve the same goal. It serves as an in-database transform engine in an Extract, Load, Transform (ELT) process (a variant of the popular ETL process) where most of the transformation is done inside the database. Future versions should provide logging and resuming allowing a fast workflow to create, edit, test, and generate translation tables.

The primary components of the framework are:
* The translation engine, implemented as a set of PL/pgSQL functions.
* A set of validation and translation helper functions implementing a general set of validation and translation rules.
* A user produced translation table defining the structure of the target table and all the validation and translation rules.
* Optionally, some user produced value lookup tables that accompany the translation table.

# Directory Structure
<pre>
./             .sql files for loading, testing, and uninstalling the engine and helper functions.

./docs         Mostly development specifications.
</pre>

# Requirements
PostgreSQL 9.6+ and PostGIS 2.3+.

# Version Releases

The framework follows the [Semantic Versioning 2.0.0](https://semver.org/) versioning scheme (major.minor.revision). Increments in revision version numbers are for bug fixes. Increments in minor version numbers are for new features, changes to the helper functions (our API) and bug fixes. Minor version increments will not break backward compatibility with existing translation tables. Increments in major version numbers are for changes that break backward compatibility in the helper functions (meaning users have to make some changes in their translation tables).

The current version is 0.0.2-beta and is available for download at https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/releases/tag/v0.0.2-beta

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
  
**Test**

  In a postgreSQL query tool window, run, in this order, the engineTest.sql file, the helperFunctionsTest.sql file and, if GIS functions are required and PostGIS is installed, the helperFunctionsGIS.sql file. Only failing tests will be displayed.
  
**Uninstallation**

  In a postgreSQL query tool window do: DROP EXTENSION table_translation_framework;


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

A translation table implements two very different steps:

1. **Validation -** Source values are first validated by a set of validation rules which establish the condition for a value to be translated. Translation happens only if all validation rules pass. When a validation rule is not fulfilled (e.g. notNull(attribute)), the translation engine sets the target value to the error code associated with the validation rule instead of the translated value.

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

You can configure the engine to stop and report errors on any validation or translation failure with the appropriate parameter to the TT_Translate() function that is created with your translation table. It is also possible to make the engine to stop on a particular rule by adding the word 'STOP' after the last parameter or after the error code of a rule (e.g. notNull(sp1_per|-8888, STOP)). More on both scenarios below.

A special optional row in the translation table can be defined to determine which rows from the source table must be translated or not. This special row 'target_attribute' must be set to ROW_TRANSLATION_RULE and its validation_rules must be set to a series of validation rules identical to other target attribute validation rules. The row will be translated if and only if at least one ROW_TRANSLATION_RULE 'validation_rules' is validated (like if there was a OR operator between them). Rows not fulfilling any rules from the ROW_TRANSLATION_RULE 'validation_rules' are skipped by the engine and hence, not translated. If no ROW_TRANSLATION_RULE is provided, all rows from the source table are translated. The 'target_attribute_type' and the 'translation_rules' of a ROW_TRANSLATION_RULE line should be set to NA.

Translation tables are themselves validated by the translation engine while processing the first source row. Any error in the translation table stops the validation/translation process with a message explaining the problem. The engine checks that:

* no NULL values exists in the table (all cells must have a value),
* target attribute names do not contain invalid characters (e.g. spaces or accents),
* target attribute types are valid PostgreSQL types (text, integer, double precision, boolean, etc...),
* helper functions for validation and translation rules exist and have the propre number of parameters and types,
* the return type of the translation functions match the target_attribute_type specified in the translation table,
* the flag indicating if the description is in sync with the validation/translation rules is set to TRUE.


**Example translation table**

The following translation table defines a target table composed of two columns: "SPECIES_1" of type text and "SPECIES_1_PER" of type integer.

The ROW_TRANSLATION_RULE special row specifies that only source rows for which the "sp1" attribute is not NULL must be translated. Other source rows (where "sp1" is NULL) must be ignored.

The source attribute "sp1" is validated by checking it is not NULL and that it matches a value in the specified lookup table. This is done using the notNull() and the matchTab() [helper functions](#helper-functions) described further in this document. If all validation tests pass, "sp1" is then translated into the target attribute "SPECIES_1" using the lookupText() helper function. This function uses the "species_lookup" column from the "species_lookup" lookup table located in the "public" schema to map the source value to the target value.

If the first notNull() rules fails, this function's default text error code ('NULL_VALUE') is returned instead of the translated value. In this example, this rule will also make the engine to STOP if "sp1" is NULL. If the first rule passes but the second validation rule fails, the 'INVALID_SPECIES' error code is returned, overwriting the matchTable() default error code (NOT_IN_SET). 

Similarly, in the second row of the translation table, the source attribute "sp1_per" is validated by checking it is not NULL and that it falls between 0 and 100. The engine will STOP if "sp1_per" is NULL. It is then translated by simply copying the value to the target attribute "SPECIES_1_PER". '-8888', the default integer error code for notNull(), equivalent to 'NULL_VALUE' for text attributes, is returned if the first rule fails. '-9999' is returned if the second validation rule fails.

A textual description of the rules is provided and the flag indicating that the description is in sync with the rules is set to TRUE.

| rule_id | target_attribute | target_attribute_type | validation_rules | translation_rules | description | desc_uptodate_with_rules |
|:--------|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|0        |ROW_TRANSLATION_RULE        |NA                 |notNull(sp1) |NA |Translate row only when sp1 is not NULL|TRUE|
|1        |SPECIES_1        |text                 |notNull(sp1\|STOP); matchTable(sp1,'public','species_lookup'\|INVALID_SPECIES)|lookupText(sp1, 'public', 'species_lookup', 'target_sp')|Maps source value to SPECIES_1 using lookup table|TRUE|
|2        |SPECIES_1_PER    |integer              |notNull(sp1_per\|STOP); between(sp1_per,'0','100')|copyInt(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|
 
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

If your source table is very big, we suggest developing and testing your translation table on a random sample of the source table to speed up the create, edit, test, generate process. You should also enable logging as described in the following section.

# How to control errors, warnings and logging?

Two types of error can stop the engine during a translation process:

**1) Translation table syntax errors -** Any syntax error in the translation table will make the engine to stop at the very beginning of a translation process with a meaningful error message. This could be due to the translation table refering a non-existing helper function, specifying an incorrect number of parameters, refering to a non-existing source value, passing a badly formed parameter (e.g. '1a' as integer) or using a helper function returning a type different than what is specified as the 'target_attribute_type'. It is up to the writer of the translation table to avoid and fix these errors. 

**2) Helper function errors -**  The second case is usually due to source value that cannot be or are badly handled by the specified translation helper function (e.g. a NULL value). It might happen at any moment during the translation, even after hours. This is why you can control if the engine should stop or not with the "stopOnTranslationError" TT_Translate() parameter. If "stopOnTranslationError" is set to FALSE (default behavior), the engine will log these errors every time it encounters one instead of stopping. These errors can often be avoided by catching them with a proper validation rule (e.g. notNull()).

**Invalidation warnings -** Invalidation warnings happen when a source value gets invalidated by a validation rule. You can control if they should stop the engine with the "stopOnInvalidSource" TT_Translate() parameter. If "stopOnInvalidSource" is set to FALSE (default behavior), the engine will log these warnings in the log table instead of stopping. You can therefore translate a source table in its entirety (which can takes hours or days) without errors and get a final report of invalidated values only at the end of the whole process. You can then fix the source table or the translation table accordingly and restart the translation process.

You can also add 'STOP' directly in the translation table helper functions in order to implement a faster "write, test, fix, retest" cycle. 

Here is how to set those stopping parameters in two very different translation scenarios:

**Scenario 1: Fixing values at the source  -** In a scenario where you want to fix the source data in order to have a clean target table without error codes, you must repeat this "modify translation rules, test, fix source table, retest" cycle until all source values pass the validation rules. You can achieve this by setting the "stopOnTranslationError" and the "stopOnInvalidSource" TT_Translate() parameters to TRUE until completion of the translation. When all source values are fixed and pass every validation rules, the engine will not stop anymore.

**Scenario 2: Fixing the translation table -** In a scenario where you do not want to modify the source table and prefer the engine to replace invalid values with error codes (the default ones or the ones defined in the translation table), it is better not to leave TT_Translate() "stopOnInvalidSource" to TRUE. It would stop the engine every time a source value is invalidated and prevent you to move forward with the translation table. In this scenario it is preferable to keep the TT_Translate() "stopOnInvalidSource" parameter to FALSE (it's default value) and add 'STOP' directly in the translation table after the validation rule error code. e.g. "notNull(attribute|ERROR_CODE, STOP)". When you are happy with the validation rules and error codes set for an attribute, you can remove 'STOP' from this rule and the engine will not stop anymore when invalidation occurs. It will write the error code in the target table in place of the translated value and log the invalid value in the log table. You can then set 'STOP' for a next validation rule and go on until you are happy with all the validation rules and error codes.

**Overwriting default error codes -** Default error codes for the provided helper functions are defined in the TT_DefaultErrorCode() function in the helperFunctions.sql file. This function is itself called by the engine TT_DefaultProjectErrorCode() function. You can redefine all default error codes by overwritting the TT_DefaultErrorCode() function or you can redefine only some of them by overwritting the TT_DefaultProjectErrorCode() function (other error codes will still be defined by TT_DefaultErrorCode()). Simply copy the TT_DefaultErrorCode() or the TT_DefaultProjectErrorCode() function in your project and define a error code for each possible types (text, integer, double precision, geometry) for every helper function for which you want to redefine the error code.

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
7. **count** - Number of rows pertaining to this log entry group. Equal to logFrequency for 'PROGRESS' entries. Equal to the number of identical invalidations or errors for 'INVALID_VALUE' and 'TRANSLATION_ERROR' entries.

The "sourceRowIdColumn" parameter is necessary for logging to be enabled. It is used by the logging system to identify, in the "firstrowid" column, the first source table row having triggered this type of log entry. If "sourceRowIdColumn" is not provided, logging is disabled.

Invalidation and translation errors can happen millions of time in some translation projects. Log entries of of the same type are grouped together in order to avoid generating a huge number of identical rows in the log table. The "count" attribute of the logging table reflects the number of time an identical error has happened during the translation process. By default the logging system will log only the first 100 entries of the same type. You can change this behavior by adding the "dupLogEntriesHandling" parameter to TT_Translate() specifying how to handle duplicate log entries. "ALL_GROUPED" will log all entries (not only the first 100 ones) grouped together. It is the slowest option. "ALL_OWN_ROW" will log each entry into its own row. It is the fastest option but it might result in a huge number of rows in the logging table. Between these two options, you can instead specify a maximum number of entries per similar invalid rows as a single quoted integer. The default value for "dupLogEntriesHandling" is '100'.

Logging tables are created beside the translation table for which the translation function was created (with TT_Prepare()). They have the same name as the translation table but with the '_log_00X' suffix.

By default, every time you execute the translation function, a new log table is created with an incremental name. You can change this behavior by settting the TT_Translate() "incrementLog" parameter to FALSE. In this case the log table number '001' will be created or overwritten if it already exists. When "incrementLog" is set to TRUE, it's default value, and you execute TT_Translate() often, you will end up with many log tables. You can list the last one using the TT_ShowLastLog() function:

```sql
SELECT * FROM TT_ShowLastLog(translationTableSchema, translationTable);
```

If you produced many log tables but are still interested in listing a specific one, you can provide it's number with the "logNb" argument to TT_ShowLastLog().

You can delete all log tables associated with a translation table with the TT_DeleteAllLogs() function:

```sql
SELECT TT_DeleteAllLogs(translationTableSchema, translationTable);
```

You can delete all log tables in the schema if you omit the "translationTable" parameter.

# How to write a lookup table?
* Some helper functions (e.g. MatchTable(), LookupText()) allow the use of lookup tables to support mapping between source and target values.
* An example is a list of source value species codes and a corresponding list of target value species names.
* Helper functions using lookup tables will by default look for the source values in the column named "source_val". The LookupText() function will return the corresponding value in the specified column.

Example lookup table. Source values for species codes in the "source_val" column are matched to their target values in the "target_sp_1"  or the "target_sp_2" column.

|source_val|target_sp_1|target_sp_2|
|:---------|:--------|:--------|
|TA        |PopuTrem |POPTRE   |
|LP        |PinuCont |PINCON   |

# A Complete Example
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
       'notNull(sp1|STOP);matchTable(sp1,'public','species_lookup'|INVALID_SPECIES)' AS validation_rules, 
       'lookupText(sp1, 'public', 'species_lookup', 'target_sp')' AS translation_rules, 
       'Maps source value to SPECIES_1 using lookup table' AS description, 
       TRUE AS desc_uptodate_with_rules
UNION ALL
SELECT 2, 'SPECIES_1_PER', 
          'integer', 
          'notNull(sp1_per|STOP);between(sp1_per,'0','100')', 
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
    * Prepared translation function translating a source table according to the content of a translation table. Logging is activated by providing a "sourceRowIdColumn". Log entries of type 'PROGRESS' happen every "logFrequency" rows. Log entries of type 'INVALID_VALUE' and 'TRANSLATION_ERROR' are grouped according to "dupLogEntriesHandling" which can be 'ALL_GROUPED', 'ALL_OWN_ROW' or an single quoted integer specifying the maximum nomber of similar entry to log in the same row. Logging table name can be incremented or overwrited by setting "incrementLog" to TRUE or FALSE. Translation can be stopped by setting "stopOnInvalidSource" or "stopOnTranslationError" to TRUE. When "ignoreDescUpToDateWithRules" is set to FALSE, the translation engine will stop as soon as one attribute's "desc_uptodate_with_rules" is marked as FALSE in the translation table. 'resume' is yet to be implemented.
    * e.g. SELECT TT_TranslateSuffix('source', 'ab16', 'ogc_fid', FALSE, FALSE, 200);

* **TT_DropAllTranslateFct**()
    * Delete all translation functions prepared with TT_Prepare().
    * e.g. SELECT TT_DropAllTranslateFct();

* **TT_ShowLastLog(**  
                 *name* **schemaName**,  
                 *name* **tableName**,  
                 *text* **logNb**[default NULL]  
                 **)**
    * Display the last log table generated after using the provided translation table or the one corresponding to the provided "logNb".
    * e.g. SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_lyr', 1); 

* **TT_DeleteAllLogs(**  
                      *name* **schemaName**,  
                      *name* **tableName**  
                      **)**
    * Delete all logging table associated with the specified translation table.
    * e.g. SELECT TT_DeleteAllLog('translation', 'ab06_avi01_lyr');

# Helper Function Syntax and Reference
Helper functions are used in translation tables to validate and translate source values. When the translation engine encounters a helper function in the translation table, it runs that function with the given parameters.

Helper functions are of two types: validation helper functions are used in the **validation_rules** column of the translation table. They validate the source values and always return TRUE or FALSE. Multiple validation helper functions can be provided by separating them with semi colons. They will run in order from left to right. If a validation fails, an error code is returned. If all validations pass, the translation helper function in the **translation_rules** column is run. Only one translation function can be provided per row. Translation helper functions take a source value as input and return a translated target value for the target table. Translation helper functions can optionally include a user defined error code.

Helper functions are generally called with the names of the source value attributes to validate or translate as the first argument, and some other optional arguments controling  aspects of the validation and translation process. 

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
  * If the column name is not found as a column in the source table, it is processed as a string.
  * Note that the column name syntax only applies to columns in the source table. Any arguments specifying columns in lookup tables for example should be provided as strings, as shown in the example table above for lookupText(sp1, 'public', 'species_lookup', 'target_sp'). This function is using the row value from the source table column sp1, and returning the corresponding value from the "target_sp" column in the public.species_lookup table.

**3. String lists**
  * Some helper functions can take a variable number of inputs. Concatenation functions are an example.
  * Since the helper functions need to receive a fixed number of arguments, when variable numbers of input values are required they are provided as a comma separated string list of values wrapped in '{}'.
  * String lists can contain both basic types and column names following the rules described above.
  * e.g. Concat({column_A, column_B, 'joined'}, '-')
    * The Concat function takes two arguments, a comma separated list of values that we provide inside {}, and a separator character.
    * This example would concatenate the values from column_A and column_B, followed by the string 'joined' and separated with '-'. If row 1 had values of 'one' and 'two' for column_A and column_B, the string 'one-two-joined' would be returned.

One feature of the translation engine is that the return type of a translation function must be of the same type as the target attribute type defined in the **target_attribute_type** column of the translation table. This means some translation functions have multiple versions that each return a different type (e.g. CopyText, CopyDouble, CopyInt). More specific versions (e.g. CopyDouble, CopyInt) are generally implemented as wrappers around more generic versions (e.g. CopyText).

Some validation helper functions have an optional 'acceptNull' parameter which returns TRUE if the source value is NULL. This allows multiple validation functions to be strung together in cases where the value to be evaluated could occur in one of multiple columns. For example, consider a translation depending on two text attributes named col1 and col2, only one of these attribute should have a value, and the value should be either 'A' or 'B'. We can validate this using the following validation rules:

HasCountOfNotNull({col1, col2}, 1|NULL_VALUE_ERROR); MatchList(col1, {'A', 'B'}, acceptNull=TRUE|NOT_IN_SET_ERROR); MatchList(col2, {'A', 'B'}, acceptNull=TRUE|NOT_IN_SET_ERROR)

  * HasCountOfNotNull checks that exactly one value is not NULL and returns the NULL_VALUE_ERROR if the test fails.
    * Note that the order of these tests is important. We need to check for NULLs before checking values are in the list.
  * Once that the fact that col1 and col2 contain one value and one NULL is validated, the first value is tested using MatchList() with the acceptNull parameter set to TRUE in order to validate it even if it's NULL. Then col2 is validated the same way. Both the attribute with the value and the attribute with the NULL will be validated. Note that if acceptNull was set to FALSE, the NULL value would trigger a FALSE to be returned which would invalidate the rule and return acceptNull. This is not the desired behaviour for this case.

# Provided Helper Functions
## Validation Functions

* **NotNull**(*stringList* **srcValList**, *boolean* **any**\[default FALSE\])
    * Returns TRUE if all values in the **srcValList** string list are not NULL. 
    * Paired with most translation functions to make sure input values are available.
    * When **any** is TRUE, returns TRUE if any values in **srcValList** is not NULL.
    * Default error codes are 'NULL_VALUE' for text attributes, -8888 for numeric attributes and NULL for other types.
    * e.g. NotNull('a')
    * e.g. NotNull({'a', 'b', 'c'})
 
* **HasCountOfNotNull**(*stringList* **srcVal1/2/3/4/5/6/7/8/9/10/11/12/13/14/15**, *int* **count**, *exact* **boolean**)
    * Counts the number of non-NULL in the **srcVals[1-15]** string lists using the CountOfNotNull() helper function.
    * Can take between 1 and 15 **srcVal** string lists of input values.
    * When **exact** is TRUE, the number of non-NULLs must matches **count** exactly.
    * When **exact** is FALSE, the number of non-NULLs can be greater than or equal to **count**.
    * Empty strings are treated as NULL.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * e.g. HasCountOfNotNull({'a','b','c'}, {NULL, NULL}, 1, TRUE)
    * There is also a variant of this function called **HasCountOfNotNullOrZero()** which is exactly the same but counts zero values as NULL.

* **HasLength**(*text* **srcVal**, *int* **length**, *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the number of characters in **srcVal** matches **length**.
    * When **acceptNull** is TRUE, NULL **srcVal** values make HasLength() to return TRUE.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * e.g. HasLength('123', 3)

* **NotEmpty**(*text* **srcVal**, *boolean* **any**\[default FALSE\])
    * Returns TRUE if all **srcVal** values are not empty strings. Returns FALSE if any **srcVal** value is an empty string, padded spaces (e.g. '' or '  ') or NULL. Paired with translation functions accepting text strings (e.g. CopyText())
    * When **any** is TRUE, returns TRUE if any **srcVal** value is not an empty strings. 
    * Default error codes are 'EMPTY_STRING' for text attributes, -8889 for numeric attributes and NULL for other types.
    * e.g. NotEmpty('a')

* **IsInt**(*text* **srcVal**, *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** represents an integer (e.g. '1.0', '1'). Returns FALSE is **srcVal** does not represent an integer (e.g. '1.1', '1a'), or if **srcVal** is NULL. Paired with translation functions that require integer inputs (e.g. CopyInt).
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsInt() to return TRUE.
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * e.g. IsInt('1')

* **IsNumeric**(*text* **srcVal**, *boolean* **acceptNull**\[default FALSE\]) 
    * Returns TRUE if **srcVal** can be cast to double precision (e.g. '1', '1.1'). Returns FALSE if **srcVal** cannot be cast to double precision (e.g. '1.1.1', '1a'), or if **srcVal** is NULL. Paired with translation functions that require numeric inputs (e.g. CopyDouble()).
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsNumeric() to return TRUE.
    * Default error codes are 'WRONG_TYPE' for text attributes, -9995 for numeric attributes and NULL for other types.
    * e.g. IsNumeric('1.1')
   
* **IsBetween**(*numeric* **srcVal**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** is between **min** and **max**. FALSE otherwise.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max*. Must include both or neither **includeMin** and **includeMax** parameters.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsBetween() to return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * e.g. IsBetween(5, 0, 100, TRUE, TRUE)
          
* **IsGreaterThan**(*numeric* **srcVal**, *numeric* **lowerBound**, *boolean* **inclusive**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** >= **lowerBound** and **inclusive** = TRUE or if **srcVal** > **lowerBound** and **inclusive** = FALSE. Returns FALSE otherwise or if **srcVal** is NULL.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsGreaterThan() to return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * e.g. IsGreaterThan(5, 0, TRUE)

* **IsLessThan**(*numeric* **srcVal**, *numeric* **upperBound**, *boolean* **inclusive**\[default TRUE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** <= **lowerBound** and **inclusive** = TRUE or if **srcVal** < **lowerBound** and **inclusive** = FALSE. Returns FALSE otherwise or if **srcVal** is NULL.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsLessThan() to return TRUE.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * e.g. IsLessThan(1, 5, TRUE)

* **IsUnique**(*text* **srcVal**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *int* **occurrences**\[default 1\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if number of occurrences of **srcVal** in "source_val" column of **lookupSchemaName**.**lookupTableName** equals **occurrences**. Useful for validating lookup tables to make sure **srcVal** only occurs once for example. Often paired with LookupText(), LookupInt(), and LookupDouble().
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsUnique() to return TRUE.
    * Default error code is 'NOT_UNIQUE' for text attributes and NULL for other types.
    * e.g. IsUnique('TA', public, species_lookup, 1)

* **MatchTable**(*text* **srcVal**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *text* **lookupColumnName**\[default 'source_val'\], *boolean* **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** is present in the **lookupColumnName** column of the **lookupSchemaName**.**lookupTableName** table.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchTable() to return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. looke('sp1', public, species_lookup, TRUE)

* **MatchTableSubstring**(*text* **srcVal**, *integer* **startChar**, *integer* **forLength**, *text* **lookupSchemaName**\[default 'public'\], *text* **lookupTableName**, *text* **lookupColumnName**\[default 'source_val'\], *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if **srcVal** is present in the **lookupColumnName** column of the **lookupSchemaName**.**lookupTableName** table.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchTable() to return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. looke('sp1', public, species_lookup, TRUE)

* **MatchList**(*stringList* **srcVal**, *stringList* **matchList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\], *boolean* **matches**\[default TRUE\], *boolean* **removeSpaces**\[default FALSE\])
    * Returns TRUE if **srcVal** is in **matchList**.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchList() to return TRUE.
    * When **matches** is FALSE, returns FALSE in the case of a match.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing matches.
    * When multiple input values are provided as a string list, they are concatenated before testing for matches.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. MatchList('a', {'a','b','c'})
    * e.g. MatchList({'a', 'b'}, {'ab','bb','cc'})
    
* **NotMatchList**(*text* **srcVal**, *stringList* **matchList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * A wrapper around MatchList() that sets **matches** to FALSE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. NotMatchList('d', '{'a','b','c'}')

* **SumIntMatchList**(*stringList* **srcValList**, *stringList* **matchValList**, *boolean* **acceptNull**\[default FALSE\], *boolean* **matches**\[default TRUE\])
    * Returns TRUE if the sums of the values in the **srcValList** string list matches one of the value provided in the **matchValList** string list using the MatchList() helper function.
    * When **acceptNull** is TRUE, NULL values in **srcValList** make SumIntMatchList() to return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. SumIntMatchList({1,2}, {3, 4, 5})

* **HasCountOfMatchList**(*text* **val1**, *stringList* **matchList1**, *text* **val2**, *stringList* **matchList2**, *text* **val3**, *stringList* **matchList3**, *text* **val4**, *stringList* **matchList4**, *text* **val5**, *stringList* **matchList5**, *text* **val6**, *stringList* **matchList6**, *text* **val7**, *stringList* **matchList7**, *text* **val8**, *stringList* **matchList8**, *text* **val9**, *stringList* **matchList9**, *text* **val10**, *stringList* **matchList10**, *int* **count**, *boolean* **exact**)
    * Runs matchList() for each set of val and matchList.
    * Counts the number of TRUE values returned and compares to the **count**.
    * If exact is TRUE and the number of TRUE matchList results is equal to the **count**, returns TRUE.
    * If exact is FALSE and the number of TRUE matchList results is greater than or equal to the **count**, returns TRUE.
    * e.g. HasCountOfMatchList(a, {a,b}, b, {a,b}, c, {a,c}, 2, TRUE) would return TRUE.

* **False**()
    * Returns FALSE. Useful if all rows should contain an error value. All rows will fail so translation function will never run. Often paired with translation functions NothingText(), NothingInt() and NothingDouble().
    * Default error codes are 'NOT_APPLICABLE' for text attributes, -8887 for numeric attributes and NULL for other types.
    * e.g. False()

* **True**()
    * Returns TRUE. Useful if no validation function is required. The validation step will pass for every row and move on to the translation function.
    * Default error codes are 'NOT_APPLICABLE' for text attributes and -8887 for numeric attributes but are never used since the function always return TRUE.
    * e.g. True()
    
 * **IsIntSubstring**(*text* **srcVal**, *int* **starChar**, *int* **forLength**, *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the substring of **srcVal** starting at character **starChar** for **forLength** is an integer.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsIntSubstring() to return TRUE.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * e.g. IsIntSubstring('2001-01-01', 1, 4)
 
  * **IsBetweenSubstring**(*text* **srcVal**, *int* **star_char**, *int* **for_length**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the **srcVal** substring starting at character **starChar** for **forLength** is between **min** and **max**.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max*. Must include both or neither **includeMin** and **includeMax** parameters.  
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * When **acceptNull** is TRUE, NULL **srcVal** values make IsBetweenSubstring() to return TRUE.
    * Default error codes are 'INVALID_VALUE' for text attributes, -9997 for numeric attributes and NULL for other types.
    * e.g. IsBetweenSubstring('2001-01-01', 1, 4, 1900, 2100, TRUE, TRUE)
    
  * **MatchListSubstring**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *stringList* **matchList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Returns TRUE if the **srcVal** substring starting at character **starChar** for **forLength** is in **matchList**.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * When **acceptNull** is TRUE, NULL **srcVal** values make MatchListSubstring() to return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. MatchListSubstring('2001-01-01', 1, 4, '{'2000', '2001'}')
    
  * **LengthMatchList**(*text* **srcVal**, *stringList* **matchList**, *boolean* **removeSpaces**\[default FALSE\], **ignoreCase**\[default FALSE\], *boolean* **acceptNull**\[default FALSE\])
    * Calculates length of **srcVal** and check that it matches one of the value in **matchList**.
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces before calculating length.
    * When **acceptNull** is TRUE, NULL **srcVal** values make LengthMatchList() to return TRUE.
    * Default error codes are 'NOT_IN_SET' for text attributes, -9998 for numeric attributes and NULL for other types.
    * e.g. LengthMatchList('12345', {5})
    
* **MinIndexNotNull**(*stringList* **intList**, *stringList* **testList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the lowest integer in **intList**. Pass it to NotNull(). 
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested. This behaviour matches MinIndexCopyText(), MinIndexMapText() and MinIndexLookupText().
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs are ignored when calculating the min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * e.g. MinIndexNotNull({1990, 2000}, {burn, wind})
    * e.g. MinIndexNotNull({1990, NULL}, {burn, wind}, 2000, 'NULL')
    
* **MaxIndexNotNull**(*stringList* **intList**, *stringList* **testList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the highest integer in **intList**. Pass it to NotNull(). 
    * When there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested. This behaviour matches MaxIndexCopyText(), MaxIndexMapText() and MaxIndexLookupText(). 
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs are ignored when calculating max value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * e.g. MinIndexNotNull({1990, 2000}, {burn, wind})
    * e.g. MinIndexNotNull({1990, 0}, {burn, wind}, 'NULL', 2000)

* **MinIndexIsInt**(*stringList* **intList**, *stringList* **testList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Same as MinIndexNotNull() but tests the value with IsInt().
    * e.g. MinIndexIsInt({1990, 2000}, {111, 222})
    * e.g. MinIndexIsInt({1990, NULL}, {111, 222}, 2000, 'NULL')
    
* **MaxIndexNotNull**(*stringList* **intList**, *stringList* **testList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Same as MaxIndexNotNull but tests the value with IsInt().
    * e.g. MaxIndexIsInt({1990, 2000}, {111, 222})
    * e.g. MaxIndexIsInt({1990, NULL}, {111, 222}, 2000, 'NULL')

* **MinIndexIsBetween**(*stringList* **intList**, *stringList* **testList**, *numeric* **min**, *numeric* **max**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the lowest integer in **intList**. Pass it to isBetween() along with min and max which are considered inclusive (i.e. the default behavior of isBetween()). 
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested. This behaviour matches MaxIndexCopyText(), MaxIndexMapText() and MaxIndexLookupText(). 
    * When **setNullTo** is provided as an integer, NULLs in intList are replaced with setNullTo. Otherwise NULLs are ignored when calculating min value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * e.g. MinIndexIsBetween({1990, 2000}, {111, 222}, 0, 2000)
    * e.g. MinIndexIsBetween({1990, NULL}, {111, 222}, 0, 2000, 2000, 'NULL')

* **MaxIndexIsBetween**(*stringList* **intList**, *stringList* **testList**, *numeric* **min**, *numeric* **max**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the highest integer in **intList**. Pass it to isBetween() along with min and max which are considered inclusive (i.e. the default behavior of isBetween()). 
    * If there are multiple occurrences of the lowest value, the **last** non-NULL value with an index matching the highest value is tested. This behaviour matches MaxIndexCopyText(), MaxIndexMapText() and MaxIndexLookupText(). 
    * When **setNullTo** is provided as an integer, NULLs in intList are replaced with setNullTo. Otherwise NULLs are ignored when calculating max value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * e.g. MaxIndexIsBetween({1990, 2000}, {111, 222}, 0, 2000)
    * e.g. MaxIndexIsBetween({1990, NULL}, {111, 222}, 0, 2000, 2000, 'NULL')

* **MinIndexMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **returnList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the lowest integer in **intList**. Pass it to MatchList() along with **returnList**. 
    * If there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested. This behaviour matches MaxIndexCopyText(), MaxIndexMapText() and MaxIndexLookupText(). 
    * When **setNullTo** is provided as an integer, NULLs in intList are replaced with setNullTo. Otherwise NULLs are ignored when calculating min value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * e.g. MinIndexMatchList({1990, 2000}, {'a', 'b'}, {'a','c','d','g'})
    * e.g. MinIndexMatchList({0, NULL}, {'a', 'b'}, {'a','c','d','g'}, 2000, 1990)

* **MaxIndexMatchList**(*stringList* **intList**, *stringList* **testList**, *stringList* **returnList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Find the target values from **testList** with a matching index to the highest integer in **intList**. Pass it to matchList() along with **returnList**. 
    * If there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested. This behaviour matches MaxIndexCopyText(), MaxIndexMapText() and MaxIndexLookupText(). 
    * When **setNullTo** is provided as an integer, NULLs in intList are replaced with setNullTo. Otherwise NULLs are ignored when calculating max value. Zeros can also be replaced using setZeroTo. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * e.g. MaxIndexMatchList({1990, 2000}, {'a', 'b'}, {'a','c','d','g'})
    * e.g. MaxIndexMatchList({0, NULL}, {'a', 'b'}, {'a','c','d','g'}, 2000, 1990)
    
* **CoalesceIsInt**(*stringList* **srcValList**, *boolean* **zeroAsNull**\[default FALSE\])
    * Return TRUE if the first non-NULL value in the **srcValList** string list is an integer.
    * If **zeroAsNull** is set to TRUE, strings evaluating to zero ('0', '00', '0.0') are treated as NULL.
    * e.g. coalesceIsInt({NULL, 0, 2000}, TRUE)

* **CoalesceIsBetween**(*stringList* **srcValList**, *numeric* **min**, *numeric* **max**, *boolean* **includeMin**\[default TRUE\], *boolean* **includeMax**\[default TRUE\], , *boolean* **zeroAsNull**\[default FALSE\])
    * Returns TRUE if the first non-NULL value in the **srcValList** string list is between **min** and **max**.
    * When **includeMin** and/or **includeMax** are set to TRUE, the acceptable range of values includes **min** and/or **max*. Must include both or neither **includeMin** and **includeMax** parameters.
    * If **zeroAsNull** is set to TRUE, strings evaluating to zero ('0', '00', '0.0') are treated as NULL.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * e.g. CoalesceIsBetween({NULL, 0, 5}, 0, 100) -- returns TRUE because 0 is between 0 and 100 and 0 which are both included in the valid interval
    * e.g. CoalesceIsBetween({NULL, 0, 5}, 0, 100, FALSE, FALSE) -- returns FALSE because 0 is not included in the valid interval
    * e.g. CoalesceIsBetween({NULL, 0, 5}, 0, 100, FALSE, FALSE, TRUE) -- returns TRUE because 0 is ignored and 5 is between 0 and 100

* **IsLessThanLookupDouble**(*numeric* **srcVal**, *text* **lookupSrcVal**, *text* **lookupSchema**, *text* **lookupTable**, *text* **lookupCol**, *text* **retrieveCol**\[default source_val]\, *boolean* **inclusive**\[default TRUE]\)
    * Runs lookupDouble using the **lookupSrcVal**, **lookupSchema**, **lookupTable**, **lookupCol** and **retrieveCol**.
    * Uses the result from LookupDouble as the upperBound argument in IsLessThan.
    * Default error codes are 'OUT_OF_RANGE' for text attributes, -9999 for numeric attributes and NULL for other types.
    * e.g. IsLessThanLookupDouble(2, lookupSrcVal, lookupSchema, lookupTable, lookupCol, retrieveCol, FALSE) -- Assuming lookupDouble returns 2: returns FALSE because 2 is not less than 2.
    * e.g. IsLessThanLookupDouble(2, lookupSrcVal, lookupSchema, lookupTable, lookupCol, retrieveCol, TRUE) -- Assuming lookupDouble returns 2: returns TRUE because 2 is less than or equal to 2.
    * e.g. IsLessThanLookupDouble(2, lookupSrcVal, lookupSchema, lookupTable, retrieveCol, TRUE) -- defaults to use 'source_val' as **lookupCol**
    * e.g. IsLessThanLookupDouble(2, lookupSrcVal, lookupSchema, lookupTable, retrieveCol) -- defaults to use 'source_val' as **lookupCol** and TRUE as **inclusive**.

* **GeoIsValid**(*geometry* **geom**, *boolean* **fixable**\[default TRUE\])
    * Returns TRUE if **geom** is a valid geometry.
    * When **fixable** is TRUE and **geom** is invalid, will attempt to make a valid geometry and return TRUE if successful. If geometry is invalid returns FALSE. Note that setting **fixable** to TRUE does not actually fix the geometry, it only tests to see if the geometry can be fixed.
    * Default error codes are 'INVALID_VALUE' for text attributes, -7779 for numeric attributes and NULL for other types (including geometry).
    * e.g. GeoIsValid(POLYGON, TRUE)
    
* **GeoIntersects**(*geometry* **geom**, *text* **intersectSchemaName**\[default public\], *text* **intersectTableName**, *geometry* **geomCol**\[default geom\])
    * Returns TRUE if **geom** intersects with any features in the **geomCol** column of the **intersectSchemaName**.**intersectTableName** table. Otherwise returns FALSE. Invalid geometries are validated before running the intersection test.
    * Default error codes are 'NO_INTERSECT' for text attributes, -7778 for numeric attributes and NULL for other types (including geometry).
    * e.g. GeoIntersects(POLYGON, public, intersect_tab, intersect_geo)
      
## Translation Functions

Default error codes for translation functions are 'TRANSLATION_ERROR' for text attributes, -3333 for numeric ones and NULL for others.

* **CopyText**(*text* **srcVal**)
    * Returns **srcVal** as text without any transformation.
    * e.g. CopyText('sp1')
      
* **CopyDouble**(*numeric* **srcVal**)
    * Returns **srcVal** as double precision without any transformation.
    * e.g. CopyDouble(1.1)

* **CopyInt**(*integer* **srcVal**)
    * Returns **srcVal** as integer without any transformation.
    * e.g. CopyInt(1)
      
* **LookupText**(*text* **srcVal**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupColName**\[default 'source_val'\], *text* **retrieveColName**, *boolean* **ignoreCase**\[default FALSE\])
    * Returns text value from the **retrieveColName** column in **lookupSchemaName**.**lookupTableName** that matches **srcVal** in the **lookupColName** column.
    * When **ignoreCase** is TRUE, case is ignored.
    * e.g. LookupText('sp1', 'public', 'species_lookup', 'target_sp', TRUE)
      
* **LookupDouble**(*text* **srcVal**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupColName**\[default 'source_val'\], *text* **retrieveColName**, *boolean* **ignoreCase**\[default FALSE\])
    * Returns double precision value from the **retrieveColName** column in **lookupSchemaName**.**lookupTableName** that matches **srcVal** in the **lookupColName** column.
    * When **ignoreCase** is TRUE, case is ignored.
    * e.g. LookupDouble(5.5, 'public', 'species_lookup', 'sp_percent', TRUE)

* **LookupInt**(*text* **srcVal**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupColName**\[default 'source_val'\], *text* **retrieveColName**, boolean **ignoreCase**\[default FALSE\])
    * Returns integer value from the **retrieveColName** column in **lookupSchemaName**.**lookupTableName** that matches **srcVal** in the **lookupColName** column.
    * When **ignoreCase** is TRUE, case is ignored.
    * e.g. LookupInt(20, 'public', 'species_lookup', 'sp_percent', TRUE)

* **LookupTextSubstring**(*text* **srcVal**, *integer* **startChar**, *integer* **forLength**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupColName**\[default 'source_val'\], *text* **retrieveColName**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Takes the substring of **srcVal** using **startChar** and **forLength** and passes it to lookupText.
    * e.g. LookupTextSubstring('sp1', '1', '2', 'public', 'species_lookup', 'target_sp', FALSE, FALSE)

* **MapText**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Return text value from **returnList** that matches index of **srcVal** in **matchList**. 
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * e.g. Map('A','{'A','B','C'}','{'D','E','F'}', TRUE)
    
* **MapSubstringText**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Calculates substring of **srcVal** and passes to MapText() using **matchList** and **returnList**.
    * e.g. MapSubstringText('ABC',1,1,'{'A','B','C'}','{'D','E','F'}')
    
* **SumIntMapText**(*stringList* **srcValList**, *stringList* **matchList**, *stringList* **returnList**)
    * Calculates the sum  of the values in the **srcValList** string list and passes the sum to MapText() with **matchList** amd **returnList**.
    * e.g. SumIntMapText({1, 2},{3, 4, 5},{'three','four','five'})
    
* **MapTextNotNullIndex**(*text* **srcVal1**, *stringList* **matchList1**, *stringList* **returnList1**, *text* **srcVal2**, *stringList* **matchList2**, *stringList* **returnList2**, *text* **srcVal3**, *stringList* **matchList3**, *stringList* **returnList3**, *text* **srcVal4**, *stringList* **matchList4**, *stringList* **returnList4**, *text* **srcVal5**, *stringList* **matchList5**, *stringList* **returnList5**, *text* **srcVal6**, *stringList* **matchList6**, *stringList* **returnList6**, *text* **srcVal7**, *stringList* **matchList7**, *stringList* **returnList7**, *text* **srcVal8**, *stringList* **matchList8**, *stringList* **returnList8**, *text* **srcVal9**, *stringList* **matchList9**, *stringList* **returnList9**, *text* **srcVal10**, *stringList* **matchList10**, *stringList* **returnList10**, *integer* indexToReturn)
    * Runs MapText for each set of val, matchList and returnList, then returns the ith non-null result where i = indexToReturn.
    * Null srcVals and null results from MapText are dropped when selecting the ith non-null result.
    * If indexToReturn > the count of results, NULL is returned.
    * Works with between two and ten sets of srcVal, matchList, and returnList.
    * e.g. MapTextNotNullIndex(a,{a,b},{A,B}, b,{a,b},{A,B}, 1) returns 'A'.
    * e.g. MapTextNotNullIndex(NULL,{a,b},{A,B}, NULL,{a,b},{A,B}, c,{c,d},{C,D}, d,{c,d},{C,D}, e,{e,f},{E,F}, f,{e,f},{E,F}, g,{g,h},{G,H}, h,{g,h},{G,H}, i,{i,j},{I,J}, j,{i,j},{I,J}, 5) returns 'G' because the NULL srcVals are ignored.
      
* **MapDouble**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Return double precision value in **returnList** that matches index of **srcVal** in **matchList**. 
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * e.g. MapDouble('A',{'A','B','C'},{1.1,1.2,1.3}, TRUE)
      
* **MapInt**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **ignoreCase**\[default FALSE\], *boolean* **removeSpaces**\[default FALSE\])
    * Return integer value in **returnList** that matches index of **srcVal** in **matchList**. 
    * When **ignoreCase** is TRUE, case is ignored.
    * When **removeSpaces** is TRUE, removes any spaces from string before testing.
    * e.g. Map('A',{'A','B','C'},{1,2,3})
      
* **Length**(*text* **srcVal**, *boolean* **trimSpaces**)
    * Returns the length of the **srcVal** string.
    * When **trimSpaces** is TRUE, removes any leading or trailing spaces before calculating length.
    * e.g. Length('12345')

* **LengthMapInt**(*text* **srcVal**, *stringList* **matchList**, *stringList* **returnList**, *boolean* **removeSpaces**\[default FALSE\])
    * Calculates length of string then pass the length to MapInt().
    * Return type is integer.
    * When **removeSpaces** is TRUE, removes any spaces before calculating length.
    * e.g. Length('12345', {5, 6, 7}, {1, 2, 3})
    
* **Multiply**(*double precision* **val1**, *double precision* **val2**)
    * Multiplies val1 by val2.
    * Return type is double precision.
    * e.g. Multiply(2, 3)

* **DivideDouble**(*double precision* **srcVal**, *double precision* **divideBy**)
    * Divides **srcVal** by **divideBy**.
    * Return type is double precision.
    * e.g. DivideDouble(2.2, 1.1)

* **DivideInt**(*double precision* **srcVal**, *double precision* **divideBy**)
    * A wrapper around DivideDouble() that returns an integer.
    * e.g. DivideInt(2.2, 1.1)

* **Pad**(*text* **srcVal**, *int* **targetLength**, *text* **padChar**, *boolean* **trunc**\[default TRUE\])
    * Returns a string of length **targetLength** made up of **srcVal** preceeded with **padChar**.
    * When **trunc** is TRUE and **srcVal** length > **targetLength**, trunc **srcVal** to **targetLength**. Returns **srcVal** otherwise. 
    * e.g. Pad('tab1', 10, 'x') -- returns 'xxxxxxtab1'
    * e.g. Pad('tab1', 2, 'x', TRUE) -- returns 'ta'
    * e.g. Pad('tab1', 2, 'x', FALSE) -- returns 'tab1'

* **Concat**(*stringList* **srcValList**, *text* **separator**)
    * Concatenate all values in the **srcValList** string list, interspersed with **separator**. 
    * e.g. Concat('{'str1','str2','str3'}', '-')

* **PadConcat**(*stringList* **srcValList**, *stringList* **lengthList**, *stringList* **padList**, *text* **separator**, *boolean* **upperCase**, *boolean* **includeEmpty**\[default TRUE\])
    * Pad all values in the **srcValList** string list according to the respective **lengthList** and **padList** values and then concatenate them with the **separator**. 
    * If **upperCase** is TRUE, all characters are converted to upper case.
    * If **includeEmpty** is FALSE, any empty strings in **srcValList** are dropped from the concatenation. 
    * e.g. PadConcat({'str1','str2','str3'}, {'5','5','7'}, {'x','x','0'}, '-', TRUE, TRUE)  -- returns 'xstr1-xstr2-000str3'

* **NothingText**()
    * Returns NULL of type text. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **target_attribute_type**.
    * e.g. NothingText()

* **NothingDouble**()
    * Returns NULL of type double precision. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **target_attribute_type**.
    * e.g. NothingDouble()

* **NothingInt**()
    * Returns NULL of type integer. Used with the validation rule False() and will therefore not be called, but all rows require a valid translation function with a return type matching the **target_attribute_type**.
    * e.g. NothingInt()

* **CountOfNotNull**(*stringList* **scrVals1/2/3/4/5/6/7/8/9/10/11/12/13/14/15**, *int* **maxRankToConsider**, *boolean* **zeroIsNull**)
    * Returns the number of string list input arguments that have at least one list element that is not NULL or empty string. Up to a maximum of 15.
    * Between 1 and 15 string lists can be provided.
    * Only the first **maxRankToConsider** string lists will be considered for the calculation. For example, if **maxRankToConsider** is one, only the first string list will be considered and the maximum values that could be returned would be 1.
    * When **zeroIsNull** is TRUE, zero values ('0') are counted as NULL.
    * **maxRankToConsider** and **zeroIsNull** always need to provided.
    * e.g. CountOfNotNull({'a', 'b'}, {'c', 'd'}, {'e', 'f'}, {'g', 'h'}, {'i', 'j'}, {'k', 'l'}, {'m', 'n'}, 7, FALSE)
 
* **IfElseCountOfNotNullText**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *int* **count**, *text* **returnIf**, *text* **returnElse**)
    * Calls CountOfNotNull() and tests if the returned value matches the count.
    * If returned value is less than or equal to count, returns **returnIf**, else returns **returnElse**.
    * zeroIsNull in countOfNotNull is set to FALSE.
    * e.g. IfElseCountOfNotNullText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, 1, 'S', 'M')

* **IfElseCountOfNotNullInt**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *int* **count**, *text* **returnIf**, *text* **returnElse**)
    * Simple wrapper around IfElseCountOfNotNullText() that returns an int.
    
* **CountOfNotNullMapText**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *stringList* **resultList**, *stringList* **mappingList**)
    * Calls CountOfNotNull() and passes the returned value to mapText using the resultList and mappingList.
    * zeroIsNull in countOfNotNull is set to FALSE.
    * e.g. IfElseCountOfNotNullText({'a','b'}, {'c','d'}, {'e','f'}, {'g','h'}, {'i','j'}, {'k','l'}, {'m','n'}, 7, {1,2,3,4,5,6,7}, {a,b,c,d,e,f,g})

* **CountOfNotNullMapInt**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *stringList* **resultList**, *stringList* **mappingList**)
    * Simple wrapper around CountOfNotNullMapText returning int.
    
* **CountOfNotNullMapDouble**(*stringList* **vals1/2/3/4/5/6/7**, *int* **maxRankToConsider**, *stringList* **resultList**, *stringList* **mappingList**)
    * Simple wrapper around CountOfNotNullMapText returning double precision.
    
* **SubstringText**(*text* **srcVal**, *int* **startChar**, *int* **forLength**, *boolean* **removeSpaces**\[default FALSE\])
    * Returns a substring of **srcVal** from **startChar** for **forLength**.
    * When **removeSpaces** is TRUE, spaces are removed from **srcVal** before taking the substring.
    * e.g. SubstringText('abcd', 2, 2)

* **SubstringInt**(*text* **srcVal**, *int* **startChar**, *int* **forLength**)
    * Simple wrapper around **SubstringText** that returns an int.
    
* **MinInt**(*stringList* **srcValList**)
    * Return the lowest integer in the **srcValList** string list. 
    * e.g. minInt({1990, 2000})

* **MaxInt**(*stringList* **srcValList**)
    * Return the highest integer in the **srcValList** string list. 
    * e.g. MaxInt({1990, 2000})

* **MinIndexCopyText**(*stringList* **intList**, *stringList* **returnList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Returns value from **returnList** matching the index of the lowest value in **intList**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested.
    * e.g. MaxIndexCopyText({1990, 2000}, {burn, wind})
    * e.g. MaxIndexCopyText({1990, NULL}, {burn, wind}, 2000, 'NULL')

* **MaxIndexCopyText**(*stringList* **intList**, *stringList* **returnList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Returns value from **returnList** matching the index of the highest value in **intList**.
    * If setNullTo is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating max value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * If there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested.
    * e.g. MaxIndexCopyText({1990, 2000}, {burn, wind})
    * e.g. MaxIndexCopyText({0, 2000}, {burn, wind}, 'NULL', 1990)

* **MinIndexCopyInt**(*stringList* **intList**, *stringList* **returnList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
  * Same as MinIndexCopyText() but returns an integer.
  
* **MaxIndexCopyInt**(*stringList* **intList**, *stringList* **returnList**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
  * Same as MaxIndexCopyText() but returns an integer.

* **MinIndexMapText**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
    * Passes value from **returnList** matching the index of the lowest value in **intList** to MapText(). Runs MapText() using **mapVals** and **targetVals**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested.
    * e.g. MinIndexMapText({1990, 2000}, {burn, wind}, {burn, wind}, {BU, WT})
    * e.g. MinIndexMapText({NULL, 0}, {burn, wind}, {burn, wind}, {BU, WT}, 2020, 2020)

* **MaxIndexMapText**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *text* **setNullTo**\[default NULL\])
    * Passes value from returnList matching the index of the highest value in intList to MapText(). Runs MapText() with mapVals and targetVals.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating max value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the highest value is tested.
    * e.g. MaxIndexMapText({1990, 2000}, {burn, wind}, {burn, wind}, {BU, WT})
    * e.g. MaxIndexMapText({1990, NULL}, {burn, wind}, {burn, wind}, {BU, WT}, 2020, 'NULL')
    
* **MinIndexMapInt**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
  * Same as MinIndexMapText() but returning an integer.

* **MaxIndexMapInt**(*stringList* **intList**, *stringList* **returnList**, *stringList* **mapVals**, *stringList* **targetVals**, *text* **setNullTo**\[default NULL\], *text* **setZeroTo**\[default NULL\])
  * Same as MaxIndexMapText() but returning an integer.

* **MinIndexLookupText**(*stringList* **intList**, *stringList* **returnList**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupColName**\[default 'source_val'\], *text* **retrieveColName**, *text* **setNullTo**\[default NULL\],  *text* **setZeroTo**\[default NULL\])
    * Passes value from **returnList** matching the index of the lowest value in **intList** to LookupText(). Runs LookupText() with **lookupSchemaName**, **lookupTableName**, **lookupColName** and **retrieveColName**.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating min value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the lowest value, the **first** non-NULL value with an index matching the lowest value is tested.
    * A 6-argument variant sets **lookupColName** to **source_val** by default. A 5-argument variant sets **lookupColName** to **source_val**, **setNullTo** to **NULL** and **setZeroTo** to **NULL**.
    * e.g. MinIndexLookupText({1990, 2000}, {burn, wind}, 'public', 'table', 'source_val', 'target_col', 'NULL', 'NULL')
    * e.g. MinIndexLookupText({1990, 2000}, {burn, wind}, 'public', 'table', 'target_val', 'NULL', 'NULL')
    * e.g. MinIndexLookupText({1990, 2000}, {burn, wind}, 'public', 'table', 'target_val')

* **MaxIndexLookupText**(*stringList* **intList**, *stringList* **returnList**, *text* **lookupSchemaName**\[default public\], *text* **lookupTableName**, *text* **lookupColName**\[default 'source_val'\], *text* **retrieveColName**, *text* **setNullTo**\[default NULL\],  *text* **setZeroTo**\[default NULL\])
    * Passes value from returnList matching the index of the highest value in intList to lookupText. Runs lookupText using the lookupSchemaName, lookupTableName, lookupColName and retrieveColName.
    * When **setNullTo** is provided as an integer, NULLs in **intList** are replaced with **setNullTo**. Otherwise NULLs ignored when calculating max value. Zeros can also be replaced using **setZeroTo**. Either both, or neither of these values need to be provided. If only one is required the other can be set to the 'NULL' default value.
    * When there are multiple occurrences of the highest value, the **last** non-NULL value with an index matching the lowest value is tested.
    * A 6-argument variant sets **lookupColName** to **source_val** by default. A 5-argument variant sets **lookupColName** to **source_val**, **etNullTo** to **NULL** and **setZeroTo** to **NULL**.
    * e.g. MaxIndexLookupText({1990, 2000}, {burn, wind}, 'public', 'table', 'source_val', 'target_col', 'NULL', 'NULL')
    * e.g. MaxIndexLookupText({1990, 2000}, {burn, wind}, 'public', 'table', 'target_val', 'NULL', 'NULL')
    * e.g. MaxIndexLookupText({1990, 2000}, {burn, wind}, 'public', 'table', 'target_val')

* **CoalesceText**(*text* **srcValList**, *boolean* **zeroAsNull**\[default FALSE\])
    * Returns the first non-NULL value in the **srcValList** string list.
    * When **zeroAsNull** is set to TRUE, strings evaluated to zero ('0', '00', '0.0') are treated as NULL.
    * e.g. CoalesceText({NULL, '0.0', 'abcd'}, TRUE) -- returns 'abcd'

* **CoalesceInt**(*text* **srcValList**, *boolean* **zeroAsNull**\[default FALSE\])
    * Simple wrapper around CoalesceText() that returns an int.

* **GeoIntersectionText**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *text* **returnCol**, *text* **method**)
    * Returns the value of the **returnCol** column of the **intersectSchemaName**.**intersectTableName** table where the geometry in the **geoCol** column intersects **geom**.
    * When multiple polygons intersect, the value from the polygon with the largest area can be returned by setting **method** to 'GREATEST_AREA'; the lowest intersecting value can be returned by setting **method** to'LOWEST_VALUE', or the highest value can be returned by setting method to 'HIGHEST_VALUE'. The 'LOWEST_VALUE' and 'HIGHEST_VALUE' methods only work when **returnCol** is numeric.
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, TYPE, GREATEST_AREA)
    
* **GeoIntersectionDouble**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *numeric* **returnCol**, *text* **method**)
    * Returns a double precision value from an intersecting polygon. Parameters are the same as **GeoIntersectionText()**.
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, LENGTH, HIGHEST_VALUE)

* **GeoIntersectionInt**(*geometry* **geom**, *text* **intersectSchemaName**, *text* **intersectTableName**, *geometry* **geoCol**, *numeric* **returnCol**, *text* **method**)
    * Returns an integer value from an intersecting polygon. Parameters are the same as **GeoIntersectionText()**.
    * e.g. GeoIntersectionText(POLYGON, public, intersect_tab, intersect_geo, YEAR, LOWEST_VALUE)

* **GeoMakeValid**(*geometry* **geom**)
    * Returns a valid version of **geom**. If **geom** cannot be validated, returns NULL.
    * e.g. GeoMakeValid(POLYGON)
    
* **GeoMakeValidMultiPolygon**(*geometry* **geom**)
    * Returns a valid version of **geom** of type ST_MultiPolygon. If **geom** cannot be validated, returns NULL.
    * e.g. GeoMakeValidMultiPolygon(POLYGON)


# Adding Custom Helper Functions
Additional helper functions can be written in PL/pgSQL. They must follow the following conventions:

  * **Namespace -** All helper function names must be prefixed with "TT_". This is necessary to create a restricted namespace for helper functions so that no standard PostgreSQL functions (which do not necessarily comply to the following conventions) can be used. This prefix must not be used when referring to the function in the translation table.
  * **Parameter Types -** All helper functions (validation and translation) must accept only text parameters (the engine converts everything to text before calling the function). This greatly simplifies the development of helper functions and the parsing and validation of translation tables.
  * **Variable number of parameters -** Helper functions should NOT be implemented as VARIADIC functions accepting an arbitrary number of parameters. If an arbitrary number of parameters must be supported, it should be implemented as a list of text values separated by a comma. This is to avoid the hurdle of finding, when validating the translation table, if the function exists in the PostgreSQL catalog. Note that when passing arguments from the translation table to the helper functions, the engine strips the '{}' from any argument lists. So helper functions of this type need only process the comma separated list of values.
  * **Default value -** Helper functions should NOT use DEFAULT parameter values. The catalog needs to contain explicit helper function signatures for all functions it could receive. If signatures with default parameter are required, a separate function signature should be created as a wrapper around the function supporting all the parameters. This is to avoid the hurdle of finding, when validating the translation table, if the function exists in the PostgreSQL catalog.
  * **Polymorphic translation functions -** If a translation helper function must be written to return different types (e.g. int and text), as many different functions with corresponding names must be written (e.g. TT_CopyInt() and TT_CopyText()). The use of the generic "any" PostgreSQL type is forbidden. This ensures that the engine can explicitly know that the translation function returns the correct type.
  * **Error handling -** All helper functions (validation and translation) must raise an exception when parameters other than the source value are NULL or of an invalid type. This is to avoid badly written translation tables. All helper functions (validation and translation) should handle any source data values (always passed as text) without failing. This is to avoid crashing of the engine when translating big source files. 
  * **Return value -** 1) Validation functions must always return a boolean. They must handle NULL and empty values and in those cases return the appropriate boolean value. When they return FALSE, an error code will be set as target value in the translated table. Default error codes are provided for each validation helper function in the TT_DefaultErrorCode() function or directly after the rule in the translation table. 2) Translation functions must return a specific type. For now only "int", "numeric", "text", "boolean" and "geometry" are supported. If any errors happen during translation, the translation function must return NULL and the engine will translate the value to the generic "TRANSLATION_ERROR" (-3333) code, or a user defined error code if one is provided directly after the rule in the tranlation table.

If you think some of your custom helper functions could be of general interest to other users of the framework, you can submit them to the project team. They could be integrated in the helper funciton file.

# Dependency Table Validation
Some helper functions use dependency tables to facilitate validation or translations. Examples include lookup tables for functions such as MatchTable() and LookupText(), and intersect tables for spatial functions such as GeoIntersects() and GeoIntersectionText(). These dependency tables need to be valid in order for the helper functions to work correctly. We can use the validation functionality of the translation engine to achieve this by creating validation-only translation tables. Each row of the validation-only translation table implement one validation rule to be run on the dependency table. For example a validation of an intersect table may be to check that all the geometries are valid. The validation rule for this row would use GeoIsValid(). Since we only care about the validation, we can simply use a translation rule such as copyText('PASS') for each row. When we run the validation-only translation table on the dependency table through the engine, any rows failing a validation will produce an error code, all passing rows will return 'PASS'. We can then fix any invalid rows before running the main translation using the dependency table. An example of a validation-only translation table can be seen in the [CASFRI 5.0](https://github.com/edwardsmarc/CASFRI/blob/master/translation/tables/ab_photoyear_validation.csv) project.

# Credit
**Pierre Racine** - Center for forest research, University Laval.

**Pierre Vernier** - Database designer.

**Marc Edwards** - SQL programmer.
