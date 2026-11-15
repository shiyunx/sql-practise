Table runners {
  "runner_id" integer
  "registration_date" date
}

Table customer_orders {
  "order_id" integer
  "customer_id" integer
  "pizza_id" integer
  "exclusions" varchar(4)
  "extras" varchar(4)
  "order_time" timestamp
}

Table runner_orders {
  "order_id" integer
  "runner_id" integer
  "pickup_time" varchar(19)
  "distance" varchar(7)
  "duration" varchar(10)
  "cancellation" varchar(23)
}

Table pizza_recipes {
  "pizza_id" integer
  "toppings" text
}

Table pizza_toppings {
  "topping_id" integer
  "topping_name" text
}

Table pizza_names {
  "pizza_id" integer
  "pizza_name" text
}

Ref: "runners"."runner_id" < "runner_orders"."runner_id"
Ref: "runner_orders"."order_id" < "customer_orders"."order_id"
Ref: "pizza_names"."pizza_id" < "customer_orders"."pizza_id"
Ref: "pizza_recipes"."pizza_id" < "customer_orders"."pizza_id"