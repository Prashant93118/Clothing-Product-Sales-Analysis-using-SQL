CREATE DATABASE Clothing_sales;
USE CLOTHING_SALES;

Set sql_safe_updates = 0;

CREATE TABLE Clothes (
    product_id        INT PRIMARY KEY,
    product_position  VARCHAR(30),      -- Aisle, End-cap, Front of Store
    promotion         VARCHAR(5),       -- Yes / No
    product_category  VARCHAR(50),      -- Only clothing
    seasonal          VARCHAR(5),       -- Yes / No
    sales_volume      INT,						
    brand             VARCHAR(50),		-- Zara
    url               TEXT,			
    name              VARCHAR(150),
    description       TEXT,
    price             DECIMAL(10,2),	
    currency          VARCHAR(10),		-- USD
	terms             VARCHAR(50),      -- Product names like - jackets, sweaters, shoes, jeans, t-shirt (Changed the column name --Product_Type)
    section           VARCHAR(20),      -- MAN / WOMAN
    season            VARCHAR(20),      -- Winter / Autumn / Summer / Spring
    material          VARCHAR(50),  	-- Clothes Material
    origin            VARCHAR(50)		-- Country name
);

LOAD DATA INFILE 'C:/Users/prashant/OneDrive/Desktop/Projects/Clothing Product sales data/Clothing_Products_sales.csv'
INTO TABLE Clothes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify data
Select * from clothes;

-- Verify count
select count(Product_id) from clothes;

-- This product dont have name of product..
DELETE from clothes
where product_id = 173576;

ALTER TABLE Clothes
CHANGE terms Product_Type Varchar(100);


-- Which product type (jackets, sweaters, shoes, jeans, t-shirts) generates the highest total sales revenue?
Select Product_Type, 
Round(Sum(Price* Sales_Volume)*100.0/
(Select Sum(Price* Sales_Volume) from clothes),2) AS Total_Revenue
From Clothes
GROUP BY Product_Type
ORDER BY Total_Revenue Desc;

-- Which individual products generate the highest total revenue?
Select name, 
sum(Price*Sales_Volume) as total_revenue
from clothes
GROUP BY name
ORDER BY total_revenue DESC
limit 1;

-- What is the average revenue per product by product type?
SELECT 
    product_type,
    AVG(product_revenue) AS avg_revenue_per_product
FROM (
    SELECT 
        name,
        product_type,
        SUM(price * sales_volume) AS product_revenue
    FROM Clothes
    GROUP BY name, product_type
) t
GROUP BY product_type
ORDER BY avg_revenue_per_product DESC;

-- Which season generates the highest total revenue?
Select Season, 
SUM(price * sales_volume) AS total_revenue
from clothes
GROUP BY Season
ORDER BY total_revenue desc;

-- How does revenue differ between MAN and WOMAN sections?.
Select Section,
SUM(price * sales_volume) AS revenue_differ
from clothes
GROUP BY Section;

-- Do promoted products generate higher revenue than non-promoted products?
Select Promotion, 
SUM(price * sales_volume) AS total_revenue
from clothes
GROUP BY Promotion;

-- What is the average sales volume difference between promoted and non-promoted products?
Select Promotion, 
Avg(sales_volume) AS Avg_sales_volume
from clothes
GROUP BY Promotion;

-- Which product types benefit the most from promotions?
SELECT 
    product_type,
    AVG(CASE WHEN promotion = 'Yes' THEN sales_volume END) -
    AVG(CASE WHEN promotion = 'No'  THEN sales_volume END) AS promo_sales_lift
FROM Clothes
GROUP BY product_type
ORDER BY promo_sales_lift DESC;

-- Does promotion have a greater impact on MAN or WOMAN products?
SELECT 
    section,
    AVG(CASE WHEN promotion = 'Yes' THEN sales_volume END) -
    AVG(CASE WHEN promotion = 'No'  THEN sales_volume END) AS promo_sales_lift
FROM Clothes
GROUP BY section
ORDER BY promo_sales_lift DESC;

-- Which product position (Aisle, End-cap, Front of Store) generates the highest sales volume?
Select Product_position,
Sum(sales_volume) as Sales_volume
from clothes
GROUP BY Product_position
ORDER BY Sales_volume desc;

-- Which position delivers the highest revenue per product?
SELECT
    product_position,
    AVG(product_revenue) AS avg_revenue_per_product
FROM (
    SELECT
        name,
        product_position,
        SUM(price * sales_volume) AS product_revenue
    FROM Clothes
    GROUP BY name, product_position
) t
GROUP BY product_position
ORDER BY avg_revenue_per_product DESC;

-- Are End-cap products consistently outperforming Aisle products across seasons?
SELECT
    season,
    product_position,
    AVG(sales_volume) AS avg_sales_volume
FROM Clothes
WHERE product_position IN ('End-cap', 'Aisle')
GROUP BY season, product_position
ORDER BY season, avg_sales_volume DESC;

-- Do seasonal products sell more units than non-seasonal products?
Select Seasonal, 
avg(sales_volume) as avg_sales_volume
from clothes
GROUP BY seasonal;

-- Which product types perform best in each season?
SELECT
    season,
    product_type,
    total_sales_volume
FROM (
    SELECT
        season,
        product_type,
        SUM(sales_volume) AS total_sales_volume,
        RANK() OVER (
            PARTITION BY season
            ORDER BY SUM(sales_volume) DESC
        ) AS rnk
    FROM Clothes
    GROUP BY season, product_type
) t
WHERE rnk = 1
ORDER BY season;


-- Is there a price difference between seasonal and non-seasonal products?
SELECT
    seasonal,
    AVG(price) AS avg_price
FROM Clothes
GROUP BY seasonal;

-- Is there a relationship between price and sales volume?
SELECT
    CASE
        WHEN price < 25 THEN 'Low Price'
        WHEN price BETWEEN 25 AND 60 THEN 'Mid Price'
        ELSE 'High Price'
    END AS price_range,
    AVG(sales_volume) AS avg_sales_volume
FROM Clothes
GROUP BY price_range
ORDER BY avg_sales_volume DESC;

-- Which price range contributes the most to total revenue?
SELECT
    price_range,
    SUM(price * sales_volume) AS total_revenue
FROM (
    SELECT
        price,
        sales_volume,
        CASE
            WHEN price < 25 THEN 'Low Price'
            WHEN price BETWEEN 25 AND 60 THEN 'Mid Price'
            ELSE 'High Price'
        END AS price_range
    FROM Clothes
) t
GROUP BY price_range
ORDER BY total_revenue DESC;

-- Are high-priced products compensating lower volume with higher revenue?
SELECT
    price_range,
    AVG(sales_volume) AS avg_sales_volume,
    AVG(price * sales_volume) AS avg_revenue
FROM (
    SELECT
        price,
        sales_volume,
        CASE
            WHEN price < 25 THEN 'Low Price'
            WHEN price BETWEEN 25 AND 60 THEN 'Mid Price'
            ELSE 'High Price'
        END AS price_range
    FROM Clothes
) t
GROUP BY price_range
ORDER BY avg_revenue DESC;

-- Which materials are associated with higher average sales volume?
SELECT
    material,
    AVG(sales_volume) AS avg_sales_volume
FROM Clothes
GROUP BY material
ORDER BY avg_sales_volume DESC;

-- Which origin countries supply products with the highest revenue contribution? 
SELECT
    origin,
    SUM(price * sales_volume) AS total_revenue
FROM Clothes
GROUP BY origin
ORDER BY total_revenue DESC;
