-- A. Pizza Metrics

-- 1. How many pizzas were ordered?

select count(*) as total_ordered
from customer_orders_cleaned;

+--------------+
| total_ordered |
+--------------+
| 14           |
+--------------+

-- 2. How many unique customer orders were made?

select count (distinct order_id) as unique_orders
from customer_orders_cleaned;

+---------------+
| unique_orders |
+---------------+
| 10            |
+---------------+

-- 3. How many successful orders were delivered by each runner?

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

-- 4. How many of each type of pizza was delivered?
 
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

-- 6. What was the maximum number of pizzas delivered in a single order?

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

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

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

-- 8. How many pizzas were delivered that had both exclusions and extras?

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

-- 9. What was the total volume of pizzas ordered for each hour of the day?

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

-- 10. What was the volume of orders for each day of the week?

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




-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

with runners_signed as (
  select
    runner_id,
    registration_date,
    registration_date - ((registration_date - '2021-01-01') % 7) as start_week
  from runners
)

select start_week,
count(runner_id) as numbers_of_runners
from runners_signed
group by start_week
order by start_week;

+------------+-------------------+
| start_week | numbers_of_runners|
+------------+-------------------+
| 2021-01-01 | 2                 |
| 2021-01-08 | 1                 |
| 2021-01-15 | 1                 |
+------------+-------------------+

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with runner_time as (
  select
    r.runner_id,
    r.order_id,
    c.order_time,
    r.pickup_time,
    (pickup_time - order_time) as runner_arrive_time
  from customer_orders_cleaned c
  join runner_orders_cleaned r
  on c.order_id = r.order_id
)

select
  runner_id,
  extract('minutes' from avg(runner_arrive_time)) as avg_arrive_time
from runner_time
group by runner_id
order by runner_id;

+-----------+-----------------+
| runner_id | avg_arrive_time |
+-----------+-----------------+
| 1         | 15              |
| 2         | 23              |
| 3         | 10              |
+-----------+-----------------+

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with pizzas_count as (
  select
    order_id,
    order_time,
    count(pizza_id) as number_of_pizzas
  from customer_orders_cleaned c
  group by order_id, order_time
),

prepare_time as (
  select
    r.runner_id,
    pc.order_time,
    r.pickup_time,
    pc.number_of_pizzas,
    (r.pickup_time - pc.order_time) as runner_arrive_time
  from runner_orders_cleaned r
  join pizzas_count pc
    on r.order_id = pc.order_id
  where r.pickup_time is not null
)

select
  number_of_pizzas,
  round(
    (extract(hour from avg(runner_arrive_time)) * 60
    + extract(minute from avg(runner_arrive_time))
    + extract(second from avg(runner_arrive_time)) / 60)::numeric
  )::integer as avg_prepare_time
from prepare_time
group by number_of_pizzas
order by number_of_pizzas;

+-----------------+------------------+
| number_of_pizzas | avg_prepare_time|
+-----------------+------------------+
| 1               | 12               |
| 2               | 18               |
| 3               | 29               |
+-----------------+------------------+

--4. What was the average distance travelled for each customer?

with distance_travelled as (
  select
    c.order_id,
    r.runner_id,
    r.distance
  from customer_orders_cleaned c
  join runner_orders_cleaned r
  on c.order_id = r.order_id
  where r.distance is not null
  group by c.order_id, r.runner_id, r.distance
  order by r.runner_id
)

select runner_id,
round(avg(distance),2) as avg_distance
from distance_travelled
group by runner_id;

+-----------+--------------+
| runner_id | avg_distance |
+-----------+--------------+
| 1         | 15.85        |
| 2         | 23.93        |
| 3         | 10.00        |
+-----------+--------------+

--5. What was the difference between the longest and shortest delivery times for all orders?

select
  min(duration) as min_time,
  max(duration) as max_time,
  max(duration) - min(duration) as time_diffence
from runner_orders_cleaned;

+----------+----------+----------------+
| min_time | max_time | time_diffence  |
+----------+----------+----------------+
| 10       | 40       | 30             |
+----------+----------+----------------+

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

with order_delivery_count as (
  select
    order_id,
    customer_id,
    order_time,
    count(pizza_id) as number_of_pizzas
  from customer_orders_cleaned
  group by order_id, customer_id, order_time
)

select
	o.customer_id,
	r.order_id,
	r.runner_id,
	r.distance,
	r.duration,
  o.number_of_pizzas,
	round(60 * r.distance / r.duration, 2) as average_speed
from runner_orders_cleaned r
join order_delivery_count o
on o.order_id = r.order_id
where r.pickup_time is not null
order by average_speed;

+-------------+----------+-----------+----------+----------+-----------------+---------------+
| customer_id | order_id | runner_id | distance | duration | number_of_pizzas | average_speed |
+-------------+----------+-----------+----------+----------+-----------------+---------------+
| 103         | 4        | 2         | 23.4     | 40       | 3               | 35.10         |
| 101         | 1        | 1         | 20       | 32       | 1               | 37.50         |
| 104         | 5        | 3         | 10       | 15       | 1               | 40.00         |
| 102         | 3        | 1         | 13.4     | 20       | 2               | 40.20         |
| 101         | 2        | 1         | 20       | 27       | 1               | 44.44         |
| 105         | 7        | 2         | 25       | 25       | 1               | 60.00         |
| 104         | 10       | 1         | 10       | 10       | 2               | 60.00         |
| 102         | 8        | 2         | 23.4     | 15       | 1               | 93.60         |
+-------------+----------+-----------+----------+----------+-----------------+---------------+

--7. What is the successful delivery percentage for each runner?

select
    runner_id,
    count(pickup_time) as pizzas_delivered,
    count(order_id) as total_orders,
    (round(100 * count(pickup_time) / count(order_id))) as successful_delivered
from runner_orders_cleaned
group by runner_id
order by runner_id;

+-----------+------------------+-------------+-----------------------+
| runner_id | pizzas_delivered | total_orders | successful_delivered |
+-----------+------------------+-------------+-----------------------+
| 1         | 4                | 4           | 100                   |
| 2         | 3                | 4           | 75                    |
| 3         | 1                | 2           | 50                    |
+-----------+------------------+-------------+-----------------------+