-- Grain: one row per employee per survey date
with eng as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_engagement
)
 
select
    -- Surrogate key
    md5(cast(coalesce(cast(employee_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(survey_date as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                                as engagement_key,
 
    -- Foreign keys
    employee_id,
    cast(to_char(survey_date, 'YYYYMMDD') as int)
                                                as survey_date_key,
 
    -- Measures
    engagement_score,
    satisfaction_score,
    work_life_balance_score,
 
    -- Derived
    round(
        (engagement_score + satisfaction_score + work_life_balance_score) / 3.0,
        2
    )                                           as avg_score,
 
    current_timestamp()                         as dbt_loaded_at
 
from eng