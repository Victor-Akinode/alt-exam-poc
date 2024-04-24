--PART 2a
---To find the most ordered item based on the number of times it appears in successfully 
---checked out carts, I wrote a SQL query that joins the LINE_ITEMS and 
---ORDERS tables to identify orders that were successfully checked out. Then, I 
--counted the occurrences of each product in these orders to determine the 
--number of times it appeared in successfully checked out carts.


SELECT
    p.id AS product_id,
    p.name AS product_name,
    COUNT(*) AS num_times_in_successful_orders
FROM
    ALT_SCHOOL.LINE_ITEMS li
JOIN
    ALT_SCHOOL.ORDERS o ON li.order_id = o.order_id
JOIN
    ALT_SCHOOL.PRODUCTS p ON li.item_id = p.id
WHERE
    o.status = 'success'
GROUP BY
    p.id, p.name
ORDER BY
    COUNT(*) DESC
LIMIT 1;


--To find the top 5 spenders without considering currency and without using the LINE_ITEMS 
--table, we can write a SQL query that calculates the total spend for each customer by summing 
--up the total amount of money spent on orders. We'll join the ORDERS and CUSTOMERS tables to get 
--the necessary information.

SELECT
    c.customer_id,
    c.location,
    SUM(o.total_amount) AS total_spend
FROM
    ALT_SCHOOL.ORDERS o
JOIN
    ALT_SCHOOL.CUSTOMERS c ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id, c.location
ORDER BY
    total_spend DESC
LIMIT 5;
