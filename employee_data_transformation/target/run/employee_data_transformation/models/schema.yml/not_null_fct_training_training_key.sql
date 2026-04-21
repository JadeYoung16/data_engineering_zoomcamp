
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select training_key
from EMPLOYEE_DATA_DB.STAGING.fct_training
where training_key is null



  
  
      
    ) dbt_internal_test