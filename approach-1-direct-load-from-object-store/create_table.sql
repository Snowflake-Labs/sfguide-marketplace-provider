-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create tables to house your data in Snowflake
-- Replace "MY_TABLE" with your preferred names
-- Replace "MY_DB" and "MY_SCHEMA" with the names you used in previous steps 
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-table.html
-- https://docs.snowflake.com/en/sql-reference/data-types.html
-- Note that this is a single basic example table with a few columns representing the more common data types; it will need to be customized to your data and the columns in your data and repeated for as many tables as you need. More advanced options are available in the documentation.
-- There is currently no option to reverse engineer a table structure from a file, so this step must be done before loading data into Snowflake. Alternatively, we have included at the bottom of this script an option to create a schema-less table using our VARIANT data type for semi-structured data (JSON, etc).
-- You will need to think about your tables and table structure relative to how your data changes over time and how your customers expect to see those changes (eg, the latest view only vs snapshots over time)

-- For a regular structured database table:

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE TABLE MY_TABLE (
COL1 NUMBER NOT NULL COMMENT 'A NUMBER COLUMN THAT CANNOT BE NULL - SEE THE DOCS FOR VARATIONS, SIZE, AND PRECISION',
COL2 STRING COMMENT 'A TEXT COLUMN THAT CAN BE NULL - SEE THE DOCS FOR VARIATIONS AND SIZING',
COL3 DATE COMMENT 'A DATE COLUMN THAT CAN BE NULL - SEE THE DOCS FOR ACCEPTED FORMATS',
COL4 TIME COMMENT 'A WALLCLOCK TIME COLUMN THAT CAN BE NULL - SEE THE DOCS FOR ACCEPTED FORMATS AND PRECISION',
COL5 TIMESTAMP_NTZ COMMENT 'A TIMESTAMP COLUMN THAT CAN BE NULL WITH NO TIMEZONE SPECIFIED',
COL6 TIMESTAMP_LTZ COMMENT 'A TIMESTAMP COLUMN THAT CAN BE NULL THAT SPECIFIES THE TIMEZONE OF THE USER SESSION'
) 
COMMENT='A TABLE COMMENT'
;

----------------------------------------------

-- For a schema-less table loaded with semi-structured data (JSON, etc)

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE TABLE MY_TABLE (
COL1 VARIANT NOT NULL COMMENT 'A COLUMN TO HOLD SEMI-STRUCTURED DATA THAT CANNOT BE NULL - SEE THE DOCS FOR DETAILS',
COL2 TIMESTAMP_LTZ COMMENT 'IT IS A GOOD PRACTICE TO INCLUDE A TIMESTAMP FOR WHEN THE ROW WAS INSERTED'
) 
COMMENT='A TABLE COMMENT'
;