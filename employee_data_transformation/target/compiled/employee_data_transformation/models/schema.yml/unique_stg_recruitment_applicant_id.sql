
    
    

select
    applicant_id as unique_field,
    count(*) as n_records

from EMPLOYEE_DATA_DB.STAGING.stg_recruitment
where applicant_id is not null
group by applicant_id
having count(*) > 1


