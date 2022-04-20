-----------------------------Generate a report including product IDs and discount effects on whether the increase in the discount rate positively impacts the number of orders for the products.

-------I found the total amount of sales according to the products and discount rates

CREATE VIEW total_sales
AS (
SELECT DISTINCT product_id, discount,quantity,
    SUM(quantity) OVER (PARTITION BY product_id,discount ORDER BY product_id, discount) AS total_sale
FROM sale.order_item)


----- With first_value I got the lowest discount rate, with last_value I got the highest discount rate


WITH table1
AS (
SELECT DISTINCT product_id,
    FIRST_VALUE(sale) OVER(PARTITION BY product_id ORDER BY product_id, discount) AS min_disc,
    LAST_VALUE(sale) OVER(PARTITION BY product_id ORDER BY product_id, discount ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_disc
FROM total_sales )


---3. tabloda ise case ile positive negative veya neutral yazdırdım---



SELECT 
    *,
    CASE
        WHEN 1.0*(max_disc - min_disc)/max_disc > 0.1 THEN 'Positive'
        WHEN 1.0*(max_disc - min_disc)/max_disc < -0.1 THEN 'Negative'
        ELSE 'Neutral'
    END AS [Discount Effect]
FROM table1;
