/*
Occupations

Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. The output should consist of four columns (Doctor, Professor, Singer, and Actor) in that specific order, with their respective names listed alphabetically under each column.
Note: Print NULL when there are no more names corresponding to an occupation.
*/

with cte as (
    select
        name,
        occupation,
        row_number() over (
            partition by occupation
            order by name
        ) as rn
    from occupations
)

select
    max(case when occupation = 'doctor' then name end) as doctor,
    max(case when occupation = 'professor' then name end) as professor,
    max(case when occupation = 'singer' then name end) as singer,
    max(case when occupation = 'actor' then name end) as actor
from cte
group by rn
order by rn;