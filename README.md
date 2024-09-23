# Analysis-of-Model-Car-database 
Project Scenario

Mint Classics Company, a retailer of classic model cars and other vehicles, is looking at closing one of their storage facilities. 

To support a data-based business decision, they are looking for suggestions and recommendations for reorganizing or reducing inventory, while still maintaining timely service to their customers. For example, they would like to be able to ship a product to a customer within 24 hours of the order being placed.

As a data analyst, I have been asked to use MySQL Workbench to familiarize yourself with the general business by examining the current data. I was provided with a data model and sample data tables to review.I then isolated and identified those parts of the data that could be useful in deciding how to reduce inventory.
I formulated various questions and tried to answer them by SQL Queries.

# Following are my findings with SQL queries used:

**1) Overall Geograpical distribution of MintClassics over the globe-**

There are total 4 warehouse located in North,East,West and South with WarehouseCodes 'a','b','c' and 'd' respectively . 

Mint Classics Company has 5 offices in USA, France, Japan, Australia and UK.In USA it has 3 offices at San Francisco, NY and Boston; in other nations offices are in respective capitals.

Customers are located across 27 nations in 97 cities. 

**2) Product Details-**
There are total 110 products of cars in the warehouses. 

Warehouse A has highest number of 2002 Suzuki XREO model and lowest number of 1960 BSA Gold Star DBD34 models. 

Similarly we get other products quantity details in each warehouse by runnnig the following query :

SELECT productName,SUM(quantityInStock) AS totalquantity,warehouseCode
FROM products
WHERE warehouseCode='a'/'b'/'c'/'d'
GROUP BY productName,warehouseCode
ORDER BY totalquantity DESC/ASC LIMIT 1;

Then to calculate the total number of products sold (Sales Count) by name and product code, following SQL Query can be given -

SELECT p.productCode, p.productName, SUM(od.quantityOrdered) AS totalSold
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode;

**3) Product Order and Warehouse Insights:**
Average shipping time for delivery is found to be 3.75 days.
Products that are not shipped can be calculated by following query:

SELECT o.orderNumber, od.productCode, p.productLine, p.productName, p.warehouseCode
FROM orders o
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
WHERE o.shippedDate IS NULL;

Top 5 most unshipped products are 1940 Ford Delivery Sedan,1999 Yamaha Speed Boat, 18th century schooner, Collectable Wooden Train and  America West Airlines B757-200 from warehouses c,d and a.

South warehouse with warehouseCode 'd' has the most unshipped products among top 5 unshipped products.

Following code gives the details of unshipped products by warehouse:

SELECT p.warehouseCode, SUM(od.quantityOrdered) AS totalUnshippedQuantity
FROM orders o
INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN products p ON od.productCode = p.productCode
WHERE o.shippedDate IS NULL
GROUP BY p.warehouseCode
ORDER BY totalUnshippedQuantity DESC;

It tells us that Warehouse having most unshipped products are ranked as- d,c,b,a,

Following SQL query gives us the inventory products which are less than stocklevel and are not meeting the stock level demands:
SELECT 
p.warehouseCode,p.productCode,p.productName,p.quantityInStock AS stockLevel,
IFNULL(SUM(od.quantityOrdered), 0) AS totalUnshippedQuantity,
(p.quantityInStock - IFNULL(SUM(od.quantityOrdered), 0)) AS availableStock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
LEFT JOIN orders o ON od.orderNumber = o.orderNumber AND o.shippedDate IS NULL
GROUP BY p.warehouseCode, p.productCode
HAVING availableStock < 0
ORDER BY availableStock ASC;

Such Products are:

1960 BSA Gold Star DBD34,1968 Ford Mustang,1997 BMW F650 ST,1928 Ford Phaeton Deluxe,Pont Yacht,F/A 18 Hornet 1/72,2002 Yamaha YZR M1,1928 Mercedes-Benz SSK,1911 Ford Town Car,1996 Peterbilt 379 Stake Bed with Outrigger,The Mayflower

1985 Toyota Supra has not been sold yet with total sales quantity as 0.

**4) Relation between customers,nations and warehouse:**

Customers who order the most from a warehouse:

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
ORDER BY totalQuantityOrdered DESC
LIMIT 1;

- Now to determine the location of warehouse and how they are in demand customers, orders and warehouse table can be used

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

- Customers who order the most from a warehouse 
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
ORDER BY totalQuantityOrdered DESC
LIMIT 1;

- Relation between country and warehouses 
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

- Now we can find the most preferred warehouse of a nation inorder to shift the warehouses according to nations
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

# Final Report:
1) East Warehouse has highest share in product quantity and has 38 type of products.
2) South Warehouse has least share and has total 23 type of products
3) Warehouses can be reorganised according to Continents like Europe, America, Asia and Australia depending on the demand by  various nations.
4) There are 110 unique products across the warehouses. For example, Warehouse A has the highest number of Suzuki XREO models, while it holds the lowest stock of BSA Gold Star models. Such insights can be used to strategically reduce inventory by identifying products that are overstocked or not selling well.
5) Significant amounts of unshipped products are concentrated in Warehouse D (South), followed by Warehouses C and B. This suggests inefficiencies in these locations, either due to overstocking of certain products or logistical issues that are preventing timely shipping.
6) With an average shipping time of 3.75 days, Mint Classics may not be meeting its goal of shipping within 24 hours. Improving logistics and identifying bottlenecks (e.g., warehouses with high unshipped inventory) could help reduce this time
7) Some products, such as the 1985 Toyota Supra, have no sales or very low sales, while others like the Suzuki XREO model are high sellers. Low-selling products should be candidates for reduction or removal from inventory to optimize storage space and cut costs.
8) The top unshipped products, including models like the 1940 Ford Delivery Sedan and the 1999 Yamaha Speed Boat, should be examined. These models may be overstocked, or the demand for them might be too low to justify keeping large quantities in stock.
9) Focus on Closing or Reorganizing Warehouse D: Given that Warehouse D has the highest number of unshipped products, inefficiencies here might justify it as a candidate for closure or reorganization. Products could be redistributed to better-performing warehouses, like Warehouse A, which seems to manage inventory more efficiently.
10) Products with negative stock levels should be replenished and moved to warehouses with better shipping performance, while overstocked, unshipped products should be reduced to optimize storage space.
    
# Conclusion:
Mint Classics can make a data-driven decision to close or reorganize one of its warehouses, particularly focusing on Warehouse D, which shows inefficiencies in shipping and inventory management. By reducing or eliminating underperforming products and rebalancing inventory across its other warehouses, the company can achieve cost savings while maintaining timely service to its customers.
