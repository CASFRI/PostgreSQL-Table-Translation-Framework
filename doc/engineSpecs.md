#### Features

The translation engine basically applies a set of translation rules,
defined in a translation table, to create a new target table from a
existing source table.

-   **Installation -** The translation engine is installed as a set of
    PostgreSQL functions defined in a .SQL file.

-   **Configuration parameters -** The translation engine behavior can
    be configurated using a set of key/value parameters.

-   **Translation table -** Rules for translating a source table into a
    target table are defined in a translation table. Each target table
    attribute is translated following a set of rules defined in one
    dedicated row of the translation table. There is one row per target
    attribute. Each row implements a set of "validation rules",
    determining if the source values are valid and what to do otherwise,
    and a "translation rule", determining how to create the target
    attribute value from the source attribute values.

-   **Rules documentation -** In addition to validation and translation
    rules, a translation row allows textually describing (documenting)
    corresponding rules and flag them when they are not in sync with the
    description. This allows an editor to textually specify rules
    without actually implementing them but still be able to warn the
    actual rule coder that the translation specification changed.

-   **Execution -** The translation engine is executed as any normal SQL
    function. It returns a SETOF rows of type RECORD.

-   **Translation file validation -** Translation tables are validated
    before being processed. Target attributes should match the attribute
    names and their order as defined in the configuration file. Helper
    functions should exist and no NULL value should be present in the
    translation table.

-   **Logging -** The translation engine produce a log table indicating
    invalidated values and progress of the translation process. The
    translation engine can be configured to stop or not as soon as it
    encounters an invalid value.

-   **Resuming -** The translation engine can be configured to resume
    from the previous execution using the progress status logged in the
    log file.

#### Configuration parameters

-   Translation engine configuration parameters are defined as a set of
    key/value.
-   As long as the number of parameters stays small, they can be passed
    as list of parameters to the main translation engine function.
-   As soon as the number of parameters becomes too big, they should be
    stored in a table having two columns: "parameter" and "value". In
    that case the only parameter passed to the function would be the
    name of the configuration table.
-   Current configuration parameters are listed in table 1 below.

**Table 1. Configuration parameters**

<table>
<thead>
<tr class="header">
<th align="left">attributeName</th>
<th align="left">Description</th>
<th align="left">possibleValues</th>
<th align="left">defaultValue</th>
<th align="left">exampleValue</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">sourceTable</td>
<td align="left">Schema and name of the source table to translate.</td>
<td align="left">text</td>
<td align="left">no default value, mandatory</td>
<td align="left">trans.source01</td>
</tr>
<tr class="even">
<td align="left">translationTable</td>
<td align="left">Schema and name of the translation table.</td>
<td align="left">text</td>
<td align="left">no default value, mandatory</td>
<td align="left">trans.translation01</td>
</tr>
<tr class="odd">
<td align="left">targetAttributeList</td>
<td align="left">List of target table attributes.</td>
<td align="left">&quot;;&quot; separated list of attribute names</td>
<td align="left">no default value, mandatory</td>
<td align="left">Name; Address; Street;</td>
</tr>
<tr class="even">
<td align="left">stopOnInvalid</td>
<td align="left">Globally determine if the engine should stop when a validation rule fails. This is mainly to validate and fix the source table when it is possible. When set to FALSE, validation rules can still be individually set so that the engine stop when when they resolve to FALSE.</td>
<td align="left">TRUE/FALSE</td>
<td align="left">TRUE</td>
<td align="left">FALSE</td>
</tr>
<tr class="odd">
<td align="left">logFrequency</td>
<td align="left">Number of lines at which to log the translation progress. Used by the translation engine to know from where to resume a following execution.</td>
<td align="left">int</td>
<td align="left">500</td>
<td align="left">100</td>
</tr>
<tr class="even">
<td align="left">ignoreDescUpToDateWithRules</td>
<td align="left">Have the translation engine ignore descUpToDateWithRules flags set to FALSE. To be used in case one want to process all the rules even when some are not up to date with their textual description. This flag should always be set to FALSE when producing an official version of the target table.</td>
<td align="left">TRUE/FALSE</td>
<td align="left">FALSE</td>
<td align="left">TRUE</td>
</tr>
</tbody>
</table>

#### Translation Tables

-   A translation table is normal PostgreSQL table having a specific
    structure.
-   Table 2 list the different attributes of a translation table.

**Table 2. Translation table attributes**

