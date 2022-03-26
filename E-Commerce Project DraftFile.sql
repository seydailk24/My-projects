

--DAwSQL Session -8 

--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

---1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”, “prod_dimen”, “shipping_dimen”, Create a new table, named as “combined_table”.

SELECT *
FROM cust_dimen;
SELECT *
FROM [market_fact ];
SELECT *
FROM orders_dimen;
SELECT *
FROM shipping_dimen;
SELECT *
FROM prod_dimen;
---join all the tables and create a new table called combined_table.---

CREATE VIEW [combined_view1]
AS
  (
  SELECT
    a.Ord_id, a.prod_id, a.Ship_id, a.Cust_id, a.Sales, a.Discount, a.Order_Quantity, a.Product_Base_Margin,
    b.Customer_Name, b.Province, b.Region, b.Customer_Segment,
    CONVERT(datetime2,(SUBSTRING(c.Order_Date,7,4) + SUBSTRING(c.Order_Date,4,2) + SUBSTRING(c.Order_Date,1,2)) ,101) as Order_Date,
    c.Order_Priority,
    d.Product_Category, d.Product_Sub_Category,
    e.Order_ID,
    CONVERT(datetime2,(SUBSTRING(e.Ship_Date,7,4) + SUBSTRING(e.Ship_Date,4,2) + SUBSTRING(e.Ship_Date,1,2)) ,101) as Ship_Date,
    e.Ship_Mode
  FROM market_fact a
    LEFT JOIN cust_dimen b ON a.Cust_id=b.Cust_id
    LEFT JOIN orders_dimen c ON a.Ord_id=c.Ord_id
    LEFT JOIN prod_dimen d ON a.Prod_id=d.Prod_id
    LEFT JOIN shipping_dimen e ON e.Ship_id=a.Ship_id
)

SELECT *
INTO combined_table
FROM [combined_view1]



UPDATE combined_table
SET Order_Date =  CONVERT(datetime, order_Date, 6)




--///////////////////////
--2. Find the top 3 customers who have the maximum count of orders.


SELECT top 3
  Cust_id, Customer_Name, COUNT(Order_ID) as max_order_numbers
from combined_table
GROUP BY Cust_id,Customer_Name
ORDER BY max_order_numbers DESC



--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.
------------------------------not : The ALTER TABLE statement is used to 
------------------------------add, delete, or modify columns in an existing table.
------------------------------The ALTER TABLE statement is also used to add and drop various constraints on an existing table.

-------------------------------------------
SELECT *
from combined_table


UPDATE combined_table
SET Order_Date =  CONVERT(datetime, order_Date, 6)


ALTER TABLE combined_table  --- add new column which is DaysTakenForDelivery to combined table 
ADD Days_Taken_For_Delivery INT

SELECT DATEDIFF(DAY,order_Date,Ship_Date) as day_different
--difference days between shipdate to order date 
FROM combined_table


SELECT *
FROM combined_table

ALTER TABLE combined_table
DROP COLUMN Days_Taken_For_Delivery

SELECT *
FROM combined_table
------------------------------------------
ALTER TABLE combined_table
ADD Days_Taken_For_Delivery INT

SELECT DATEDIFF(DAY,Order_Date,Ship_Date) as different_of_days
FROM combined_table

UPDATE combined_table
SET Days_Taken_For_Delivery = DATEDIFF(DAY,Order_Date,Ship_Date)

SELECT *
FROM combined_table

--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"



SELECT top 1
  Cust_id, Customer_Name, max(Days_Taken_For_Delivery) as max_time_to_get_delivery
FROM combined_table
GROUP BY Customer_Name,Cust_id
ORDER BY Customer_Name DESC


--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use date functions and subqueries

SELECT COUNT(distinct cust_id)
From combined_table
WHERE Order_Date between '01/01/2011' and '01/31/2011'



SELECT MONTH(order_date) month_ , DATENAME(MONTH,order_date) month_names , COUNT(distinct cust_id) how_many_cust
FROM combined_table A
WHERE                    
    EXISTS (
           SELECT cust_id
  From combined_table B
  WHERE month(order_date) =1
    and year(order_date)= 2011
    and A.Cust_id = B.Cust_id
            )
  AND YEAR(order_date)=2011
GROUP BY MONTH(order_date),DATENAME(MONTH,order_date)
ORDER BY 1



--////////////////////////////////////////////


