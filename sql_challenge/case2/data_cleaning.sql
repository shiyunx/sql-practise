/**
Check data 

1. customer_orders table
- Replace blank and NaN with null.
- Standardise exclusions column and extras column.

2. runner_orders table
- Replace blank and NaN with null.
- Remove extra spaces.
- Convert pickup_time from varchar to timestamp.
- Convert distance from varchar to numeric.
- Convert duration from varchar to numeric (minutes).
- Standarise cancellation column.
**/

-- Check exclusions column and extras column.
SELECT DISTINCT exclusions, extras
FROM customer_orders;

-- Check cancellation column
SELECT DISTINCT pickup_time, distance, duration, cancellation
FROM runner_orders;

-- Clean customer_orders table

DROP TABLE IF EXISTS customer_orders_cleaned;

CREATE TABLE customer_orders_cleaned AS
WITH cleaned AS (
    SELECT
        order_id,
        customer_id,
        pizza_id,

        CASE
            WHEN exclusions IS NULL
                OR TRIM(exclusions) = ''
                OR LOWER(TRIM(exclusions)) IN ('null', 'nan')
            THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,

        CASE
            WHEN extras IS NULL
                OR TRIM(extras) = ''
                OR LOWER(TRIM(extras)) IN ('null', 'nan')
            THEN NULL
            ELSE TRIM(extras)
        END AS extras,

        order_time

    FROM pizza_runner.customer_orders
)


SELECT *
FROM cleaned;

-- Verify cleaned customer_orders table

SELECT *
FROM customer_orders_cleaned
ORDER BY order_id;

+----------+------------+----------+------------+--------+---------------------+
| order_id | customer_id| pizza_id | exclusions | extras | order_time          |
+----------+------------+----------+------------+--------+---------------------+
| 1        | 101        | 1        | null       | null   | 2020-01-01 18:05:02 |
| 2        | 101        | 1        | null       | null   | 2020-01-01 19:00:52 |
| 3        | 102        | 1        | null       | null   | 2020-01-02 23:51:23 |
| 3        | 102        | 2        | null       | null   | 2020-01-02 23:51:23 |
| 4        | 103        | 1        | 4          | null   | 2020-01-04 13:23:46 |
| 4        | 103        | 1        | 4          | null   | 2020-01-04 13:23:46 |
| 4        | 103        | 2        | 4          | null   | 2020-01-04 13:23:46 |
| 5        | 104        | 1        | null       | 1      | 2020-01-08 21:00:29 |
| 6        | 101        | 2        | null       | null   | 2020-01-08 21:03:13 |
| 7        | 105        | 2        | null       | 1      | 2020-01-08 21:20:29 |
| 8        | 102        | 1        | null       | null   | 2020-01-09 23:54:33 |
| 9        | 103        | 1        | 4          | 1, 5    | 2020-01-10 11:22:59 |
| 10       | 104        | 1        | null       | null   | 2020-01-11 18:34:49 |
| 10       | 104        | 1        | 2, 6       | 1, 4    | 2020-01-11 18:34:49 |
+----------+------------+----------+------------+--------+---------------------+

-- Clean runner_orders table

DROP TABLE IF EXISTS runner_orders_cleaned;

CREATE TABLE runner_orders_cleaned AS
WITH cleaned AS (
    SELECT
        order_id,
        runner_id,

        CASE
            WHEN pickup_time IS NULL
                OR TRIM(pickup_time) = ''
                OR LOWER(TRIM(pickup_time)) IN ('null', 'nan')
            THEN NULL
            ELSE TRIM(pickup_time)::TIMESTAMP
        END AS pickup_time,

        CASE
            WHEN distance IS NULL
                OR TRIM(distance) = ''
                OR LOWER(TRIM(distance)) IN ('null', 'nan')
            THEN NULL
            ELSE NULLIF(
                REGEXP_REPLACE(LOWER(TRIM(distance)), '[^0-9.]', '', 'g'),
                ''
            )::NUMERIC
        END AS distance,

        CASE
            WHEN duration IS NULL
                OR TRIM(duration) = ''
                OR LOWER(TRIM(duration)) IN ('null', 'nan')
            THEN NULL
            ELSE NULLIF(
                REGEXP_REPLACE(LOWER(TRIM(duration)), '[^0-9.]', '', 'g'),
                ''
            )::INTEGER
        END AS duration,

        CASE
            WHEN cancellation IS NULL
                OR TRIM(cancellation) = ''
                OR LOWER(TRIM(cancellation)) IN ('null', 'nan')
            THEN NULL
            ELSE TRIM(cancellation)
        END AS cancellation

    FROM pizza_runner.runner_orders
)

SELECT *
FROM cleaned;

-- Check cleaned runner_orders table

SELECT *
FROM runner_orders_cleaned
ORDER BY order_id;

+----------+-----------+---------------------+----------+----------+------------------------+
| order_id | runner_id | pickup_time         | distance | duration | cancellation            |
+----------+-----------+---------------------+----------+----------+------------------------+
| 1        | 1         | 2020-01-01 18:15:34 | 20       | 32       | null                   |
| 2        | 1         | 2020-01-01 19:10:54 | 20       | 27       | null                   |
| 3        | 1         | 2020-01-03 00:12:37 | 13.4     | 20       | null                   |
| 4        | 2         | 2020-01-04 13:53:03 | 23.4     | 40       | null                   |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15       | null                   |
| 6        | 3         | null                | null     | null     | Restaurant Cancellation|
| 7        | 2         | 2020-01-08 21:30:45 | 25       | 25       | null                   |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4     | 15       | null                   |
| 9        | 2         | null                | null     | null     | Customer Cancellation |
| 10       | 1         | 2020-01-11 18:50:20 | 10       | 10       | null                   |
+----------+-----------+---------------------+----------+----------+------------------------+

-- Verify cleaned runner_orders table

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'runner_orders_cleaned';

+---------------------+--------------+-----------------------------+
| table_name          | column_name  | data_type                   |
+---------------------+--------------+-----------------------------+
| runner_orders_cleaned| order_id     | integer                     |
| runner_orders_cleaned| runner_id    | integer                     |
| runner_orders_cleaned| pickup_time  | timestamp without time zone |
| runner_orders_cleaned| distance     | numeric                     |
| runner_orders_cleaned| duration     | integer                     |
| runner_orders_cleaned| cancellation | text                        |
+---------------------+--------------+-----------------------------+



