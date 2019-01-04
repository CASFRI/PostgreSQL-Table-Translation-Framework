### Engine tasks:

#### Configuration

-   Config values can be passed as list of variables if long (in which
    case parameter to provide to engine is location of config file), or
    as parameters to the engine if there are few.

#### Translation file validation

-   Translation engine should validate the list of target attributes and
    helper function names before starting translation.
-   Regular expression to check function name is correct, and contents
    of parentheses are valid. Parsing function will evaluate each helper
    function. Parser should also check output values in the
    translationRules are valid.
-   Check if descUtdWithRules is FALSE. Stop if FALSE.
-   Check targetAttributes are in the correct order using
    targetAttributeList.

#### Logging and resuming

-   Logging invalid values - log each invalidation once and report
    number of occurrences.
    -   E.g. 'Species "bFf" entered 204 times.'
-   Logging is recorded as a table in the database
    -   Fields: time, translationFileName, description, count, rowNumber
-   Log file is used to resume translation after stop.
    -   Log file should log progress of translation every 100 lines.

#### Helper functions

-   Can distinguish between absent and invalid values. Absent = -9999,
    invalid = -8888.

 

Table 1. Spec configuration parameters.

<table>
<thead>
<tr class="header">
<th align="left">Config.attribute.name</th>
<th align="left">Possible.values</th>
<th align="left">Description</th>
<th align="left">Example.value</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">stopWhenInvalid</td>
<td align="left">TRUE/FALSE</td>
<td align="left">Should the engine stop when engine invalidates value? Default to FALSE</td>
<td align="left">FALSE</td>
</tr>
<tr class="even">
<td align="left">targetAttributeList</td>
<td align="left">; separated list of attribute names</td>
<td align="left">List of target attributes. Default to nothing</td>
<td align="left">Name; Address; Street;</td>
</tr>
<tr class="odd">
<td align="left">logFrequency</td>
<td align="left">int</td>
<td align="left">Number of lines at which to log progress. Default to 500</td>
<td align="left">100</td>
</tr>
</tbody>
</table>

 

Table 2. Spec translation file.

<table>
<thead>
<tr class="header">
<th align="left">Validation.file.attribute</th>
<th align="left">Example.values</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">targetAttribute</td>
<td align="left">firstname</td>
<td align="left">Name of the target attribute after translation</td>
</tr>
<tr class="even">
<td align="left">targetAttributeType</td>
<td align="left">int</td>
<td align="left">Type of target attribute</td>
</tr>
<tr class="odd">
<td align="left">validationRules</td>
<td align="left">notnull</td>
<td align="left">Rule to validate the source attribute</td>
</tr>
<tr class="even">
<td align="left">invalidRules</td>
<td align="left">nullOrInv(CDE_CO, -9999, -8888)</td>
<td align="left">What to return when validation rule returns FALSE</td>
</tr>
<tr class="odd">
<td align="left">translationRules</td>
<td align="left">map(DOW, 1,2,3,4,5,6,7, Mo,Tu,We,Th,Fr,Sa,Su)</td>
<td align="left">Way to transform source attribute into target attribute</td>
</tr>
<tr class="even">
<td align="left">description</td>
<td align="left">convert number representing day of week with two letter abbreviation</td>
<td align="left">Textual description of the validation, invalid, and translation rules. Can be used by non-technical person to describe translation process</td>
</tr>
<tr class="odd">
<td align="left">descUtdWithRules</td>
<td align="left">FALSE</td>
<td align="left">Flag for non-technical person to indicate that rules are not up to date with description</td>
</tr>
</tbody>
</table>

   

### Helper Functions Specifications

**Helper function** - to determine if a value is valid or invalid

#### Constants

-   -9999 = Invalid values that are not null
-   -8888 = Undefined value - true null value - applies to all types
-   -1111 = Empty string ("") - does not apply to int and float

-   Note: Talk to Benedicte about constants

-   From Perl code:
    -   INFTY =&gt; -1
    -   ERRCODE =&gt; -9999
    -   SPECIES\_ERRCODE =&gt; "XXXX ERRC"
    -   MISSCODE =&gt; -1111
    -   UNDEF=&gt; -8889

#### Validation rules functions

-   **bool TT\_Between(str variable, int lower\_bnd, bool
    lb\_inclusive=TRUE, int upper\_bnd, bool ub\_inclusive=TRUE)**
    -   Returns a boolean: true if "variable" is &gt;= "lower\_bnd" and
        &lt;= "upper\_bnd"; else false
    -   "lower\_bnd" and "upper\_bnd" are inclusive by default
    -   Set "lb\_inclusive" or "ub\_inclusive" to FALSE to exclude
        corresponding bounds
-   **bool TT\_GreaterThan(str variable, float lower\_bnd, bool
    lb\_inclusive=TRUE)**
    -   Returns a boolean: TRUE if "variable" is &gt;= "lower\_bnd";
        else FALSE
    -   "lower\_bnd" is inclusive by default
    -   Set "lb\_inclusive" to FALSE to exclude corresponding bounds
-   **bool TT\_LesserThan(str variable, float upper\_bnd, bool
    ub\_inclusive=TRUE)**
    -   Returns a boolean: TRUE if "variable" is &gt;= "upper\_bnd";
        else FALSE
    -   "upper\_bnd" is inclusive by default
    -   Set "ub\_inclusive" to FALSE to exclude corresponding bounds

#### Invalid rules functions

-   **Int TT\_Invalid(str attribute\_name, int null\_value, int
    empty\_value, int invalid\_value)**
    -   Returns "null\_value" if "attribute\_name" is a true null,
        "empty\_value" if the "attribute\_name" is an empty string,
        "invalid\_value" otherwise (if not null or not empty).
