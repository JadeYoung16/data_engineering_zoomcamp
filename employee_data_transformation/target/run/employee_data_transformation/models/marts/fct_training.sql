
  create or replace   view EMPLOYEE_DATA_DB.STAGING.fct_training
  
  
  
  
  as (
    -- Grain: one row per employee per training session
with trn as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_training
),
 
prog as (
    select * from EMPLOYEE_DATA_DB.STAGING.dim_training_program
)
 
select
    -- Surrogate key
    md5(cast(coalesce(cast(trn.employee_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(trn.training_date as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(trn.training_program_name as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(trn.trainer_name as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
        as training_key,
 
    -- Foreign keys
    trn.employee_id,
    prog.training_program_key,
    cast(to_char(trn.training_date, 'YYYYMMDD') as int)
                                                as training_date_key,
 
    -- Measures
    trn.training_duration_days,
    trn.training_cost,
    trn.trainer_name,
 
    -- Flags
    trn.is_passed,
 
    current_timestamp()                         as dbt_loaded_at
 
from trn
left join prog
    on  trn.training_program_name = prog.training_program_name
    and trn.training_type         = prog.training_type
    and trn.training_location     = prog.training_location
  );

