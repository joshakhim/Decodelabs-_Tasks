CREATE DATABASE decodelabs_project3;
USE decodelabs_project3;

CREATE TABLE sales_data (
    OrderID VARCHAR(20),
    Date DATE,
    CustomerID VARCHAR(20),
    Product VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    ShippingAddress VARCHAR(255),
    PaymentMethod VARCHAR(50),
    OrderStatus VARCHAR(50),
    TrackingNumber VARCHAR(50),
    ItemsInCart INT,
    CouponCode VARCHAR(50),
    ReferralSource VARCHAR(50),
    TotalPrice DECIMAL(10,2)
);

SELECT *
FROM sales_data
LIMIT 10;


DESCRIBE sales_data;


SELECT COUNT(*)
FROM sales_data;


SELECT
SUM(CASE WHEN OrderID IS NULL THEN 1 ELSE 0 END) AS OrderID_Nulls,
SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS CustomerID_Nulls,
SUM(CASE WHEN TotalPrice IS NULL THEN 1 ELSE 0 END) AS TotalPrice_Nulls
FROM sales_data;


SELECT COUNT(*) - COUNT(DISTINCT OrderID)
AS DuplicateOrders
FROM sales_data;


SELECT
MIN(Date) AS EarliestDate,
MAX(Date) AS LatestDate
FROM sales_data;



-- =========================================
-- TOTAL REVENUE GENERATED
-- =========================================

SELECT
    ROUND(SUM(TotalPrice), 2) AS TotalRevenue
FROM sales_data;


-- =========================================
-- TOP PRODUCTS BY REVENUE
-- =========================================

SELECT
    Product,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM sales_data
GROUP BY Product
ORDER BY Revenue DESC;


-- =========================================
-- ORDER STATUS PERFORMANCE
-- =========================================

SELECT
    OrderStatus,
    COUNT(*) AS TotalOrders,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM sales_data
GROUP BY OrderStatus
ORDER BY Revenue DESC;

-- =========================================
-- PAYMENT METHOD PERFORMANCE
-- =========================================

SELECT
    PaymentMethod,
    COUNT(*) AS Transactions,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM sales_data
GROUP BY PaymentMethod
ORDER BY Revenue DESC;


-- =========================================
-- MONTHLY REVENUE TREND
-- =========================================

SELECT
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM sales_data
GROUP BY DATE_FORMAT(Date, '%Y-%m')
ORDER BY Month;


-- =========================================
-- TOP CUSTOMERS BY REVENUE
-- =========================================

SELECT
    CustomerID,
    ROUND(SUM(TotalPrice), 2) AS TotalSpent
FROM sales_data
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;


-- =========================================
-- REFERRAL SOURCE PERFORMANCE
-- =========================================

SELECT
    ReferralSource,
    COUNT(*) AS Orders,
    ROUND(SUM(TotalPrice), 2) AS Revenue
FROM sales_data
GROUP BY ReferralSource
ORDER BY Revenue DESC;


-- =========================================
-- CUSTOMER REVENUE RANKING
-- WINDOW FUNCTION
-- =========================================

SELECT
    CustomerID,
    ROUND(SUM(TotalPrice), 2) AS TotalRevenue,
    RANK() OVER(
        ORDER BY SUM(TotalPrice) DESC
    ) AS RevenueRank
FROM sales_data
GROUP BY CustomerID;


-- =========================================
-- CUSTOMERS ABOVE AVERAGE SPENDING
-- SUBQUERY
-- =========================================

SELECT
    CustomerID,
    ROUND(SUM(TotalPrice), 2) AS TotalSpent
FROM sales_data
GROUP BY CustomerID
HAVING SUM(TotalPrice) >
(
    SELECT AVG(CustomerTotal)
    FROM
    (
        SELECT
            SUM(TotalPrice) AS CustomerTotal
        FROM sales_data
        GROUP BY CustomerID
    ) AS AvgTable
)
ORDER BY TotalSpent DESC;


-- =========================================
-- BEST PRODUCT BY PAYMENT METHOD
-- ADVANCED GROUPING
-- =========================================

SELECT
    PaymentMethod,
    Product,
    ROUND(SUM(TotalPrice),2) AS Revenue
FROM sales_data
GROUP BY PaymentMethod, Product
ORDER BY PaymentMethod, Revenue DESC;


/* =====================================================
   AVERAGE ORDER VALUE (AOV) ANALYSIS
   Objective:
   Calculate the average amount spent per transaction.
   ===================================================== */

SELECT
    ROUND(AVG(TotalPrice), 2) AS AverageOrderValue
FROM sales_data;


/* =====================================================
   ORDER STATUS DISTRIBUTION ANALYSIS
   Objective:
   Determine how many orders exist in each status.
   This helps evaluate operational efficiency and
   cancellation rates.
   ===================================================== */

SELECT
    OrderStatus,
    COUNT(*) AS TotalOrders
FROM sales_data
GROUP BY OrderStatus
ORDER BY TotalOrders DESC;
CREATE INDEX idx_customerid
ON sales_data(CustomerID);


/* =====================================================
   TOP-SELLING PRODUCTS BY QUANTITY
   Objective:
   Identify the products customers purchase most often.
   This measures popularity rather than revenue.
   ===================================================== */

SELECT
    Product,
    SUM(Quantity) AS UnitsSold
FROM sales_data
GROUP BY Product
ORDER BY UnitsSold DESC
LIMIT 5;
CREATE INDEX idx_orderdate
ON sales_data(Date);


/* =====================================================
   PRODUCT REVENUE CONTRIBUTION ANALYSIS
   Objective:
   Determine what percentage of total revenue each
   product contributes.
   ===================================================== */

SELECT
    Product,
    ROUND(
        SUM(TotalPrice) * 100 /
        (SELECT SUM(TotalPrice) FROM sales_data),
        2
    ) AS RevenuePercentage
FROM sales_data
GROUP BY Product
ORDER BY RevenuePercentage DESC;



/* =====================================================
   TOP 10 CUSTOMERS BY REVENUE
   Objective:
   Identify the highest-value customers based on
   total spending.
   ===================================================== */

SELECT
    CustomerID,
    ROUND(SUM(TotalPrice), 2) AS TotalRevenue
FROM sales_data
GROUP BY CustomerID
ORDER BY TotalRevenue DESC
LIMIT 10;



CREATE INDEX idx_product
ON sales_data(Product);

CREATE INDEX idx_orderstatus
ON sales_data(OrderStatus);