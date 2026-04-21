from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator
from datetime import datetime

# config
SNOWFLAKE_CONN_ID = 'snowflake_conn'
WAREHOUSE        = 'EE_COMPUTE_WH'
DATABASE         = 'EMPLOYEE_DATA_DB'
SCHEMA           = 'RAW'
STAGE            = 'employee_raw_stage'

def get_copy_query(table_name, file_name):
    return f"""
    USE WAREHOUSE {WAREHOUSE};
    USE DATABASE {DATABASE};
    USE SCHEMA {SCHEMA};
    TRUNCATE TABLE {table_name};
    COPY INTO {table_name}
    FROM @{STAGE}/{file_name}
    FILE_FORMAT = (FORMAT_NAME = 'csv_format')
    FORCE = TRUE;
    """

with DAG(
    dag_id='employee_data_pipeline_v2',
    start_date=datetime(2026, 4, 20),
    schedule='@daily',
    catchup=False
) as dag:

    # 1. load employee_data.csv
    task_load_emp = SQLExecuteQueryOperator(
        task_id='load_employee_info',
        conn_id=SNOWFLAKE_CONN_ID,
        sql=get_copy_query('RAW_EMPLOYEE_INFO', 'employee_data.csv')
    )

    # 2. load employee_engagement_survey_data.csv
    task_load_survey = SQLExecuteQueryOperator(
        task_id='load_engagement_survey',
        conn_id=SNOWFLAKE_CONN_ID,
        sql=get_copy_query('RAW_ENGAGEMENT', 'employee_engagement_survey_data.csv')
    )

    # 3. load recruitment_data.csv
    task_load_recruitment = SQLExecuteQueryOperator(
        task_id='load_recruitment',
        conn_id=SNOWFLAKE_CONN_ID,
        sql=get_copy_query('RAW_RECRUITMENT', 'recruitment_data.csv')
    )

    # 4. load training_and_development_data.csv
    task_load_training = SQLExecuteQueryOperator(
        task_id='load_training',
        conn_id=SNOWFLAKE_CONN_ID,
        sql=get_copy_query('RAW_TRAINING', 'training_and_development_data.csv')
    )

    # 5. run dbt transformations
    run_dbt = BashOperator(
        task_id='run_dbt_transformations',
        bash_command=(
            "cd /opt/airflow/employee_data_transformation && "
            "/home/airflow/.local/bin/dbt build "
            "--profiles-dir /home/airflow/.dbt"
        )
    )

    # all loads run in parallel, then dbt runs
    [task_load_emp, task_load_survey, task_load_recruitment, task_load_training] >> run_dbt