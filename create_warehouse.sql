-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create a virtual warehouse (compute) to execute queries in Snowflake
-- Replace "MY_WH" with your preferred warehouse name
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-warehouse.html

CREATE OR REPLACE WAREHOUSE
MY_WH
WITH
WAREHOUSE_SIZE = XSMALL
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
;
