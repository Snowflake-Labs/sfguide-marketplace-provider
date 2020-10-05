-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create a share object to allow other Snowflake customers to access your data
-- Replace "MY_DB", "MY_SCHEMA", and "MY TABLE" with the names you used in previous steps 
-- Replace "MY_SHARED_SCHEMA", "MY_SECURE_VIEW" and "MY_SHARE" with your preferred names
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/user-guide-data-share.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-share.html
-- https://docs.snowflake.com/en/user-guide/views-secure.html
-- Note that it is good practice to abstract the objects that other Snowflake customers can see through the use of Secure Views rather than sharing tables directly. Secure Views can be simple views or have account-based row-level security built into them (one Snowflake customer account see one slice of data, another Snowflake customer account sees a different slice). This script does not provide an example of row-level security but the create_share.sql script in Approach 3 does.
-- This accelerator also assumes that you are operating as a user with the ACCOUNTADMIN role. If you have implemented more fine-grained role permissions in Snowflake, there are likely tweaks to the code below that will be required based on how you have implemented roles and privileges.

-- Create a separate schema to align with the share to isolate your shared vs non-shared objects

USE DATABASE MY_DB;

CREATE OR REPLACE SCHEMA MY_SHARED_SCHEMA;

-- Create secure view on your table(s), selecting the appropriate columns that should be visible. It is recommended that you select specific columns instead of * to control the reveal of new columns.

USE SCHEMA MY_DB.MY_SHARED_SCHEMA;

CREATE OR REPLACE SECURE VIEW MY_SECURE_VIEW AS 
SELECT COL1, COL2, COLN FROM MY_DB.MY_SCHEMA.MY_TABLE;

-- Create share and grant the appropriate privileges to the share 

CREATE OR REPLACE SHARE MY_SHARE;

GRANT USAGE ON DATABASE MY_DB TO SHARE MY_SHARE;

GRANT USAGE ON SCHEMA MY_DB.MY_SHARED_SCHEMA TO SHARE MY_SHARE;

GRANT SELECT ON VIEW MY_SECURE_VIEW TO SHARE MY_SHARE;

-- Examine share metadata

SHOW SHARES LIKE 'MY_SHARE%';

DESC SHARE MY_SHARE;

-- You are now ready to create your listing on the Marketplace or in an Exchange