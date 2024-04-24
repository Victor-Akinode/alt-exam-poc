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


--To find the top 5 spenders without considering currency and without using the LINE_ITEMS table, 
--I join the ORDERS table with the CUSTOMERS table to associate each order with its customer.
--I join the LINE_ITEMS table to link orders with the products they contain.
--I also join the PRODUCTS table to retrieve the price of each product.
--I sum up the prices of products in each order for each customer using the SUM function.
--The results are ordered by total_spend in descending order to identify the top spenders.
--Finally, I limit the result to the top 5 spenders using the LIMIT clause.

SELECT
    c.customer_id,
    c.location,
    SUM(p.price) AS total_spend
FROM
    ALT_SCHOOL.ORDERS o
JOIN
    ALT_SCHOOL.CUSTOMERS c ON o.customer_id = c.customer_id
JOIN
    ALT_SCHOOL.LINE_ITEMS li ON o.order_id = li.order_id
JOIN
    ALT_SCHOOL.PRODUCTS p ON li.item_id = p.id
GROUP BY
    c.customer_id, c.location
ORDER BY
    total_spend DESC
LIMIT 5;

--PART 2b
--To determine the most common location (country) where successful checkouts occurred using the EVENTS table, need to filter the events related to successful
-- checkouts, extract the location information from each event, and then count the occurrences of each location.
-- I join the events table with the customers table based on the customer_id to associate each successful checkout event with its corresponding customer.
-- I retrieved the location information from the customers table.
-- I grouped the results by location and count the number of successful checkouts in each location.
-- I ordered the results by the count of successful checkouts in descending order.
-- I limited the output to the top location with the highest number of successful checkouts.

-- The asnwer I got is Korea, which has 17 checkouts

SELECT
    c.location,
    COUNT(*) AS checkout_count
FROM
    ALT_SCHOOL.EVENTS e
JOIN
    ALT_SCHOOL.CUSTOMERS c ON e.customer_id = c.customer_id
WHERE
    e.event_data ->> 'status' = 'success' 
    c.location
ORDER BY
    checkout_count DESC
LIMIT 1;

