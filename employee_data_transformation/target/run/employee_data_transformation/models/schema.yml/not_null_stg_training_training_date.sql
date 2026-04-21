
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select training_date
from EMPLOYEE_DATA_DB.STAGING.stg_training
where training_date is null



  
  
      
    ) dbt_internal_test