select * from foodPrices; 

--A. deleting the first row since it has meaniningless values from Header.  
delete top(1) from foodPrices; 
select * from foodPrices; 

------------------------------------------------------------------
--B. The duration of the dataset.
select min(date), max(date) from foodPrices;

/* The dataset is for a period of 31 years. 
It has data from 1994 to 2024(Jan & Feb). */

------------------------------------------------------------------
--C. The number of distinct Category and Commodities in the data.
select category, count(distinct commodity) as 'Commodities_Count'
from foodPrices 
Group by category with rollup
order by Commodities_Count asc;
/* There are total 6 categories and 23 commodities. Oil and Fats has the maximum number of commodities i.e.6 
and Milk and dairy has the least which is 2.*/

------------------------------------------------------------------
--D. Replace 'Blank' or "null" values in state column.
select count(*) from foodPrices 
where admin1 = null or admin1 = '';
/*There are 602 rows which don't have any location information.*/
------------------------------------------------------------------
--E. Remove this blank state rows.
Delete from foodPrices 
where admin1= null or admin1 ='';

------------------------------------------------------------------

-- Q1. Count the list of records as per the commodity 
select commodity, count (*) from foodPrices group by commodity; 
--A1. There are 23 different commodites are present in the dataset. 

------------------------------------------------------------------

-- Q2. Find out from how many states data is included. 
select count (Distinct(admin1)) from foodPrices where admin1 <> '';
-- A2. 27 states and 4 Union terrirories (Andaman nicobar, Chandigargh, Delhi, Puducheri)
------------------------------------------------------------------

-- Q3. Find out the states and its market which have had the highest prices of Rice under cereals and tubers category - Retail purchases
SELECT admin1, market AS State, max(cast (price as DECIMAL (9,2))) AS Max_Price
FROM foodPrices WHERE category = 'cereals and tubers' AND commodity = 'Rice' AND pricetype = 'Retail'
GROUP BY admin1, market ORDER BY Max_Price DESC;
--A3. Rajasthan (Jodhpur) sold Rice with maximum price.
------------------------------------------------------------------

-- Q4. Find out the states and its market which have had the highest prices of Rice under cereals and tubers category- Wholesale purchases
SELECT admin1 as state, market , max(cast (price as DECIMAL (9,2))) as mprice FROM foodPrices
WHERE category ='cereals and tubers' AND pricetype = 'Wholesale' AND commodity ='Rice'
group by admin1, market order by mprice desc;
--A4. Tamil Nadu (Chennai) sold Rice with maximum price 4900.

------------------------------------------------------------------

-- Q5.Find out the states and its market which have had the highest prices of Milk under milk and dairy category- Retail purchases only
SELECT admin1 as state,market, max(cast (price as DECIMAL (9,2))) as max_price FROM foodPrices
WHERE category = 'milk and dairy' AND pricetype = 'Retail' AND commodity = 'Milk'
GROUP BY admin1, market ORDER BY max_price DESC;
--A5. There were 7 markets in total selling Milk. Out of them, Gujarat (Ahmedabad) sold with highest price. 

------------------------------------------------------------------

--Q6.Find out the states and its market which have had the highest prices of Milk (pasteurized) under milk and dairy category- Retail purchases only
SELECT admin1 as state,market,max(cast (price as DECIMAL (9,2))) as max_price FROM foodPrices
WHERE category = 'milk and dairy' AND pricetype = 'Retail' AND commodity = 'Milk (pasteurized)'
GROUP BY admin1, market ORDER BY max_price DESC;
--A6. Tripura (Agartala) sold the Pasteurized milk with highest price. 

------------------------------------------------------------------

-- Q7. Find out the states and its market which have had the highest prices of Ghee (vanaspati) under oil and fats- Retail purchases only
SELECT admin1 as state,market ,max(cast (price as DECIMAL (9,2))) as mprice FROM foodPrices
WHERE admin1 <> '' AND category ='oil and fats' AND commodity ='Ghee (vanaspati)'
group by admin1, market order by mprice desc;
--A7. Karnataka (Mysore) sold with highest price. 

------------------------------------------------------------------

-- Q8. Finding out the avegarge price of oil and fats as whole
select AVG(cast (price as DECIMAL (9,2))) 'Average Price' from foodPrices
where category= 'oil and fats';

------------------------------------------------------------------

-- Q9. Find out the average prices for each type of oil under oil and fats
select commodity, AVG(cast (price as DECIMAL (9,2))) 'Average Price' from foodPrices
where category= 'oil and fats' group by commodity order by AVG(cast (price as DECIMAL (9,2))) desc;
-- Oil(groundnut) has the highest Average Price out of all 6 types of Commodity. 

------------------------------------------------------------------

-- Q10. Finding out the average prices of lentils
select commodity, AVG(cast (price as DECIMAL (9,2))) 'Average Price' from foodPrices
where category= 'pulses and nuts' group by commodity order by AVG(cast (price as DECIMAL (9,2))) desc;
--Lentils (urad) has the highest Average price out of all 5 types. 

