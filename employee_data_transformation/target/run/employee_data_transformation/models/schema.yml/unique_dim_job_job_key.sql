
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    job_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.dim_job
where job_key is not null
group by job_key
having count(*) > 1



  
  
      
    ) dbt_internal_test