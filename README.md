# Snowflake Data Marketplace Provider Accelerator 

This project contains code that can be used as templates to build the end-to-end workflow for listing data on the Snowflake Marketplace or in a private Exchange. 

A full demo of using the project can be seen here: [https://snowflake.wistia.com/medias/gx2vicqnmt](https://snowflake.wistia.com/medias/gx2vicqnmt)

------

There are two different approaches depending on where the underlying provider-data exists:

- **direct-load-from-object-store** - use this approach when your data already exists in cloud object store and you are comfortable loading that data into Snowflake using traditional loading methods. This method works best when the consumer experience is consistent customer to customer and region to region. 

* **external-tables** - use this approach when you'd rather "point" to some of your data in object store and only load it into a given Snowflake region as customer demand dictates.

Regardless of approach, there are certain steps that must be done in every approach. They are listed below and their scripts are in the root-level of this repository.

- Create a virtual warehouse (create_warehouse.sql)
- Create a database and schema (create_database.sql)
- Create an external stage (create_stage.sql)
- Create a listing on the Marketplace or Exchange through the UI (create_listing.sql)

## Usage

Follow the instructions in each `.sql` file within this repository.


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## License
Apache-2.0 License

Copyright (c) 2020 Snowflake Inc. All rights reserved.
