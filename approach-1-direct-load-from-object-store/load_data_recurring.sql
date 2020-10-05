-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Load your data into your tables in Snowflake as new data arrives
-- Replace "MY_TABLE", "MY_DB", "MY_SCHEMA", "MY_WH", "MY_STAGE", "MY_FORMAT" with the names you used in previous steps
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/user-guide-data-load.html
-- https://docs.snowflake.com/en/user-guide/data-pipelines.html
-- This script focuses on loading future files on an incremental basis. There are two primary methods for doing this: the COPY statement used in the load_data_once.sql script, and Snowpipe. The two options are described below.
-- The COPY approaches uses compute (Virtual Warehouse) that you manage to load files, just like the initial data load. Use this approach when you want full control over the end-to-end process, the timing of your loads are predictable, and if you're willing to commit to at least a minute's worth of compute billing. Snowflake compute is charged by the second, but when you resume a Virtual Warehouse, you are committing to at least a minute's worth of billing time. The downside of using COPY is that you are required to orchestrate the end-to-end process, most likely using a Snowflake task.
-- The other approach uses a Snowflake managed background service (called Snowpipe) to load your data, only charging you for the exact compute time required because a Virtual Warehouse is not used to load the data. Use this option as more of a low-orchestration approach when your file arrival is less predictable and when your incremental data loads in a few seconds under normal circumstances. The downside of Snowpipe is that it is more involved to setup and if your data product requires you to load thousands of files each time, there are additional file charges to consider.

----------------------------------------------

-- If you want to use the COPY approach...
-- This approach does not vary based on whether you are in AWS, Azure, or GCP
-- This approach will create a Snowflake task to run a COPY statement on a schedule using documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-task.html
-- Replace "MY_TASK" with your preferred names
-- Tasks are always created in a suspended state and must be resumed before they will run.
-- The example below assumes a single task to load a single table from a single path of files using the COPY statement from the load_data_once.sql script with a slight alteration that assumes incremental files use the same base file name ("MY_FILE") with a date or timestamp suffix ("MY_FILE_YYYY_MM_DD"). The suffix is ommitted to load any new file that hasn't been loaded before. If you have many independent tables to load, you will repeat this for each table. It is also possible to chain tasks together into a dependency tree for more complicated workflows, but that is not illustrated here.
-- The example below also assumes that this task will be run on a cron schedule of every night at 2am America/Los Angeles time, reflected by the format which is documented in the link above. You can customize the schedule to your needs. Tasks can also be scheduled to run on an interval measured in minutes. See the documentation for more details.

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE TASK MY_TASK
WAREHOUSE = MY_WH
SCHEDULE = 'USING CRON 0 2 * * * America/Los_Angeles'
AS 
COPY INTO MY_TABLE 
FROM @MY_STAGE/file-path-if-needed/MY_FILE 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

-- Resume the suspended task

ALTER TASK MY_TASK RESUME;

-- Monitor the task history of the 10 most recent executions of a specified task (completed, still running, or scheduled in the future) scheduled within the last hour:

USE DATABASE MY_DB;

SELECT *
	FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
		SCHEDULED_TIME_RANGE_START=>DATEADD('HOUR',-1,CURRENT_TIMESTAMP()),
		RESULT_LIMIT => 10,
		TASK_NAME=>'MY_TASK'));
		
----------------------------------------------

-- If you want to use the Snowpipe approach...
-- This approach does vary slightly based on whether you are in AWS, Azure, or GCP
-- Replace "MY_TASK" with your preferred names
-- The documentation is located here:
-- https://docs.snowflake.com/en/user-guide/data-load-snowpipe.html
-- There are two ways that Snowpipe can be alerted to new files: cloud service notifications or a REST API call. The method shown below is the notification style, which at the time of this commit is not available on GCP. Please see the documentation to understand how to call the Snowpipe REST API to invoke a pipe.
-- The example below assumes a single pipe to load a single table from a single path of files using the COPY statement from the load_data_once.sql script with a slight alteration that assumes incremental files use the same base file name ("MY_FILE") with a date or timestamp suffix ("MY_FILE_YYYY_MM_DD"). The suffix is ommitted to load any new file that hasn't been loaded before. If you have many independent tables to load, you will repeat this for each table.
-- Compare the stage reference in the pipe definition with existing pipes. Verify that the directory paths for the same S3 bucket do not overlap; otherwise, multiple pipes could load the same set of data files multiple times, into one or more target tables. See the documentation for more details.

----------------------------------------------

-- If your data is in AWS S3
-- Create a pipe

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE PIPE MY_PIPE 
AUTO_INGEST = TRUE 
AS
COPY INTO MY_TABLE 
FROM @MY_STAGE/file-path-if-needed/MY_FILE 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

SHOW PIPES;

-- Note the ARN of the SQS queue for the stage in the notification_channel column. Copy the ARN to a convenient location.
-- Follow the steps located here:
-- https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html#step-4-configure-event-notifications

-- Retrieve the status of the pipe

SELECT SYSTEM$PIPE_STATUS('MY_DB.MY_SCHEMA.MY_PIPE');

-- Manually add a file to your external stage in the proper path to test that the pipe picks up the new file. There could be as much as a 1-2 minute delay from when the file is added to when the notification tells the pipe that a new file has been added. You can test that the new file was loaded by doing a simple 'select count(*) from table' query before and after you upload the file.

----------------------------------------------

-- If your data in in Azure
-- Follow steps 1 and 2 at the link below to configure Azure Event Grid and create a Snowflake notification integration:
-- https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-azure.html#configuring-automated-snowpipe-using-azure-event-grid

-- Create a pipe replacing "MY_NOTIFICATION" with your value from step 2 above

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE PIPE MY_PIPE 
AUTO_INGEST = TRUE
INTEGRATION = 'MY_NOTIFICATION' 
AS
COPY INTO MY_TABLE 
FROM @MY_STAGE/file-path-if-needed/MY_FILE 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

-- Retrieve the status of the pipe

SELECT SYSTEM$PIPE_STATUS('MY_DB.MY_SCHEMA.MY_PIPE');

-- Manually add a file to your external stage in the proper path to test that the pipe picks up the new file. There could be as much as a 1-2 minute delay from when the file is added to when the notification tells the pipe that a new file has been added. You can test that the new file was loaded by doing a simple 'select count(*) from table' query before and after you upload the file.