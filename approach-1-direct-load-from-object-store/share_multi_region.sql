-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Replicate your Snowflake database(s) to other regions/clouds for sharing in those regions
-- Replace "MY_USER" with the user you use to log into Snowflake
-- Replace "MY_TABLE", "MY_DB", "MY_SCHEMA", "MY_WH", "MY_STAGE", "MY_FORMAT" with the names you used in previous steps
-- REPLACE "MY_SECONDARY_REGION", "MY_SECONDARY_ACCOUNT", "MY_EMAIL", and "MY_EDITION" with your values
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/user-guide/database-replication-intro.html
-- https://docs.snowflake.com/en/user-guide/data-pipelines.html
-- The steps in this guide refer to your "PRIMARY" account and any "SECONDARY" accounts. The general flow is that you will load your data into one Snowflake account (PRIMARY) and replicate that data to other Snowflake accounts (SECONDARY). In the beginning of this script, you will set yourself up as an Organization in your PRIMARY account and then create any required SECONDARY accounts, enabling them for replication. Then you will configure a one-time and recurring replication.

-- Contact your Snowflake team to make sure you are enabled for the Organizations Preview

-- Using your PRIMARY account
-- Grant yourself ORGADMIN privileges

GRANT ROLE ORGADMIN TO USER MY_USER;

-- Create one or more accounts in various clouds/regions
-- Make sure you understand what edition of Snowflake you are using by navigating to the "Organization" area of the Snowflake UI and noting your edition

USE ROLE ORGADMIN;

-- Show the list of all possible Snowflake regions and note the one you want

SHOW REGIONS;

CREATE ACCOUNT MY_SECONDARY_ACCOUNT ADMIN_NAME=MY_USER, ADMIN_PASSWORD='CHANGEM3', EMAIL='MY_EMAIL', EDITION='MY_EDITION', REGION='MY_SECONDARY_REGION', COMMENT='A COMMENT'; 

-- Enable replication for your account

SELECT SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER('MY_PRIMARY_ACCOUNT', 'ENABLE_ACCOUNT_DATABASE_REPLICATION', 'TRUE');

-- Alter your database to be a primary database for replication

SHOW REPLICATION ACCOUNTS;

-- Make a note of the organization, snowflake_region, and account name columns from the above query results

-- Log in to each of the SECONDARY ACCOUNTS
-- Enable replication for each account

SELECT SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER('MY_SECONDARY_ACCOUNT', 'ENABLE_ACCOUNT_DATABASE_REPLICATION', 'TRUE');

-- Return to PRIMARY ACCOUNT

USE ROLE ACCOUNTADMIN;

ALTER DATABASE MY_DB ENABLE REPLICATION TO ACCOUNTS
MY_ORGANIZATION.MY_SECONDARY_ACCOUNT
-- repeat a comma separated list as needed
;

-- In each of the SECONDARY ACCOUNTS
-- Create replica database 

CREATE DATABASE MY_DB
AS REPLICA OF MY_ORGANIZATION.MY_PRIMARY_ACCOUNT.MY_DB
-- Where MY_ORGANIZATION.MY_PRIMARY_ACCOUNT is your PRIMARY account 
AUTO_REFRESH_MATERIALIZED_VIEWS_ON_SECONDARY = TRUE
-- This guide has not discussed materialized views, which is a feature enabled in our ENTERPRISE edition, but if you decide to use this Snowflake feature in your PRIMARY MY_DB, you will likely want those materialized views to be refreshed in the SECONDARY versions as well
;

SHOW REPLICATION DATABASES;

-- You should see the primary database and each secondary database you have created so far

-- Perform the initial refresh of the secondary database from the primary database. Depending on your data volume, you may need to increase the statement timeout parameter for the initial replication using the documentation below:
-- https://docs.snowflake.com/en/user-guide/database-replication-config.html#increasing-the-statement-timeout-for-the-initial-replication

ALTER DATABASE MY_DB REFRESH;

-- Monitor progress 

USE DATABASE MY_DB;

SELECT * FROM TABLE(INFORMATION_SCHEMA.DATABASE_REFRESH_PROGRESS(MY_DB));

-- For future refreshes of the secondary database, you have three choices: 1) manually run the refresh on each secondary account using the same command as shown above for the initial refresh, 2) create a Snowflake task to run the refresh command on a schedule or interval, or 3) use some external tooling or service to run the command as an outside call into Snowflake. Option 2 is shown below.

-- Create necessary objects to store and execute the refresh task. If you have more than one secondary database per account (because you are replicating multiple databases), you can create one "control" database, one "replication" warehouse, and a task per secondary database. You do not need to create many control databases/warehouses, though you may need to increase 

CREATE OR REPLACE DATABASE REPLICATION_CONTROL;

CREATE OR REPLACE WAREHOUSE REPLICATION_WH
WITH
WAREHOUSE_SIZE = XSMALL
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
;

-- The example below assumes that this replication refresh task will be run hourly, reflected by the format which is documented in the link below. You can customize the schedule to your needs. See the documentation below for more details.
-- https://docs.snowflake.com/en/sql-reference/sql/create-task.html
 
USE SCHEMA REPLICATION_CONTROL.PUBLIC;

CREATE OR REPLACE TASK MY_DB_REPLICATION_TASK
WAREHOUSE = REPLICATION_WH
SCHEDULE = '60 minute'
AS 
ALTER DATABASE MY_DB REFRESH
;

-- Resume the suspended task

ALTER TASK MY_TASK RESUME;

-- Optionally, create the same share in the SECONDARY account(s) as the PRIMARY account. This can also be done from the UI when fulfilling a request.

CREATE OR REPLACE SHARE MY_SHARE;

GRANT USAGE ON DATABASE MY_DB TO SHARE MY_SHARE;

GRANT USAGE ON SCHEMA MY_DB.MY_SHARED_SCHEMA TO SHARE MY_SHARE;

GRANT SELECT ON VIEW MY_DB.MY_SHARED_SCHEMA.MY_SECURE_VIEW TO SHARE MY_SHARE;

-- Examine share metadata

SHOW SHARES LIKE 'MY_SHARE%';

DESC SHARE MY_SHARE;
