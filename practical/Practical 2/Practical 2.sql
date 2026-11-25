CREATE SCHEMA inmon;
CREATE TABLE inmon.customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE inmon.stores (
    store_id INTEGER PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE inmon.categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE inmon.products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INTEGER,
    brand VARCHAR(50),

    FOREIGN KEY (category_id)
        REFERENCES inmon.categories(category_id)
);

CREATE TABLE inmon.sales_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    store_id INTEGER,
    order_date DATE,

    FOREIGN KEY (customer_id)
        REFERENCES inmon.customers(customer_id),

    FOREIGN KEY (store_id)
        REFERENCES inmon.stores(store_id)
);

CREATE TABLE inmon.sales_order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price NUMERIC(10,2),

    FOREIGN KEY (order_id)
        REFERENCES inmon.sales_orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES inmon.products(product_id)
);
INSERT INTO inmon.customers VALUES
(1, 'Rahul', 'Hyderabad'),
(2, 'Priya', 'Vijayawada'),
(3, 'Amit', 'Chennai');

INSERT INTO inmon.stores VALUES
(1, 'Store A', 'Hyderabad', 'Telangana'),
(2, 'Store B', 'Vijayawada', 'Andhra Pradesh');

INSERT INTO inmon.categories VALUES
(1, 'Electronics'),
(2, 'Accessories');

INSERT INTO inmon.products VALUES
(101, 'Laptop', 1, 'Dell'),
(102, 'Mouse', 2, 'Logitech'),
(103, 'Mobile', 1, 'Samsung');

INSERT INTO inmon.sales_orders VALUES
(1001, 1, 1, '2026-01-10'),
(1002, 2, 2, '2026-01-11'),
(1003, 3, 1, '2026-02-05');

INSERT INTO inmon.sales_order_items VALUES
(1, 1001, 101, 1, 50000),
(2, 1001, 102, 2, 500),
(3, 1002, 103, 1, 20000),
(4, 1003, 101, 1, 50000);
SELECT * FROM inmon.customers;
SELECT
    C.customer_name,
    P.product_name,
    S.store_name,
    O.order_date,
    I.quantity,
    I.unit_price,
    I.quantity * I.unit_price AS sales_amount
FROM inmon.sales_orders O
JOIN inmon.customers C
    ON O.customer_id = C.customer_id
JOIN inmon.stores S
    ON O.store_id = S.store_id
JOIN inmon.sales_order_items I
    ON O.order_id = I.order_id
JOIN inmon.products P
    ON I.product_id = P.product_id
ORDER BY O.order_id;
SELECT
    SUM(quantity * unit_price) AS total_sales
FROM inmon.sales_order_items;
CREATE SCHEMA kimball;
CREATE TABLE kimball.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE kimball.dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER,
    product_name VARCHAR(100),
    category_name VARCHAR(50),
    brand VARCHAR(50)
);

CREATE TABLE kimball.dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id INTEGER,
    store_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE kimball.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE,
    day INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    quarter INTEGER,
    year INTEGER
);
CREATE TABLE kimball.fact_sales (
    sales_key SERIAL PRIMARY KEY,
    customer_key INTEGER,
    product_key INTEGER,
    store_key INTEGER,
    date_key INTEGER,
    quantity INTEGER,
    unit_price NUMERIC(10,2),
    sales_amount NUMERIC(12,2),

    FOREIGN KEY (customer_key)
        REFERENCES kimball.dim_customer(customer_key),

    FOREIGN KEY (product_key)
        REFERENCES kimball.dim_product(product_key),

    FOREIGN KEY (store_key)
        REFERENCES kimball.dim_store(store_key),

    FOREIGN KEY (date_key)
        REFERENCES kimball.dim_date(date_key)
);
INSERT INTO kimball.dim_customer
(customer_id, customer_name, city)
SELECT
    customer_id,
    customer_name,
    city
FROM inmon.customers;

INSERT INTO kimball.dim_product
(product_id, product_name, category_name, brand)
SELECT
    P.product_id,
    P.product_name,
    C.category_name,
    P.brand
FROM inmon.products P
JOIN inmon.categories C
    ON P.category_id = C.category_id;

INSERT INTO kimball.dim_store
(store_id, store_name, city, state)
SELECT
    store_id,
    store_name,
    city,
    state
FROM inmon.stores;
INSERT INTO kimball.dim_date
(date_key, full_date, day, month, month_name, quarter, year)
VALUES
(20260110, '2026-01-10', 10, 1, 'January', 1, 2026),
(20260111, '2026-01-11', 11, 1, 'January', 1, 2026),
(20260205, '2026-02-05', 5, 2, 'February', 1, 2026);
INSERT INTO kimball.fact_sales
(
    customer_key,
    product_key,
    store_key,
    date_key,
    quantity,
    unit_price,
    sales_amount
)
SELECT
    DC.customer_key,
    DP.product_key,
    DS.store_key,
    TO_CHAR(O.order_date, 'YYYYMMDD')::INTEGER,
    I.quantity,
    I.unit_price,
    I.quantity * I.unit_price
FROM inmon.sales_orders O
JOIN inmon.sales_order_items I
    ON O.order_id = I.order_id
JOIN kimball.dim_customer DC
    ON O.customer_id = DC.customer_id
JOIN kimball.dim_product DP
    ON I.product_id = DP.product_id
JOIN kimball.dim_store DS
    ON O.store_id = DS.store_id;
SELECT * FROM kimball.fact_sales;
SELECT
    P.product_name,
    SUM(F.quantity) AS total_quantity,
    SUM(F.sales_amount) AS total_sales
FROM kimball.fact_sales F
JOIN kimball.dim_product P
    ON F.product_key = P.product_key
GROUP BY P.product_name
ORDER BY total_sales DESC;
SELECT
    S.store_name,
    SUM(F.sales_amount) AS total_sales
FROM kimball.fact_sales F
JOIN kimball.dim_store S
    ON F.store_key = S.store_key
GROUP BY S.store_name
ORDER BY total_sales DESC;
