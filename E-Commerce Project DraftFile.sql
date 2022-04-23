

--DAwSQL Session -8

--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

---1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”, “prod_dimen”, “shipping_dimen”, Create a new table, named as “combined_table”.

CREATE VIEW [combined_view1]
AS
  (
  SELECT
    a.Ord_id, a.prod_id, a.Ship_id, a.Cust_id, a.Sales, a.Discount, a.Order_Quantity, a.Product_Base_Margin,
    b.Customer_Name, b.Province, b.Region, b.Customer_Segment,
    c.order_Date,c.Order_Priority,
    d.Product_Category, d.Product_Sub_Category,
    e.Order_ID,e.Ship_Date,e.Ship_Mode
  FROM market_fact a
    JOIN cust_dimen b ON a.Cust_id=b.Cust_id
    JOIN orders_dimen c ON a.Ord_id=c.Ord_id
    JOIN prod_dimen d ON a.Prod_id=d.Prod_id
    JOIN shipping_dimen e ON e.Ship_id=a.Ship_id
)

SELECT *
INTO combined_table
FROM [combined_view1]


--///////////////////////
--2. Find the top 3 customers who have the maximum count of orders.


SELECT top 3
  Cust_id, Customer_Name, COUNT(Order_ID) as max_order_numbers
from combined_table
GROUP BY Cust_id,Customer_Name
ORDER BY 3 DESC



--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.


ALTER TABLE combined_table  --- add new column which is DaysTakenForDelivery to combined table
ADD DaysTakenForDelivery SMALLINT

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(day, order_Date, Ship_Date)




--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.



SELECT top 1
  Cust_id, Customer_Name, max(Days_Taken_For_Delivery) as max_time_to_get_delivery
FROM combined_table
GROUP BY Customer_Name,Cust_id
ORDER BY Customer_Name DESC


--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select  cust_id as Unique_customers
from combined_table
WHERE YEAR(order_date) = 2011
AND month(order_date) = 1




select month(order_date) as ord_month,
      COUNT(distinct cust_id) as count_of_customers
FROM combined_table
group by month(Order_date)





SELECT month(order_date) ord_month,
       COUNT(distinct cust_id) count_of_customers
FROM combined_table A
WHERE exists (
  select cust_id
  from combined_table B
  WHERE
  A.cust_id = B.cust_id AND
  YEAR(order_date) = 2011 AND
  month(order_date) = 1
group by month(order_date)
)


--////////////////////////////////////////////


--6. write a query to return for each user acording to the time elapsed between the first purchasing and the third purchasing,
--in ascending order by Customer ID
--Use "MIN" with Window Functions
SELECT Cust_id,
       Ord_id,
       MIN (Order_Date) OVER (PARTITION BY Cust_id) FIRST_ORDER_DATE,
       Order_Date
from combined_table

select Cust_id,
       Ord_id,
      
      MIN (Order_Date) OVER (PARTITION BY Cust_id) FIRST_ORDER_DATE,
      DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_date) DENSE_NUM
from combined_table



select DISTINCT
      cust_id,
      Order_Date,
      DENSE_NUM,
      FIRST_ORDER_DATE,
      DATEDIFF(day, FIRST_ORDER_DATE, Order_Date) as Time_elapsed
from
( select cust_id,
        Ord_id
        order_date,
      MIN (Order_Date) OVER (PARTITION BY Cust_id) FIRST_ORDER_DATE,
      DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_date) DENSE_NUM
      from combined_table
) A
WHERE DENSE_NUM = 3



--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14,
--as well as the ratio of these products to the total number of products purchased by all customers.
--Use CASE Expression, CTE, CAST and/or Aggregate Functions

​
with t1 as
(
select Cust_id ,
		sum(case when prod_id ='Prod_11' then Order_Quantity else 0 end) count_prod11,
		sum(case when prod_id ='Prod_14' then Order_Quantity else 0 end) count_prod14,
		sum(Order_Quantity) Order_Quantity
from combined_table
group by Cust_id
having sum(case when prod_id ='Prod_11' then Order_Quantity else 0 end) >0
and sum(case when prod_id ='Prod_14' then Order_Quantity else 0 end) >0
)
select *,CAST(1.0*count_prod11/Order_Quantity as decimal (2,2)) prod11_ratio ,
		 CAST(1.0*count_prod14/Order_Quantity as decimal (2,2)) prod14_ratio
from t1

--/////////////////



--CUSTOMER SEGMENTATION



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.
CREATE VIEW customer_logs
AS 
SELECT Cust_id,
       YEAR(Order_Date) as ord_year,
       MONTH(Order_Date) as ord_month
from combined_table


SELECT * 
from customer_logs
ORDER BY 2,3 



--//////////////////////////////////



--2.Create a �view� that keeps the number of monthly visits by users. 
---(Show separately all months from the beginning  business)
--Don't forget to call up columns you might need later.
SELECT Cust_id,
      YEAR(Order_Date) as ord_year,
      MONTH(Order_Date) as ord_month,
      COUNT(*) OVER (PARTITION BY Cust_id, YEAR(Order_Date), MONTH(Order_Date)) cnt_log
from combined_table 


CREATE VIEW num_of_visits
AS
SELECT Cust_id,
      ord_year,
      ord_month,
      COUNT(*) num_of_log
 FROM customer_logs
group by Cust_id,
         ord_year,
         ord_month

SELECT *
from num_of_visits 

--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can order the months using "DENSE_RANK" function.
--then create a new column for each month showing the next month using 
CREATE VIEW NEXT_visit
AS
SELECT *,
lead(CURRENT_M, 1) OVER (PARTITION BY Cust_id order by CURRENT_M) NEXT_visit_m
from 
(select *,
		dense_rank() over(order by ord_year,ord_month) as CURRENT_M
from num_of_visits) A 


SELECT *
from NEXT_visit 
WHERE Cust_id = 'Cust_100'
--/////////////////////////////////

--4. Calculate monthly time gap between two consecutive visits by each customer.
CREATE VIEW time_gaps
AS
SELECT *,
NEXT_visit_m - CURRENT_M as time_gap
from NEXT_visit


SELECT *
from time_gaps

--///////////////////////////////////


--5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--For example:
--Labeled as �churn� if the customer hasn't made another purchase for the months since they made their first purchase.
--Labeled as �regular� if the customer has made a purchase every month.
--Etc.
WITH T1 AS(
SELECT Cust_id,
       AVG(time_gap) AS AvgTimeGap
from time_gaps
group by Cust_id
)
SELECT Cust_id,
case when avgTimeGap  is null then 'Churn'
     when avgTimeGap = 1 then 'regular'
     when avgTimeGap > 1 then 'Irregular'
     else 'unKNOWN'
END AS cust_category
FROM T1 


--/////////////////////////////////////
