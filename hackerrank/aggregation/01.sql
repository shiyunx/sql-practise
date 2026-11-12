/*
https://www.hackerrank.com/challenges/average-population/problem?isFullScreen=true
Average Population

Query the average population for all cities in CITY, rounded down to the nearest integer.
*/

select floor(avg(population))
from city;