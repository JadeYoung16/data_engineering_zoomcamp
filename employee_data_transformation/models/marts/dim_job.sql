with stg as (
    select * from {{ ref('stg_employee') }}
),
 
deduped as (
    select distinct
        job_title,
        job_function
    from stg
    where job_title is not null
)
 
select
    {{ dbt_utils.generate_surrogate_key(['job_title', 'job_function']) }}
                            as job_key,
    job_title,
    job_function
from deduped
 