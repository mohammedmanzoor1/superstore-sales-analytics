USE SQLTABLEAU ---entering into database

SELECT * FROM Superstore_sql--------- RETRIVING DATA FROM TABLE


SELECT COLUMN_NAME, DATA_TYPE----LOOKING FOR COLUMN NAMES AND THERE DATA TYPES
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' ----means relations between tables
  AND TABLE_NAME = 'Superstore_sql';

 

  SELECT ------------CHECKING FOR NULL VALUES
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS ORDER_ID_NULL,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS ORDER_DATE_NULL,
    SUM(CASE WHEN Customer_Name IS NULL THEN 1 ELSE 0 END) AS CUSTOMER_ID_NULL,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS SALES_NULL,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS PORFIT_NULL
 FROM Superstore_sql;

 UPDATE Superstore_sql --------------UPDATEING PROFITS TO 0
 SET Profit = 0
 WHERE Profit IS NULL;


UPDATE Superstore_sql -------REPLACEING CUSTOMER NAMES IF THERE ARE ANY NULLS
SET Customer_Name = 'Unknown'
WHERE Customer_Name IS NULL OR Customer_Name = '';

SELECT Order_ID, COUNT(*) AS duplicate_count ------- CHECKING DUPLICATES 
FROM Superstore_sql
GROUP BY Order_ID
HAVING COUNT(*) > 1;


SELECT  ----------LOOKING FOR UNIQUE ROWS AND ORDER
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Order_ID) AS unique_orders
FROM Superstore_sql;

WITH cte AS (----Removeing duplicates if any
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Order_ID ORDER BY Order_ID) AS rn
    FROM Superstore_sql
)
DELETE FROM cte
WHERE rn > 1;

SELECT *-----loss analysis in profit
FROM Superstore_sql
WHERE Profit < 0;

SELECT *-------- CHECKING DATE ISSUES
FROM Superstore_sql
WHERE Order_Date > GETDATE();


SELECT ----CHECKING TOTAL SALES AND PROFIT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Superstore_sql;

SELECT --CHECKING SALES AND PROFIT WISE CATEGORY
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Superstore_sql
GROUP BY Category
ORDER BY Total_Sales DESC;


SELECT  ---------MONTHY SALES 
    FORMAT(Order_Date, 'yyyy-MM') AS Month,
    SUM(Sales) AS Monthly_Sales
FROM Superstore_sql
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month ;


SELECT TOP 10 --------CHECKING TOP 10 COSTOMERS
    Customer_Name,
    SUM(Sales) AS Total_Sales
FROM Superstore_sql
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;

SELECT----LOCATION WISE SALES AND PROFIT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Superstore_sql
GROUP BY Region;


SELECT--------IMPACT OF DISCOUNT ON PROFIT
    Discount,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM Superstore_sql
GROUP BY Discount
ORDER BY Discount;


SELECT Discount, Sales, Profit
FROM Superstore_sql
WHERE Discount IS NULL
   OR Sales IS NULL
   OR Profit IS NULL;


   ALTER TABLE Superstore_sql-------REMOVING EXCEED DECIMALS IN SALES
ALTER COLUMN Sales DECIMAL(10,2);

ALTER TABLE Superstore_sql-------REMOVNG EXCEED DECIMAL IN PROFIT
ALTER COLUMN Profit DECIMAL(10,2);

ALTER TABLE Superstore_sql-------REMOVNG EXCEED DECIMAL IN DISCOUNT
ALTER COLUMN Discount DECIMAL(3,2);

----VERIFYING THE COLUMNS AND TABLE

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    NUMERIC_PRECISION, 
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore_sql';

--------------CREATEING KPIS ON SQL

SELECT----1ST KPI TOTAL SALES
    ROUND(SUM(Sales), 0) AS Total_Sales
    FROM Superstore_sql;
    
    SELECT ---2ND KPI TOTAL PROFIT
    ROUND(SUM(Profit), 0) AS Total_Profit
FROM Superstore_sql;

SELECT ----AVG SALES
      ROUND(AVG(Sales),0) AS AVG_SALES
      FROM Superstore_sql;


SELECT ----AVG PROFIT
      ROUND(AVG(Profit),0) AS AVG_PROFIT
      FROM Superstore_sql;


      SELECT---3RD KPI PROFIT BY MARGIN IN PERCENTAGE
    ROUND(
        (SUM(Profit) * 100.0) / NULLIF(SUM(Sales), 0),2)AS Profit_Margin_Percent
FROM Superstore_sql;

SELECT--- 4TH KPI AVG ORDERS 
    ROUND(
        SUM(Sales) / COUNT(DISTINCT Order_ID),2) AS Avg_Orders
FROM Superstore_sql;

SELECT---5TH KPI UNIQUE COSTOMER'S 
    COUNT(DISTINCT Customer_Name) AS Total_Customers
FROM Superstore_sql;


SELECT ---6TH REGION WISE SALES AND PROFIT 
    Region,
    ROUND(SUM(Sales), 0) AS Sales,
    ROUND(SUM(Profit), 0) AS Profit
FROM Superstore_sql
GROUP BY Region;


SELECT---7TH KPI CATEGORY WISE SALES
    Category,
    ROUND(SUM(Sales), 0) AS Sales,
    ROUND(SUM(Profit), 0) AS Profit
FROM Superstore_sql
GROUP BY Category;

------TO EASILY SHOW KPIS THIS IS THE SYNTAX FOR SHOWING---- VIEW IS A VIRTUAL TABLE

CREATE VIEW vw_Superstore_KPIs AS
SELECT
    ROUND(SUM(Sales), 0) AS Total_Sales,
    ROUND(SUM(Profit), 0) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_Name) AS Total_Customers,
    ROUND((SUM(Profit) * 100.0) / NULLIF(SUM(Sales), 0),2) AS Profit_Margin_Percent
FROM Superstore_sql;

---LOOKING FOR THE VIEW TABLE WE HAVE JUST CREATED---

SELECT * FROM vw_Superstore_KPIs;

--------CREATING CLEANED TABLE FOR SAVING DATA-------
SELECT
    Order_ID,
    Order_Date,
    CASE 
        WHEN Customer_Name IS NULL OR Customer_Name = '' 
        THEN 'Unknown'
        ELSE Customer_Name
    END AS Customer_Name,
    Segment,
    Region,
    Category,
    Product_Name,
    ROUND(Sales, 0) AS Sales,
    Quantity,
    CAST(Discount AS DECIMAL(3,2)) AS Discount,
    ROUND(CASE WHEN Profit IS NULL THEN 0 ELSE Profit END, 0) AS Profit
INTO Superstore_Clean_Table
FROM Superstore_sql;

SELECT * FROM Superstore_Clean_Table;----retrieving from the table




-----------now moving to tableau
















































