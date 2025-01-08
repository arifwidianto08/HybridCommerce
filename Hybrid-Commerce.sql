-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS order_payments;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS order_fulfillments;
DROP TABLE IF EXISTS order_shippings;
DROP TABLE IF EXISTS shipping_methods;
DROP TABLE IF EXISTS order_line_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product_warehouse_stocks;
DROP TABLE IF EXISTS product_shelf_stocks;
DROP TABLE IF EXISTS inventory_movements;
DROP TABLE IF EXISTS product_category_maps;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS shelves;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customer_addresses;
DROP TABLE IF EXISTS customers;

-- Create tables
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    registration_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    line_1 VARCHAR(255) NOT NULL,
    line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    position ENUM('manager', 'cashier') NOT NULL,
    hire_date DATETIME,
    salary DECIMAL(10,2) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shelves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    number INT NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    barcode VARCHAR(50) NOT NULL UNIQUE,
    available_in_store INT,
    available_in_warehouse INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_category_maps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (category_id) REFERENCES product_categories(id)
);

CREATE TABLE inventory_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT,
    shelf_id INT,
    movement_date DATETIME,
    movement_type ENUM('in', 'out'),
    quantity INT,
    movement_source VARCHAR(50),
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (shelf_id) REFERENCES shelves(id)
);

CREATE TABLE product_shelf_stocks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shelf_id INT NOT NULL,
    product_id INT NOT NULL,
    stock INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shelf_id) REFERENCES shelves(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE product_warehouse_stocks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    stock INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('online', 'offline'),
    customer_id INT NOT NULL,
    employee_id INT,
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE order_line_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE shipping_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_shippings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    shipping_method_id INT,
    shipping_date DATETIME,
    estimation_arrival DATETIME,
    tracking_number VARCHAR(100),
    line_1 VARCHAR(255) NOT NULL,
    line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES orders(id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(id)
);

CREATE TABLE order_fulfillments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    fulfillment_status ENUM('fulfilled', 'partially_fulfilled', 'unfulfilled'),
    fulfillment_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES orders(id)
);

