with source as (
    select * from EMPLOYEE_DATA_DB.RAW.RAW_ENGAGEMENT
),

cleaned as (
    select
        cast("Employee ID" as varchar)          as employee_id,
        to_date("Survey Date", 'DD-MM-YYYY')    as survey_date,
        cast("Engagement Score" as int)         as engagement_score,
        cast("Satisfaction Score" as int)       as satisfaction_score,
        cast("Work-Life Balance Score" as int)  as work_life_balance_score
    from source
    where "Employee ID" is not null
)

select * from cleaned