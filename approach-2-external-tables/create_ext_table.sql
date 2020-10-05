-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create external tables to point to your data from Snowflake.
-- Replace "MY_EXT_TABLE" with your preferred names.
-- Replace "MY_DB", "MY_SCHEMA", and "MY_STAGE" with the names you used in previous steps .
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-external-table.html
-- https://docs.snowflake.com/en/sql-reference/data-types.html
-- Query performance against external tables is highly dependent on a good partitioning scheme within your object store folder structures based on how your users will query your data, or based on how your materialized views will materialized the data in Snowflake as new data arrives. It is common to partition data by tenant (user, company, etc) and time (year, month, day), though your exact needs will vary.
-- Note that this is a single basic example external table with a few columns representing the more common data types; it will need to be customized to your data and the columns in your data and repeated for as many tables as you need. More advanced options are available in the documentation.

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

-- Create one or more external tables to point to your data from Snowflake.
-- This examples assumes that data files are organized into a <stage>/<tenant_id>/<year>/<month>/<day_num> structure. Note the use of 'METADATA$FILENAME' to extract parts of the file path. You may need to change the numbers in the SPLIT_PART function based on your file path construction and the value of "MY_FILE_PATH" below, if any.
-- There is currently no option to reverse engineer a table structure from a file, so this step must be done before you can query your data through Snowflake. 
-- You will need to think about your tables and table structure relative to how your data changes over time and how your customers expect to see those changes (eg, the latest view only vs snapshots over time)

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE EXTERNAL TABLE MY_EXT_TABLE (
TENANT_ID NUMBER AS TO_NUMBER(SPLIT_PART(METADATA$FILENAME, '/', 2)) COMMENT 'A NUMBER COLUMN REPRESENTING THE TENANT_ID DERIVED FROM THE FILE PATH',
COL2 DATE AS TO_DATE(SPLIT_PART(METADATA$FILENAME, '/', 3) || '/' || SPLIT_PART(METADATA$FILENAME, '/', 4) || '/' || SPLIT_PART(METADATA$FILENAME, '/', 5), 'YYYY/MM/DD') COMMENT 'A DATE COLUMN CREATED BY CONCATENATING THE PARTS OF THE FILE PATH THAT REPRESENT YEAR, MONTH, AND MONTH DAY NUMBER',
COL3 STRING AS (VALUE:C1::STRING) COMMENT 'A STRING COLUMN THAT REFERENCES THE FIRST COLUMN IN THE CSV',
COL4 STRING AS (VALUE:C2::STRING) COMMENT 'A STRING COLUMN THAT REFERENCES THE SECOND COLUMN IN THE CSV',
COL5 NUMBER AS (VALUE:C3::NUMBER) COMMENT 'A NUMBER COLUMN THAT REFERENCES THE THIRD COLUMN IN THE CSV',
) 
PARTITION BY (COL1, COL2)
LOCATION = @MY_STAGE/<MY_FILE_PATH>
FILE_FORMAT = (FORMAT_NAME = MY_FORMAT)
REFRESH_ON_CREATE = TRUE;
COMMENT='A TABLE COMMENT'
;

-- Verify that you can see table results. It is possible that the external table creates successfully but because of mistakes in the external table definition above, rows are not visible.

SELECT * FROM MY_EXT_TABLE LIMIT 5;
