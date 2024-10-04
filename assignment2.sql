CREATE DATABASE IF NOT EXISTS opt_db;
USE opt_db;

CREATE TABLE IF NOT EXISTS opt_clients (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL
);

CREATE TABLE IF NOT EXISTS opt_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category ENUM('Category1', 'Category2', 'Category3', 'Category4', 'Category5') NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS opt_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    client_id CHAR(36),
    product_id INT,
    FOREIGN KEY (client_id) REFERENCES opt_clients(id),
    FOREIGN KEY (product_id) REFERENCES opt_products(product_id)
);



SELECT * 
FROM (
    SELECT product_category, 
        (SELECT COUNT(*)
         FROM (
             SELECT o.client_id, o.product_id
             FROM opt_orders o
             JOIN opt_clients c ON o.client_id = c.id
             WHERE c.status = 'active'
         ) AS active_orders
         JOIN opt_products p ON active_orders.product_id = p.product_id
         WHERE p.product_category = distinct_categories.product_category
        ) AS category_product_count
    FROM (
        SELECT DISTINCT p.product_category
        FROM opt_products p
        JOIN opt_orders o ON o.product_id = p.product_id
        JOIN opt_clients c ON o.client_id = c.id
        WHERE c.status = 'active'
    ) AS distinct_categories
) AS final_result
ORDER BY category_product_count DESC;
   
   
   
   
CREATE INDEX idx_opt_clients_status
ON opt_clients(status);
drop index idx_opt_clients_status on opt_clients;

WITH cte as (
	SELECT *
	FROM opt_clients  as c
	WHERE c.status = 'active'
)
,

grouped_category as (
SELECT product_category, count(*) as category_product_count
FROM cte c
JOIN opt_orders o
ON o.client_id = c.id
JOIN opt_products p
ON p.product_id = o.product_id
GROUP BY product_category

)

SELECT * 
FROM grouped_category
ORDER BY category_product_count DESC;









              