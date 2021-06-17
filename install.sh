#!/bin/bash -x
#
# This script install the Table Translation Framework in the 
# PostgreSQL folder to be installed as en extension.
#
# Copy the configSample.bat file to config.bat and 
# and edit the path to your PostgreSQL installation.
# Once installed you can install the extension in your database by doing:
#
# CREATE EXTENSION IF NOT EXISTS table_translation_framework;
# 
# and deinstall bu doing:
#
# DROP EXTENSION IF EXISTS table_translation_framework;
#

ext_name=table_translation_framework
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load config variables from local config file
# Load config variables from local config file
if [ -f $scriptDir/config.sh ]; then 
  source $scriptDir/config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

ctrl_file="$pghome/share/extension/$ext_name.control"
sql_file="$pghome/share/extension/$ext_name--$tt_version.sql"

# Create the table_translation_framework.control file

cat > "$ctrl_file" <<- EOM
# table translation framework
comment = 'Translate a table into another table using a translation table.'
default_version = '$tt_version'
relocatable = false
EOM

# Create the table_translation_framework.sql file

cat > "$sql_file" <<- EOM
/* $ext_name--$tt_version.sql */
-- complain if script is sourced in psql, rather than via CREATE EXTENSION

\echo Use "CREATE EXTENSION $ext_name;" to load this file. \quit

-- Engine part --

EOM

cat engine.sql >> "$sql_file"

cat >> "$sql_file" <<- EOM

-- Helper Functions Part --

EOM

cat helperFunctions.sql >> "$sql_file"

cat >> "$sql_file" <<- EOM

-- GIS Helper functions part --

EOM

cat helperFunctionsGIS.sql >> "$sql_file"
