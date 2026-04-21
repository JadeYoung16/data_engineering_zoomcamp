
  create or replace   view EMPLOYEE_DATA_DB.STAGING.dim_employee
  
  
  
  
  as (
    with stg as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_employee
)
 
select
    employee_id,
    first_name,
    last_name,
    full_name,
    date_of_birth,
    case
        when gender_code = 'M' then 'Male'
        when gender_code = 'F' then 'Female'
        else 'Unknown'
    end                                                         as gender,
    state,
    race,
    marital_status,
    email,
    employee_type,
    classification_type,
    pay_zone,
    location_code,
    start_date,
    exit_date,
    termination_type,
    termination_reason,
    is_active,
 
    -- Tenure in years
    round(
        datediff('day',
            start_date,
            coalesce(exit_date, current_date())
        ) / 365.25, 1
    )                                                           as tenure_years
 
from stg
  );

