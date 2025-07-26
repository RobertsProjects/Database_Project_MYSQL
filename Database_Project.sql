
-- Create the Employee Table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    birth_day DATE,
    sex VARCHAR(1),
    salary INT,
    super_id INT,
    branch_id INT
);
    
-- Insert the first employee record
INSERT INTO employee VALUES(100, 'David' , 'Wallace' , '1967-11-17' , 'M' , 250000, NULL, NULL);

-- Asssign branch 1 to employee
UPDATE employee
SET branch_id = 1
Where emp_id = 100;

-- Insert more employee to populate table
insert into EMPLOYEE values(101, 'Jan', 'Levinson', '1961-05-11','F',110000,100,1);
INSERT INTO employee VALUES(102,'DAVID' , 'Scott' , '1964-03-15' , 'M' ,75000, 100, NULL);
INSERT INTO employee VALUES(103, 'Angela' , 'Martin' , '1971-06-25' , 'F' , 63000 , 102,2);
INSERT INTO employee VALUES(104, 'Kelly' , 'Kapoor' , '1980-02-05' , 'F' , 55000 , 102,2);
INSERT INTO employee VALUES(105, 'Stanley' , 'Hudson' , '1958-02-19' , 'M' , 69000 , 102 , 2);
INSERT INTO employee VALUES(106, 'Josh' , 'Porter' , '1969-09-05' , 'M' , 78000 , 100 , NULL);

-- Assign branch 2, and 3
UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;
UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

-- add more employee under branch 3
INSERT INTO employee VALUES(107, 'Andy' , 'Bernard' , '1973-07-22' , 'M' , 65000 , 106 ,3);
INSERT INTO employee VALUES(108, 'Jim' , 'Halpert' , '1978-10-01' , 'M' , 71000 , 106 , 3);

UPDATE employee
SET first_name= 'Michael' WHERE emp_id = 102;

-- Create branch table with foreign keys
CREATE TABLE branch (
	branch_id INT PRIMARY KEY,
	branch_name VARCHAR(40),
	mgr_id INT,
	mgr_start_date DATE,
	FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

-- Insert into branches
INSERT INTO branch VALUES(1, 'Corporate', 100, '2006-02-09');
INSERT INTO branch VALUES(2, 'Scranton' , 102, '1992-04-06');
INSERT INTO branch VALUES(3, 'Stamford' , 106, '1998-02-13');

-- Add foreign keys to employee table
ALTER TABLE employee ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id) ON DELETE SET NULL;
ALTER TABLE employee ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id) ON DELETE SET NULL;

-- Create client table    
CREATE TABLE client (
	client_id INT PRIMARY KEY,
	client_name VARCHAR(40),
	branch_id INT,
	FOREIGN KEY(branch_id) REFERENCES branch (branch_id) ON DELETE SET NULL
);

-- Insert into client table
INSERT INTO client VALUES(400, 'Dunmore Highschool' , 2);
INSERT INTO client VALUES(401, 'Lackawana Country' , 2);
INSERT INTO client VALUES(402, 'FedEx' , 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC' , 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages' , 2);
INSERT INTO client VALUES(405, 'Times Newspaper' , 3);
INSERT INTO client VALUES(406, 'FedEx' , 2);

