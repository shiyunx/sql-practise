-- A. Pizza Metrics

--1. How many pizzas were ordered?

select count(*) as total_ordered
from customer_orders_cleaned;

+--------------+
| total_ordered |
+--------------+
| 14           |
+--------------+

--2. How many unique customer orders were made?

select count (distinct order_id) as unique_orders
from customer_orders_cleaned;

+---------------+
| unique_orders |
+---------------+
| 10            |
+---------------+

--3. How many successful orders were delivered by each runner?

select runner_id, 
count(order_id) as successful_orders
from runner_orders_cleaned
where cancellation is null
group by runner_id
order by successful_orders desc;

+-----------+-------------------+
| runner_id | successful_orders |
+-----------+-------------------+
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |
+-----------+-------------------+

--4. How many of each type of pizza was delivered?
 
select p.pizza_name,
count(c.*) as pizza_delivered
from customer_orders_cleaned c
join pizza_names p
on c.pizza_id = p.pizza_id
join runner_orders_cleaned r
on c.order_id = r.order_id
where cancellation is null
group by pizza_name
order by pizza_delivered desc;

+------------+-----------------+
| pizza_name | pizza_delivered |
+------------+-----------------+
| Meatlovers | 9               |
| Vegetarian | 3               |
+------------+-----------------+

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, 
  sum(case when pizza_id = 1 then 1 else 0 end) as meat_lovers,
  sum(case when pizza_id = 2 then 1 else 0 end) as vegetarian
from customer_orders_cleaned
group by customer_id
order by customer_id;

+-------------+-------------+------------+
| customer_id | meat_lovers | vegetarian |
+-------------+-------------+------------+
| 101         | 2           | 1          |
| 102         | 2           | 1          |
| 103         | 3           | 1          |
| 104         | 3           | 0          |
| 105         | 0           | 1          |
+-------------+-------------+------------+

--6. What was the maximum number of pizzas delivered in a single order?

with pizza_count as (
  select c.order_id,
    count(c.pizza_id) as pizza_order
  from customer_orders_cleaned c
  join runner_orders_cleaned r
  on c.order_id = r.order_id
  where cancellation is null
  group by c.order_id
)

select
  max(pizza_order) as max_pizza_count
from pizza_count;

+-----------------+
| max_pizza_count |
+-----------------+
| 3               |
+-----------------+

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select c.customer_id,
  sum(case when c.exclusions is not null or c.extras is not null then 1 else 0 end) as changes,
  sum(case when c.exclusions is null and c.extras is null then 1 else 0 end) as no_changes
from customer_orders_cleaned c
join runner_orders_cleaned r
on c.order_id = r.order_id
where cancellation is null
group by c.customer_id
order by c.customer_id;

+-------------+---------+------------+
| customer_id | changes | no_changes |
+-------------+---------+------------+
| 101         | 0       | 2          |
| 102         | 0       | 3          |
| 103         | 3       | 0          |
| 104         | 2       | 1          |
| 105         | 1       | 0          |
+-------------+---------+------------+

--8. How many pizzas were delivered that had both exclusions and extras?

select
  sum(case when c.exclusions is not null and c.extras is not null then 1 else 0 end) as pizza_count
from customer_orders_cleaned c
join runner_orders_cleaned r
on c.order_id = r.order_id
where cancellation is null;

+-------------+
| pizza_count |
+-------------+
| 1           |
+-------------+

--9. What was the total volume of pizzas ordered for each hour of the day?

select
extract(hour from order_time) as order_hour,
count(*) as total_pizzas
from customer_orders_cleaned
group by extract(hour from order_time)
order by order_hour;

+------------+--------------+
| order_hour | total_pizzas |
+------------+--------------+
| 11         | 1            |
| 13         | 3            |
| 18         | 3            |
| 19         | 1            |
| 21         | 3            |
| 23         | 3            |
+------------+--------------+

--10. What was the volume of orders for each day of the week?

select
to_char(order_time, 'day') as day_of_week,
count(*) as total_pizzas
from customer_orders_cleaned
group by day_of_week,
extract('dow' from order_time)
order by extract('dow' from order_time);

+-------------+--------------+
| day_of_week | total_pizzas |
+-------------+--------------+
| wednesday   | 5            |
| thursday    | 3            |
| friday      | 1            |
| saturday    | 5            |
+-------------+--------------+