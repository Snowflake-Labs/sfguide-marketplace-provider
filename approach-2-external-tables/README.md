Copyright (c) 2020 Snowflake Inc. All rights reserved.

Approach 2: Use External Tables to point to your data in object store and use Materialized Views to ingest into Snowflake as needed by customer demand.

This accelerator contains scripts that can be used as templates to build the end-to-end workflow for listing data on the Snowflake Marketplace or in a private Exchange. The accelerator assumes you already have a Snowflake account and know how to login as the user with ACCOUNTADMIN rights and will not need fine-grain security controls beyond that single user. Since this approach involves repeating the same setup in multiple Snowflake accounts, you're encouraged to save your versions of these scripts for repeat use. The overall steps in the workflow are as follows:

1. Create a virtual warehouse (create_warehouse.sql - script is at the root level)
2. Create a database and schema (create_database.sql - script is at the root level)
3. Create an external stage (create_stage.sql - script is at the root level)
4. Create one or more external tables to point to your data from Snowflake (create_ext_table.sql)
5. Create one or more materialized views to create highly performant copies of your external tables in Snowflake (create_matview.sql)
6. Create one or more shares (create_share.sql)
7. Create a listing on the Marketplace or Exchange through the UI (create_listing.sql - script is at the root level)
8. Automate the refresh of your external tables (refresh_ext_table.sql)
9. Optionally prepare to share your data to other clouds/regions (share_multi_region.sql)