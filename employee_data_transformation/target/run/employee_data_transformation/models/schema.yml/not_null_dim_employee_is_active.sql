
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_active
from EMPLOYEE_DATA_DB.STAGING.dim_employee
where is_active is null



  
  
      
    ) dbt_internal_test