select * from customers;
select * from employees;
select * from warehouses;
select * from products;
select * from orders;
select * from orderdetails;
select * from payments;



# 1.	Total Sales and Total Quantity Orders by each Product Line and warehouse

select p.warehousecode,p.productLine, sum(od.quantityOrdered*od.priceEach) as TotalSales, sum(od.quantityOrdered) as "Total Quantity Ordered"
from orderdetails od join products p on od.productCode = p.productCode
group by productLine
order by TotalSales desc
;



## 2. Total Sales by Product Line each year

select p.productLine, p.warehousecode, sum(if(year(o.orderdate)= 2003, od.quantityOrdered*od.priceEach, 0 )) as TotalSales2003,
sum(if(year(o.orderdate)= 2004, od.quantityOrdered*od.priceEach, 0 )) as TotalSales2004,
sum(if(year(o.orderdate)= 2005, od.quantityOrdered*od.priceEach, 0 )) as TotalSales2005
from orderdetails od join products p on od.productCode = p.productCode
join orders o on od.orderNumber = o.orderNumber
group by productLine
order by  TotalSales2004 desc;



# 3.   Growth %sale from year 2003 to 2004 in each ProductLine

select *, round((TotalSales2004-TotalSales2003)*100/TotalSales2004,1) "Growth_Sales_%"
FROM (
select p.productLine, p.warehousecode, sum(if(year(o.orderdate)= 2003, od.quantityOrdered*od.priceEach, 0 )) as TotalSales2003,
sum(if(year(o.orderdate)= 2004, od.quantityOrdered*od.priceEach, 0 )) as TotalSales2004
from orderdetails od join products p on od.productCode = p.productCode
join orders o on od.orderNumber = o.orderNumber
where o.status = "Shipped"
group by productLine) su;




# 4. sales growth from 2004 to 2005 for the first five months in each ProductLine.

select *,sum(TotalSalesJAN2004 + TotalSalesJAN2005 + TotalSalesFEB2004 + TotalSalesFEB2005 + 
TotalSalesMAR2004 + TotalSalesMAR2005 + TotalSalesAPR2004 + TotalSalesAPR2005 + TotalSalesMAY2004 + TotalSalesMAY2005) as TotalSales, 
round((TotalSalesJAN2005-TotalSalesJAN2004)*100/TotalSalesJAN2005,1) "JAN Growth Sales %", 
round((TotalSalesFEB2005-TotalSalesFEB2004)*100/TotalSalesFEB2005,1) "FEB Growth Sales %",
round((TotalSalesMAR2005-TotalSalesMAR2004)*100/TotalSalesMAR2005,1) "MAR Growth Sales %",
round((TotalSalesAPR2005-TotalSalesAPR2004)*100/TotalSalesAPR2005,1) "APR Growth Sales %",
round((TotalSalesMAY2005-TotalSalesMAY2004)*100/TotalSalesMAY2005,1) "MAY Growth Sales %"
FROM (
select p.productLine,p.warehousecode, sum(if(year(o.orderdate)= 2004 and month(o.orderdate)= 1, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesJAN2004,
sum(if(year(o.orderdate)= 2005 and month(o.orderdate)= 1, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesJAN2005,
sum(if(year(o.orderdate)= 2004 and month(o.orderdate)= 2, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesFEB2004,
sum(if(year(o.orderdate)= 2005 and month(o.orderdate)= 2, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesFEB2005,
sum(if(year(o.orderdate)= 2004 and month(o.orderdate)= 3, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesMAR2004,
sum(if(year(o.orderdate)= 2005 and month(o.orderdate)= 3, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesMAR2005,
sum(if(year(o.orderdate)= 2004 and month(o.orderdate)= 4, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesAPR2004,
sum(if(year(o.orderdate)= 2005 and month(o.orderdate)= 4, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesAPR2005,
sum(if(year(o.orderdate)= 2004 and month(o.orderdate)= 5, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesMAY2004,
sum(if(year(o.orderdate)= 2005 and month(o.orderdate)= 5, od.quantityOrdered*od.priceEach, 0 )) as TotalSalesMAY2005
from orderdetails od join products p on od.productCode = p.productCode
join orders o on od.orderNumber = o.orderNumber
where o.status = "Shipped"
group by productLine)  su
group by productLine;




## 5. Inventory Recomendation for Products

SELECT
    p.productCode,
    p.productName,
    w.warehouseCode,
    w.warehousename,
    SUM(od.quantityOrdered) AS totalOrdered,
    p.quantityInStock,
    (p.quantityInStock - SUM(od.quantityOrdered)) AS potentialExcess,
    ROUND((SUM(od.quantityOrdered) / p.quantityInStock) * 100, 2) AS orderPercentage,
    CASE
        WHEN (p.quantityInStock - SUM(od.quantityOrdered)) > 0 THEN 'Potential Reduction'
        ELSE 'Maintain Inventory'
    END AS inventoryRecommendation
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
JOIN
    customers c ON o.customerNumber = c.customerNumber
JOIN
    warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY
    p.productCode, w.warehouseCode
ORDER BY
    inventoryRecommendation,
    orderPercentage DESC;
    
    
    
## 6. Products whose Total Order is less than 800 and quantity in stock is higher than 3000

SELECT
    p.productCode,
    p.productName,
    p.productLine,
    p.warehousecode,
    p.quantityinstock,
    SUM(od.quantityOrdered) AS totalOrdered,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales,
    ROUND((SUM(od.quantityOrdered) / p.quantityInStock) * 100, 2) AS salesToInventoryRatio
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
WHERE
    o.status = 'Shipped' AND
    YEAR(o.orderDate) BETWEEN 2003 AND 2005  -- Specify the desired time period
GROUP BY
    p.productCode, p.productName, p.productLine, p.quantityInStock
HAVING
    totalOrdered < 800  -- Set the threshold for low totalOrdered
    and quantityinstock > 3000
ORDER BY
    totalOrdered ASC;
    


## 7. Sales to Inventory Ratio.  
    
SELECT
    p.warehouseCode,
    w.warehousename,
    SUM(od.quantityOrdered) AS totalOrdered,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales,
    SUM(p.quantityInStock) AS totalInventory,
    ROUND((SUM(od.quantityOrdered) / SUM(p.quantityInStock)) * 100, 2) AS salesToInventoryRatio
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
JOIN
    warehouses w ON p.warehouseCode = w.warehouseCode
WHERE
    o.status = 'Shipped' AND
    YEAR(o.orderDate) BETWEEN 2003 AND 2005  -- Specify the desired time period
GROUP BY
    p.warehouseCode, w.warehousename
ORDER BY
    salesToInventoryRatio ASC, totalSales ASC;
    
    

    
##  8. Average Shipping days from all warehouse
    
SELECT
    p.warehouseCode,
    w.warehousename,
    SUM(od.quantityOrdered) AS totalQuantityOrdered,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales,
    AVG(DATEDIFF(o.shippedDate, o.orderDate)) AS avgShippingTimeDays
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
JOIN
    customers c ON o.customerNumber = c.customerNumber
JOIN
    warehouses w ON p.warehouseCode = w.warehouseCode
WHERE
    o.status = 'Shipped'
GROUP BY
    p.warehouseCode, w.warehousename
ORDER BY
    avgShippingTimeDays ASC;
    
    
    
    