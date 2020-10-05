-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create a stage using simple access or a storage integration to allow Snowflake access to your files in object store
-- Replace "MY_STORAGE" and "MY_STAGE" with your preferred names
-- Replace "MY_DB" and "MY_SCHEMA" with the names you used in previous steps 
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-storage-integration.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-stage.html
-- This template offers walkthroughs for AWS, Azure, and GCP - please jump to the appropriate section for you

----------------------------------------------

-- If your data is in AWS S3

-- Simple access approach, which requires using access key
-- Replace "MY_KEY" and "MY_SECRET_KEY" with your values

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE STAGE MY_STAGE 
URL = 's3://provider-accelerator-testing/test1/' 
CREDENTIALS = (AWS_KEY_ID = 'MY_KEY' AWS_SECRET_KEY = 'MY_SECRET_KEY')
;

-- Storage integration approach, which is more secure
-- Replace STORAGE_AWS_ROLE_ARN, STORAGE_ALLOWED_LOCATIONS, and URL with your values
-- Before creating storage integration, work with your AWS administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config.html#step-1-configure-access-permissions-for-the-s3-bucket

CREATE STORAGE INTEGRATION MY_STORAGE
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::001234567890:role/myrole'
ENABLED = TRUE
STORAGE_ALLOWED_LOCATIONS = ('s3://mybucket1/path1/', 's3://mybucket2/path2/')
;

DESC STORAGE INTEGRATION MY_STORAGE;

-- Provide the values of STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID to your AWS administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config.html#step-5-grant-the-iam-user-permissions-to-access-bucket-objects
-- Now create the stage, replacing URL with your value and using your database & schema 

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE STAGE MY_STAGE
URL = 's3://mybucket1/path1/'
STORAGE_INTEGRATION = MY_STORAGE
;

----------------------------------------------

-- If your data is in Azure Blob Storage
-- Replace AZURE_TENANT_ID and STORAGE_ALLOWED_LOCATIONS with your values

CREATE STORAGE INTEGRATION MY_STORAGE
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = AZURE
ENABLED = TRUE
AZURE_TENANT_ID = '<tenant_id>'
STORAGE_ALLOWED_LOCATIONS = ('azure://myaccount.blob.core.windows.net/mycontainer/path1/', 'azure://myaccount.blob.core.windows.net/mycontainer/path2/')
;

DESC STORAGE INTEGRATION MY_STORAGE;

-- Provide the values of AZURE_CONSENT_URL and AZURE_MULTI_TENANT_APP_NAME to your Azure administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-azure-config.html#step-2-grant-snowflake-access-to-the-storage-locations
-- Now create the stage, replacing URL with your value and using your database & schema 

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE STAGE MY_STAGE
URL = 'azure://myaccount.blob.core.windows.net/load/files/'
STORAGE_INTEGRATION = MY_STORAGE
;

----------------------------------------------

-- If your data is in Google Cloud Storage
-- Replace STORAGE_ALLOWED_LOCATIONS with your values

CREATE STORAGE INTEGRATION MY_STORAGE
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = GCS
ENABLED = TRUE
STORAGE_ALLOWED_LOCATIONS = ('gcs://mybucket1/path1/', 'gcs://mybucket2/path2/')
;

DESC STORAGE INTEGRATION MY_STORAGE;

-- Provide the value of STORAGE_GCP_SERVICE_ACCOUNT to your GCP administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-gcs-config.html#step-3-grant-the-service-account-permissions-to-access-bucket-objects
-- Now create the stage, replacing URL with your value and using your database & schema 

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE STAGE MY_STAGE
URL = 'gcs://load/files/'
STORAGE_INTEGRATION = MY_STORAGE
;