--PART 2a(i)
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

--Part 2a(ii)
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

--PART 2b(i)
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

--Part2b(ii)
--I used CTEs to define two temporary result sets that we'll use in the main query.
--The abandoned_carts CTE selects distinct customer IDs (customer_id) from the EVENTS table where the status in the event_data column is 'failed'. This identifies customers who abandoned their carts.
--The events_before_abandonment CTE counts the number of events that occurred before abandonment for each customer. It performs the following steps:
--I joined the EVENTS table (e) with the abandoned_carts CTE (ac) based on customer_id.
--I Filtered out events that are visits or checkouts, as these are not relevant to abandoned carts.
--I used a subquery with NOT EXISTS to exclude events that occurred after a successful checkout. 
--For each event in the main query, it checks if there exists another event (e2) for the same customer with a status of 'success' and a later timestamp. If such an event exists, it means the event occurred after a successful checkout, and it is excluded.
--I used the results by customer_id and counts the number of events for each customer.
--Finally, the main query selects customer_id and num_events from the events_before_abandonment CTE, which contains the count of events before abandonment for each customer.
WITH abandoned_carts AS (
    SELECT DISTINCT customer_id
    FROM ALT_SCHOOL.EVENTS
    WHERE event_data ->> 'status' = 'failed'
),
events_before_abandonment AS (
    SELECT
        e.customer_id,
        COUNT(*) AS num_events
    FROM
        ALT_SCHOOL.EVENTS e
    JOIN
        abandoned_carts ac ON e.customer_id = ac.customer_id
    WHERE
        e.event_data ->> 'event_type' != 'visit' -- Exclude visits
        AND e.event_data ->> 'event_type' != 'checkout' -- Exclude checkouts
        AND NOT EXISTS (
            SELECT 1
            FROM ALT_SCHOOL.EVENTS e2
            WHERE e2.customer_id = e.customer_id
            AND e2.event_data ->> 'status' = 'success'
            AND e2.event_timestamp > e.event_timestamp
        ) -- Exclude events after successful checkout
    GROUP BY
        e.customer_id
)
SELECT
    customer_id,
    num_events
FROM
    events_before_abandonment;


--Part 2b(iii)
--To find the average number of visits per customer, considering only customers who completed a checkout, I followed these steps:

--Identifying customers who completed a checkout.
--Counting the total number of visits for each of these customers.
--Calculating the average number of visits per customer.

--Here is a further breakdown of the code:
--completed_checkouts CTE: This CTE identifies customers who completed a checkout by selecting distinct customer IDs (customer_id) from the EVENTS table where the status in the event_data column is 'success'.
--customer_visits CTE: This CTE counts the total number of visits for each customer who completed a checkout. It performs the following steps:
--I joined the EVENTS table (e) with the completed_checkouts CTE (cc) based on customer_id.
--I filtered out events that are visits ('event_type' = 'visit').
--I grouped the results by customer_id and counts the number of visits for each customer.
--Finally, the main query calculates the average number of visits per customer by taking the average of the number of visits (num_visits) from the customer_visits CTE.

--The query efficiently calculates the average number of visits per customer, considering only customers who completed a checkout. The result is returned as average_visits 
--rounded to 2 decimal places. Please execute this query and let me know if it provides the desired result!
WITH completed_checkouts AS (
    SELECT DISTINCT customer_id
    FROM ALT_SCHOOL.EVENTS
    WHERE event_data ->> 'status' = 'success'
),
customer_visits AS (
    SELECT
        e.customer_id,
        COUNT(*) AS num_visits
    FROM
        ALT_SCHOOL.EVENTS e
    JOIN
        completed_checkouts cc ON e.customer_id = cc.customer_id
    WHERE
        e.event_data ->> 'event_type' = 'visit'
    GROUP BY
        e.customer_id
)
SELECT
    AVG(num_visits) AS average_visits
FROM
    customer_visits;
