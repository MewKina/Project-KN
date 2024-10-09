-- this is to create the database thing for the management
CREATE DATABASE RestaurantManagement;

-- this is to use the database thing
USE RestaurantManagement;

-- customer table creation
CREATE TABLE Customers (
	customer_name VARCHAR(255) PRIMARY KEY,
    phone_number VARCHAR(255)
);

-- table seating thing, im not sure how to word it
CREATE TABLE `Tables` (
	table_number INT PRIMARY KEY,
    number_of_chairs INT,
    status ENUM('occupied', 'not occupied')
);

-- table reservations
CREATE TABLE Reservations (
	reservations_id INT AUTO_INCREMENT PRIMARY KEY,
	customer_name VARCHAR(255),
	customer_contact VARCHAR(255),
	date DATE,
	time TIME,
	number_of_people INT,
	table_number INT,
	FOREIGN KEY (customer_name) REFERENCES Customers(customer_name),
	FOREIGN KEY (table_number) REFERENCES `tables`(table_number)
);

-- table for the employees
CREATE TABLE Employees (
	emp_id INT AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(255),
	last_name VARCHAR(255),
	date_of_birth DATE,
	hire_date DATE,
	position ENUM('manager', 'waiter', 'host', 'janitor', 'chef'),
    type ENUM('part-time', 'full-time')
);

