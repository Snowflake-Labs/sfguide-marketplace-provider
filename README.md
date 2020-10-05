Copyright (c) 2020 Snowflake Inc. All rights reserved.

Repository to accelerate Provider on-boarding their data to Snowflake for the Marketplace or a private Exchange using a variety of approaches.

This accelerator contains code that can be used as templates or full automation to build the end-to-end workflow for listing data on the Snowflake Marketplace or in a private Exchange. There are multiple approaches to doing this, depending on where your data already exists as a provider. These approaches are listed below.

* approach-1-direct-load-from-object-store - use this approach when your data already exists in cloud object store and you are comfortable loading that data into Snowflake using traditional loading methods. This method works best when the consumer experience is consistent customer to customer and region to region. 

* approach-2-external-tables - use this approach when you'd rather "point" to some of your data in object store and only load it into a given Snowflake region as customer demand dictates.

Regardless of approach, there are certain steps that must be done in every approach. They are listed below and their scripts are in the root-level of this repository.

- Create a virtual warehouse (create_warehouse.sql)
- Create a database and schema (create_database.sql)
- Create an external stage (create_stage.sql)
- Create a listing on the Marketplace or Exchange through the UI (create_listing.sql)