CREATE TABLE payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    payment_method_id INT,
    amount DECIMAL(10,2),
    status ENUM('paid', 'unpaid', 'partially_paid'),
    paid_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES orders(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

-- Insert sample data

-- Customers
INSERT INTO customers (name, phone, email, address, registration_date) VALUES
('John Doe', '+1234567890', 'john@example.com', '123 Main St', '2024-01-01'),
('Jane Smith', '+1234567891', 'jane@example.com', '456 Oak Ave', '2024-01-02'),
('Bob Johnson', '+1234567892', 'bob@example.com', '789 Pine Rd', '2024-01-03'),
('Alice Brown', '+1234567893', 'alice@example.com', '321 Elm St', '2024-01-04'),
('Charlie Wilson', '+1234567894', 'charlie@example.com', '654 Maple Dr', '2024-01-05'),
('Diana Miller', '+1234567895', 'diana@example.com', '987 Cedar Ln', '2024-01-06'),
('Edward Davis', '+1234567896', 'edward@example.com', '147 Birch Rd', '2024-01-07'),
('Fiona Garcia', '+1234567897', 'fiona@example.com', '258 Walnut Ave', '2024-01-08'),
('George Martinez', '+1234567898', 'george@example.com', '369 Pine St', '2024-01-09'),
('Helen Anderson', '+1234567899', 'helen@example.com', '741 Oak Rd', '2024-01-10'),
('Ian Taylor', '+1234567900', 'ian@example.com', '852 Maple St', '2024-01-11'),
('Julia Thomas', '+1234567901', 'julia@example.com', '963 Cedar Ave', '2024-01-12'),
('Kevin White', '+1234567902', 'kevin@example.com', '159 Elm Dr', '2024-01-13'),
('Laura Hall', '+1234567903', 'laura@example.com', '753 Birch St', '2024-01-14'),
('Michael Lee', '+1234567904', 'michael@example.com', '951 Walnut Rd', '2024-01-15'),
('Nancy Clark', '+1234567905', 'nancy@example.com', '357 Pine Ave', '2024-01-16'),
('Oliver Young', '+1234567906', 'oliver@example.com', '486 Oak Dr', '2024-01-17'),
('Patricia King', '+1234567907', 'patricia@example.com', '159 Maple Ln', '2024-01-18'),
('Quincy Adams', '+1234567908', 'quincy@example.com', '753 Cedar St', '2024-01-19'),
('Rachel Green', '+1234567909', 'rachel@example.com', '951 Elm Ave', '2024-01-20');

-- Customer Addresses
INSERT INTO customer_addresses (customer_id, line_1, line_2, city, state, postal_code, country) VALUES
(1, '123 Main St', 'Apt 4B', 'New York', 'NY', '10001', 'USA'),
(2, '456 Oak Ave', NULL, 'Los Angeles', 'CA', '90001', 'USA'),
(3, '789 Pine Rd', 'Suite 100', 'Chicago', 'IL', '60601', 'USA'),
(4, '321 Elm St', NULL, 'Houston', 'TX', '77001', 'USA'),
(5, '654 Maple Dr', 'Unit 7', 'Phoenix', 'AZ', '85001', 'USA'),
(6, '987 Cedar Ln', NULL, 'Philadelphia', 'PA', '19101', 'USA'),
(7, '147 Birch Rd', 'Apt 12C', 'San Antonio', 'TX', '78201', 'USA'),
(8, '258 Walnut Ave', NULL, 'San Diego', 'CA', '92101', 'USA'),
(9, '369 Pine St', 'Suite 200', 'Dallas', 'TX', '75201', 'USA'),
(10, '741 Oak Rd', NULL, 'San Jose', 'CA', '95101', 'USA'),
(11, '852 Maple St', 'Apt 15D', 'Austin', 'TX', '78701', 'USA'),
(12, '963 Cedar Ave', NULL, 'Jacksonville', 'FL', '32201', 'USA'),
(13, '159 Elm Dr', 'Unit 9', 'San Francisco', 'CA', '94101', 'USA'),
(14, '753 Birch St', NULL, 'Indianapolis', 'IN', '46201', 'USA'),
(15, '951 Walnut Rd', 'Suite 300', 'Columbus', 'OH', '43201', 'USA'),
(16, '357 Pine Ave', NULL, 'Fort Worth', 'TX', '76101', 'USA'),
(17, '486 Oak Dr', 'Apt 20E', 'Charlotte', 'NC', '28201', 'USA'),
(18, '159 Maple Ln', NULL, 'Detroit', 'MI', '48201', 'USA'),
(19, '753 Cedar St', 'Suite 400', 'El Paso', 'TX', '79901', 'USA'),
(20, '951 Elm Ave', NULL, 'Seattle', 'WA', '98101', 'USA');

-- Employees
INSERT INTO employees (name, position, hire_date, salary, phone, email) VALUES
('Manager One', 'manager', '2023-01-01', 60000.00, '+1111111111', 'manager1@example.com'),
('Manager Two', 'manager', '2023-01-02', 62000.00, '+1111111112', 'manager2@example.com'),
('Manager Three', 'manager', '2023-01-03', 61000.00, '+1111111113', 'manager3@example.com'),
('Manager Four', 'manager', '2023-01-04', 63000.00, '+1111111114', 'manager4@example.com'),
('Manager Five', 'manager', '2023-01-05', 64000.00, '+1111111115', 'manager5@example.com'),
('Cashier One', 'cashier', '2023-02-01', 35000.00, '+2222222221', 'cashier1@example.com'),
('Cashier Two', 'cashier', '2023-02-02', 35500.00, '+2222222222', 'cashier2@example.com'),
('Cashier Three', 'cashier', '2023-02-03', 35500.00, '+2222222223', 'cashier3@example.com'),
('Cashier Four', 'cashier', '2023-02-04', 36000.00, '+2222222224', 'cashier4@example.com'),
('Cashier Five', 'cashier', '2023-02-05', 36000.00, '+2222222225', 'cashier5@example.com'),
('Cashier Six', 'cashier', '2023-02-06', 36500.00, '+2222222226', 'cashier6@example.com'),
('Cashier Seven', 'cashier', '2023-02-07', 36500.00, '+2222222227', 'cashier7@example.com'),
('Cashier Eight', 'cashier', '2023-02-08', 37000.00, '+2222222228', 'cashier8@example.com'),
('Cashier Nine', 'cashier', '2023-02-09', 37000.00, '+2222222229', 'cashier9@example.com'),
('Cashier Ten', 'cashier', '2023-02-10', 37500.00, '+2222222230', 'cashier10@example.com'),
('Cashier Eleven', 'cashier', '2023-02-11', 37500.00, '+2222222231', 'cashier11@example.com'),
('Cashier Twelve', 'cashier', '2023-02-12', 38000.00, '+2222222232', 'cashier12@example.com'),
('Cashier Thirteen', 'cashier', '2023-02-13', 38000.00, '+2222222233', 'cashier13@example.com'),
('Cashier Fourteen', 'cashier', '2023-02-14', 38500.00, '+2222222234', 'cashier14@example.com'),
('Cashier Fifteen', 'cashier', '2023-02-15', 38500.00, '+2222222235', 'cashier15@example.com');

-- Warehouses
INSERT INTO warehouses (name, location) VALUES
('Main Warehouse', '123 Warehouse St, Industry City'),
('North Warehouse', '456 Storage Ave, North City'),
('South Warehouse', '789 Logistics Rd, South City'),
('East Warehouse', '321 Distribution Ln, East City'),
('West Warehouse', '654 Supply Dr, West City'),
('Central Warehouse', '987 Inventory Ct, Central City'),
('Downtown Warehouse', '147 Stock St, Downtown'),
('Suburban Warehouse', '258 Freight Ave, Suburbs'),
('Airport Warehouse', '369 Cargo Rd, Airport District'),
('Port Warehouse', '741 Ship Ln, Port City'),
('Mountain Warehouse', '852 Highland Dr, Mountain View'),
('Valley Warehouse', '963 Lowland St, Valley City'),
('Coastal Warehouse', '159 Beach Rd, Coast City'),
('Desert Warehouse', '753 Sand Ave, Desert City'),
('Forest Warehouse', '951 Wood St, Forest City'),
('Lake Warehouse', '357 Shore Dr, Lake City'),
('River Warehouse', '486 Stream Ave, River City'),
('Hill Warehouse', '159 Summit St, Hill City'),
('Prairie Warehouse', '753 Plains Rd, Prairie City'),
('Metro Warehouse', '951 Urban Ave, Metro City');

-- Shelves
INSERT INTO shelves (number, location) VALUES
(101, 'Aisle A1'),
(102, 'Aisle A2'),
(103, 'Aisle A3'),
(201, 'Aisle B1'),
(202, 'Aisle B2'),
(203, 'Aisle B3'),
(301, 'Aisle C1'),
(302, 'Aisle C2'),
(303, 'Aisle C3'),
(401, 'Aisle D1'),
(402, 'Aisle D2'),
(403, 'Aisle D3'),
(501, 'Aisle E1'),
(502, 'Aisle E2'),
(503, 'Aisle E3'),
(601, 'Aisle F1'),
(602, 'Aisle F2'),
(603, 'Aisle F3'),
(701, 'Aisle G1'),
(702, 'Aisle G2');

-- Products
INSERT INTO products (name, price, barcode, available_in_store, available_in_warehouse) VALUES
('Laptop', 999.99, 'LAP001', 50, 200),
('Smartphone', 699.99, 'PHN001', 100, 500),
('Tablet', 399.99, 'TAB001', 75, 300),
('Headphones', 99.99, 'AUD001', 200, 800),
('Mouse', 29.99, 'ACC001', 150, 600),
('Keyboard', 59.99, 'ACC002', 100, 400),
('Monitor', 299.99, 'DSP001', 40, 160),
('Printer', 199.99, 'PRN001', 30, 120),
('Scanner', 149.99, 'SCN001', 25, 100),
('Router', 79.99, 'NET001', 60, 240),
('External HDD', 89.99, 'STR001', 80, 320),
('USB Drive', 19.99, 'STR002', 300, 1200),
('Webcam', 49.99, 'CAM001', 90, 360),
('Speaker', 129.99, 'AUD002', 70, 280),
('Microphone', 69.99, 'AUD003', 45, 180),
('Graphics Card', 499.99, 'GPU001', 20, 80),
('RAM', 89.99, 'RAM001', 150, 600),
('Power Supply', 79.99, 'PWR001', 40, 160),
('Case Fan', 19.99, 'FAN001', 200, 800),
('Motherboard', 199.99, 'MBD001', 30, 120);

-- Product Categories
INSERT INTO product_categories (name) VALUES
('Electronics'),
('Computers'),
('Accessories'),
('Storage'),
('Audio'),
('Video'),
('Networking'),
('Components'),
('Peripherals'),
('Gaming'),
('Office'),
('Mobile'),
('Photography'),
('Security'),
('Smart Home'),
('Cables'),
('Power'),
('Cooling'),
('Software'),
('Servers');

-- Product Category Maps
INSERT INTO product_category_maps (product_id, category_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 12),
(3, 1), (3, 12),
(4, 1), (4, 5),
(5, 3), (5, 9),
(6, 3), (6, 9),
(7, 1), (7, 6),
(8, 1), (8, 11),
(9, 1), (9, 11),
(10, 1), (10, 7),
(11, 1), (11, 4),
(12, 3), (12, 4),
(13, 1), (13, 13),
(14, 1), (14, 5),
(15, 1), (15, 5),
(16, 1), (16, 8),
(17, 1), (17, 8),
(18, 1), (18, 17),
(19, 3), (19, 18),
(20, 1), (20, 8);

-- Shipping Methods
INSERT INTO shipping_methods (name) VALUES
('Standard Shipping'),
('Express Shipping'),
('Next Day Delivery'),
('Two-Day Shipping'),
('Ground Shipping'),
('International Shipping'),
('Local Delivery'),
('Pickup in Store'),
('Same Day Delivery'),
('Priority Mail'),
('First Class Mail'),
('Freight Shipping'),
('Economy Shipping'),
('Overnight Shipping'),
('Standard Ground'),
('Express Air'),
('International Economy'),
('International Priority'),
('Local Courier'),
('Postal Service');

-- Payment Methods
INSERT INTO payment_methods (name) VALUES
('Credit Card'),
('Debit Card'),
('PayPal'),
('Cash'),
('Bank Transfer'),
('Mobile Payment'),
('Gift Card'),
('COD'),
('Cryptocurrency'),
('Check'),
('Money Order'),
('Store Credit'),
('Digital Wallet'),
('Wire Transfer'),
('QRIS'),
('Installment'),
('Points Redemption'),
('Voucher'),
('E-Check'),
('Financing');

-- Initialize some orders
INSERT INTO orders (type, customer_id, employee_id, total_amount) VALUES
('online', 1, 1, 1299.98),
('offline', 2, 6, 799.98),
('online', 3, 2, 599.97),
('offline', 4, 7, 449.96),
('online', 5, 3, 899.95),
('offline', 6, 8, 299.94),
('online', 7, 4, 699.93),
('offline', 8, 9, 199.92),
('online', 9, 5, 399.91),
('offline', 10, 10, 599.90),
('online', 11, 1, 799.89),
('offline', 12, 6, 999.88),
('online', 13, 2, 1199.87),
('offline', 14, 7, 1399.86),
('online', 15, 3, 1599.85),
('offline', 16, 8, 1799.84),
('online', 17, 4, 1999.83),
('offline', 18, 9, 2199.82),
('online', 19, 5, 2399.81),
('offline', 20, 10, 2599.80);

-- Order Line Items
INSERT INTO order_line_items (transaction_id, product_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 999.99, 999.99),
(1, 5, 1, 29.99, 29.99),
(2, 2, 1, 699.99, 699.99),
(3, 3, 1, 399.99, 399.99),
(4, 4, 1, 99.99, 99.99),
(5, 6, 1, 59.99, 59.99),
(6, 7, 1, 299.99, 299.99),
(7, 8, 1, 199.99, 199.99),
(8, 9, 1, 149.99, 149.99),
(9, 10, 1, 79.99, 79.99),
(10, 11, 1, 89.99, 89.99),
(11, 12, 1, 19.99, 19.99),
(12, 13, 1, 49.99, 49.99),
(13, 14, 1, 129.99, 129.99),
(14, 15, 1, 69.99, 69.99),
(15, 16, 1, 499.99, 499.99),
(16, 17, 1, 89.99, 89.99),
(17, 18, 1, 79.99, 79.99),
(18, 19, 1, 19.99, 19.99),
(19, 20, 1, 199.99, 199.99);

-- Order Fulfillments
INSERT INTO order_fulfillments (transaction_id, fulfillment_status, fulfillment_date) VALUES
(1, 'fulfilled', '2024-01-01 14:30:00'),
(2, 'fulfilled', '2024-01-02 15:30:00'),
(3, 'fulfilled', '2024-01-03 16:30:00'),
(4, 'fulfilled', '2024-01-04 17:30:00'),
(5, 'partially_fulfilled', '2024-01-05 18:30:00'),
(6, 'partially_fulfilled', '2024-01-06 19:30:00'),
(7, 'partially_fulfilled', '2024-01-07 20:30:00'),
(8, 'unfulfilled', NULL),
(9, 'unfulfilled', NULL),
(10, 'unfulfilled', NULL),
(11, 'fulfilled', '2024-01-11 14:30:00'),
(12, 'fulfilled', '2024-01-12 15:30:00'),
(13, 'fulfilled', '2024-01-13 16:30:00'),
(14, 'fulfilled', '2024-01-14 17:30:00'),
(15, 'partially_fulfilled', '2024-01-15 18:30:00'),
(16, 'partially_fulfilled', '2024-01-16 19:30:00'),
(17, 'partially_fulfilled', '2024-01-17 20:30:00'),
(18, 'unfulfilled', NULL),
(19, 'unfulfilled', NULL),
(20, 'unfulfilled', NULL);

-- Order Payments
INSERT INTO order_payments (transaction_id, payment_method_id, amount, status, paid_at) VALUES
(1, 1, 1299.98, 'paid', '2024-01-01 14:00:00'),
(2, 4, 799.98, 'paid', '2024-01-02 15:00:00'),
(3, 2, 599.97, 'paid', '2024-01-03 16:00:00'),
(4, 4, 449.96, 'paid', '2024-01-04 17:00:00'),
(5, 3, 899.95, 'partially_paid', '2024-01-05 18:00:00'),
(6, 4, 299.94, 'partially_paid', '2024-01-06 19:00:00'),
(7, 1, 699.93, 'partially_paid', '2024-01-07 20:00:00'),
(8, 4, 199.92, 'unpaid', NULL),
(9, 2, 399.91, 'unpaid', NULL),
(10, 4, 599.90, 'unpaid', NULL),
(11, 1, 799.89, 'paid', '2024-01-11 14:00:00'),
(12, 4, 999.88, 'paid', '2024-01-12 15:00:00'),
(13, 2, 1199.87, 'paid', '2024-01-13 16:00:00'),
(14, 4, 1399.86, 'paid', '2024-01-14 17:00:00'),
(15, 3, 1599.85, 'partially_paid', '2024-01-15 18:00:00'),
(16, 4, 1799.84, 'partially_paid', '2024-01-16 19:00:00'),
(17, 1, 1999.83, 'partially_paid', '2024-01-17 20:00:00'),
(18, 4, 2199.82, 'unpaid', NULL),
(19, 2, 2399.81, 'unpaid', NULL),
(20, 4, 2599.80, 'unpaid', NULL);

-- Order Shippings
INSERT INTO order_shippings (transaction_id, shipping_method_id, shipping_date, estimation_arrival, tracking_number, line_1, line_2, city, state, postal_code, country) VALUES
(1, 1, '2024-01-01', '2024-01-05', 'TRK001', '123 Ship St', 'Apt 1', 'New York', 'NY', '10001', 'USA'),
(2, 2, '2024-01-02', '2024-01-04', 'TRK002', '456 Delivery Ave', NULL, 'Los Angeles', 'CA', '90001', 'USA'),
(3, 3, '2024-01-03', '2024-01-04', 'TRK003', '789 Post Rd', 'Suite 3', 'Chicago', 'IL', '60601', 'USA'),
(4, 1, '2024-01-04', '2024-01-08', 'TRK004', '321 Mail St', NULL, 'Houston', 'TX', '77001', 'USA'),
(5, 2, '2024-01-05', '2024-01-07', 'TRK005', '654 Courier Dr', 'Unit 5', 'Phoenix', 'AZ', '85001', 'USA'),
(6, 3, '2024-01-06', '2024-01-07', 'TRK006', '987 Express Ln', NULL, 'Philadelphia', 'PA', '19101', 'USA'),
(7, 1, '2024-01-07', '2024-01-11', 'TRK007', '147 Package Rd', 'Apt 7', 'San Antonio', 'TX', '78201', 'USA'),
(8, 2, '2024-01-08', '2024-01-10', 'TRK008', '258 Postal Ave', NULL, 'San Diego', 'CA', '92101', 'USA'),
(9, 3, '2024-01-09', '2024-01-10', 'TRK009', '369 Delivery St', 'Suite 9', 'Dallas', 'TX', '75201', 'USA'),
(10, 1, '2024-01-10', '2024-01-14', 'TRK010', '741 Shipping Rd', NULL, 'San Jose', 'CA', '95101', 'USA'),
(11, 2, '2024-01-11', '2024-01-13', 'TRK011', '852 Mail Dr', 'Unit 11', 'Austin', 'TX', '78701', 'USA'),
(12, 3, '2024-01-12', '2024-01-13', 'TRK012', '963 Post Ln', NULL, 'Jacksonville', 'FL', '32201', 'USA'),
(13, 1, '2024-01-13', '2024-01-17', 'TRK013', '159 Express Rd', 'Apt 13', 'San Francisco', 'CA', '94101', 'USA'),
(14, 2, '2024-01-14', '2024-01-16', 'TRK014', '753 Courier Ave', NULL, 'Indianapolis', 'IN', '46201', 'USA'),
(15, 3, '2024-01-15', '2024-01-16', 'TRK015', '951 Package St', 'Suite 15', 'Columbus', 'OH', '43201', 'USA'),
(16, 1, '2024-01-16', '2024-01-20', 'TRK016', '357 Postal Rd', NULL, 'Fort Worth', 'TX', '76101', 'USA'),
(17, 2, '2024-01-17', '2024-01-19', 'TRK017', '486 Delivery Dr', 'Unit 17', 'Charlotte', 'NC', '28201', 'USA'),
(18, 3, '2024-01-18', '2024-01-19', 'TRK018', '159 Ship Ln', NULL, 'Detroit', 'MI', '48201', 'USA'),
(19, 1, '2024-01-19', '2024-01-23', 'TRK019', '753 Mail Rd', 'Apt 19', 'El Paso', 'TX', '79901', 'USA'),
(20, 2, '2024-01-20', '2024-01-22', 'TRK020', '951 Express Ave', NULL, 'Seattle', 'WA', '98101', 'USA');

-- Product Warehouse Stocks
INSERT INTO product_warehouse_stocks (warehouse_id, product_id, stock) VALUES
(1, 1, 50), (1, 2, 100), (1, 3, 75), (1, 4, 200),
(2, 5, 150), (2, 6, 100), (2, 7, 40), (2, 8, 30),
(3, 9, 25), (3, 10, 60), (3, 11, 80), (3, 12, 300),
(4, 13, 90), (4, 14, 70), (4, 15, 45), (4, 16, 20),
(5, 17, 150), (5, 18, 40), (5, 19, 200), (5, 20, 30);

-- Product Shelf Stocks
INSERT INTO product_shelf_stocks (shelf_id, product_id, stock) VALUES
(1, 1, 10), (1, 2, 20), (1, 3, 15), (1, 4, 40),
(2, 5, 30), (2, 6, 20), (2, 7, 8), (2, 8, 6),
(3, 9, 5), (3, 10, 12), (3, 11, 16), (3, 12, 60),
(4, 13, 18), (4, 14, 14), (4, 15, 9), (4, 16, 4),
(5, 17, 30), (5, 18, 8), (5, 19, 40), (5, 20, 6);

-- Inventory Movements
INSERT INTO inventory_movements (product_id, warehouse_id, shelf_id, movement_date, movement_type, quantity, movement_source, reason) VALUES
(1, 1, NULL, '2024-01-01', 'in', 50, 'supplier', 'Initial stock'),
(2, 1, NULL, '2024-01-01', 'in', 100, 'supplier', 'Initial stock'),
(3, 1, NULL, '2024-01-01', 'in', 75, 'supplier', 'Initial stock'),
(4, 1, NULL, '2024-01-01', 'in', 200, 'supplier', 'Initial stock'),
(5, 2, NULL, '2024-01-02', 'in', 150, 'supplier', 'Initial stock'),
(6, 2, NULL, '2024-01-02', 'in', 100, 'supplier', 'Initial stock'),
(7, 2, NULL, '2024-01-02', 'in', 40, 'supplier', 'Initial stock'),
(8, 2, NULL, '2024-01-02', 'in', 30, 'supplier', 'Initial stock'),
(9, 3, NULL, '2024-01-03', 'in', 25, 'supplier', 'Initial stock'),
(10, 3, NULL, '2024-01-03', 'in', 60, 'supplier', 'Initial stock'),
(1, NULL, 1, '2024-01-04', 'out', 5, 'sales', 'Customer purchase'),
(2, NULL, 1, '2024-01-04', 'out', 10, 'sales', 'Customer purchase'),
(3, NULL, 1, '2024-01-04', 'out', 7, 'sales', 'Customer purchase'),
(4, NULL, 1, '2024-01-04', 'out', 20, 'sales', 'Customer purchase'),
(5, NULL, 2, '2024-01-05', 'out', 15, 'sales', 'Customer purchase'),
(6, NULL, 2, '2024-01-05', 'out', 10, 'sales', 'Customer purchase'),
(7, NULL, 2, '2024-01-05', 'out', 4, 'sales', 'Customer purchase'),
(8, NULL, 2, '2024-01-05', 'out', 3, 'sales', 'Customer purchase'),
(9, NULL, 3, '2024-01-06', 'out', 2, 'sales', 'Customer purchase'),
(10, NULL, 3, '2024-01-06', 'out', 6, 'sales', 'Customer purchase');