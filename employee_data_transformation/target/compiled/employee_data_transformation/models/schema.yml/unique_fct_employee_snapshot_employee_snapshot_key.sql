
    
    

select
    employee_snapshot_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.fct_employee_snapshot
where employee_snapshot_key is not null
group by employee_snapshot_key
having count(*) > 1


