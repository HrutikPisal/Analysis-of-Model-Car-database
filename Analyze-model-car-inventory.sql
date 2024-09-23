SELECT DISTINCT warehouseCode
FROM products;
-- there are four warehouses in total with
SELECT DISTINCT warehouseName,warehouseCode 
FROM warehouses;
-- four directions north, south, east and west
SELECT distinct country 
FROM offices;
-- offices are located in 5 nations USA, France, Japan,Australia and UK
SELECT DISTINCT city 
FROM offices;
-- In USA it has three offices in cities of San Francisco, NY and Boston; in other nations respective capital cities offices are located 
SELECT COUNT(DISTINCT country) AS count 
from customers;
-- there are 27 different countries from customers and 
SELECT COUNT(DISTINCT city) AS count 
from customers;
-- 95 different cities 
-- Now let's focus on the products and their details
SELECT COUNT(DISTINCT productName) AS productName FROM products;
-- There are in total 110 products 

SELECT productName,SUM(quantityInStock) AS totalquantity,warehouseCode 
FROM products 
GROUP BY productName,warehouseCode 
ORDER BY totalquantity DESC;
-- This query gives the totalquantity of each product in each warehouse 
-- warehouse A has highest number of suzuki XREO model and lowest number of 1960 BSA Gold Star DBD34 models
-- similarly we get other products quantity details in each warehouse
-- Number of product sales count:
SELECT p.productCode, p.productName, SUM(od.quantityOrdered) AS totalSold
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode;

SELECT orderNumber,productCode,quantityOrdered,priceEach 
FROM orderdetails;
-- now to get orderdetails of each product

SELECT orderNumber,orderDate,requiredDate,shippedDate 
FROM orders;
-- Main tables are orderdetails,orders,products,and warehouses to derive necessary conclusions for my problem statement.
-- Average shipping time:

SELECT AVG(DATEDIFF(shippedDate, orderDate)) AS avgShippingTime_in_days
FROM orders
WHERE status = 'Shipped';

-- Products that are not shipped
SELECT o.orderNumber, od.productCode, p.productLine, p.productName, p.warehouseCode
FROM orders o
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
WHERE o.shippedDate IS NULL;
-- Name of most unshipped products with inventory
SELECT p.productCode, p.productName, p.warehouseCode, SUM(od.quantityOrdered) AS totalUnshippedQuantity
FROM orders o
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
WHERE o.shippedDate IS NULL
GROUP BY p.productCode, p.productName, p.warehouseCode
ORDER BY totalUnshippedQuantity DESC
LIMIT 10;
-- Warehouse which has the most unshipped products
SELECT p.warehouseCode, SUM(od.quantityOrdered) AS totalUnshippedQuantity
FROM orders o
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
WHERE o.shippedDate IS NULL
GROUP BY p.warehouseCode
ORDER BY totalUnshippedQuantity DESC;
-- the number of unshipped products can help in inventory reorganization and management 
-- Get stock levels per warehouse
SELECT w.warehouseCode, w.warehouseName, SUM(p.quantityInStock) AS totalInventory
FROM warehouses w
JOIN products p ON w.warehouseCode = p.warehouseCode
GROUP BY w.warehouseCode;
-- to compare the total inventory and unshipped products to derive insight for inventory reorganization and management
SELECT 
    p.warehouseCode,
    p.productCode,
    p.productName,
    p.quantityInStock AS stockLevel,
    IFNULL(SUM(od.quantityOrdered), 0) AS totalUnshippedQuantity,
    (p.quantityInStock - IFNULL(SUM(od.quantityOrdered), 0)) AS availableStock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
LEFT JOIN orders o ON od.orderNumber = o.orderNumber AND o.shippedDate IS NULL
GROUP BY p.warehouseCode, p.productCode
ORDER BY p.warehouseCode, availableStock DESC;
-- now we can derive the inventory products which are less than stocklevel and are not meeting the stock level demands
SELECT 
    p.warehouseCode,
    p.productCode,
    p.productName,
    p.quantityInStock AS stockLevel,
    IFNULL(SUM(od.quantityOrdered), 0) AS totalUnshippedQuantity,
    (p.quantityInStock - IFNULL(SUM(od.quantityOrdered), 0)) AS availableStock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
LEFT JOIN orders o ON od.orderNumber = o.orderNumber AND o.shippedDate IS NULL
GROUP BY p.warehouseCode, p.productCode
HAVING availableStock < 0
ORDER BY availableStock ASC;
-- to find the products which have very less sales we can give as:
SELECT 
    p.productCode,
    p.productName,
    p.productLine,
    p.quantityInStock,
    IFNULL(SUM(od.quantityOrdered), 0) AS totalSalesQuantity
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
LEFT JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productCode, p.productName, p.productLine, p.quantityInStock
HAVING totalSalesQuantity = 0 OR totalSalesQuantity < 10
ORDER BY totalSalesQuantity ASC;

-- now to determine th location of warehouse and how they are in demand customers, orders and warehouse table can be used

SELECT 
    c.customerNumber,
    c.customerName,
    p.warehouseCode,
    COUNT(DISTINCT o.orderNumber) AS totalOrders,
    SUM(od.quantityOrdered) AS totalQuantityOrdered
FROM customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
GROUP BY c.customerNumber, c.customerName, p.warehouseCode
ORDER BY c.customerNumber, totalOrders DESC;
-- Customers who order the most from a warehouse 
SELECT 
    c.customerNumber,
    c.customerName,
    p.warehouseCode,
    SUM(od.quantityOrdered) AS totalQuantityOrdered
FROM customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
WHERE p.warehouseCode = 'd'  -- Replace 'WAREHOUSE_CODE' with the actual warehouse code
GROUP BY c.customerNumber, c.customerName, p.warehouseCode
ORDER BY totalQuantityOrdered DESC;
-- Relation between country and warehouses 
SELECT 
    c.country,
    p.warehouseCode,
    COUNT(DISTINCT o.orderNumber) AS totalOrders,
    SUM(od.quantityOrdered) AS totalQuantityOrdered
FROM customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
GROUP BY c.country, p.warehouseCode
ORDER BY c.country, totalQuantityOrdered DESC;
-- now we can find the most preferred warehouse of a nation inorder to shift the warehouses according to nations
SELECT 
    t1.country,
    t1.warehouseCode,
    t1.totalQuantityOrdered
FROM (
    SELECT 
        c.country,
        p.warehouseCode,
        SUM(od.quantityOrdered) AS totalQuantityOrdered
    FROM customers c
    INNER JOIN orders o ON c.customerNumber = o.customerNumber
    INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
    INNER JOIN products p ON od.productCode = p.productCode
    GROUP BY c.country, p.warehouseCode
) t1
INNER JOIN (
    -- Subquery to get the maximum total quantity for each country
    SELECT 
        country,
        MAX(totalQuantityOrdered) AS maxQuantity
    FROM (
        SELECT 
            c.country,
            p.warehouseCode,
            SUM(od.quantityOrdered) AS totalQuantityOrdered
        FROM customers c
        INNER JOIN orders o ON c.customerNumber = o.customerNumber
        INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
        INNER JOIN products p ON od.productCode = p.productCode
        GROUP BY c.country, p.warehouseCode
    ) t2
    GROUP BY country
) t3 ON t1.country = t3.country AND t1.totalQuantityOrdered = t3.maxQuantity;


