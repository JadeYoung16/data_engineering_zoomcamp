with source as (
    select * from {{ source('raw', 'RAW_EMPLOYEE_INFO') }}
),

cleaned as (
    select
        -- IDs
        cast("EmpID" as varchar)                                        as employee_id,
        cast("LocationCode" as varchar)                                 as location_code,

        -- Personal info
        initcap(trim("FirstName"))                                      as first_name,
        initcap(trim("LastName"))                                       as last_name,
        initcap(trim("FirstName")) || ' ' || initcap(trim("LastName"))  as full_name,
        try_cast(dob as date)                                           as date_of_birth,
        trim("GenderCode")                                              as gender_code,
        trim("State")                                                   as state,
        trim("RaceDesc")                                                as race,
        trim("MaritalDesc")                                             as marital_status,

        -- Job info
        initcap(trim("Title"))                                          as job_title,
        trim("JobFunctionDescription")                                  as job_function,
        trim("DepartmentType")                                          as department,
        trim("Division")                                                as division,
        trim("BusinessUnit")                                            as business_unit,
        initcap(trim("Supervisor"))                                     as supervisor_name,
        lower(trim("ADEmail"))                                          as email,

        -- Employment details
        trim("EmployeeStatus")                                          as employee_status,
        trim("EmployeeType")                                            as employee_type,
        trim("EmployeeClassificationType")                              as classification_type,
        trim("PayZone")                                                 as pay_zone,
        try_cast("StartDate" as date)                                   as start_date,
        try_cast("ExitDate" as date)                                    as exit_date,

        -- Termination
        trim("TerminationType")                                         as termination_type,
        trim("TerminationDescription")                                  as termination_reason,

        -- Performance
        trim("Performance Score")                                       as performance_score,
        cast("Current Employee Rating" as int)                         as current_employee_rating,

        -- Derived
        case
            when "ExitDate" is null then true
            else false
        end                                                             as is_active

    from source
    where "EmpID" is not null
)

select * from cleaned