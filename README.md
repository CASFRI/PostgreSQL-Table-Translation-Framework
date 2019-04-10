# Introduction
The PostgreSQL Table Translation Framework allows PostgreSQL users to validate and translate a source table into a new target table  using validation and translation rules. This framework simplify the writing of complex SQL queries attempting to achieve the same goal. It is very much like an in-db transform engine in a Extract, Load, Transform (ELT) process (a variant of the popular ETL process where most of the transformation is done inside the database). Future versions should provide logging and resuming allowing a fast create, edit, test, generate translation table creation/edition cycle.

The primary components of the framework are:
* The translation engine, implemented as a set of PL/pgSQL functions.
* A set of validation and translation helper functions implementing the most usual validation and translation rules.
* A user produced translation table defining the structure of the target table and all the validation and the translation rules.
* Optionally, some user produced value lookup tables that accompany the translation table.

# Directory structure
<pre>
./             .sql files for loading, testing, and uninstalling the engine and helper functions.

./docs         Mostly development specifications.
</pre>

# Requirements
PostgreSQL 9.6+ and PostGIS 2.3+.

# Version Releases
* [PostgreSQL Table Translation Framework 0.1 beta](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework/releases/tag/v0.1-beta)

# Installation/Uninstallation
* **Installation -** In a PostgreSQL query window, or using the PSQL client, run, in this order:

  1. the engine.sql file,
  2. the helperFunctions.sql file,
  3. the helperFunctionsTest.sql file. All tests should pass (the "passed" column should be TRUE for all tests).
  4. the engineTest.sql file. All tests should pass.
  
* **Uninstallation -** You can uninstall all the functions by running the helperFunctionsUninstall.sql and the engineUninstall.sql files.

