
    
    

select
    engagement_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.fct_engagement
where engagement_key is not null
group by engagement_key
having count(*) > 1


