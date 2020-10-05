-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create a database and schema to house tables in Snowflake
-- Replace "MY_DB" and "MY_SCHEMA" with your preferred names
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-database.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-schema.html

-- Create database

CREATE OR REPLACE DATABASE MY_DB;

-- Create schema in the database

USE DATABASE MY_DB;

CREATE OR REPLACE SCHEMA MY_SCHEMA;
