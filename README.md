## 1. Project Overview
This project is an end-to-end Business Intelligence solution built to analyze a bank’s loan portfolio.  
The report helps understand loan demand, funding performance, repayment behavior, and credit risk across time, geography, and borrower segments.  
The dashboard is designed for **bank managers, risk teams, and business analysts** to support data-driven lending and portfolio decisions.

## 2. Business Problem / Objective

Banks manage thousands of loans across different borrower profiles, regions, and risk categories.  
Without proper analysis, it becomes difficult to answer questions such as:
- How many loans are performing well vs defaulting?
- How much money is funded vs actually received?
- Which regions, purposes, or borrower profiles carry higher risk?
- How is loan demand changing month over month?

### Objective of this Report:
- Monitor overall loan portfolio performance
- Track Month-to-Date (MTD) and Month-over-Month (MoM) trends
- Identify **Good Loans vs Bad Loans**
- Analyze lending behavior by geography, loan purpose, employment length, and home ownership
- Provide both **high-level insights** and **row-level drill-down**


## 3. Dataset Description & Data Dictionary

### Dataset Source
- File: `financial_loan.csv`
- Records: ~38,000 loan applications (24 Columns & 38576 Rows)
- Type: Structured transactional loan data

### Key Columns Used

| Column Name | Description |
|-----------|-------------|
| id | Unique identifier for each loan |
| issue_date | Loan origination date |
| loan_amount | Total funded loan amount |
| total_payment | Total amount received from borrower |
| loan_status | Current status of loan (Fully Paid, Current, Charged Off) |
| int_rate | Interest rate of the loan |
| dti | Debt-to-Income ratio of borrower |
| emp_length | Employment length of borrower |
| purpose | Loan purpose (debt consolidation, credit card, etc.) |
| home_ownership | RENT / OWN / MORTGAGE |
| address_state | Borrower’s state |

A detailed **Data Dictionary** is provided in:
- `Data Dictionary.xlsx`
- `Descriptive Data Dictionary.docx`


## 4. Data Cleaning & Transformation (Power Query)

The following transformations were applied in Power BI:

- Removed null and duplicate records
- Standardized loan status values
- Converted date columns to proper Date format
- Created Year and Month fields for time analysis
- Added calculated column:
  - **Good Vs Bad Loan**
    - Good Loan → Fully Paid, Current
    - Bad Loan → Charged Off

These steps ensured clean, consistent, and analysis-ready data.


## 5. Data Model

### Model Design
- **Single Fact Table:** `bank_loan_data`
- **Date Dimension Table:** `Date Table`

### Date Table – Additional Calculated Columns

To enable proper time-based analysis and correct month ordering in visuals, additional calculated columns were created in the Date Table.


#### Date Table
```DAX
Date Table = 
CALENDAR(
    MIN(bank_loan_data[issue_date]),
    MAX(bank_loan_data[issue_date])
)
```

#### Month
```DAX
Month = FORMAT('Date Table'[Date], "mmm")
```

- Displays month names in a readable format (Jan, Feb, Mar, etc.)
- Used in charts and slicers for better readability

#### Month_Number
```DAX
Month_Number = MONTH('Date Table'[Date])
```

- Stores numeric month values (1–12)
- Used to sort the Month column correctly in chronological order
- Prevents incorrect alphabetical sorting of months in visuals


### Relationships

- **One-to-Many relationship**
- `Date Table[Date]` → `bank_loan_data[issue_date]`

This relationship enables accurate time-based analysis such as:
- Month-to-Date (MTD)
- Previous Month-to-Date (PMTD)
- Month-over-Month (MoM) trends


## 6. Key KPIs & Metrics

The following key performance indicators were developed to evaluate loan portfolio performance:

- Total Loan Applications
- Total Funded Amount
- Total Amount Received
- Average Interest Rate
- Average Debt-to-Income Ratio (DTI)
- Good Loan Percentage
- Bad Loan Percentage
- Month-to-Date (MTD) and Month-over-Month (MoM) metrics for funding and recovery


## 7. Important DAX Measures

### Good vs Bad Loan Metrics

```DAX
Good Loan % =
CALCULATE(
    [Total Loan Applications],
    bank_loan_data[Good Vs Bad Loan] = "Good Loan"
) / [Total Loan Applications]
```

```DAX
Bad Loan % =
CALCULATE(
    [Total Loan Applications],
    bank_loan_data[Good Vs Bad Loan] = "Bad Loan"
) / [Total Loan Applications]
```

```DAX
Good Loan Funded Amount =
CALCULATE(
    [Total Funded Amount],
    bank_loan_data[Good Vs Bad Loan] = "Good Loan"
)
```

```DAX
Bad Loan Received Amount =
CALCULATE(
    [Total Amount Received],
    bank_loan_data[Good Vs Bad Loan] = "Bad Loan"
)
```

### Time Intelligence (MTD & MoM)

```DAX
MTD Total Amount Received =
CALCULATE(
    TOTALMTD(
        [Total Amount Received],
        'Date Table'[Date]
    )
)
```

```DAX
PMTD Total Amount Received =
CALCULATE(
    [Total Amount Received],
    DATESMTD(
        DATEADD('Date Table'[Date], -1, MONTH)
    )
)
```

```DAX
MoM Total Amount Received =
([MTD Total Amount Received] - [PMTD Total Amount Received])
/ [PMTD Total Amount Received]
```

### Dynamic Measure Selection (Field Parameter)

```DAX
Select Measure = {
    ("Total Amount Received", NAMEOF('bank_loan_data'[Total Amount Received]), 0),
    ("Total Funded Amount", NAMEOF('bank_loan_data'[Total Funded Amount]), 1),
    ("Total Loan Applications", NAMEOF('bank_loan_data'[Total Loan Applications]), 2)
}
```

This parameter allows users to dynamically switch between key metrics in visuals, improving report interactivity and flexibility.


## 8. Report Pages & Visuals

### 📌 Page 1: Summary

**Visuals Included:**
- High-level KPIs (Applications, Funding, Recovery, Interest Rate, DTI)
- Month-to-Date (MTD) and Month-over-Month (MoM) comparison
- Good vs Bad Loan Donut Charts
- Loan Status Grid View with key metrics

**Purpose:**  
Quick portfolio health check for management.


### 📌 Page 2: Overview

**Visuals Included:**
- Monthly trend analysis (Line Chart)
- Regional analysis by state (Map)
- Loan distribution by:
  - Term
  - Purpose
  - Employment Length
  - Home Ownership

**Purpose:**  
Identify trends, patterns, and risk concentration across different borrower segments.


### 📌 Page 3: Details

**Visuals Included:**
- Row-level loan table
- Conditional formatting on recovery performance
- Filters for:
  - State
  - Purpose
  - Grade
  - Good vs Bad Loan

**Purpose:**  
Enable deep-dive analysis and detailed validation of individual loan records.


## 9. Insights & Findings

- Majority of loans fall under the **Good Loan** category
- Charged-off loans show higher average interest rates and higher DTI
- Debt consolidation is the most common loan purpose
- Employment length has a clear impact on loan performance
- Certain regions contribute disproportionately to bad loans
- Month-over-Month trends highlight seasonal variation in loan demand

## 10. Conclusion

This project demonstrates a complete Business Intelligence workflow, including:

- Business understanding
- Data preparation and transformation
- SQL-based analysis
- Power BI data modeling
- DAX measures and time intelligence
- Insightful and interactive dashboards

The report can be directly used by banking teams to monitor loan performance, manage credit risk, and support strategic decision-making.
