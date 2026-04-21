
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select start_date
from EMPLOYEE_DATA_DB.STAGING.stg_employee
where start_date is null



  
  
      
    ) dbt_internal_test