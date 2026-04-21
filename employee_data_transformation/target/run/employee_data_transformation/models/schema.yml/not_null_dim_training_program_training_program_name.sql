
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select training_program_name
from EMPLOYEE_DATA_DB.STAGING.dim_training_program
where training_program_name is null



  
  
      
    ) dbt_internal_test