-- to see all sys databases
select name from sys.databases;

-- lets rename the database but database is having lock, so we need to get exclusive access.
-- firstly lets move out from 'Bank Loan DB' and get into 'master' DB
USE master;
GO

-- set the DB for single user to avoid conflits
ALTER DATABASE [Bank Loan DB]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

-- rename the DB
ALTER DATABASE [Bank Loan DB]
MODIFY NAME = BankLoanDB;

-- set again DB to multiuser
ALTER DATABASE Bank_Loan_DB
SET MULTI_USER;
GO

-- see DBs
select name from sys.databases

-- use respecetd DB
use Bank_Loan_DB;

-- see the main table
select * from bank_loan_data;


-- Total Loan Applications
select count(id) as total_loan_applications 
from bank_loan_data;

-- MTD Total Loan Applications
select count(id) as MTD_total_loan_applications 
from bank_loan_data
where MONTH(issue_date) = 12 and YEAR(issue_date) = 2021;

-- PMTD Total Loan Applications
select count(id) as PMTD_total_loan_applications 
from bank_loan_data
where MONTH(issue_date) = 11 and YEAR(issue_date) = 2021;



-- Total Funded Amount
select sum(loan_amount) as total_funded_amount
from bank_loan_data;

-- MTD Total Funded Amount
select sum(loan_amount) as MTD_total_funded_amount
from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021;

-- PMTD Total Funded Amount
select sum(loan_amount) as PMTD_total_funded_amount
from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021;



-- Total Amount Received
select sum(total_payment) as total_payment_amount
from bank_loan_data;

-- MTD Total Amount Received
select sum(total_payment) as MTD_total_payment_amount
from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021;

-- PMTD Total Amount Received
select sum(total_payment) as PMTD_total_payment_amount
from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021;



-- Average Interest Rate
select round(avg(int_rate)*100, 2) as avg_interest_rate
from bank_loan_data;

-- MTD Average Interest Rate
select round(avg(int_rate)*100, 2) as MTD_avg_interest_rate
from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021;

-- PMTD Average Interest Rate
select round(avg(int_rate)*100, 2) as PMTD_avg_interest_rate
from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021;



-- Average Debt-to-Income Ratio (DTI)
select round(avg(dti)*100, 2) as Avg_DTI
from bank_loan_data;

-- MTD Average Debt-to-Income Ratio (DTI)
select round(avg(dti)*100, 2) as MTD_Avg_DTI
from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021;

-- PMTD Average Debt-to-Income Ratio (DTI)
select round(avg(dti)*100, 2) as PMTD_Avg_DTI
from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021;



-- to calculate the good loan application percentage
SELECT 
    cast(round((
        SELECT COUNT(*) 
        FROM bank_loan_data 
        WHERE loan_status IN ('Fully Paid', 'Current')) * 100.0
    / 
    (SELECT COUNT(*) FROM bank_loan_data), 2) as decimal(4,2)) 
    AS good_loan_percentage;

-- OR

select 
   cast(ROUND( count(case 
        when loan_status in ('Fully Paid', 'Current') then id end) * 100.0
    /
    count(*), 2) as decimal(4,2)) as good_loan_percentage
from bank_loan_data


-- to calculate the good loan application
select COUNT(loan_status) as good_loan_applications
from bank_loan_data
where loan_status in ('Fully Paid', 'Current');


-- to calculate the good loan funded amount
select sum(loan_amount) as good_loan_funded_amount
from bank_loan_data
where loan_status in ('Fully Paid', 'Current');


-- to calculate the good loan total received amount
select sum(total_payment) as good_loan_received_amount
from bank_loan_data
where loan_status in ('Fully Paid', 'Current');
 


-- to calculate the bad loan application percentage
select 
    cast(round((select COUNT(*) from bank_loan_data
        where loan_status = 'Charged Off')* 100.0
/
(select COUNT(*) from bank_loan_data), 2) as decimal (4,2))
as bad_loan_percentage;

-- OR

select 
cast(round(COUNT( case when loan_status = 'Charged Off' then id end)* 100.0
/
count(*), 2) as decimal(4,2)) as good_loan_percentage
from bank_loan_data;


-- to calculate the bad loan application
select COUNT(*) as bad_loan_application
from bank_loan_data
where loan_status = 'Charged Off';


-- to calculate the bad loan funded amount
select sum(loan_amount) AS bad_loan_funded_amount
from bank_loan_data
where loan_status = 'Charged Off';


-- to calculate the bad loan total received amount
select sum(total_payment) AS bad_loan_funded_amount
from bank_loan_data
where loan_status = 'Charged Off';


-- Loan Status Grid View
select loan_status,
COUNT(id)  as Loan_Count,
SUM(total_payment) as Total_Amount_Received,
sum(loan_amount) as Total_Funded_Amount,
round(avg(int_rate*100.0), 2) as Interest_Rate,
round(avg(dti*100.0), 2) as DTI
from bank_loan_data
group by loan_status;

-- MTD_Amount Grid View
select loan_status,
COUNT(id) as Loan_Count,
SUM(loan_amount) as MTD_total_funded_amount,
sum(total_payment) as MTD_total_received_amount
from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021 
group by loan_status;


-- Monthly Trends by Issue Date 
select 
MONTH(issue_date) as Month_Number,
DATENAME(MONTH, issue_date) as Month_Name,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Received_Amount
from bank_loan_data
group by DATENAME(MONTH, issue_date), MONTH(issue_date)
order by MONTH(issue_date) asc


-- Regional Analysis by State 
select 
address_state as Country_State,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Received_Amount
from bank_loan_data
group by address_state 
order by address_state asc


-- Loan Term Analysis 
select 
term as Loan_Term,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Received_Amount
from bank_loan_data
group by term 
order by term asc


-- Employee Length Analysis
select 
emp_length,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Received_Amount
from bank_loan_data
group by emp_length 
order by emp_length asc


-- Loan Purpose Breakdown
select 
purpose,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Received_Amount
from bank_loan_data
group by purpose 
order by Total_Loan_Applications desc


-- Home Ownership Analysis 
select 
home_ownership,
COUNT(id) as Total_Loan_Applications,
SUM(loan_amount) as Total_Funded_Amount,
SUM(total_payment) as Total_Received_Amount
from bank_loan_data
group by home_ownership 
order by Total_Loan_Applications desc


-- KPI Query
SELECT
    COUNT(*) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount,
    ROUND(AVG(int_rate) * 100, 2) AS Avg_Interest_Rate,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI,
    CAST(
        COUNT(CASE WHEN loan_status IN ('Fully Paid','Current') THEN 1 END)
        * 100.0 / COUNT(*) AS DECIMAL(5,2)
    ) AS Good_Loan_Percentage
FROM bank_loan_data;

















