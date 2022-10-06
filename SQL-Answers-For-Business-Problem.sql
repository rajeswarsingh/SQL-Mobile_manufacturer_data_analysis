--SQL Advance Case Study
--Q1--BEGIN 
SELECT DISTINCT c.state
FROM   fact_transactions a,
       dim_customer b,
       dim_location c
WHERE  a.idcustomer = b.idcustomer
       AND a.idlocation = c.idlocation
       AND Datepart(year, date) >= 2005;

--Q1--END

--Q2--BEGIN
SELECT TOP 1 d.state,
             Sum(c.quantity) 'most_buying_samsung_ph'
FROM   dim_manufacturer a,
       dim_model b,
       fact_transactions c,
       dim_location d
WHERE  a.manufacturer_name = 'Samsung'
       AND a.idmanufacturer = b.idmanufacturer
       AND b.idmodel = c.idmodel
       AND c.idlocation = d.idlocation
       AND d.country = 'US'
GROUP  BY d.state
ORDER  BY 2 DESC;

--Q2--END

--Q3--BEGIN      
SELECT b.model_name,
       d.zipcode,
       d.state,
       Count(1) AS number_of_transcation
FROM   dim_model b,
       fact_transactions c,
       dim_location d
WHERE  b.idmodel = c.idmodel
       AND c.idlocation = d.idlocation
GROUP  BY b.model_name,
          d.zipcode,
          d.state
ORDER  BY 4 DESC;

--Q3--END

--Q4--BEGIN
SELECT TOP 1 'cheapest cell phone' AS Type,
             model_name,
             unit_price
FROM   dim_model
ORDER  BY 2;

--Q4--END

--Q5--BEGIN
SELECT model_name,
       Avg(unit_price) avg_price
FROM   dim_model
WHERE  idmanufacturer IN (SELECT TOP 5 a.idmanufacturer
                          FROM   dim_manufacturer a,
                                 dim_model b,
                                 fact_transactions c,
                                 dim_location d
                          WHERE  a.idmanufacturer = b.idmanufacturer
                                 AND b.idmodel = c.idmodel
                                 AND c.idlocation = d.idlocation
                          GROUP  BY a.manufacturer_name,
                                    a.idmanufacturer
                          ORDER  BY Sum(quantity) DESC)
GROUP  BY model_name
ORDER  BY avg_price

--Q5--END

--Q6--BEGIN
SELECT customer_name,
       Avg(( totalprice )) Avrage_amount_spent
FROM   dim_customer a,
       fact_transactions b
WHERE  a.idcustomer = b.idcustomer
       AND Datepart(year, date) = 2009
GROUP  BY customer_name
ORDER  BY 1;

--Q6--END

--Q7--BEGIN  
SELECT model_name,
       quantity,
       date
FROM   (SELECT TOP 5 a.model_name,
                     Sum(quantity)        quantity,
                     Datepart(year, date) date
        FROM   dim_model a,
               fact_transactions b
        WHERE  a.idmodel = b.idmodel
               AND Datepart(year, date) IN ( 2008 )
        GROUP  BY a.model_name,
                  Datepart(year, date)
        ORDER  BY 2 DESC) AS t1
INTERSECT
SELECT model_name,
       quantity,
       date
FROM   (SELECT TOP 5 a.model_name,
                     Sum(quantity)        quantity,
                     Datepart(year, date) date
        FROM   dim_model a,
               fact_transactions b
        WHERE  a.idmodel = b.idmodel
               AND Datepart(year, date) IN ( 2009 )
        GROUP  BY a.model_name,
                  Datepart(year, date)
        ORDER  BY 2 DESC) AS t2
INTERSECT
SELECT model_name,
       quantity,
       date
FROM   (SELECT TOP 5 a.model_name,
                     Sum(quantity)        quantity,
                     Datepart(year, date) date
        FROM   dim_model a,
               fact_transactions b
        WHERE  a.idmodel = b.idmodel
               AND Datepart(year, date) IN ( 2010 )
        GROUP  BY a.model_name,
                  Datepart(year, date)
        ORDER  BY 2 DESC) AS t3;

--Q7--END  

--Q8--BEGIN
SELECT manufacturer_name AS top_second_Manufacturer_Name,
       total_sale,
       year
FROM   (SELECT TOP 1 manufacturer_name,
                     total_sale,
                     year
        FROM   (SELECT TOP 2 a.manufacturer_name,
                             Sum(totalprice)      total_sale,
                             Datepart(year, date) year
                FROM   dim_manufacturer a,
                       dim_model b,
                       fact_transactions c
                WHERE  a.idmanufacturer = b.idmanufacturer
                       AND b.idmodel = c.idmodel
                       AND Datepart(year, date) IN ( 2009 )
                GROUP  BY a.manufacturer_name,
                          Datepart(year, date)
                ORDER  BY Sum(totalprice) DESC) AS t1
        ORDER  BY 2) AS o1
UNION ALL
SELECT manufacturer_name,
       total_sale,
       year
FROM   (SELECT TOP 1 manufacturer_name,
                     total_sale,
                     year
        FROM   (SELECT TOP 2 a.manufacturer_name,
                             Sum(totalprice)      total_sale,
                             Datepart(year, date) year
                FROM   dim_manufacturer a,
                       dim_model b,
                       fact_transactions c
                WHERE  a.idmanufacturer = b.idmanufacturer
                       AND b.idmodel = c.idmodel
                       AND Datepart(year, date) IN ( 2010 )
                GROUP  BY a.manufacturer_name,
                          Datepart(year, date)
                ORDER  BY Sum(totalprice) DESC) AS t1
        ORDER  BY 2) o2;

--Q8--END

--Q9--BEGIN
SELECT manufacturer_name
FROM   (SELECT a.manufacturer_name
        FROM   dim_manufacturer a,
               dim_model b,
               fact_transactions c
        WHERE  a.idmanufacturer = b.idmanufacturer
               AND b.idmodel = c.idmodel
               AND Datepart(year, date) IN ( 2010 )
        GROUP  BY a.manufacturer_name) AS o1
EXCEPT
SELECT manufacturer_name
FROM   (SELECT a.manufacturer_name
        FROM   dim_manufacturer a,
               dim_model b,
               fact_transactions c
        WHERE  a.idmanufacturer = b.idmanufacturer
               AND b.idmodel = c.idmodel
               AND Datepart(year, date) IN ( 2009 )
        GROUP  BY a.manufacturer_name) AS o2;

--Q9--END

--Q10--BEGIN
SELECT TOP 100 customer_name,
               Datepart(year, date) year,
               Avg(totalprice)      avg_spend,
               Avg(quantity)        avg_quantity,
               ( Sum(totalprice) / (SELECT Sum(totalprice)
                                    FROM   fact_transactions a
                                    WHERE  a.idcustomer = idcustomer) ) * 100
                                    percentage_of_change
FROM   dim_customer a,
       fact_transactions b
WHERE  a.idcustomer = b.idcustomer
GROUP  BY customer_name,
          Datepart(year, date)
ORDER  BY avg_spend DESC;
--Q10--END