-- table for part-time
CREATE TABLE Part_Time (
	emp_id INT,
	hourly_rate DECIMAL(10,2),
	hours_worked INT,
	FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- table for full-time
CREATE TABLE Full_Time (
	emp_id INT,
	monthly_salary DECIMAL(10,2),
	FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- table for manager
CREATE TABLE Managers (
	emp_id INT,
	department VARCHAR(255),
	years_of_experience INT,
	FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- table for hostess
CREATE TABLE Hosts (
	emp_id INT,
	language_spoken VARCHAR(255),
	FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);
-- table for inventory
CREATE table Inventory (
	ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
	ingredient_name VARCHAR(255),
	expire_date DATE,
	buy_date DATE,
	quantity INT
);

-- table for recipe
CREATE TABLE Recipes (
	recipe_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_id INT,
    ingredient_amount INT,
    FOREIGN KEY (ingredient_id) REFERENCES Inventory(ingredient_id)
    
);
-- table for menu, please run the table for inventory first, i wrote this one first by accident and im too lazy to change it
CREATE TABLE Menu (
	dish_name VARCHAR(255) PRIMARY KEY,
    recipe_id INT,
	category ENUM('appetizer', 'main dish', 'dessert', 'drinks'),
	price DECIMAL(10,2),
	FOREIGN KEY (ingredient_id) REFERENCES Inventory(ingredient_id),
    FOREIGN KEY (ingredient_amount) REFERENCES Recipes(ingredient_amount)
    
);

-- table for orders
CREATE TABLE `Orders` (
	order_id INT AUTO_INCREMENT PRIMARY KEY,
	table_number INT,
	dish_name VARCHAR(255),
	quantity INT,
	FOREIGN KEY (table_number) REFERENCES `Tables`(table_number),
	FOREIGN KEY (dish_name) REFERENCES Menu(dish_name)
);

-- table for billing
CREATE TABLE Billing (
	billing_id INT AUTO_INCREMENT PRIMARY KEY,
	manager_id INT,
	total_price DECIMAL(10,2),
	date DATE,
	type VARCHAR(255),
	FOREIGN KEY (manager_id) REFERENCES Employees(emp_id)
);

-- table for the salaries
CREATE TABLE Salary (
	salary_id INT AUTO_INCREMENT PRIMARY KEY,
	billing_id INT,
	emp_id INT,
	salary DECIMAL(10,2),
	bonus DECIMAL(10,2),
	FOREIGN KEY (billing_id) REFERENCES Billing(billing_id),
	FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- table for stock orders
CREATE TABLE Stock_orders (
	stock_order_id INT AUTO_INCREMENT PRIMARY KEY,
	billing_id INT,
	ingredient_id INT,
	price_per_unit DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (billing_id) REFERENCES Billing(billing_id),
	FOREIGN KEY (ingredient_id) REFERENCES Inventory(ingredient_id)
);

-- table for the reciept
CREATE TABLE Reciepts (
	reciept_id INT AUTO_INCREMENT PRIMARY KEY,
	customer_name VARCHAR(255),
	order_id INT,
	date DATE,
	time TIME,
	dish_name VARCHAR(255),
	order_amount DECIMAL(10,2),
	total_price DECIMAL(10,2),
	tips DECIMAL(10,2),
	discount DECIMAL(10,2),
	final_amount DECIMAL(10,2),
	FOREIGN KEY (customer_name) REFERENCES Customers(customer_name),
	FOREIGN KEY (order_id) REFERENCES `orders`(order_id),
	FOREIGN KEY (dish_name) REFERENCES Menu(dish_name)
);

-- table for monthly income
CREATE TABLE Monthly_income (
	income_id INT AUTO_INCREMENT PRIMARY KEY,
	month INT,
	dish_amount DECIMAL(10,2),
	total_net DECIMAL(10,2),
	total_tip DECIMAL(10,2),
	total_income_per_month DECIMAL(10,2)
    
    
);

    

-- also none of these are loaded yet, ill load them once we have all the customer information and stuff
-- QUERIES

-- get all customers
SELECT * FROM customer;

-- get order for the specific customer
SELECT * FROM `Orders`
WHERE table_number IN (SELECT table_number FROM Reservations WHERE customer_name = 'insert name');

-- get menu items with their price
SELECT dish_name, price FROM Menu;

-- monthly income and balance
SELECT * FROM Monthly_Income;
SELECT * FROM Monthly_Balance;

-- UPDATE QUERIES

-- update a customer's phone number
UPDATE Customers
SET phone_number = 111-222-3333
WHERE customer_name = 'insert name';

-- update the table status
UPDATE `Tables`
SET status = 'occupied'
WHERE table_number = 5;

-- update the price of the menu
UPDATE Menu
SET price = 30
WHERE dish_name = 'insert dish name';

-- DELETE QUERIES

-- delete a customer
DELETE FROM Customers
WHERE customer_name = 'insert name';

-- delete an order
DELETE FROM `orders`
WHERE order_id = 001;

-- delete a menu item
DELETE FROM Menu
WHERE dish_name = 'insert dish name';


-- CREATING VEIWS AND REPORTS

-- customer report
CREATE VIEW Customer_Report AS
SELECT customers.customer_name, customers.phone_number, COUNT(reservations.reservation_id) AS total_reservations, IFNULL(SUM(reservations.number_of_people), 0) AS total_guests
FROM customers
LEFT JOIN Reservations ON customers.customer_name = reservations.customer_name
GROUP BY customers.customer_name;

-- transactions view thing
CREATE VIEW Transaction_report AS
SELECT orders.order_id, reservations.customer_name, orders.table_number, orders.dish_name, reservations.total_price, reservations.final_amount
FROM `orders` JOIN receipt ON orders.order_id = reservations.order_id;

-- income and expense report
-- monthly income report

CREATE VIEW Monthly_income_report AS
SELECT month, total_net, total_tip, total_income_per_month
FROM monthly_income;

-- monthly expense report
CREATE VIEW Monthly_expense_report AS
SELECT month, total_stock, total_salaries, total_expense
FROM Monthly_Expense;

-- reports with queries
-- query for customer report
SELECT * FROM Customer_Report ORDER BY total_guests DESC;

-- query for transaction report
SELECT * FROM Transaction_Report WHERE final_amount > 0 ORDER BY total_price DESC;

-- query for generating income report
SELECT * FROM Monthly_Income_Report WHERE total_income_per_month >0;

-- query for exoense report
SELECT * FROM Monthly_Expense_Report WHERE total_expense >0;


-- table information!!!

-- customer information
INSERT INTO Customers (customer_name, phone_number) VALUES
('John Smith', '555-123-4567'),
('Emily Johnson', '555-234-5678'),
('Michael Brown', '555-345-6789'),
('Jessica Williams', '555-456-7890'),
('David Miller', '555-567-8901'),
('Sarah Davis', '555-678-9012'),
('James Wilson', '555-789-0123'),
('Laura Taylor', '555-890-1234'),
('Daniel Anderson', '555-901-2345'),
('Sophia Martinez', '555-012-3456'),
('Oliver Moore', '555-123-4567'),
('Emma Clark', '555-234-5678'),
('Liam Lewis', '555-345-6789'),
('Isabella Hall', '555-456-7890'),
('Mason Allen', '555-567-8901'),
('Ava Young', '555-678-9012'),
('Lucas Hernandez', '555-789-0123'),
('Mia King', '555-890-1234'),
('Ethan Wright', '555-901-2345'),
('Amelia Scott', '555-012-3456');

-- table information
INSERT INTO `Tables` (table_number, number_of_chairs, status) VALUES
(1, 4, 'not occupied'),
(2, 2, 'not occupied'),
(3, 6, 'not occupied'),
(4, 4, 'occupied'),
(5, 2, 'not occupied'),
(6, 4, 'occupied'),
(7, 6, 'not occupied'),
(8, 4, 'occupied'),
(9, 2, 'not occupied'),
(10, 4, 'occupied'),
(11, 6, 'not occupied'),
(12, 2, 'occupied'),
(13, 4, 'not occupied'),
(14, 6, 'occupied'),
(15, 2, 'occupied'),
(16, 4, 'occupied'),
(17, 6, 'occupied'),
(18, 4, 'occupied'),
(19, 2, 'not occupied'),
(20, 6, 'occupied');

-- reservations inserts

INSERT INTO Reservations (emp_id, customer_name, customer_contact, date, time, number_of_people, table_number) VALUES
('John Smith', '555-123-4567', '2024-10-08 12:00:00', '12:00:00', 4, 1),
('Emily Johnson', '555-234-5678', '2024-10-08 13:00:00', '13:00:00', 2, 2),
('Michael Brown', '555-345-6789', '2024-10-09 14:00:00', '14:00:00', 6, 3),
('Jessica Williams', '555-456-7890', '2024-10-09 15:00:00', '15:00:00', 4, 4),
('David Miller', '555-567-8901', '2024-10-10 16:00:00', '16:00:00', 2, 5),
('Sarah Davis', '555-678-9012', '2024-10-10 17:00:00', '17:00:00', 4, 6),
('James Wilson', '555-789-0123', '2024-10-11 18:00:00', '18:00:00', 6, 7),
('Laura Taylor', '555-890-1234', '2024-10-11 19:00:00', '19:00:00', 4, 8),
('Daniel Anderson', '555-901-2345', '2024-10-12 12:00:00', '12:00:00', 2, 9),
('Sophia Martinez', '555-012-3456', '2024-10-12 13:00:00', '13:00:00', 4, 10),
('Oliver Moore', '555-123-4567', '2024-10-13 14:00:00', '14:00:00', 6, 11),
('Emma Clark', '555-234-5678', '2024-10-13 15:00:00', '15:00:00', 2, 12),
('Liam Lewis', '555-345-6789', '2024-10-14 16:00:00', '16:00:00', 4, 13),
('Isabella Hall', '555-456-7890', '2024-10-14 17:00:00', '17:00:00', 6, 14),
('Mason Allen', '555-567-8901', '2024-10-15 18:00:00', '18:00:00', 2, 15),
('Ava Young', '555-678-9012', '2024-10-15 19:00:00', '19:00:00', 4, 16),
('Lucas Hernandez', '555-789-0123', '2024-10-16 12:00:00', '12:00:00', 6, 17),
('Mia King', '555-890-1234', '2024-10-16 13:00:00', '13:00:00', 4, 18),
('Ethan Wright', '555-901-2345', '2024-10-17 14:00:00', '14:00:00', 2, 19),
('Amelia Scott', '555-012-3456', '2024-10-17 15:00:00', '15:00:00', 6, 20);

-- employees inserts 
INSERT INTO Employees (first_name, last_name, date_of_birth, hire_date, position, type) VALUES
('John', 'Doe', '1980-03-14', '2010-01-05', 'Manager', 'full-time'),
('Emily', 'Smith', '1992-06-23', '2018-05-12', 'Waiter', 'part-time'),
('Michael', 'Brown', '1985-08-19', '2012-07-22', 'Chef', 'full-time'),
('Jessica', 'Johnson', '1995-10-25', '2020-09-15', 'Host', 'part-time'),
('David', 'Miller', '1988-12-31', '2015-11-09', 'Waiter', 'full-time'),
('Sarah', 'Davis', '1991-07-07', '2017-04-05', 'Host', 'part-time'),
('James', 'Wilson', '1983-01-11', '2009-02-16', 'janitor', 'full-time'),
('Laura', 'Taylor', '1990-09-21', '2016-06-19', 'Chef', 'full-time'),
('Daniel', 'Moore', '1984-04-17', '2011-03-11', 'Waiter', 'full-time'),
('Sophia', 'Martinez', '1993-05-30', '2019-08-25', 'janitor', 'part-time'),
('Oliver', 'Anderson', '1987-11-08', '2014-01-28', 'Waiter', 'full-time'),
('Emma', 'Clark', '1994-02-22', '2021-07-14', 'Waiter', 'part-time');



-- part-time inserts 
INSERT INTO Part_Time (emp_id, hourly_rate, hours_worked) VALUES
(2, 40, 12),
(4, 40, 20),
(6, 40, 15),
(10, 40, 18),
(12, 40, 22);


-- full time inserts
INSERT INTO Full_Time (emp_id, monthly_salary) VALUES
(1, 40000),
(3, 35000),
(5, 30000),
(7, 20000),
(8, 35000),
(9, 30000),
(11, 30000);




-- managers
INSERT INTO Managers (emp_id, department, years_of_experience) VALUES
(1, 'General Management', 10);

INSERT INTO Host (emp_id, language_spoken) VALUES
(4, 'Thai'),
(4, 'English'),
(6, 'Thai'),
(6, 'English'),
(6, 'Spanish');

INSERT INTO Inventory (ingredient_name, expire_date, buy_date, quantity) VALUES
('rice noodles', '2024-12-20', '2024-10-01', 100),
('fish sauce', '2024-10-20', '2024-10-01', 100),
('bean sprots', '2024-10-22', '2024-09-20',100),
('egg', '2024-10-28', '2024-10-02', 150),
('tamarind paste', '2024-10-28', '2024-09-28' , 10),
('garlic', '2024-11-10', '2024-10-11', 50),
('lime', '2024-11-05', '2024-10-15', 100),
('rice', '2024-11-15', '2024-10-05', 50),
('cilantro', '2024-11-01', '2024-10-03', 50),
('oil', '2025-05-05', '2024-10-05', 20),
('rice paper', '2024-12-20', '2024-09-01', 50),
('shrimp', '2024-11-10', '2024-10-15', 100),
('lettuce', '2024-10-30', '2024-10-01', 100),
('avocado', '2024-10-30', '2024-10-15', 50),
('coconut milk', '2025-01-30', '2024-10-07', 50),
('mango', '2024-11-10', '2024-10-17', 50),
('sugar', '2025-12-30', '2024-10-02', 50),
('water', '2050-12-30', '2024-01-01', 100);

INSERT INTO Recipes (recipe_id, ingredient_id, ingredient_amount) VALUES
('1', '11' , 1),
('1', '12', 2),
('1', '13', 2),
('1', '14', 1),
('2', '1', 1),
('2', '2', 1),
('2', '3', 1),
('2', '4', 1),
('2', '5', 1),
('2', '6', 2),
('2', '7', 1),
('3', '8', 1),
('3', '4', 1),
('3', '2', 1),
('3', '7', 1),
('4', '7', 1),
('4', '17', 1),
('4', '16', 1),
('5', '8', 1),
('5', '14', 1),
('5', '15', 2),
('5', '16', 2);

INSERT INTO Menu (dish_name, category, price, recipe_id) VALUES
('pad thai', 'main dish', 45, 2),
('spring roll', 'appetizer', 40, 1),
('friedrice', 'main dish', 45 , 3),
('cha manow', 'drinks', 25, 4),
('mango sticky-rice', 30, 5);

INSERT INTO `orders` (table_number, dish_name, quantity) VALUES
('4', 'pad thai', 2),
('4', 'mango stick-rice', 2),
('6', 'friedrice', 4),
('6', 'cha manow', 4),
('10', 'spring roll', 3);

INSERT INTO Billing (emp_id, total_price, salary, bonus) VALUES
(1, 1500.00, 3500.00, 500.00);

INSERT INTO Salary (billing_id, emp_id, salary, bonus) VALUES
(1, 1, 3500.00, 500.00);

INSERT INTO Stock_orders (billing_id, ingredient_id, price_per_unit, quantity) VALUES
(1, 1, 2.50, 20),
(1, 2, 3.00, 10);

INSERT INTO Reciepts (customer_name, order_id, date, time, dish_name, order_amount, total_price, taxes, tips, discount, final_amount) VALUES
('John Doe', 1, '2024-10-08', '12:00:00', 'Pasta', 12.99, 25.98, 2.00, 3.00, 0.00, 30.98);

INSERT INTO Monthly_income (month, dish_amount, total_net, total_tip, total_income_per_month) VALUES
(10, 500.00, 400.00, 50.00, 450.00);

INSERT INTO Monthly_expense (month, total_stock, total_maintenance, total_salaries, total_expense) VALUES
(10, 200.00, 50.00, 1500.00, 1750.00);

INSERT INTO Monthly_Balance (month, total_income, total_expense, balance) VALUES
(10, 450.00, 1750.00, -1300.00);







