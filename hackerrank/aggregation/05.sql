/*
https://www.hackerrank.com/challenges/earnings-of-employees/problem?isFullScreen=true
Top Earners

We define an employee's total earnings to be their salary x months worked, and the maximum total earnings to be the maximum total earnings for any employee in the Employee table. Write a query to find the maximum total earnings for all employees as well as the total number of employees who have maximum total earnings. Then print these values as  space-separated integers.
*/

select months * salary as total_earnings,
count(*) as count_employees
from employee
group by months * salary
order by total_earnings desc
limit 1;