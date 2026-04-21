
  create or replace   view EMPLOYEE_DATA_DB.STAGING.dim_department
  
  
  
  
  as (
    with stg as (
    select * from EMPLOYEE_DATA_DB.STAGING.stg_employee
),
 
deduped as (
    select distinct
        department,
        division,
        business_unit
    from stg
    where department is not null
)
 
select
    md5(cast(coalesce(cast(department as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(division as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(business_unit as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                            as department_key,
    department              as department_name,
    division                as division_name,
    business_unit           as business_unit_name
from deduped
  );