<table>
<thead>
<tr class="header">
<th align="left">attributeName</th>
<th align="left">description</th>
<th align="left">exampleValue</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">targetAttribute</td>
<td align="left">Name of the target attribute after translation. Should not contain SPACEs and be shorter than 64 characters.</td>
<td align="left">fullName</td>
</tr>
<tr class="even">
<td align="left">targetAttributeType</td>
<td align="left">Type of target attribute (int, decimal, text). All PostgreSQL types are allowed.</td>
<td align="left">text</td>
</tr>
<tr class="odd">
<td align="left">validationRules</td>
<td align="left">Rule, defined as a set of semi-colon separated list of helper functions, to validate the source attribute.</td>
<td align="left">notNull(&quot;first_name, last_name&quot;,-8888);smallerThan(&quot;first_name, last_name&quot;, 20, -9999)</td>
</tr>
<tr class="even">
<td align="left">translationRules</td>
<td align="left">Rules defining the way to transform source attributes into the target attribute.</td>
<td align="left">concat(&quot;first_name&quot;, &quot; &quot;, &quot;last_name&quot;)</td>
</tr>
<tr class="odd">
<td align="left">description</td>
<td align="left">Textual description of the validation, invalid, and translation rules. Can be used by non-technical person to describe translation process</td>
<td align="left">Concatenate first_name with last_name to procuce fullName.</td>
</tr>
<tr class="even">
<td align="left">descUpToDateWithRules</td>
<td align="left">Boolean flag indicating that rules are not up to date with the description. Used when the person writing the description is not the same as the person coding the actual rules or when both columns can not be modified at the same time. The translation engine stops when encounterng a FALSE flag unless specified in the configuration table &quot;ignoreDescUpToDateWithRules&quot; parameter.</td>
<td align="left">FALSE</td>
</tr>
</tbody>
</table>

#### Execution

-   The translation engine is executed as any normal SQL function
    (TT\_Translate(parameters...)).
-   It can be used as part of any SELECT, FROM or WHERE SQL statement
    parts. e.g. CREATE TABLE AS SELECT (TT\_Translate(parameters...)).\*
-   TT\_Translate(parameters...) returns a SETOF rows of type RECORD.

-   Note: If it is not possible to return a SETOF RECORD, an
    initialisation function TT\_Init() could create a empty table with
    the right types and TT\_Translate() could rewrite itself into a
    temporary function with the temporary table as return type.
    TT\_Translate() would then return the result of this temporary
    function...

-   Another option would be to have the translation engine to return one
    row per call. The drawback is that the translation table would have
    to be read for each source row. i.e. maybe millions of time. One
    advantage of this option is that the TT\_Translate() function would
    be more compatible with SQL syntax in that it would not refer to the
    source table as a parameter but in the FROm clause. TT\_Translate()
    would only refer to its values.

-   The execution stops if any of these condition is encountered:

    -   The configuration variable "stopOnInvalid"" is set to TRUE and a
        source value is invalidated by a validation rule. This use case
        is helpful for validating and fixing source values when
        possible.
    -   No invalidation value is defined for a validation rule and the
        source value is invalidated by this validation rule. This makes
        it mandatory to define an invalidation value. The translation
        process can not finish otherwise.
    -   The configuration variable "stopOnInvalid"" is set to FALSE, all
        invalidation values are provided, one validation rule has its
        "stopOnInvalid" flag set and a source value is invalidated by
        this validation rule. This use case is helpful in a typical
        execution sequence as described below:

-   Typical execution sequence:

    1.  Write a basic translation table.
    2.  Translate.
    3.  Translation stops as soon as a validation rule not providing an
        invalidation value or having its "stopOnInvalid" parameter
        specifically set to TRUE fails.
    4.  Update the translation table and resume execution; back to step
        2).
    5.  Translation file is complete. Translate from scratch with all
        invalidation values provided and "stopOnInvalid" set to FALSE in
        the configuraiton file and not set (default to FALSE) in any
        validation rule.

-   These configuration options provide enough flexibility for many use
    cases.
-   Multiple translations are managed though normal SQL coding.

#### Translation File Validation

-   The translation engine must validate the structure and the content
    of the valisation file before starting any translation (or during
    the first translation?):

    -   the list of target attributes names must match the names and the
        order defined in the "targetAttributeList" configuration
        variable. Each name should be shorter than 64 charaters and
        contain no spaces.
    -   helper function names should match existing function and their
        parameters should be in the right format.
    -   there should be no null or empty values in the translation file.

-   The translation engine should stop if the translation table is
    invalidated in any way. This should not be configurable.
-   Regular expression are used to check if helper function names and
    their parameters are valid. Parsing function will evaluate each
    helper function. Parser should also check if values outputted by the
    translation rule matches "targetAttributeType".
