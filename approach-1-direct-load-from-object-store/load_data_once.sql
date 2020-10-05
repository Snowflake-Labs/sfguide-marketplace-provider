-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Load your data into your tables in Snowflake one time
-- Replace "MY_TABLE" with the names you used in previous steps
-- Replace "MY_DB" and "MY_SCHEMA" with the names you used in previous steps 
-- Replace "MY_WH" with the name you used in previous steps
-- Replace "MY_STAGE" with the name you used in previous steps
-- Replace "MY_FORMAT" with your preferred names
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-file-format.html
-- https://docs.snowflake.com/en/user-guide-data-load.html
-- Note that this process focuses on an initial data load, but the last step (COPY) can be used to load subsequent new files into the table. This will be covered in more detail in the load_data_recurring.sql file.
-- The Snowflake COPY command is primarily a bulk insert tool. While there are some transformations that can be done on insert, the COPY command cannot UPDATE or DELETE existing records. If your data requires this, the most common pattern is to use the COPY to load an initial staging table, then run additional SQL DML statements to process that data into downstream table(s). That pattern is not covered in this accelerator.

-- Create one or more file formats for your data files, depending on how many different formats you use
-- Create a CSV file format named my_csv_format that defines the following rules for data files: fields are delimited using the pipe character (|), files include a single header line that will be skipped, the strings NULL and null will be replaced with NULL values, empty strings will be interpreted as NULL values, files will be compressed/decompressed using GZIP compression. Your rules may be different - parameters can be changed or omitted based on your files.

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE FILE FORMAT MY_FORMAT
TYPE = CSV
FIELD_DELIMITER = '|'
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null')
EMPTY_FIELD_AS_NULL = TRUE
COMPRESSION = GZIP
;

-- Optional if needed: Create a JSON file format that uses the defaults for all JSON parameters

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE FILE FORMAT MY_FORMAT
TYPE = JSON;

-- Use your previously defined Warehouse, Database, Schema, Table, Stage, and File Format to load data once
-- Replace "MY_FILE.EXTENSION" with your file name and include a file path if necessary when you have many files organized in object story by folders
-- The example below assumes loading a single file. Please see the documentation for loading multiple files using pattern matching.
-- https://docs.snowflake.com/en/sql-reference/sql/copy-into-table.html

USE WAREHOUSE MY_WH;
USE SCHEMA MY_DB.MY_SCHEMA;

-- List files in stage

LS @MY_STAGE;

-- Run a validation check before loading 

COPY INTO MY_TABLE 
FROM @MY_STAGE/[file-path-if-needed]/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
VALIDATION_MODE = 'RETURN_ERRORS'
;

-- If no errors...

COPY INTO MY_TABLE 
FROM @MY_STAGE/file-path-if-needed/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

-- View COPY history for the last hour of history
-- https://docs.snowflake.com/en/sql-reference/functions/copy_history.html 

USE SCHEMA MY_DB.MY_SCHEMA;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(TABLE_NAME=>'MY_TABLE', START_TIME=> DATEADD(HOURS, -1, CURRENT_TIMESTAMP())));

-- View 10 rows of data loaded into the table 

SELECT *
FROM MY_TABLE
LIMIT 10
;
