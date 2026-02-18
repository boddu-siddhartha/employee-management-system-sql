-- Step 1: Create Database --
CREATE DATABASE IF NOT EXISTS employees_db;
USE employees_db;

-- Step 2: Create Tables --
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50));
SELECT * FROM JobDepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE);
SELECT * FROM SalaryBonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT CHECK (age >= 18),
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE);
SELECT * FROM Employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE);
SELECT * FROM Qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE);
SELECT * FROM Leaves;      

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE);
SELECT * FROM Payroll;

-- Analysis Questions
-- 1. EMPLOYEE INSIGHTS
-- 1.1. How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS No_Of_Unique_Employees
FROM Employee;

-- 1.2. Which departments have the highest number of employees?
SELECT j.jobdept AS Department, COUNT(e.emp_ID) AS No_of_Employees
FROM JobDepartment j 
JOIN Employee e ON j.Job_ID = e.Job_ID
GROUP BY j.jobdept
ORDER BY No_of_Employees DESC LIMIT 4;

-- 1.3. What is the average salary per department?
SELECT j.jobdept AS Department, ROUND(AVG(s.amount),2) AS Average_Salary
FROM JobDepartment j 
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept
ORDER BY Average_Salary DESC;

-- 1.4. Who are the top 5 highest-paid employees? 
SELECT e.emp_ID, CONCAT(e.firstname,' ',e.lastname) AS employee_name, 
SUM(p.total_amount) AS highest_Pay
FROM Employee e
JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, employee_name
ORDER BY Highest_Pay DESC LIMIT 5;

-- 1.5. What is the total salary expenditure across the company?
SELECT SUM(total_amount) AS Total_Salary_Expenditure
FROM Payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- 2.1. How many different job roles exist in each department?
SELECT jobdept AS Department, COUNT(DISTINCT name) AS No_Of_Job_Roles
FROM JobDepartment
GROUP BY jobdept
ORDER BY No_Of_Job_Roles DESC;

-- 2.2. What is the average salary range per department?
SELECT jobdept AS Department, ROUND(AVG(s.annual),2) AS Avg_Salary
FROM JobDepartment j
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept
ORDER BY Avg_Salary DESC;

-- 2.3. Which job roles offer the highest salary?
SELECT j.name AS Job_Role, j.jobdept AS Department ,s.annual AS Annual_Salary
FROM JobDepartment j
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
ORDER BY s.amount DESC LIMIT 4;

-- 2.4. Which departments have the highest total salary allocation?
SELECT j.jobdept AS Department, SUM(s.annual) AS Total_Salary_Allocation
FROM JobDepartment j
JOIN salarybonus s ON j.job_ID = s.job_ID
GROUP BY j.jobdept
ORDER BY Total_Salary_Allocation DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- 3.1. How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS Employees_with_Qualification
FROM Qualification;

-- 3.2. Which positions require the most qualifications?
SELECT Position, COUNT(QualID) AS No_of_Qualification
FROM Qualification
GROUP BY Position;

-- 3.3. Which employees have the highest number of qualifications?
SELECT e.emp_ID, CONCAT(e.firstname,' ',e.lastname) AS employee_name,
COUNT(q.QualID) AS Qualifications FROM employee e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID
ORDER BY COUNT(q.QualID) DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
-- 4.1. Which year had the most employees taking leaves?
SELECT YEAR(date) AS Year, COUNT(*) AS No_Of_Leaves
FROM Leaves
GROUP BY YEAR(date)
ORDER BY No_Of_Leaves DESC;

-- 4.2. What is the average number of leave days taken by its employees per department?
SELECT j.jobdept AS Department, 
ROUND(COUNT(l.leave_ID) * 1.0 / COUNT(DISTINCT e.emp_ID), 0) AS Avg_Leaves
FROM JobDepartment j
JOIN Employee e ON j.Job_ID = e.Job_ID
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY j.jobdept;

-- 4.3. Which employees have taken the most leaves?
SELECT e.emp_ID, CONCAT(e.firstname,' ',e.lastname) AS employee_name,
COUNT(l.leave_ID) AS no_of_leaves
FROM Employee e 
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY emp_ID, employee_name
ORDER BY no_of_leaves DESC;

-- 4.4. What is the total number of leave days taken company-wide?
SELECT COUNT(leave_ID) AS Total_Company_Leaves
FROM Leaves;

-- 4.5. How do leave days correlate with payroll amounts?
SELECT e.emp_ID, CONCAT(e.firstname,' ',e.lastname) AS employee_name,
COUNT(l.leave_ID) AS leave_days, SUM(p.total_amount) AS total_pay
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, employee_name;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- 5.1. What is the total monthly payroll processed?
SELECT YEAR(date) AS Year, MONTH(date) AS Month, 
SUM(total_amount) AS Total_Monthly_Payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY Year, Month;

-- 5.2. What is the average bonus given per department?
SELECT j.jobdept AS Department,ROUND( AVG(s.bonus),2) AS Avg_Bonus
FROM JobDepartment j
JOIN Payroll p ON j.job_ID = p.job_ID
JOIN SalaryBonus s ON p.salary_ID = s.salary_ID
GROUP BY j.jobdept
ORDER BY Avg_Bonus DESC;

-- 5.3. Which department receives the highest total bonuses?
SELECT j.jobdept AS Department, SUM(s.bonus) AS Highest_Bonus
FROM JobDepartment j
JOIN Payroll p ON j.job_ID = p.job_ID
JOIN SalaryBonus s ON p.salary_ID = s.salary_ID
GROUP BY j.jobdept
ORDER BY Highest_Bonus DESC;

-- 5.4. What is the average value of total_amount after considering leave deductions?
SELECT ROUND(AVG(total_amount),2) AS Total_Avg_Value
FROM Payroll;