-   The translation engine should stop by default if
    "descUpToDateWithRules"" is set to FALSE for any target attribute.
    This behavior is configurable.

#### Logging and Resuming

-   The translation engine logs, in a logging table, the translation
    progress and any invalid value.
-   The logging table has the same name as the source table with "\_log"
    as suffix.

-   The logging table has the following columns:
    -   **logid -** identifier of the log entry. A simple incrementing
        number.
    -   **timestamp -** date and time of the log entry.
    -   **type -** type of the logging entry (PROGRESS or INVALIDATION).
    -   **message -** logging message itself mostly indicating reason of
        invalidation.
    -   **rowNumber -** number of the first row having triggered the log
        entry.
    -   **count -** number of occurrence of the same invalidation since
        first trigered in the case of an INVALIDATION entry or the
        number or row processed in the case of a PROGRESS entry. That
        last number is used to determine the row from which to resume in
        a subsequent execution if this option is activated.
-   If the translation engine is stopped by an invalidation condition,
    or because of a system failure, it can resume its process, in a
    subsequent execution, starting at the row having triggered the
    invalid entry or after the last row processed. In the first case
    this row is determined by the "rowNumber" logging table attribute.
    In the last case this row is computed from the first row triggering
    the last PROGRESS entry (equally stored as "rowNumber") + the
    "count" of processed rows for this entry.
-   All invalid values are reported in the log even if invalidation
    rules are defined for those values and the engine is not set to stop
    on invalidation.
-   If the translation engine is set to not stop when encountering an
    invalid value, it may generate thousands, even millions of similar
    log entries. To avoid this, entries of the same type are simply
    counted and their count is reported instead of reporting one row per
    invalidation.
-   The translation engine may be configured to continue even if an
    invalid value is encountered. This behavior is usefull to get a
    complete report of invalid values.
-   Progress is reported every "logFrequency" lines. This is a
    configuration variable defaulting to 500.

### Helper Functions Specifications

-   There are two types of helper function:

    -   **validation helper functions:** Return an invalidation code
        when passed values do not fulfill some specific conditions or a
        valid value.

    -   **translation helper functions:** Return a specific value when
        validation rules are fulfilled.

-   All validation helper functions should be able to accept a single
    attribute or a comma separated list of attributes. E.g.
    smallerThan("first\_name, last\_name", 20) so that the function
    returns FALSE is any of the listed value does not fulfill the
    condition.
-   When applicable, translate helper functions should be designed to be
    able to transform one or many attributes into one.
-   Only "validationRules" can be a semi-colon separated list of helper
    functions. This is the equivalent of putting a AND logical operator
    between each function.
-   Every validation function must take a list of values, some
    parameters, an invalidation value and a flag indicating to stop the
    translation engine or not when one value is invalidated.
-   Every validation function must return TRUE, FALSE or the
    invalidation value.
-   Translation rules must take a list of values and a set of parameters
    and return a single value of type compatible with the type of the
    target attribute as defined by "targetAttributeType".
-   Translation functions should always double check for null values and
    if the passed values are of the right type.

#### List of validation rules functions

-   **bool between(str variable, int lowerBound, bool lbInclusive=TRUE,
    int upperBound, bool ubInclusive=TRUE, str invalidValue=NULL,
    boolean stopEngine=FALSE)**
    -   TRUE if "variable" &gt;= "lowerBound" and "variable" &lt;=
        "upperBound", FALSE or invalidValue otherwise.
    -   "lbInclusive" and "ubInclusive" determines if corresponding
        bounds are inclusive or not.
-   **bool greaterThan(str variable, float lowerBound, bool
    inclusive=TRUE, str invalidValue=NULL, boolean stopEngine=FALSE)**
    -   TRUE if "variable" is &gt;= "lowerBound", FALSE or invalidValue
        otherwise.
    -   "inclusive" determines if "lowerBound" is inclusive.
-   **bool lesserThan(str variable, float upperBound, bool
    inclusive=TRUE, str invalidValue=NULL, boolean stopEngine=FALSE)**
    -   TRUE if "variable" is &gt;= "upperBound", FALSE or invalidValue
        otherwise.
    -   "inclusive" determines if "upperBound" is inclusive.

#### Notes

-   CAS specific error codes extracted from Perl code:
    -   INFTY =&gt; -1
    -   ERRCODE =&gt; -9999 = Invalid values that are not null
    -   SPECIES\_ERRCODE =&gt; "XXXX ERRC"
    -   MISSCODE =&gt; -1111 = Empty string ("") - does not apply to int
        and float
    -   UNDEF=&gt; -8888 = Undefined value - true null value - applies
        to all types
