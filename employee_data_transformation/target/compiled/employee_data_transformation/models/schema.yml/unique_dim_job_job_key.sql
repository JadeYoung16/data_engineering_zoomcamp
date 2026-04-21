
    
    

select
    job_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.dim_job
where job_key is not null
group by job_key
having count(*) > 1


