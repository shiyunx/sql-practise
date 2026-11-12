/*
https://www.hackerrank.com/challenges/revising-aggregations-the-average-function/problem?isFullScreen=true
Averages

Query the average population of all cities in CITY where District is California.
*/

select avg(population)
from city
where district = 'california';