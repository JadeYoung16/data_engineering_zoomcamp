with stg as (
    select * from {{ ref('stg_employee') }}
),
 
deduped as (
    select distinct
        department,
        division,
        business_unit
    from stg
    where department is not null
)
 
select
    {{ dbt_utils.generate_surrogate_key(['department', 'division', 'business_unit']) }}
                            as department_key,
    department              as department_name,
    division                as division_name,
    business_unit           as business_unit_name
from deduped
 