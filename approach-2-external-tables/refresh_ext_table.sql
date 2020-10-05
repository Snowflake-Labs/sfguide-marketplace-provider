-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Refresh your external table on a schedule.
-- Replace "MY_EXT_TABLE", "MY_DB", "MY_SCHEMA", "MY_WH", "MY_STAGE", "MY_FORMAT" with the names you used in previous steps
-- Replace "MY_TASK" with your preferred names
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/alter-external-table.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-task.html
-- This script creates a Snowflake task to refresh the external table on a scheduled or interval basis. You should determine the type of task (schedule or interval) based on how frequently new files are added to object store and how frequently you want to expose new data to your consumers.
-- Tasks are always created in a suspended state and must be resumed before they will run.
-- The example below also assumes that this task will be run on a cron schedule of every night at 2am America/Los Angeles time, reflected by the format which is documented in the link above. You can customize the schedule to your needs. Tasks can also be scheduled to run on an interval measured in minutes. See the documentation for more details.

USE SCHEMA MY_DB.MY_SCHEMA;

CREATE OR REPLACE TASK MY_TASK
WAREHOUSE = MY_WH
SCHEDULE = 'USING CRON 0 2 * * * America/Los_Angeles'
AS 
ALTER EXTERNAL TABLE MY_EXT_TABLE REFRESH;
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
		
