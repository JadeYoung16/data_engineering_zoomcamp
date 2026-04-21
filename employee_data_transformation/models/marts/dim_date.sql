{{ config(materialized='table') }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2000-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

final_dates as (
    select
        date_day as date_key,
        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        monthname(date_day) as month_name,
        dayname(date_day) as day_name,
        dayofweek(date_day) as day_of_week,
        case 
            when dayname(date_day) in ('Sat', 'Sun') then false 
            else true 
        end as is_weekday
    from date_spine
)

select * from final_dates