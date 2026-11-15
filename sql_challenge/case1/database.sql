Table sales {
  "customer_id" varchar(1)
  "order_date" date
  "product_id" integer
}

Table menu {
  "product_id" integer
  "product_name" varchar(5)
  "price" integer
}

Table members {
  "customer_id" varchar(1)
  "join_date" date
}

Ref: "sales"."customer_id" > "members"."customer_id"
Ref: "sales"."product_id" > "menu"."product_id"

