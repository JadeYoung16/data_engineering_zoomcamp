
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select engagement_key
from EMPLOYEE_DATA_DB.STAGING.fct_engagement
where engagement_key is null



  
  
      
    ) dbt_internal_test