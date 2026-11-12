/*
https://www.hackerrank.com/challenges/what-type-of-triangle/problem?isFullScreen=true
Type of Triangle

Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.
*/

select
    case
        when a + b <= c or a + c <= b or b + c <= a then 'not a triangle'
        when a = b and b = c then 'equilateral'
        when a = b or b = c or a = c then 'isosceles'
        else 'scalene'
    end as triangle_type
from triangles;