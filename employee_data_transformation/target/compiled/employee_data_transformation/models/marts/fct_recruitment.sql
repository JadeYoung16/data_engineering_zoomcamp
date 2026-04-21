-- Grain: one row per applicant
with rec as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_recruitment
)
 
select
    -- Surrogate key
    md5(cast(coalesce(cast(applicant_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                                as recruitment_key,
 
    -- Foreign keys
    applicant_id,
    cast(to_char(application_date, 'YYYYMMDD') as int)
                                                as application_date_key,
 
    -- Applicant info
    full_name,
    gender,
    date_of_birth,
    education_level,
    years_of_experience,
    city,
    state,
    country,
    job_title,
 
    -- Measures
    desired_salary,
 
    -- Status
    application_status,
    case
        when lower(application_status) = 'hired' then true
        else false
    end                                         as is_hired,
 
    current_timestamp()                         as dbt_loaded_at
 
from rec