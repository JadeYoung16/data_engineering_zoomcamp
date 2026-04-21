
  create or replace   view EMPLOYEE_DATA_DB.STAGING.dim_job
  
  
  
  
  as (
    with stg as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_employee
),
 
deduped as (
    select distinct
        job_title,
        job_function
    from stg
    where job_title is not null
)
 
select
    md5(cast(coalesce(cast(job_title as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(job_function as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                            as job_key,
    job_title,
    job_function
from deduped
  );

