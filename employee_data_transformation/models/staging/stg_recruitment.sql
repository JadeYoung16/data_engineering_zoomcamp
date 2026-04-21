with source as (
    select * from {{ source('raw', 'RAW_RECRUITMENT') }}
),
 
cleaned as (
    select
        cast("Applicant ID" as varchar)             as applicant_id,
        try_cast("Application Date" as date)        as application_date,
        initcap(trim("First Name"))                 as first_name,
        initcap(trim("Last Name"))                  as last_name,
        initcap(trim("First Name"))
            || ' ' || initcap(trim("Last Name"))    as full_name,
        trim(upper("Gender"))                       as gender,
        try_cast("Date of Birth" as date)           as date_of_birth,
        trim("Phone Number")                        as phone_number,
        lower(trim("Email"))                        as email,
        trim("Address")                             as address,
        trim("City")                                as city,
        trim("State")                               as state,
        cast("Zip Code" as varchar)                 as zip_code,
        trim("Country")                             as country,
        trim("Education Level")                     as education_level,
        cast("Years of Experience" as int)          as years_of_experience,
        cast("Desired Salary" as float)             as desired_salary,
        initcap(trim("Job Title"))                  as job_title,
        trim("Status")                              as application_status
    from source
    where "Applicant ID" is not null
)
 
select * from cleaned
 