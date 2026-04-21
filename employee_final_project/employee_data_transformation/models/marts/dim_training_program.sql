with stg as (
    select * from {{ ref('stg_training') }}
),
 
deduped as (
    select distinct
        training_program_name,
        training_type,
        training_location
    from stg
    where training_program_name is not null
)
 
select
    {{ dbt_utils.generate_surrogate_key(['training_program_name', 'training_type', 'training_location']) }}
                                    as training_program_key,
    training_program_name,
    training_type,
    training_location
from deduped
