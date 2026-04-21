
    
    

with all_values as (

    select
        performance_tier as value_field,
        count(*) as n_records

    from EMPLOYEE_DATA_DB.STAGING.fct_employee_snapshot
    group by performance_tier

)

select *
from all_values
where value_field not in (
    'High','Medium','Low','Unknown'
)


