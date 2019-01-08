---
title: "Translation Engine Specifications"
output:
 html_document:
  keep_md: true
---



#### Features

The translation engine basically applies a set of translation rules, defined in a translation file, to create a new target table from a existing source table. 

- **Configuration -** The translation engine behavior can be configurated using a set of key/value parameters.

- **Translation file row -** Each target table attribute has it's own row in the translation file. Each row implements a validation rule, determining if the source values are acceptables, an invalid rule, determining what to do when validation fails and a translation rule determining how to create the target attribute value from the source attribute values.

- **Translation file validation -** Validation files are validated before being processed. Target attributes should correspond to what is defined in the configuration file, helper function should exist and no null value should be present.

- **Rules documentation -** In addition to rules, a translation rule row allows textually describing (documenting) corresponding rules and flag them when they are not in synch with the description. This allows an editor to textually specify rules without actually implementing them but still be able to warn the rule writer that the spec changed.

- **Log -** The translation engine log any invalid value and the progress of the translation process. It can be configured to stop or not when encountering an invalid value.

- **Resuming -** The translation engine can be configured to resume from previous execution using the progress status logeg in the log file.

#### Configuration
- Configuration parameters are defined as a set of key/value.
- As far as the number of parameters is small, they can be passed as list of parameter to the main translation engine PostgreSQL function.
- As soon as the number of parameter becomes too big, they should be stored in a filesystem CSV table. In that case the only parameter passed to the function would be the location of the configuration file.
- Current parameters are listed in table 1 below.

**Table 1. Configuration parameters**

attributeName                 Description                                                                                              possibleValues                          defaultValue   exampleValue           
----------------------------  -------------------------------------------------------------------------------------------------------  --------------------------------------  -------------  -----------------------
targetAttributeList           List of target attributes. Default to nothing.                                                           ";" separated list of attribute names   ""             Name; Address; Street; 
stopWhenInvalid               Determine if the engine should stop when a validation rule fails.                                        TRUE/FALSE                              TRUE           FALSE                  
logFrequency                  Number of lines at which to log the translation progress. Used to know from where to resume execution.   int                                     500            100                    
ignoreDescUpToDateWithRules   Ignore when some descUpToDateWithRules flag are set to FALSE.                                            TRUE/FALSE                              FALSE          TRUE                   

#### Translation Files
- A translation file is a filesystem CSV file.
- Table 2 list the different attributes of a translation file.


**Table 2. Translation file attributes**

attributeName           description                                                                                                                                                                                                                                                                                                                                          exampleValue                                                              
----------------------  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  --------------------------------------------------------------------------
targetAttribute         Name of the target attribute after translation.                                                                                                                                                                                                                                                                                                      fullName                                                                  
targetAttributeType     Type of target attribute (int, decimal, text)                                                                                                                                                                                                                                                                                                        text                                                                      
validateRules           Rule, defined as a set of semi-colon separated list of helper functions, to validate the source attribute.                                                                                                                                                                                                                                           notNull("first_name, last_name");smallerThan("first_name, last_name", 20) 
invalidRules            Rule indicating what to return when validation rule resolve to FALSE.                                                                                                                                                                                                                                                                                invalid(“first_name, last_name”, -9999, -8888, -1111)                     
translateRules          Rules defining the way to transform source attributes into the target attribute.                                                                                                                                                                                                                                                                     concat("first_name", " ", "last_name")                                    
description             Textual description of the validation, invalid, and translation rules. Can be used by non-technical person to describe translation process                                                                                                                                                                                                           Concatenate first_name with last_name to procuce fullName.                
descUpToDateWithRules   Boolean flag indicating that rules are not up to date with the description. Often used when the person writing the description is not the same as the person writing the actual rules or when both columns can not be modified at the same time. The translation engine stops when encounterng a FALSE flag unless specified in the configuration.   FALSE                                                                     


#### Translation File Validation
- The translation engine should validate the list of target attributes and helper function names before starting any translation.
- null or empty values are not accepted in the tranlation file.
- The translation engine should stop if the list of target attribute does not match the names and the order defined in the targetAttributeList configuration variable.
- Regular expression are used to check if helper function names are correct and contents of parentheses are valid. Parsing function will evaluate each helper function. Parser should also check if values outputted by the translationRules matches targetAttributeType.
- The translation engine should stop by default if descUpToDateWithRules is set to FALSE for any target attribute. This behavior is configurable.

#### Logging and Resuming
- Logging invalid values - log each invalidation once and report number of occurrences.
    - E.g. 'Species "bFf" entered 204 times.'
- Logging is recorded as a table in the database
    - Fields: time, translationFileName, description, count, rowNumber
- Log file is used to resume translation after stop.
    - Log file should log progress of translation every 100 lines.

#### Helper Functions
- Can distinguish between absent and invalid values. Absent = -9999, invalid = -8888.
 



\  


### Helper Functions Specifications
**Helper function** - to determine if a value is valid or invalid

#### Constants
- -9999 = Invalid values that are not null
- -8888 = Undefined value - true null value - applies to all types
- -1111 = Empty string ("") - does not apply to int and float

- Note: Talk to Benedicte about constants

- From Perl code:
    - INFTY => -1
    - ERRCODE => -9999
    - SPECIES_ERRCODE => "XXXX ERRC"
    - MISSCODE => -1111
    - UNDEF=> -8889

#### Validation rules functions

- **bool TT_Between(str variable, int lower_bnd, bool lb_inclusive=TRUE, int upper_bnd, bool ub_inclusive=TRUE)**
    - Returns a boolean: true if "variable" is >= "lower_bnd" and <= "upper_bnd"; else false
    - "lower_bnd" and "upper_bnd" are inclusive by default
    - Set "lb_inclusive" or "ub_inclusive" to FALSE to exclude corresponding bounds

- **bool TT_GreaterThan(str variable, float lower_bnd, bool lb_inclusive=TRUE)**
    - Returns a boolean: TRUE if "variable" is >= "lower_bnd"; else FALSE
    - "lower_bnd" is inclusive by default
    - Set "lb_inclusive" to FALSE to exclude corresponding bounds

- **bool TT_LesserThan(str variable, float upper_bnd, bool ub_inclusive=TRUE)**
    - Returns a boolean: TRUE if "variable" is >= "upper_bnd"; else FALSE
    - "upper_bnd" is inclusive by default
    - Set "ub_inclusive" to FALSE to exclude corresponding bounds

#### Invalid rules functions

- **Int TT_Invalid(str attribute_name, int null_value, int empty_value, int invalid_value)**
    - Returns "null_value" if "attribute_name" is a true null, "empty_value" if the "attribute_name" is an empty string,  "invalid_value" otherwise (if not null or not empty).
