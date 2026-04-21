
  create or replace   view EMPLOYEE_DATA_DB.STAGING.fct_employee_snapshot
  
  
  
  
  as (
    -- Grain: one row per employee
with emp as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_employee
),
 
dept as (
    select * from EMPLOYEE_DATA_DB.STAGING.dim_department
),
 
job as (
    select * from EMPLOYEE_DATA_DB.STAGING.dim_job
)
 
select
    -- Surrogate key
    md5(cast(coalesce(cast(emp.employee_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                                as employee_snapshot_key,
 
    -- Foreign keys
    emp.employee_id,
 
    dept.department_key,
 
    job.job_key,
 
    -- Date FKs
    cast(to_char(emp.start_date, 'YYYYMMDD') as int)
                                                as start_date_key,
    coalesce(
        cast(to_char(emp.exit_date, 'YYYYMMDD') as int),
        -1
    )                                           as exit_date_key,
 
    -- Measures
    emp.current_employee_rating,
 
    case
        when lower(emp.performance_score) in ('exceeds', 'exceptional')     then 'High'
        when lower(emp.performance_score) = 'fully meets'                   then 'Medium'
        when lower(emp.performance_score) in ('needs improvement', 'pip')   then 'Low'
        else 'Unknown'
    end                                         as performance_tier,
 
    -- Flags
    emp.is_active,
    case
        when emp.exit_date is not null then true
        else false
    end                                         as has_attrited,
 
    -- Tenure
    round(
        datediff('day',
            emp.start_date,
            coalesce(emp.exit_date, current_date())
        ) / 365.25, 1
    )                                           as tenure_years,
 
    current_timestamp()                         as dbt_loaded_at
 
from emp
left join dept
    on  emp.department   = dept.department_name
    and emp.division     = dept.division_name
    and emp.business_unit= dept.business_unit_name
left join job
    on  emp.job_title    = job.job_title
    and emp.job_function = job.job_function
  );

