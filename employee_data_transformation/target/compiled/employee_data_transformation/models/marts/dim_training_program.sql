with stg as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_training
),
 
deduped as (
    select distinct
        training_program_name,
        training_type,
        training_location
    from stg
    where training_program_name is not null
)
 
select
    md5(cast(coalesce(cast(training_program_name as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(training_type as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(training_location as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                    as training_program_key,
    training_program_name,
    training_type,
    training_location
from deduped