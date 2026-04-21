
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select employee_id
from EMPLOYEE_DATA_DB.STAGING.fct_employee_snapshot
where employee_id is null



  
  
      
    ) dbt_internal_test