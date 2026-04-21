
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select employee_snapshot_key
from EMPLOYEE_DATA_DB.STAGING.fct_employee_snapshot
where employee_snapshot_key is null



  
  
      
    ) dbt_internal_test