::
:: This script install the Table Translation Framework in the 
:: PostgreSQL folder to be installed as en extension.
::
:: Copy the configSample.bat file to config.bat and 
:: and edit the path to your PostgreSQL installation.
:: Once installed you can install the extension in your database by doing:
::
:: CREATE EXTENSION IF NOT EXISTS table_translation_framework;
:: 
:: and deinstall bu doing:
::
:: DROP EXTENSION IF EXISTS table_translation_framework;
::

SET tt_version=0.0.4
SET pghome=C:\Program Files\PostgreSQL\11
SET ext_name=table_translation_framework

:: Load config variables from local config file
IF EXIST "%~dp0\config.bat" ( 
  CALL "%~dp0\config.bat"
) ELSE (
  ECHO ERROR: NO config.bat FILE
  EXIT /b
)

SET ctrl_file="%pghome%"\share\extension\%ext_name%.control
SET sql_file="%pghome%"\share\extension\%ext_name%--%tt_version%.sql

:: Create the table_translation_framework.control file

(
ECHO # table translation framework
ECHO comment = 'Translate a table into another table using a translation table.'
ECHO default_version = '%tt_version%'
ECHO relocatable = false
) > %ctrl_file%

:: Create the table_translation_framework.sql file
(
ECHO /* %ext_name%--%tt_version%.sql */
ECHO -- complain if script is sourced in psql, rather than via CREATE EXTENSION
ECHO.
ECHO \echo Use "CREATE EXTENSION %ext_name%;" to load this file. \quit
ECHO.
ECHO -- Engine part --
ECHO.
) > %sql_file%

TYPE engine.sql >> %sql_file%

(
ECHO.
ECHO -- Helper Functions Part --
ECHO.
) >> %sql_file%

TYPE helperFunctions.sql >> %sql_file%

(
ECHO.
ECHO -- GIS Helper functions part --
ECHO.
) >> %sql_file%

TYPE helperFunctionsGIS.sql >> %sql_file%
