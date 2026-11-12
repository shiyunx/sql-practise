/*
https://www.hackerrank.com/challenges/revising-aggregations-the-count-function/problem?isFullScreen=true
The Count Function

Query a count of the number of cities in CITY having a Population larger than 100000.
*/

select count(*)
from city
where population > 100000;