# Vocabulary
*Translation engine* - The PL/pgSQL code implementing the [PostgreSQL Table Translation Framework](https://github.com/edwardsmarc/PostgreSQL-Table-Translation-Framework).

*Helper function* - A set of PL/pgSQL functions used in the translation table to facilitate validation of source values and their translation to target values.

*Source table* - The table to be validated and translated.

*Target table* - The table created by the translation process.

*Translation table* - User created table read by the translation engine and defining the structure of the target table, the validation rules and the translation rules.

*Lookup table* - User created table of lookup values used by some helper functions to convert source values into target values.

*Source attribute/value* - The attribute or value stored in the source table.

*Target attribute/value* - The attribute or value to be stored in the translated target table.

# What are translation tables and how to write them?

A translation table is a normal PostgreSQL table defining the structure of the target table (one row per target attribute), how to validate source values to be translated and how to translate them into the target attributes. It also provides a way to document the validation and translation rules and to flag rules that are not yet in synch with their description (in the case where rules are written as a second step or by different people).

The translation table implements two very different steps:

1. **Validation -** The source values are first validated by a set of validation rules separated by a semicolon. Each validation rule defines an error code that is returned if the rule is not fulfilled. The next step (translation) happens only if all the validation rules pass. A boolean flag (TRUE or FALSE) can make a failing validation rule to stop the engine. This flag is set to false by default so that the engine report errors without stopping.

2. **Translation -** The source values are translated to the target values by the (unique) translation rule.

Translation tables have one row par target attribute and they must contain these six columns:

 1. **targetAttribute** - The name of the target attribute to be created in the target table.
 2. **targetAttributeType** - The data type of the target attribute.
 3. **validationRules** - A semicolon separated list of validation rules needed to validate the source values before translating.
 4. **translationRules** - The translation rules to convert source values to target values.
 5. **description** - A text description of the translation taking place.
 6. **descUpToDateWithRules** - A boolean describing whether the translation rules are up to date with the description. This allows non-technical users to propose translations using the description column. Once the described translation has been applied throughout the table this attribute should be set to TRUE.
 
* Multiple validation rules can be seperated with a semi-colon.
* Error codes to be returned by the engine if validation rules return FALSE should follow a '|' at the end of the helper function parameters (e.g. notNull(sp1_per|-8888)).

Translation tables are themselves validated by the translation engine while processing the first source row. Any error in the translation table stops the validation/translation process. The engine check that:

* no null values exists (all cell must have a value),
* target attribute names do not contain invalid characters (e.g. spaces or accents),
* target attribute types are valid PostgreSQL types (integer, text, boolean, etc...)
* validation and translation rules helper functions exist and have the propre number of parameter and types,
* the flag indicating if the description is in synch with the validation/translation rules is set to TRUE.

**Example translation table**

The following translation table defines a target table composed of two columns: "SPECIES_1" of type text and "SPECIES_1_PER" of type integer.

The source attribute "sp1" is validated by checking it is not null, and that it matches a value in the specified lookup table. This is done using the notNull() and the match() [helper functions](#helper-functions) described further in this document. If all validation test pass, "sp1" is then translated into the target attribute "SPECIES_1" using the lookup table named "species_lookup". If the first validation rules fails, the "NULL" string is returned instead. If the first rules pass but the second validation rules fails, the "NOT_IN_SET" string is returned.

Similarly, the source attribute "sp1_per" is validated by checking it is not null, and that it falls between 0 and 100. It is then translated by simply copying the value to the target attribute "SPECISE_1_PER". "-8888", an integer error code, is returned if the first rule fails. "-9999" is returned if the second validation rules fails.

A textual description of the rules is provided and the flag indicarting that the deacription is in synch with the rules is set to TRUE.

| targetAttribute | targetAttributeType | validationRules | translationRules | description | descUpToDateWithRules |
|:----------------|:--------------------|:----------------|:-----------------|:------------|:----------------------|
|SPECIES_1        |text                 |notNull(sp1\|NULL); match(sp1,public,species_lookup\|NOT_IN_SET)|lookup(sp1, public, species_lookup, targetSp)|Maps source value to SPECIES_1 using lookup table|TRUE|
|SPECIES_1_PER|integer|notNull(sp1_per\|-8888); between(sp1_per,0,100\|-9999)|copy(sp1_per)|Copies source value to SPECIES_PER_1|TRUE|

# How to actually translate a source table?

The translation is done in two steps:

**1. Prepare the translation function**

```sql
SELECT TT_Prepare(translationTableSchema, translationTable);
```

It is necessary to dynamically prepare the actual translation function because PostgreSQL does not allow a function to return an arbitrary number of column of arbitrary types. The translation function has to explicitly declare what it is going to return at declaration time. Since every translation table can get the translation function to return a different set of columns, it is necessary to define a new translation function for every translation table. This step is necessary only when a new translation table is being used, when a new atribute is defined in the translation table or when a target attribute type is changed.

**2. Translate the table with the prepared function**

```sql
CREATE TABLE target_table AS
SELECT * FROM TT_Translate(sourceTableSchema, sourceTable);
```

The TT_Translate() function returns the translated target table. It is designed to be used in place of any table in a SQL statement.

By default the prepared function will always be named TT_Translate(). If you are dealing with many tranlation tables at the same time, you might want to prepare a translation function for each of them. You can do this by adding a suffix as the third parameter of the TT_Prepare() function (e.g. TT_Prepare('public', 'translation_table', '02') with prepare the TT_Translate02() function). You would normally parovide a different suffix for each of your translation table.

If your source table is very big, we suggest that you develop and try your translation table on a random sample of it so that the process of create, edit, test, generate gets quicker. Future releases of the framework will provide a logging and a resuming mechanism which will ease the development of translation tables. 

# How to write a lookup table?
* Some helper functions (match(), lookup()) allow the use of lookup tables providing a mapping between source and target values.
* An example is a list of species codes source values and a corresponding list of species names target values.
* Helper functions using lookup tables will always look for the source values in the column named 'source_val'. The lookup() function will return the corresponding value in the specified column.

Example lookup table. Source values for species codes in the "source_val" column are matched to their target values in the "targetSp1"  or the "targetSp2" column.

|source_val|targetSp1|targetSp2|
|:---------|:--------|:--------|
|TA        |PopuTrem |POPTRE   |
|LP        |PinuCont |PINCON   |

# Complete Example
Create an example lookup table:
```sql
CREATE TABLE species_lookup AS
SELECT 'TA' AS sourceSp, 
       'PopuTrem' AS targetSp
UNION ALL
SELECT 'LP', 'PinuCont';
```

Create an example translation table:
```sql
CREATE TABLE translation_table AS
SELECT 1 AS ogc_fid, 
       'SPECIES_1' AS targetAttribute, 
       'text' AS targetAttributeType, 
       'notNull(sp1|NULL);match(sp1,public,species_lookup|NOT_IN_SET)' AS validationRules, 
       'lookup(sp1, public, species_lookup, targetSp)' AS translationRules, 
       'Maps source value to SPECIES_1 using lookup table' AS description, 
       TRUE AS descUpToDateWithRules
UNION ALL
SELECT 2, 'SPECIES_1_PER', 
          'integer', 
          'notNull(sp1_per|-8888);between(sp1_per,0,100|-9999)', 
          'copy(sp1_per)', 
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
SELECT TT_Prepare('public', 'translate');

CREATE TABLE target_table AS
SELECT * FROM TT_Translate('public', 'source_example', 'public', 'translation_table');
```

# Provided Helper Functions
Helper functions are used in translation tables to validate and translate source values. When the translation engine encounters a helper function in the translation table, it runs that function with the given parameters.

Helper functions are of two types: validation helper functions are used in the **validationRules** column of the translation table. They validate the source values and always return TRUE or FALSE. If the validation fails an error code is returned, otherwise the translation helper function in the **translationRules** column is run. Translation helper functions take a source value as input and return a translated target value for the target table.

Helper functions are generally called with the name of the source value attribute to validate or translate as first argument and some other fixed arguments controling others aspects of the process. Source values are replaced by the translation engine with the actual value when the current row is being processed.

## Validation Functions

1. **NotNull**(srcVal[])
    * Returns TRUE if all srcVal are not NULL. Returns FALSE if any srcVal is NULL.
    * e.g. NotNull('a', 'b', 'c')
    * Signatures:
      * NotNull(text[])
      * NotNull(boolean[])
      * NotNull(double precision[])
      * NotNull(int[])
2. **NotEmpty**(srcVal[])
    * Returns TRUE if all srcVal are not empty strings. Returns FALSE if any srcVal is an empty string or simply padded spaces (e.g. '' or '  ') or NULL.
    * e.g. NotEmpty('a', 'b', 'c')
    * Signatures:
      * NotEmpty(text[])

3. **IsInt**(srcVal[])
    * Returns TRUE if srcVal are all integers. Returns FALSE if any srcVal are NULL. Strings with numeric characters and '.' will be passed to IsInt(). Strings with anything else (e.g. letter characters) return FALSE.
    * e.g. IsInt(1,2,3,4,5)
    * Signatures:
      * IsInt(text[])
      * IsInt(double precision[])
      * IsInt(int[])

4. **IsNumeric**(srcVal[]) 
    * Returns TRUE if srcVal can be cast to double precision. NULL srcVal return FALSE.
    * e.g. IsNumeric('1.1', '1.2', '1.3')
    * Signatures:
      * IsNumeric(text[])
      * IsNumeric(double precision[])
      * IsNumeric(int[])

5. **Between**(srcVal, min, max)
    * Returns TRUE if srcVal is between min and max. FALSE otherwise.
    * e.g. Between(5, 0, 100)
    * Signatures
      * Between(double precision, double precision, double precision)
      * Between(int, double precision, double precision)
      * Between(text, double precision, double precision)
      * Between(int, double precision, text)
      * Between(int, text, double precision)
      * Between(text, double precision, text)
      * Between(text, text, double precision)
6. **GreaterThan**(srcVal, lowerBound, inclusive\[default TRUE\])
    * Returns TRUE if srcVal >= lowerBound and inclusive = TRUE or if srcVal > lowerBound and inclusive = FALSE. Returns FALSE otherwise or if srcVal is NULL.
    * e.g. GreaterThan(5, 0, TRUE)
    * Signatures:
      * GreaterThan(double precision, double precision, boolean)
      * GreaterThan(int, double precision, boolean)

7. **LessThan**(srcVal, upperBound, inclusive\[default TRUE\])
    * Returns TRUE if srcVal <= lowerBound and inclusive = TRUE or if srcVal < lowerBound and inclusive = FALSE. Returns FALSE otherwise or if srcVal is NULL.
    * e.g. LessThan(1, 5, TRUE)
    * Signatures:
      * LessThan(double precision, double precision, boolean)
      * LessThan(int, double precision, boolean)

8. **HasUniqueValues**(srcVal, lookupSchemaName, lookupTableName, occurences\[default 1\])
    * Returns TRUE if number of occurences of srcVal in source_val column of lookupSchemaName.lookupTableName equals occurences.
    * e.g. HasUniqueValues(TA, public, species_lookup, 1)
    * Signatures:
      * HasUniqueValues(text, name, name, int)
      * HasUniqueValues(double precision, name, name, int)
      * HasUniqueValues(int, name, name, int)

9. **Match**(srcVal, lookupSchemaName, lookupTableName, ignoreCase\[default TRUE\]) - table version
    * Returns TRUE if srcVal is present in the source_val column of lookupSchemaName.lookupTableName. Ignores letter case if ignoreCase = TRUE.
    * e.g. TT_Match(sp1,public,species_lookup, TRUE)
    * Signatures:
      * Match(text, name, name, boolean)
      * Match(double precision, name, name, boolean)
      * Match(int, name, name, boolean)

10. **Match**(srcVal, lst, ignoreCase\[default TRUE\]) - list version
    * Returns TRUE if srcVal is in lst. Ignores letter case if ignoreCase = TRUE.
    * e.g. Match('a', 'a,b,c', TRUE)
    * Signatures:
      * Match(text, text)
      * Match(double precision, text)
      * Match(int, text)

11. **False**()
    * Returns FALSE.
    * e.g. False()
    * Signatures:
      * False()

12. **IsString**(srcVal[])
    * Returns TRUE if srcVal are all strings.
    * e.g. IsString('a', 'b', 'c')
    * Signatures:
      * IsString(text[])
      * IsString(double precision[])
      * IsString(int[])
      
## Translation Functions

1. **Copy**(srcVal)
    * Returns srcVal without any transformation.
    * e.g. Copy(sp1)
    * Signatures:
      * Copy(text)
      * Copy(double precision)
      * Copy(int)
      * Copy(boolean)

2. **Concat**(sep, processNulls, srcVal[])
    * Returns the concatenated source values separated by sep. NULLs are ignored if processNulls = TRUE. An error is raised if processNulls = FALSE and any srcVal is NULL.
    * e.g. Concat('_', FALSE, 'a', 'b', 'c')
    * Signatures:
      * Concat(text, boolean, text[])

3. **Lookup**(srcVal, lookupSchemaName, lookupTableName, lookupCol, ignoreCase\[default TRUE\])
    * Returns value from lookupColumn in lookupSchemaName.lookupTableName that matches srcVal in source_val column. If multiple matches, first row is returned.
    * e.g. Lookup(sp1, public, species_lookup, targetSp)
    * Signatures:
      * Lookup(text, name, name, text, boolean)
      * Lookup(double precision, name, name, text, boolean)
      * Lookup(int, name, name, text, boolean)

4. **Length**(srcVal)
    * Returns the length of the srcVal string.
    * e.g. Length('12345')
    * Signatures:
      * Length(text)
      * Length(double precision)
      * Length(int)

5. **Pad**(srcVal, targetLength, padChar\[default x\])
    * Returns a string of length targetLength made up of srcVal preceeded with padChar if source value length < targetLength. Returns srcVal trimmed to targetLength if srcVal length > targetLength.
    * e.g. Pad(tab1, 10, x)
    * Signatures:
      * Pad(text, int, text)
      * Pad(double precision, int, text)
      * Pad(int, int, text)

6. **Map**(srcVal, lst1, lst2, ignoreCase\[default TRUE\])
    * Return value in lst2 that matches index of srcVal in lst1. Ignore letter cases if ignoreCase = TRUE.
    * e.g. Map('A','A,B,C','1,2,3', TRUE)
    * Signatures:
      * Map(text, text, text, boolean)
      * Map(double precision, text, text, boolean)
      * Map(int, text, text, boolean)

# Adding Custom Helper Functions
Additional helper functions can be written in PL/pgSQL. They must follow the following conventions:

  * All helper function names must be prefixed with "TT_". The prefix must not be used in the translation file. This is necessary to create a restricted namespace for helper functions so that no standard PostgreSQL functions (which do not necessarily comply to these conventions) can be used.
  * All helper functions (validation and translation) must accept only text parameters (the engine convert everything to text before calling the function).
  * All helper functions (validation and translation) must raise an exception when parameter other than the source value are NULL or of an invalid type.
  * Validation functions must always return a boolean. They must handle NULL and empty values and in those cases return the appropriate boolean value.
  * Helper function should NOT be implemented as VARIADIC functions accepting an arbitrary number of parameters. If an arbitrary number of parameters must be supported, it should be implemented as a list of text values separated by a comma or a semicolon.
  
If you think your custom helper function could be of general interest to other framework users, you can submit it to the project. It could be integrated.

# Known issues
1. Single quotes in the translation file are not yet allowed.

# Credit
Pierre Racine, Center for forest research, University Laval

Pierre Vernier, Center for forest research, University Laval

Marc Edwards, Center for forest research, University Laval
