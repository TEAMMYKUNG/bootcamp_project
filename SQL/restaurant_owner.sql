/* Restaurant Owners  5TABLE --> 1 FACT , 4 DIM
   add foreign key Write  SQL 3 Queries analyze data
   3 Sub Queries / With */

CREATE TABLE fact_orders (
  order_id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT,
  order_date date NOT NULL,
  channel_id INT NOT NULL,
  staff_id INT NOT NULL,
  member_id INT NOT NULL,
  product_id INT NOT NULL,
  FOREIGN KEY(channel_id) REFERENCES dim_channels(channel_id)
  FOREIGN KEY(staff_id) REFERENCES dim_staff(staff_id)
  FOREIGN KEY(member_id) REFERENCES dim_members(member_id)
  FOREIGN KEY(product_id) REFERENCES dim_products(product_id)
);
CREATE TABLE dim_members (
  member_id INT UNIQUE PRIMARY KEY,
  firstname TEXT,
  lastname TEXT
);
CREATE TABLE dim_staff (
  staff_id INT UNIQUE PRIMARY KEY,
  firstname TEXT,
  lastname TEXT
);
CREATE TABLE dim_products (
  product_id INT UNIQUE PRIMARY KEY,
  product_name TEXT,
  price REAL
);
CREATE TABLE dim_channels (
  channel_id INT UNIQUE PRIMARY KEY,
  channel_name TEXT
);

INSERT INTO dim_staff VALUES
  (1, 'Eiko', 'Uemura'),
  (2, 'Haru', 'Arata'),
  (3, 'Rin', 'Tabata'),
  (4, 'Keiichi', 'Ozawa'),
  (5, 'Mitsuo', 'Handa');

INSERT INTO dim_channels VALUES
  (1, 'Restaurant'),
  (2, 'Grab'),
  (3, 'Robinhood'),
  (4, 'Panda'),
  (5, 'Shopee'),
  (6, 'Line');

INSERT INTO dim_products VALUES
  (1, 'Salmon Don', 170),
  (2, 'Spicy Tuna Don', 150),
  (3, 'Wagrill Don', 175),
  (4, 'Tempura don', 140),
  (5, 'Unagi Don', 170),
  (6, 'Kurobuta Don', 135),
  (7, 'Karaage Don', 135);

INSERT INTO dim_members VALUES
  (1, 'Tommy', 'Dean'),
  (2, 'Louise', 'Khan'),
  (3, 'Jessica', 'Baxter'),
  (4, 'Erin', 'Rose'),
  (5, 'Victoria', 'Thornton'),
  (6, 'Monty', 'Meza'),
  (7, 'Luzy', 'Bowden');

-- Date , Channel , Staff , Member, Product
INSERT INTO 
  fact_orders(order_date,channel_id,staff_id,member_id,product_id) VALUES
  ('2022-08-01',4,1,2,6),
  ('2022-08-01',5,2,1,4),
  ('2022-08-02',1,2,1,3),
  ('2022-08-02',2,5,7,1),
  ('2022-08-02',5,3,1,1),
  ('2022-08-02',3,3,3,5),
  ('2022-08-03',5,4,6,4),
  ('2022-08-03',5,2,4,4),
  ('2022-08-03',1,4,7,2),
  ('2022-08-03',5,4,5,7),
  ('2022-08-03',2,2,3,6),
  ('2022-08-04',5,3,5,1),
  ('2022-08-04',6,1,1,3),
  ('2022-08-04',5,2,7,4),
  ('2022-08-04',4,2,3,1),
  ('2022-08-04',3,1,6,3),
  ('2022-08-04',2,4,5,4),
  ('2022-08-05',4,5,7,6),
  ('2022-08-05',2,4,5,6),
  ('2022-08-05',4,3,3,7),
  ('2022-08-05',3,3,6,7),
  ('2022-08-06',4,4,5,4),
  ('2022-08-06',2,5,2,2),
  ('2022-08-06',5,3,3,2),
  ('2022-08-06',3,4,6,5),
  ('2022-08-06',3,4,4,2),
  ('2022-08-06',4,4,6,6),
  ('2022-08-06',3,5,1,4),
  ('2022-08-07',6,4,7,3),
  ('2022-08-07',1,3,1,4),
  ('2022-08-07',3,5,4,4),
  ('2022-08-07',4,4,1,3),
  ('2022-08-07',2,5,7,2);


.mode markdown
.header on

-- Revenue / Day
WITH product_sale AS(
  SELECT
    ord.order_id,
    ord.order_date,
    pro.product_name,
    pro.price
  FROM fact_orders AS 'ord'
  JOIN dim_products AS 'pro'
    ON ord.product_id = pro.product_id
)
SELECT 
  order_date DATE,
  sum(price) Revenue,
  COUNT(*) 'ORDERS'
FROM product_sale
GROUP BY order_date;


-- Product Sold Amount
SELECT 
  product_name Product,
  count(*) Sold
FROM (
  SELECT
    ord.order_id,
    ord.order_date,
    pro.product_name,
    pro.price
  FROM fact_orders AS 'ord'
  JOIN dim_products AS 'pro'
    ON ord.product_id = pro.product_id)
GROUP BY product_name
ORDER BY Sold DESC;

-- Sold / Channel list
SELECT
  channel_name Platform,
  count(*) Sold
FROM(
  SELECT
    ord.order_date,
    pro.product_name,
    pro.price,
    ch.channel_name
  FROM fact_orders AS 'ord'
  JOIN dim_products AS 'pro'
    ON ord.product_id = pro.product_id
  JOIN dim_channels AS 'ch'
    ON ord.channel_id = ch.channel_id)
GROUP BY channel_name
ORDER BY 2 DESC;



--top3 member
SELECT 
  Customer,
  SUM(price) Total
FROM (
  SELECT
    ord.order_id,
    ord.order_date,
    ord.member_id,
    pro.product_name,
    pro.price,
    mem.firstname || ' ' || mem.lastname as Customer
  FROM fact_orders AS 'ord'
  JOIN dim_products AS 'pro'
    ON ord.product_id = pro.product_id
  JOIN dim_members AS 'mem'
    ON ord.member_id = mem.member_id
  )
GROUP BY Customer
ORDER BY Total DESC
limit 3