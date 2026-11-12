/*
Weather Observation Station 20

A median is defined as a number separating the higher half of a data set from the lower half. Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to 4 decimal places.
*/

with cte as (
    select
        lat_n,
        row_number() over (order by lat_n) as rn,
        count(*) over () as total_count
    from station
)
select round(avg(lat_n), 4)
from cte
where rn in (
    floor((total_count + 1) / 2),
    ceil((total_count + 1) / 2)
);