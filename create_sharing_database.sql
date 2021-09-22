
-- Copyright (c) 2021 Snowflake Inc. All rights reserved.
-- Create a smaller database to be shared with Marketplace or Data Exchange data consumers and replicated across multiple regions
-- Create tables to house the data to be shared with consumers
-- Set up a recurring task to regularly refresh the shared database and table
-- Replace "MY_SHARED_DB", "MY_SHARED_TABLE", "MY_SHARED_DB_TASK", and "MY_WH" with your preferred names
-- "SOURCE_DB", "SOURCE_SCHEMA", and "SOURCE_TABLE" should refer to your existing primary database
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-database.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-table.html
-- https://docs.snowflake.com/en/sql-reference/data-types.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-task.html
-- https://docs.snowflake.com/en/sql-reference/sql/insert.html
-- This example is designed for data providers that have a large primary database and wish to maintain a smaller database to be shared with external consumers for security or replication cost reasons
-- Note that this is a single basic example table with a few columns representing the more common data types; it will need to be customized to your data and the columns in your data and repeated for as many tables as you need. More advanced options are available in the documentation.
-- You will need to think about your tables and table structure relative to how your data changes over time and how your customers expect to see those changes (eg, the latest view only vs snapshots over time)

-- Create database

CREATE OR REPLACE DATABASE MY_SHARED_DB;

USE DATABASE MY_SHARED_DB;

USE SCHEMA MY_SHARED_DB.PUBLIC;

-- For a regular structured database table:

CREATE OR REPLACE TABLE MY_SHARED_TABLE (
COL1 NUMBER NOT NULL COMMENT 'A NUMBER COLUMN THAT CANNOT BE NULL - SEE THE DOCS FOR VARATIONS, SIZE, AND PRECISION',
COL2 STRING COMMENT 'A TEXT COLUMN THAT CAN BE NULL - SEE THE DOCS FOR VARIATIONS AND SIZING',
COL3 DATE COMMENT 'A DATE COLUMN THAT CAN BE NULL - SEE THE DOCS FOR ACCEPTED FORMATS',
COL4 TIME COMMENT 'A WALLCLOCK TIME COLUMN THAT CAN BE NULL - SEE THE DOCS FOR ACCEPTED FORMATS AND PRECISION',
COL5 TIMESTAMP_NTZ COMMENT 'A TIMESTAMP COLUMN THAT CAN BE NULL WITH NO TIMEZONE SPECIFIED',
COL6 TIMESTAMP_LTZ COMMENT 'A TIMESTAMP COLUMN THAT CAN BE NULL THAT SPECIFIES THE TIMEZONE OF THE USER SESSION'
) 
COMMENT='A TABLE COMMENT'
;

-- Option 1: For a frequent minute-based refresh; timing can be customized be changing the number of minutes between task runs

USE SCHEMA MY_SHARED_DB.PUBLIC;

CREATE TASK MY_SHARED_DB_TASK
  WAREHOUSE = MY_WH
  SCHEDULE = '1440 MINUTE'
AS
INSERT OVERWRITE INTO MY_SHARED_TABLE
	SELECT
		COL1
		, COL2
		, COL3
		, COL4
		, COL5
		, CURRENT_TIMESTAMP()
	FROM SOURCE_DB.SOURCE_SCHEMA.SOURCE_TABLE;

-- Resume the suspended task

ALTER TASK MY_SHARED_DB_TASK RESUME;

-- Option 2: For a weekly refresh at 4am UTC every Monday; timing can be customized using cron format documented in the link below
-- https://docs.snowflake.com/en/sql-reference/sql/create-task.html

USE SCHEMA MY_SHARED_DB.PUBLIC;

CREATE TASK MY_SHARED_DB_TASK
  WAREHOUSE = MY_WH
  SCHEDULE = '0 4 * * 1 UTC'
AS
INSERT OVERWRITE INTO MY_SHARED_TABLE
	SELECT
		COL1
		, COL2
		, COL3
		, COL4
		, COL5
		, CURRENT_TIMESTAMP()
	FROM SOURCE_DB.SOURCE_SCHEMA.SOURCE_TABLE;

-- Resume the suspended task

ALTER TASK MY_TASK RESUME;
