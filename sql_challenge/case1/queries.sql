-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id,
sum(m.price) as total_spent
from sales s
inner join menu m
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id ;

+-------------+-------------+
| customer_id | total_spent |
+-------------+-------------+
| A           | 76          |
| B           | 74          |
| C           | 36          |
+-------------+-------------+

-- 2. How many days has each customer visited the restaurant?

select customer_id, 
count (distinct order_date) as visited_days
from sales 
group by customer_id
order by customer_id;

+-------------+--------------+
| customer_id | visited_days |
+-------------+--------------+
| A           | 4            |
| B           | 6            |
| C           | 2            |
+-------------+--------------+

-- 3. What was the first item from the menu purchased by each customer?

with first_item_purchased as
(
  select
  	s.customer_id,
  	s.order_date,
  	m.product_name,
  	dense_rank() over (
  		partition by s.customer_id 
  		order by s.order_date) as ranking
  	from sales s
  	inner join menu m
  	on s.product_id = m.product_id
)
select distinct customer_id, product_name
from first_item_purchased
where ranking = 1;

+-------------+--------------+
| customer_id | product_name |
+-------------+--------------+
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |
+-------------+--------------+

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name,
count(s.product_id) as most_purchased_item
from sales s
inner join menu m
on s.product_id = m.product_id
group by m.product_name
order by most_purchased_item desc
limit 1;

+--------------+---------------------+
| product_name  | most_purchased_item |
+--------------+---------------------+
| ramen         | 8                   |
+--------------+---------------------+

--5. Which item was the most popular for each customer?

with most_popular_item as
(
  select 
  	s.customer_id,
  	m.product_name,
  	count(m.product_id) as order_count,
  	dense_rank() over (
  		partition by s.customer_id 
  		order by count(s.product_id) desc) as ranking
  	from sales s
  	inner join menu m
  	on s.product_id = m.product_id
  	group by s.customer_id, m.product_name
)
select customer_id, product_name, order_count
from most_popular_item
where ranking = 1;

+-------------+--------------+-------------+
| customer_id | product_name | order_count |
+-------------+--------------+-------------+
| A           | ramen        | 3           |
| B           | ramen        | 2           |
| B           | curry        | 2           |
| B           | sushi        | 2           |
| C           | ramen        | 3           |
+-------------+--------------+-------------+

--6. Which item was purchased first by the customer after they became a member?

with member_first_item_purchased as
(
  select 
  	s.customer_id,
  	m.product_name,
	s.order_date,	
  	dense_rank() over (
  		partition by s.customer_id 
  		order by s.order_date) as ranking
  from sales s
  inner join menu m
  on s.product_id = m.product_id
  inner join members mem
  on s.customer_id = mem.customer_id
  where s.order_date >= mem.join_date
)
select customer_id, product_name, order_date
from member_first_item_purchased
where ranking = 1;

+-------------+--------------+------------+
| customer_id | product_name | order_date |
+-------------+--------------+------------+
| A           | curry        | 2021-01-07 |
| B           | sushi        | 2021-01-11 |
+-------------+--------------+------------+

--7. Which item was purchased just before the customer became a member?

with nonmember_last_item_purchased as
(
  select
    s.customer_id,
	m.product_name,
    s.order_date,
    dense_rank() over (
        partition by s.customer_id
        order by s.order_date desc) as ranking
  from sales s
  inner join menu m
  on s.product_id = m.product_id
  inner join members mem
  on s.customer_id = mem.customer_id
  where s.order_date < mem.join_date
)
select customer_id, product_name, order_date
from nonmember_last_item_purchased 
where ranking = 1;

+-------------+--------------+------------+
| customer_id | product_name | order_date |
+-------------+--------------+------------+
| A           | sushi        | 2021-01-01 |
| A           | curry        | 2021-01-01 |
| B           | sushi        | 2021-01-04 |
+-------------+--------------+------------+

--8. What is the total items and amount spent for each member before they became a member?

select s.customer_id,
count(s.product_id) as total_items,
sum(m.price) as total_spent
from sales s
inner join menu m
on s.product_id = m.product_id
inner join members mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id
order by s.customer_id;

+-------------+-------------+-------------+
| customer_id | total_items | total_spent |
+-------------+-------------+-------------+
| A           | 2           | 25          |
| B           | 3           | 40          |
+-------------+-------------+-------------+

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10 points per $1 = other items = price * 10, 20 points per $1 = sushi = price * 20

with total_customer_points as
(
    select
        s.customer_id,
        sum(
            case
                when m.product_name = 'sushi' then (m.price * 20)
                else (m.price * 10)
            end
        ) as total_points
    from sales s
    inner join menu m
        on s.product_id = m.product_id
    group by s.customer_id
)
select
    customer_id,
    total_points
from total_customer_points
order by customer_id;

+-------------+-------------+
| customer_id | total_points |
+-------------+-------------+
| A           | 860         |
| B           | 940         |
| C           | 360         |
+-------------+-------------+

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


with jan_member_points as
(
  select 
    mem.customer_id,
    sum(
      case
        when s.order_date < mem.join_date then
          case 
            when m.product_name = 'sushi' then (m.price * 20)
            else (m.price * 10)
          end
        when s.order_date > (mem.join_date + 6) then 
          case 
            when m.product_name = 'sushi' then (m.price * 20)
            else (m.price * 10)
          end 
        else (m.price * 20)	
      end
    ) as member_points
  from sales s
  inner join menu m
    on s.product_id = m.product_id
  inner join members mem
    on s.customer_id = mem.customer_id
  where s.order_date <= '2021-01-31'
  group by mem.customer_id
)
select
  customer_id,
  member_points
from jan_member_points
where customer_id in ('A', 'B')
order by customer_id;

+-------------+--------------+
| customer_id | member_points |
+-------------+--------------+
| A           | 1370         |
| B           | 820          |
+-------------+--------------+