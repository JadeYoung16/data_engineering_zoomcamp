
    
    

select
    department_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.dim_department
where department_key is not null
group by department_key
having count(*) > 1


