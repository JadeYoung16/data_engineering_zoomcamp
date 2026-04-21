
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    recruitment_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.fct_recruitment
where recruitment_key is not null
group by recruitment_key
having count(*) > 1



  
  
      
    ) dbt_internal_test