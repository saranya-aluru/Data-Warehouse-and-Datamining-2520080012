CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(100)
);

SELECT * FROM Customers;

INSERT INTO Customers (customer_name, city, email)
VALUES
('Rahul', 'Hyderabad', 'rahul@gmail.com'),
('Priya', 'Vijayawada', 'priya@gmail.com'),
('Amit', 'Bangalore', 'amit@gmail.com');


CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    category VARCHAR(50)
);


INSERT INTO Products
(product_name, price, category)
VALUES
('Laptop', 55000, 'Electronics'),
('Mobile', 20000, 'Electronics'),
('Headphones', 2000, 'Accessories'),
('Keyboard', 1500, 'Accessories'),
('Monitor', 12000, 'Electronics');

SELECT * FROM Products;



CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    order_date DATE,
    total_amount DECIMAL(10,2)
);


INSERT INTO Orders
(customer_id, order_date, total_amount)
VALUES
(1, '2026-01-10', 57000),
(2, '2026-01-12', 20000),
(3, '2026-02-05', 21500),
(1, '2026-02-10', 12000),
(2, '2026-02-15', 55000);

SELECT * FROM Orders;


BEGIN;

INSERT INTO Orders
(customer_id, order_date, total_amount)
VALUES
(1, CURRENT_DATE, 55000);

COMMIT;


BEGIN;

UPDATE Orders
SET total_amount = 100
WHERE order_id = 1;

ROLLBACK;


SELECT
    SUM(total_amount) AS Total_Revenue
FROM Orders;



SELECT
    c.customer_name,
    SUM(o.total_amount) AS Total_Purchase
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;


SELECT
    c.city,
    SUM(o.total_amount) AS City_Sales
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY City_Sales DESC;


SELECT
    COUNT(order_id) AS Total_Orders
FROM Orders;


SELECT
    SUM(total_amount) AS Total_Revenue
FROM Orders;


SELECT
    c.customer_name,
    SUM(o.total_amount) AS Total_Purchase
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY Total_Purchase DESC;


SELECT
    c.city,
    SUM(o.total_amount) AS City_Sales
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY City_Sales DESC;


SELECT
    EXTRACT(MONTH FROM order_date) AS Sales_Month,
    SUM(total_amount) AS Monthly_Revenue
FROM Orders
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY Sales_Month;


CREATE TABLE OrderDetails (
    detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id),
    product_id INT REFERENCES Products(product_id),
    quantity INT,
    subtotal DECIMAL(10,2)
);


INSERT INTO OrderDetails
(order_id, product_id, quantity, subtotal)
VALUES
(1, 1, 1, 55000),
(1, 3, 1, 2000),
(2, 2, 1, 20000),
(3, 2, 1, 20000),
(3, 4, 1, 1500),
(4, 5, 1, 12000),
(5, 1, 1, 55000),
(6, 3, 1, 2000),
(6, 4, 1, 1500);


SELECT
    p.product_name,
    SUM(od.quantity) AS Total_Quantity,
    SUM(od.subtotal) AS Total_Sales
FROM Products p
JOIN OrderDetails od
ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY Total_Quantity DESC;


SELECT
    p.product_name,
    SUM(od.quantity) AS Total_Quantity,
    SUM(od.subtotal) AS Total_Sales
FROM Products p
JOIN OrderDetails od
ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY Total_Quantity DESC;















