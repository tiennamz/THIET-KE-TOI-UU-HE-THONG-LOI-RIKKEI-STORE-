--  PHẦN D – SQL
CREATE DATABASE sql_team_a;
USE sql_team_a;

CREATE TABLE users(
	user_id INT PRIMARY KEY AUTO_INCREMENT,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    birth_date DATE

);


CREATE TABLE categories(
	category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL

);

CREATE TABLE products(
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price BIGINT CHECK(price > 0),
    quantity INT CHECK(quantity > 0),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)

);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    order_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    order_status ENUM('Pending', 'Paid', 'Cancelled')
    
);
CREATE TABLE order_detail(
	order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT ,
    quantity_total INT,
    total_price INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE(order_id, product_id)

);


INSERT INTO categories (category_name) VALUES 
('Electronics'),
('Clothing'),
('Books'),
('Home Appliances');


INSERT INTO products (product_name, price, quantity, category_id) VALUES 
('Laptop Dell XPS', 25000000, 50, 1),    
('Iphone 15 Pro', 28000000, 100, 1),     
('Áo thun nam', 150000, 200, 2),         
('Sách Đắc Nhân Tâm', 85000, 150, 3),    
('Nồi chiên không dầu', 1500000, 80, 4), 
('Bàn phím cơ', 1200000, 60, 1);         


INSERT INTO users (fullname, email, birth_date) VALUES 
('Đỗ Tiến Nam', 'nam.do@example.com', '2005-10-15'),
('Nguyễn Văn A', 'nva@example.com', '2000-01-01'),
('Trần Thị B', 'ttb@example.com', '1995-05-20'),
('Lê Hoàng C', 'lhc@example.com', '1998-08-08'),
('Phạm Thị D', 'ptd@example.com', '2002-12-12'),
('User Ảo', 'ghost@example.com', '2000-01-01'); 


INSERT INTO orders (user_id, order_date, order_status) VALUES 
(1, '2026-04-01', 'Paid'),
(1, '2026-04-05', 'Pending'),
(2, '2026-04-10', 'Paid'),
(3, '2026-04-15', 'Cancelled'),
(4, '2026-04-20', 'Paid');


INSERT INTO order_detail (order_id, product_id, quantity_total, total_price) VALUES 
(1, 1, 1, 25000000), 
(1, 2, 2, 56000000),
(2, 3, 3, 450000),  
(3, 5, 1, 1500000), 
(4, 4, 2, 170000),   
(5, 1, 2, 50000000); 

-- Q1
-- Lấy danh sách tất cả đơn hàng gồm:
-- order_id
-- order_date
-- full_name (user)
-- total_money

SELECT 
	o.order_id,
	o.order_date,
	u.fullname,
	od.total_price
FROM order_detail od
INNER JOIN orders o
ON o.order_id = od.order_id
INNER JOIN users u
ON o.user_id = u.user_id;


-- Tìm tất cả sản phẩm thuộc category = 'Electronics'
SELECT 
	product_id,
	product_name,
	price,
	quantity,
	category_id
FROM products
WHERE category_id = (
	SELECT category_id
    FROM categories
    WHERE category_name = 'Electronics'
);

-- Tìm danh sách users (user_id, full_name, email)
SELECT 
	user_id,
	fullname,
	email
FROM users;

-- Tính tổng số tiền tất cả đơn hàng trong hệ thống.
SELECT SUM(total_price) AS total_money
FROM order_detail;

-- Tính tổng số lượng sản phẩm đã bán theo từng product:
-- product_id
-- product_name (nếu có)
-- total_quantity
SELECT 
	p.product_id,
	p.product_name,
	SUM(od.quantity_total) AS quantity_total
FROM order_detail od
INNER JOIN products p
ON od.product_id = p.product_id
GROUP BY product_id;

-- Tìm sản phẩm có tổng số lượng bán lớn nhất.
SELECT 
	p.product_name,
	SUM(od.total_price) AS total_price
FROM order_detail od
INNER JOIN products p
ON od.product_id = p.product_id
GROUP BY product_name
ORDER BY total_price DESC
LIMIT 1;

-- Q7
-- Lấy danh sách đơn hàng kèm:
-- order_id
-- full_name
-- total_money
-- số lượng sản phẩm trong đơn
SELECT 
	o.order_id,
	u.fullname,
	SUM(od.total_price) AS total_price,
	SUM(od.quantity_total) AS quantity_total
FROM order_detail od
INNER JOIN orders o
ON o.order_id = od.order_id
INNER JOIN users u
ON o.user_id = u.user_id
GROUP BY o.order_id,
		u.fullname;

-- Tìm sản phẩm không xuất hiện trong bất kỳ Order_Details nào 
SELECT 
	product_name
FROM products
WHERE product_id NOT IN (
SELECT product_id
FROM order_detail
);

-- Tìm danh sách users đã từng mua hàng, kèm số đơn hàng của mỗi user.
SELECT 
	u.fullname,
	COUNT(o.user_id) AS total_orders
FROM users u
LEFT JOIN orders o
ON o.user_id = u.user_id
GROUP BY fullname;

-- Tìm sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm.
SELECT 
	product_name,
	price
FROM products
WHERE price > (
	SELECT AVG(price)
    FROM products
);

-- Tìm users có tổng chi tiêu lớn hơn mức trung bình của tất cả users.
SELECT 
	fullname,
	SUM(total_price) AS total_price
FROM order_detail od
INNER JOIN orders o
ON o.order_id = od.order_id
INNER JOIN users u
ON o.user_id = u.user_id
WHERE total_price > (
	SELECT AVG(total_price)
    FROM order_detail
)
GROUP BY fullname;

-- Tìm đơn hàng có giá trị lớn nhất trong hệ thống.
SELECT 
    order_id, 
    SUM(total_price) AS total_price
FROM order_detail
GROUP BY order_id
ORDER BY order_total DESC
LIMIT 1;

-- Tìm category có tổng doanh thu cao nhất.
SELECT 
	category_name,
	SUM(total_price) AS total_price
FROM order_detail od
INNER JOIN orders o
ON o.order_id = od.order_id
INNER JOIN products p
ON od.product_id = p.product_id
INNER JOIN categories c
ON c.category_id = p.category_id
GROUP BY category_name
ORDER BY total_price DESC
LIMIT 1;

-- Tìm top 3 sản phẩm bán chạy nhất (theo quantity).
-- Theo quantity giảm dần
-- Nếu bằng nhau thì ưu tiên product_id nhỏ hơn
SELECT 
	product_name,
	quantity_total,
	price
FROM order_detail od
INNER JOIN products p
ON od.product_id = p.product_id
ORDER BY quantity_total DESC, od.product_id ASC;

-- Tìm users chưa từng đặt bất kỳ đơn hàng nào.
SELECT 
	user_id,
	fullname,
	email
FROM users
WHERE user_id NOT IN (
	SELECT user_id
    FROM orders
);
