
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select department_name
from EMPLOYEE_DATA_DB.STAGING.dim_department
where department_name is null



  
  
      
    ) dbt_internal_test