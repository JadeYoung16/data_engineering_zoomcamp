
    
    

select
    employee_id as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.stg_employee
where employee_id is not null
group by employee_id
having count(*) > 1


