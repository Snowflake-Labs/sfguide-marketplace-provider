Copyright (c) 2020 Snowflake Inc. All rights reserved.

Approach 1: Direct load from object store

This accelerator contains scripts that can be used as templates to build the end-to-end workflow for listing data on the Snowflake Marketplace or in a private Exchange when your data already exists in object store in AWS, Azure, or GCP using a supported file format. The accelerator assumes you already have a Snowflake account and know how to login as the user with ACCOUNTADMIN rights and will not need fine-grain security controls beyond that single user. The overall steps in the workflow are as follows:

1. Create a virtual warehouse (create_warehouse.sql - script is at the root level)
2. Create a database and schema (create_database.sql - script is at the root level)
3. Create an external stage (create_stage.sql - script is at the root level)
4. Create one or more tables to load your data (create_table.sql)
5. Perform a one-time load of your data (load_data_once.sql)
6. Create one or more shares (create_share.sql)
7. Create a listing on the Marketplace or Exchange through the UI (create_listing.sql - script is at the root level)
8. Automate the recurring load of new data (load_data_recurring.sql)
9. Optionally prepare to share your data to other clouds/regions (share_multi_region.sql)
