CREATE WAREHOUSE EE_COMPUTE_WH WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60;
CREATE DATABASE EMPLOYEE_DATA_DB;
CREATE SCHEMA EMPLOYEE_DATA_DB.RAW;

-- 1. Create Landing Tables
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE EE_COMPUTE_WH;
USE DATABASE EMPLOYEE_DATA_DB;
USE SCHEMA RAW;

-- Step 1: Storage integration
CREATE OR REPLACE STORAGE INTEGRATION S3_INT
    TYPE                        = EXTERNAL_STAGE
    STORAGE_PROVIDER            = 'S3'
    STORAGE_ALLOWED_LOCATIONS   = ('s3://data-engineer-project-ee-datalake/')
    ENABLED                     = TRUE
    STORAGE_AWS_ROLE_ARN        = 'arn:aws:iam::259851212117:role/snowflake-s3-role';

-- Step 2: File formats
CREATE OR REPLACE FILE FORMAT csv_format_infer   -- for INFER_SCHEMA
    TYPE                         = 'CSV'
    PARSE_HEADER                 = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF                      = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL          = TRUE;

CREATE OR REPLACE FILE FORMAT csv_format         -- for COPY INTO
    TYPE                         = 'CSV'
    FIELD_DELIMITER              = ','
    SKIP_HEADER                  = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF                      = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL          = TRUE;

-- Step 3: Stage
CREATE OR REPLACE STAGE EMPLOYEE_DATA_DB.RAW.employee_raw_stage
    URL                 = 's3://data-engineer-project-ee-datalake/raw'
    STORAGE_INTEGRATION = S3_INT
    FILE_FORMAT         = (FORMAT_NAME = 'csv_format');

LIST @employee_raw_stage;

-- Step 4: Create tables using INFER_SCHEMA
CREATE OR REPLACE TABLE RAW_EMPLOYEE_INFO
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) FROM TABLE(
        INFER_SCHEMA(LOCATION=>'@employee_raw_stage/employee_data.csv', FILE_FORMAT=>'csv_format_infer')
    )
);

CREATE OR REPLACE TABLE RAW_ENGAGEMENT
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) FROM TABLE(
        INFER_SCHEMA(LOCATION=>'@employee_raw_stage/employee_engagement_survey_data.csv', FILE_FORMAT=>'csv_format_infer')
    )
);

CREATE OR REPLACE TABLE RAW_RECRUITMENT
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) FROM TABLE(
        INFER_SCHEMA(LOCATION=>'@employee_raw_stage/recruitment_data.csv', FILE_FORMAT=>'csv_format_infer')
    )
);

CREATE OR REPLACE TABLE RAW_TRAINING
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) FROM TABLE(
        INFER_SCHEMA(LOCATION=>'@employee_raw_stage/training_and_development_data.csv', FILE_FORMAT=>'csv_format_infer')
    )
);

-- Step 5: Load data
COPY INTO RAW_EMPLOYEE_INFO
FROM @employee_raw_stage/employee_data.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format') FORCE = TRUE;

COPY INTO RAW_ENGAGEMENT
FROM @employee_raw_stage/employee_engagement_survey_data.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format') FORCE = TRUE;

COPY INTO RAW_RECRUITMENT
FROM @employee_raw_stage/recruitment_data.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format') FORCE = TRUE;

COPY INTO RAW_TRAINING
FROM @employee_raw_stage/training_and_development_data.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format') FORCE = TRUE;

-- Step 6: Verify
SELECT 'RAW_EMPLOYEE_INFO' AS tbl, COUNT(*) AS cnt FROM RAW_EMPLOYEE_INFO  UNION ALL
SELECT 'RAW_ENGAGEMENT',           COUNT(*)        FROM RAW_ENGAGEMENT     UNION ALL
SELECT 'RAW_RECRUITMENT',          COUNT(*)        FROM RAW_RECRUITMENT    UNION ALL
SELECT 'RAW_TRAINING',             COUNT(*)        FROM RAW_TRAINING;


---test
SELECT raw_content FROM EMPLOYEE_DATA_DB.RAW.RAW_EMPLOYEE_INFO LIMIT 1;

LIST @EMPLOYEE_DATA_DB.RAW.employee_raw_stage;

DESC TABLE RAW_EMPLOYEE_INFO;

SELECT * FROM TABLE(
    INFER_SCHEMA(
        LOCATION    => '@employee_raw_stage/employee_data.csv',
        FILE_FORMAT => 'csv_format'
    )
);

DESC INTEGRATION S3_INT;

USE DATABASE EMPLOYEE_DATA_DB;
USE SCHEMA RAW;
TRUNCATE TABLE RAW_EMPLOYEE_INFO;
TRUNCATE TABLE RAW_ENGAGEMENT;
TRUNCATE TABLE RAW_RECRUITMENT;
TRUNCATE TABLE RAW_TRAINING;


