CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM sales
SELECT * FROM menu
SELECT * FROM members

-- 1. What is the total amount each customer spent at the restaurant?

SELECT sales.customer_id, SUM(menu.price) AS total_spent 
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY total_spent DESC

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id , COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?

WITH cte AS
(
SELECT s.customer_id, m.product_name,
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS row_num
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
)
  SELECT customer_id,product_name AS first_product
  FROM cte
  WHERE row_num = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(s.customer_id) AS purchase_num
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_num DESC
LIMIT 1

-- 5. Which item was the most popular for each customer?

WITH cte2 AS
(
SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS purchase_num
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
),
cte3 AS 
(
SELECT customer_id, product_name,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY purchase_num DESC) AS item_rank
FROM cte2
)
SELECT customer_id, product_name AS most_popular_item
FROM cte3
WHERE item_rank = 1

-- 6. Which item was purchased first by the customer after they became a member?

WITH cte4 AS
(
SELECT s.customer_id, s.order_date, s.product_id,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS item_rank
FROM sales AS s
JOIN members AS m
ON s.customer_id = m.customer_id
WHERE s.order_date > m.join_date
)
SELECT cte4.customer_id, menu.product_name AS after_membership_item
FROM cte4
JOIN menu
ON cte4.product_id = menu.product_id
WHERE cte4.item_rank = 1

-- 7. Which item was purchased just before the customer became a member?

WITH cte5 AS
(
SELECT s.customer_id, s.order_date, s.product_id,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC ) AS item_rank
FROM sales AS s
JOIN members AS m
ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date
)
SELECT cte5.customer_id, menu.product_name AS before_membership_item
FROM cte5
JOIN menu
ON cte5.product_id = menu.product_id
WHERE cte5.item_rank = 1

-- 8. What is the total items and amount spent for each member before they became a member?

WITH cte6 AS
(
SELECT s.customer_id, s.order_date, s.product_id
FROM sales AS s
JOIN members AS m
ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date
),
cte7 AS
(
SELECT cte6.customer_id, cte6.product_id,menu.price
FROM cte6
JOIN menu
ON cte6.product_id = menu.product_id
)
SELECT customer_id, COUNT(product_id) AS total_item, SUM(price) AS amount_spent
FROM cte7
GROUP BY customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, SUM(
             			   CASE
								WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
								ELSE m.price * 10
						   END
) AS total_points
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH cte8 AS
(
SELECT s.customer_id, s.order_date, members.join_date, s.product_id
FROM sales AS s
JOIN members
ON s.customer_id = members.customer_id
WHERE members.join_date >= s.order_date AND order_date < '2021-02-01'
)
SELECT cte8.customer_id, SUM(
						CASE
							WHEN cte8.order_date BETWEEN cte8.join_date AND (cte8.join_date + INTERVAL '7 days') THEN m.price * 10 * 2
							WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
							ELSE m.price * 10
						END
) AS total_january_pints
FROM cte8
JOIN menu AS m
ON cte8.product_id = m.product_id
GROUP BY cte8.customer_id

---------------------------------   OR   -----------------------------------------------

WITH cte8 AS
(
SELECT s.customer_id, s.order_date, m.product_id, m.price,
CASE 
	WHEN s.order_date BETWEEN mb.join_date AND (mb.join_date + INTERVAL '7 days') THEN m.price * 10 * 2
	WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
	ELSE m.price * 10
END AS total_january_points
FROM menu AS m
JOIN sales AS s
ON s.product_id = m.product_id
JOIN members AS mb
ON s.customer_id = mb.customer_id
WHERE order_date < '2021-02-01' AND mb.join_date >= s.order_date
)
SELECT customer_id, SUM(total_january_points) AS total_january_points
FROM cte8
GROUP BY customer_id

-- Bonus Q.NO - 11

SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE
	WHEN s.order_date >= mb.join_date THEN 'Y'
	ELSE 'N'
END AS member
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
LEFT JOIN members AS mb
ON s.customer_id = mb.customer_id
ORDER BY s.customer_id, s.order_date

-- Bonus Q.NO - 12

WITH cte10 AS
(
SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE
	WHEN s.order_date >= mb.join_date THEN 'Y'
	ELSE 'N'
END AS member
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
LEFT JOIN members AS mb
ON s.customer_id = mb.customer_id
)
SELECT customer_id, order_date, product_name, price, member,
CASE
	WHEN member = 'Y' THEN RANK() OVER(PARTITION BY customer_id,member ORDER BY order_date) 
	ELSE null
END AS ranking
FROM cte10