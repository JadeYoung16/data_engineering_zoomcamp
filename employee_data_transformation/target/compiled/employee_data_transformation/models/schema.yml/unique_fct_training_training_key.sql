
    
    

select
    training_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.fct_training
where training_key is not null
group by training_key
having count(*) > 1