-- create works_with table    
CREATE TABLE works_with (
	emp_id INT,
	client_id INT,
	total_sales INT,
	PRIMARY KEY(emp_id, client_id),
	FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
	FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

-- Populate works_with table
INSERT INTO works_with VALUES(105, 400, 55000);
INSERT INTO works_with VALUES(102, 401, 267000);
INSERT INTO works_with VALUES(108, 402, 22500);
INSERT INTO works_with VALUES(107, 403, 5000);
INSERT INTO works_with VALUES(108, 403, 12000);
INSERT INTO works_with VALUES(105, 404, 33000);
INSERT INTO works_with VALUES(107, 405, 26000);
INSERT INTO works_with VALUES(102, 406, 15000);
INSERT INTO works_with VALUES(105, 406, 130000);
    
-- Create branch_supplier table
CREATE TABLE branch_supplier (
	branch_id INT,
	supplier_name VARCHAR(40),
	supply_type VARCHAR(40),
	PRIMARY KEY(branch_id, supplier_name),
	FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);

-- Insert suppliers for each branch
INSERT INTO branch_supplier VALUES(2, 'Hammer Mill' , 'Paper');
INSERT INTO branch_supplier VALUES(2, 'Uni-ball' , 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Patriot Paper' , 'Paper');
INSERT INTO branch_supplier VALUES(2, 'J.T. Form & Labels' , 'Custom forms');
INSERT INTO branch_supplier VALUES(3, 'Uni-ball' , 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Hammer Mill' , 'Paper');
INSERT INTO branch_supplier VALUES(3, 'Stamford Lables' , 'Custom forms');

-- Create stored procedure to retrieve total sales by a given employee ID with optional filtering by minimum sales
DELIMITER $$
CREATE PROCEDURE GetEmployeeSales (
    IN emp INT,
    IN min_sales INT
)
BEGIN
    SELECT e.first_name, e.last_name, w.client_id, w.total_sales
    FROM works_with w
    JOIN employee e ON e.emp_id = w.emp_id
    WHERE w.emp_id = emp AND w.total_sales >= min_sales;
END $$
DELIMITER ;
CALL GetEmployeeSales(105, 30000);

-- Create view to show each employee with their manager’s name and branch
CREATE VIEW employee_hierarchy AS
SELECT 
    e.emp_id,
    e.first_name AS employee_first,
    e.last_name AS employee_last,
    m.first_name AS manager_first,
    m.last_name AS manager_last,
    b.branch_name
FROM employee e
LEFT JOIN employee m ON e.super_id = m.emp_id
LEFT JOIN branch b ON e.branch_id = b.branch_id;
SELECT * FROM employee_hierarchy;

-- Create index to improve performance
CREATE INDEX idx_total_sales ON works_with(total_sales);
CREATE INDEX idx_client_name ON client(client_name);
CREATE INDEX idx_branch_name ON branch(branch_name);

-- create table to log trigger
CREATE TABLE trigger_test (
	message VARCHAR(100)
);
-- Create trigger to log message before inserting new employee
DELIMITER $$
CREATE
	TRIGGER my_trigger1 BEFORE INSERT
    ON employee FOR EACH ROW BEGIN INSERT INTO
    trigger_test VALUES('added new employee');
    END$$
DELIMITER ;
-- Insert employees to test trigger behavior
INSERT INTO employee
VALUES(109, 'Oscar' , 'Martinez' , '1968-02-19' , 'M' , 69000, 106, 3);
INSERT INTO employee VALUES(111, 'Pam' , 'Beesly' , '1988-02-19' , 'F' , 69000, 106, 3);
INSERT INTO employee VALUES(110, 'Kevin' , 'Malone' , '1978-02-19' , 'M' ,69000, 106, 3);
-- View trigger logs
SELECT * FROM trigger_test;

-- Analyse dataset, the query returns the top 3 employees by total sales per branch
SELECT *
FROM (
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        b.branch_name,
        SUM(w.total_sales) AS total_sales,
        RANK() OVER (PARTITION BY b.branch_id ORDER BY SUM(w.total_sales) DESC) AS sales_rank
    FROM employee e
    JOIN branch b ON e.branch_id = b.branch_id
    JOIN works_with w ON e.emp_id = w.emp_id
    GROUP BY e.emp_id, b.branch_id
) ranked_sales
WHERE sales_rank <= 3;

-- The query compare their salary to the average salary of employees in the same branch
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.branch_id,
    (
        SELECT AVG(e2.salary)
        FROM employee e2
        WHERE e2.branch_id = e.branch_id
    ) AS avg_branch_salary
FROM employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employee e2
    WHERE e2.branch_id = e.branch_id
);


-- Check for duplicates
SELECT first_name, last_name, birth_day, COUNT(*) AS count
FROM employee
GROUP BY first_name, last_name, birth_day
HAVING COUNT(*) > 1;

-- Check missing values
SELECT * 
FROM employee
WHERE branch_id IS NULL OR super_id IS NULL;

SELECT COUNT(*) AS null_clients
FROM client
WHERE client_name IS NULL OR branch_id IS NULL;

-- Check clients with non-existent branches
SELECT c.*
FROM client c
LEFT JOIN branch b ON c.branch_id = b.branch_id
WHERE b.branch_id IS NULL;

-- More queries to the datase
SELECT employee.emp_id, employee.first_name, branch.branch_name
FROM employee LEFT JOIN branch ON employee.emp_id = branch.mgr_id;

SELECT employee.first_name, employee.last_name FROM employee
WHERE employee.emp_id IN (
SELECT works_with.emp_id FROM works_with WHERE works_with.total_sales > 30000
);

SELECT client.client_name FROM client WHERE client.branch_id = (
SELECT branch.branch_id FROM branch WHERE branch.mgr_id = 102 LIMIT 1
);

SELECT SUM(total_sales), emp_id FROM works_with GROUP BY emp_id;
SELECT SUM(total_sales), client_id FROM works_with GROUP BY client_id;
SELECT * FROM client WHERE client_name LIKE '%LLC';
SELECT * FROM branch_supplier WHERE supplier_name LIKE '%label%';
SELECT * FROM employee WHERE birth_day LIKE '____-10%';
SELECT * FROM client WHERE client_name LIKE '%school%';







