----- ASSIGNMENT 2 SOLUTION

--1. IDENTIFY TABLE WHICH ONE IS WE ARE GONNA USE

PRODUCT 
CUSTOMER
ORDER 
ORDER_ITEM 

'2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'

/* You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' buy the products below or not.
1. 'Polk Audio - 50 W Woofer - Black' -- (first_product)
2. 'SB-2000 12 500W Subwoofer (Piano Gloss Black)' -- (second_product)
3. 'Virtually Invisible 891 In-Wall Speakers (Pair)' -- (third_product)
To generate this report, you are required to use the appropriate SQL Server Built-in string functions (ISNULL(), NULLIF(), etc.) and Joins, as well as basic SQL knowledge. As a result, a report exactly like the attached file is expected from you.
*/

SELECT NULLIF(10,9)
SELECT ISNULL('123', NO)

SELECT E.customer_id, E.first_name, E.last_name,
		
		ISNULL(NULLIF(ISNULL(STR(F.customer_id), 'NO'), STR(F.customer_id)), 'YES') FIRST_PRODUCT,
		ISNULL(NULLIF(ISNULL(STR(G.customer_id), 'NO'), STR(G.customer_id)), 'YES') SECOND_PRODUCT,
		ISNULL(NULLIF(ISNULL(STR(H.customer_id), 'NO'), STR(H.customer_id)), 'YES') THIRD_PRODUCT
FROM 
(
SELECT DISTINCT D.customer_id, D.first_name, D.last_name
FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id 
AND B.order_id = C.order_id
AND C.customer_id = D.customer_id
AND A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
) E 
LEFT JOIN
(
SELECT DISTINCT D.customer_id, D.first_name, D.last_name
FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id 
AND B.order_id = C.order_id
AND C.customer_id = D.customer_id
AND A.product_name = 'Polk Audio - 50 W Woofer - Black'
) F
ON E.customer_id = F.customer_id
LEFT JOIN
(
SELECT DISTINCT D.customer_id, D.first_name, D.last_name
FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id 
AND B.order_id = C.order_id
AND C.customer_id = D.customer_id
AND A.product_name = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)'
) G
ON E.customer_id = G.customer_id
LEFT JOIN
(
SELECT DISTINCT D.customer_id, D.first_name, D.last_name
FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id 
AND B.order_id = C.order_id
AND C.customer_id = D.customer_id
AND A.product_name = 'Virtually Invisible 891 In-Wall Speakers (Pair)'
) H
ON E.customer_id = H.customer_id
