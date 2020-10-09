-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create one or more materialized views to create highly performant copies of your external tables in Snowflake.
-- Replace "MY_EXT_TABLE_MV" with your value. The "MV" suffix can be used to distinguish materialized views from base tables.
-- Replace "MY_WH", "MY_DB", "MY_SCHEMA", and "MY_EXT_TABLE" with the names you used in previous steps.
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/user-guide/views-materialized.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-materialized-view.html
-- https://docs.snowflake.com/en/user-guide/views-secure.html
-- A Snowflake materialized view will typically create a new physical copy of the data from a base table, model it in a different form (as defined by a query), and store it as a new queryable object that looks and feels like a regular table. However, under the covers, the materialized view looks for new updates to the base table and updates itself after those updates to the base table occurs. Queries run against a materialized view when it hasn't yet updated itself from changes to the base external table will not lock, but will run more slowly than after the materialized view updates itself. This experience should be factored into your external table refresh schedule.
-- When a materialized view is pointed to an external table, the materialized view also serves as the mechanism to load the external data into Snowflake to create a more performant object to query than the underlying external table, which will be slower to query.
-- The creation of the materialized view in this approach is technically optional, but is highly recommended to a) improve performance for your consumers, and b) to better control multi-region data sharing (as covered in share_multi_region.sql). 
-- The query below used to define the materialized view has an optional WHERE clause that defines which tenants in a multi-tenant external table will be included in the materialized view. This is helpful when you want to isolate tenants from each other and/or you want to control which tenants' data gets loaded into which cloud/region. If you are not using a multi-tenant design, the WHERE clause and the TENANT_COL in the SELECT clause can be omitted.
-- The query below shows a simple selection of all rows. More sophisticated aggregation and transformation queries can be used.

USE WAREHOUSE MY_WH;
USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE SECURE MATERIALIZED VIEW MY_EXT_TABLE_MV AS 
SELECT COL1, COL2, COLN, TENANT_COL FROM MY_EXT_TABLE
-- WHERE TENANT_COL IN (<VALUE1>,<VALUE2>,<VALUEN>)
-- WHERE TENANT_COL = <VALUE>
;
