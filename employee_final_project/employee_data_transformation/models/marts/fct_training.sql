-- Grain: one row per employee per training session
with trn as (
    select * from {{ ref('stg_training') }}
),
 
prog as (
    select * from {{ ref('dim_training_program') }}
)
 
select
    -- Surrogate key
    {{ dbt_utils.generate_surrogate_key(['trn.employee_id', 'trn.training_date', 'trn.training_program_name', 'trn.trainer_name']) }}
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