--6. write a query to return for each user acording to the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions
-----not RANK ve DENSE_RANK Fonksiyonları ROW_NUMBER fonksiyonuna çok benzemektedir.
--Farkı ORDER_BY deyimi ile bu fonksiyonların birbiri arasındaki bağlantılarıdır. 
--RANK fonksiyonu ile tekrar eden satırlara aynı numaralar verilir ve kullanılmayan numaralar geçilir.
-- DENSE_RANK fonksiyonunda ise kullanılmayan numaralar geçilmez. 
 select cust_id, order_date,
      MIN (Order_Date) OVER (PARTITION BY Cust_id) FIRST_ORDER_DATE,
      DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_date) DENSE_NUM
      from combined_table




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
select *,CAST(1.0*count_prod11/Order_Quantity as decimal (2,2)) prod11_yüzdelik ,
		 CAST(1.0*count_prod14/Order_Quantity as decimal (2,2)) prod14_yüzdelik
from t1





--/////////////////



--CUSTOMER SEGMENTATION



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.

CREATE VIEW visit_logs_customers
AS
  SELECT Cust_id, YEAR(Order_Date) year_ , MONTH(Order_Date) month_, COUNT(Cust_id) as countofcustomer
  FROM combined_table
  GROUP BY Cust_id,Order_Date



--//////////////////////////////////



--2.Create a �view� that keeps the number of monthly visits by users. (Show separately all months from the beginning  business)
--Don't forget to call up columns you might need later.

SELECT YEAR(order_date) years_,month(order_date) months_,COUNT(Cust_id) as count_of_customers
from combined_table
GROUP BY month(Order_Date),YEAR(Order_Date)
ORDER BY month(Order_Date)

create view monthly_log as
​
select 
	Cust_id,
	datepart(YEAR,Order_Date)  years_,
	datename(month,Order_Date) month_,
	count(Cust_id) monthly_visit_of_custumoers
from combined_table
group by Cust_id,datepart(YEAR,Order_Date) , datename(month,Order_Date),Order_Date

​

​


--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can order the months using "DENSE_RANK" function.
--then create a new column for each month showing the next month using the order you have made above. (use "LEAD" function.)
--Don't forget to call up columns you might need later.

create VIEW next_months
AS


SELECT *,
		LEAD(Dense_Month, 1) OVER (PARTITION BY Cust_id ORDER BY Dense_Month) next_month
FROM
(
​
select *,
		dense_rank() over(order by years_,month_) Dense_Month
from monthly_log
)a




select *,
		dense_rank() over(order by years_,month_) Dense_Month
from monthly_log

--/////////////////////////////////



--4. Calculate monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

create VIEW time_gab 
AS
SELECT *, 
next_months - Dense_Month 
from next_months






--///////////////////////////////////


--5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--For example: 
--Labeled as �churn� if the customer hasn't made another purchase for the months since they made their first purchase.
--Labeled as �regular� if the customer has made a purchase every month.
--Etc.

SELECT cust_id, AVG(time_gap) AS AvgTimeGap,
       CASE WHEN AVG(time_gap) IS NULL THEN 'Churn'
	     WHEN AVG(time_gap) <=1 THEN 'Regular'
	     ELSE 'Irregular'	
       END CustLabels 
from time_gab
group by Cust_id
​

--/////////////////////////////////////




--MONTH-WISE RETENT�ON RATE


--Find month-by-month customer retention rate  since the start of the business.


SELECT distinct YEAR(Order_Date) years, MONTH(Order_Date) months,
COUNT(Cust_id) OVER(PARTITION by year(order_Date), month(order_Date)) customer_id_count
from combined_table

--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps


SELECT DISTINCT YEAR(order_date) [year], 
                MONTH(order_date) [month],
                DATENAME(month,order_date) [month_name],
                COUNT(cust_id) OVER (PARTITION BY year(order_date), month(order_date) order by year(order_date), month(order_date)  ) num_cust
FROM combined_table

--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

create view month_wise as
(
SELECT DISTINCT YEAR(order_date) [year], 
                MONTH(order_date) [month],
                DATENAME(month,order_date) [month_name],
                COUNT(cust_id) OVER (PARTITION BY year(order_date), month(order_date) order by year(order_date), month(order_date)) num_cust
FROM combined_table
)
​
select year, month, num_cust, lead(num_cust,1) over (order by year, month) rate_,
	FORMAT(num_cust*1.0*100/(lead(num_cust,1) over (order by year, month, num_cust)),'N2')
from month_wise
​





---///////////////////////////////////
--Good luck!