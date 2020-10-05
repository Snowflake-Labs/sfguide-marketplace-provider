-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Prepare yourself to share in other clouds/regions based on the cloud/region where your customers have Snowflake accounts.
-- Replace "MY_USER" and "MY_SECONDARY_ACCOUNT" with your existing and preferred values.
-- This approach requires you to "clone" the setup in your primary account to all other Snowflake accounts that you operate. This is one benefit of this approach - each Snowflake account is the same except for a few exceptions noted below.
-- The steps in this guide refer to your "PRIMARY" account and any "SECONDARY" accounts. The general flow is that you will repeat the setup you did in your PRIMARY account to all SECONDARY accounts. In the beginning of this script, you will set yourself up as an Organization in your PRIMARY account and then create any required SECONDARY accounts. Then you will re-execute most of the steps done 

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

-- Re-execute the following setup steps in your SECONDARY Snowflake accounts based on however many accounts you created above. Additional notes are provided for each step where needed.

-- 1. Create a virtual warehouse (create_warehouse.sql - script is at the root level)

-- 2. Create a database and schema (create_database.sql - script is at the root level)

-- 3. Create an external stage (create_stage.sql - script is at the root level)
-- In this step, you are pointing to the same external stage location from every account, no matter what cloud/region the external stage and the Snowflake account reside in. For example, it's possible to create an S3-based external stage in an Azure-hosted Snowflake account. The setup steps are exactly the same.

-- 4. Create one or more external tables to point to your data from Snowflake (create_ext_table.sql)

-- 5. Create one or more materialized views to create highly performant copies of your external tables in Snowflake (create_matview.sql)
-- In this step you are likely employing a filter (WHERE clause) in the SQL statement that defines the materialized view because you want to only materialize (ingest) the data for the customers who will be receiving a share from that account. Note that while this accelerator shows hard-coding within the WHERE clause for the materialized view statement, it is possible to use Snowflake stored procedures to dynamically generate the materialized view CREATE statement and dynamically populate the WHERE clause with values from the entitlement table, if your entitlement table in a given Snowflake account is only populated with the tenant_id values specific to that account. However, it is not possible in a Snowflake materialized view to populate the WHERE clause with a sub-select to the entitlements table. See the documentation below for an example of how to use a stored procedure to dynamically generate the materialized view create statement:
-- https://docs.snowflake.com/en/sql-reference/stored-procedures-usage.html#dynamically-creating-a-sql-statement
-- Also note that if you ever add a new sharing customer (tenant_id) to that Snowflake account, a new row will need to be added to the entitlements table and the materialized view definition will need to be recreated. This could affect sharing access while the materialized view is being recreated and should be done in off-hours when possible.

-- 6. Create one or more shares (create_share.sql)

-- 7. Create a listing on the Marketplace or Exchange through the UI (create_listing.sql - script is at the root level)
-- In this step, you will not be creating a new listing, but rather expanding the cloud/regions where the existing share is available.

-- 8. Automate the refresh of your external tables (refresh_ext_table.sql)

