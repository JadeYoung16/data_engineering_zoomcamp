
    
    

select
    training_program_key as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.dim_training_program
where training_program_key is not null
group by training_program_key
having count(*) > 1


