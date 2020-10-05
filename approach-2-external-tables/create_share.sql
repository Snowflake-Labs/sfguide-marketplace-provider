-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create a share object to allow other Snowflake customers to access your data.
-- Replace "MY_DB", "MY_SCHEMA", "MY_EXT_TABLE" and "MY_EXT_TABLE_MV" with the names you used in previous steps. 
-- Replace "MY_SHARED_SCHEMA", "MY_SECURE_VIEW" and "MY_SHARE" with your preferred names.
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/user-guide-data-share.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-share.html
-- https://docs.snowflake.com/en/user-guide/views-secure.html
-- Note that it is good practice to abstract the objects that other Snowflake customers can see through the use of Secure Views rather than sharing tables directly. Secure Views can be simple views or have account-based row-level security built into them (one Snowflake customer account see one slice of data, another Snowflake customer account sees a different slice). This script inclues an example of setting up row-level security at the bottom of the script.
-- This accelerator also assumes that you are operating as a user with the ACCOUNTADMIN role. If you have implemented more fine-grained role permissions in Snowflake, there are likely tweaks to the code below that will be required based on how you have implemented roles and privileges.
-- This script also 

-- Create a separate schema to align with the share to isolate your shared vs non-shared objects

USE DATABASE MY_DB;

CREATE OR REPLACE SCHEMA MY_SHARED_SCHEMA;

-- Create secure view on your external table(s) or materialized view(s), selecting the appropriate columns that should be visible. It is recommended that you select specific columns instead of * to control the reveal of new columns.

USE SCHEMA MY_DB.MY_SHARED_SCHEMA;

CREATE OR REPLACE SECURE VIEW MY_SECURE_VIEW AS 
SELECT COL1, COL2, COLN FROM MY_DB.MY_SCHEMA.MY_EXT_TABLE;
-- Optionally select from MY_DB.MY_SCHEMA.MY_EXT_TABLE_MV

-- Create share and grant the appropriate privileges to the share 

CREATE OR REPLACE SHARE MY_SHARE;

GRANT USAGE ON DATABASE MY_DB TO SHARE MY_SHARE;

GRANT USAGE ON SCHEMA MY_DB.MY_SHARED_SCHEMA TO SHARE MY_SHARE;

GRANT SELECT ON VIEW MY_SECURE_VIEW TO SHARE MY_SHARE;

-- Examine share metadata

SHOW SHARES LIKE 'MY_SHARE%';

DESC SHARE MY_SHARE;

-- You are now ready to create your listing on the Marketplace or in an Exchange

----------------------------------------------

-- Optional: enable consumer-account-based row-level security on a multi-tenant object.
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/user-guide/data-sharing-secure-views.html
-- Securing a multi-tenant object requires a tenant_id column in the primary table to be shared. Additionally, an entitlements table defines which Snowflake accounts can see which tenants. There does not have to be a 1:1 relationship between tenant_id and Snowflake account, but that is the most common setup, which is reflected below.

-- Create entitlements table

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE TABLE SHARING_ENTITLEMENTS (
TENANT_ID STRING COMMENT 'KEY COLUMN THAT CONTROLS ROW VISIBILITY ON BASE TABLES',
SNOWFLAKE_ACCOUNT STRING COMMENT 'COLUMN THAT CONTROLS WHICH SNOWFLAKE ACCOUNT CAN SEE WHICH TENANT'
)
COMMENT 'A TABLE USED TO ENFORCE ROW-LEVEL SECURITY ON SHARED MULTI-TENANT TABLES'
;

-- Populate this table based on your values. Note that because sharing works specifically within cloud/region, the SNOWFLAKE_ACCOUNT value does not need to include any cloud/region designation. An example insert is shown below; replace the placeholder values with your own values.

INSERT INTO SHARING_ENTITLEMENTS VALUES ('<TENANT_ID1','<SNOWFLAKE_ACCOUNT1>');

-- Create a secure view that joines the entitlement table with the base table using the CURRENT_ACCOUNT() function.

USE SCHEMA MY_DB.MY_SHARED_SCHEMA;

CREATE OR REPLACE SECURE VIEW MY_SECURE_VIEW AS
SELECT COL1, COL2, COLN FROM MY_DB.MY_SCHEMA.MY_EXT_TABLE_MV EXT
JOIN MY_DB.MY_SCHEMA.SHARING_ENTITLEMENTS SE ON EXT.TENANT_ID = SE.TENANT_ID
AND SE.SNOWFLAKE_ACCOUNT = CURRENT_ACCOUNT()
;

-- If the share is not yet created, create the share as shown above in the first section
-- Run the same grant statements as shown above in the first section