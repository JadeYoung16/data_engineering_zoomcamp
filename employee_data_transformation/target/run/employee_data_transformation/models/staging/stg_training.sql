
  create or replace   view EMPLOYEE_DATA_DB.STAGING.stg_training
  
  
  
  
  as (
    with source as (
    select * from EMPLOYEE_DATA_DB.RAW.RAW_TRAINING
),
 
cleaned as (
    select
        cast("Employee ID" as varchar)              as employee_id,
        try_cast("Training Date" as date)           as training_date,
        trim("Training Program Name")               as training_program_name,
        trim("Training Type")                       as training_type,
        trim("Training Outcome")                    as training_outcome,
        trim("Location")                            as training_location,
        initcap(trim("Trainer"))                    as trainer_name,
        cast("Training Duration(Days)" as int)      as training_duration_days,
        cast("Training Cost" as float)              as training_cost,
 
        -- Derived
        case
            when lower(trim("Training Outcome")) = 'passed' then true
            else false
        end                                         as is_passed
 
    from source
    where "Employee ID" is not null
)
 
select * from cleaned
  );