------------------------------------------------------------------

-- Q11. Finding out the average price of Onions and tomatoes
select commodity, AVG(cast (price as DECIMAL (9,2))) 'Average Price' from foodPrices
where category= 'vegetables and fruits' group by commodity order by AVG(cast (price as DECIMAL (9,2))) desc;
--Tomatoes has the Average price of 31.32 and Onions has 27.39.

------------------------------------------------------------------

-- Q12 Find out which commodity has the highest price 
select commodity, AVG(cast (price as DECIMAL (9,2))) 'Average Price' from foodPrices
group by commodity order by AVG(cast (price as DECIMAL (9,2))) desc;
-- Black Tea has the highest average price (this data was available from 2013) 

------------------------------------------------------------------

-- Q14 Create a table for zones
-- Select city and State from foodPrices table and insert it into newly created zones table

DROP Table if exists zones;
CREATE TABLE zones (
  City VARCHAR(255),
  State VARCHAR (255),
  zone VARCHAR(255),
  PRIMARY KEY(City, State)
);

Insert into zones
select DISTINCT admin2, admin1, NULL
from foodPrices
where admin2 is not NULL;


UPDATE zones SET zone ='South'  WHERE State IN ( 'Tamil Nadu', 'Telangana', 'Andhra Pradesh', 'Kerala', 'Karnataka') ;
update zones set zone = 'North' WHERE State IN( 'Himachal Pradesh''Punjab','Uttarakhand','Uttar Pradesh','Haryana');
update zones set zone = 'East' WHERE State IN ( 'Bihar','Orissa','Jharkhand', 'West Bengal');
update zones set zone = 'West' WHERE State IN ('Rajasthan','Gujarat','Goa','Maharashtra');
update zones set zone = 'Central' WHERE State IN ('Madhya Pradesh','Chhattisgarh');
update zones set zone = 'North East' WHERE State IN( 'Assam','Sikkim','Manipur','Meghalaya', 'Nagaland','Mizoram','Tripura','Arunachal Pradesh');
update zones set zone = 'Union Territory' WHERE State IN ('Chandigarh','Delhi','Puducherry','Andaman and Nicobar');

select * from zones;

------------------------------------------------------------------

-- Q15 JOIN zones table and foodPrices AND Create a view
drop view if exists [commodity_prices]; 
CREATE VIEW [commodity_prices] 
AS
Select fo.date,zo.City,zo.State,fo.market,zo.zone,fo.latitude,fo.longitude,fo.category,fo.commodity,fo.unit,fo.priceflag,fo.pricetype,fo.currency,fo.price,fo.usdprice
from foodPrices fo
JOIN zones zo
ON CONCAT(zo.State, zo.City) = CONCAT(fo.admin1, fo.admin2);

select * from commodity_prices;

------------------------------------------------------------------

-- Q16 Average price of commodities zone wise 
Select date,zone,category,commodity, AVG(Cast (price as Decimal (9,2))) as Average_price
FROM commodity_prices
Group by zone,category,commodity, date
order by commodity,Average_price DESC;

------------------------------------------------------------------

-- Q17 Find out the price differences between  2022 and 2012 
--A17. Meghalya (North East zone) had highest price difference.

Create Table price_year2012(
State varchar(255),
zone varchar(255),
category varchar(255),
commodity varchar(255),
Average_price_2012 float);

INSERT INTO price_year2012
SELECT State,zone,category,commodity,avg(Cast (price as Decimal (9,2))) from commodity_prices
WHERE YEAR (date) = 2012  AND pricetype = 'Retail' group by State,zone,category,commodity;

select * from price_year2012; 

Create Table price_year2023
(State varchar(255),
zone varchar(255),
category varchar(255),
commodity varchar(255),
Average_price_2022 float);

INSERT INTO price_year2023
SELECT State,zone,category,commodity,avg(Cast (price as Decimal (9,2))) from commodity_prices
WHERE YEAR (date) = 2022 and pricetype = 'Retail'
group by State,zone,category,commodity;

select * from price_year2023; 

SELECT B.State,B.zone,B.category,B.commodity,B.Average_price_2012,C.Average_price_2022,C.Average_price_2022 - B.Average_price_2012 as Diff_bw_price
FROM price_year2012 B
JOIN price_year2023 C
ON B.category = C.category AND B.commodity = C.commodity AND B.State = C.State AND B.zone = C.zone
order by Diff_bw_price desc;

------------------------------------------------------------------

-- Q18 Find out the average prices of each category food products zone wise

SELECT zone,category, avg(cast (price as decimal(9,2))) as avgprice
from commodity_prices
where pricetype = 'Retail'
group by zone,category order by avgprice DESC;

------------------------------------------------------------------

-- Q19 Find out the average prices of each commodity zone wise

SELECT zone,commodity, avg(cast (price as decimal(9,2))) as avgprice
from commodity_prices
where pricetype = 'Retail' 
group by zone,commodity order by avgprice DESC;

