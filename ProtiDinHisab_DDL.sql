
-- DDL: Database Structure for Darul Uloom Madrasah


----- Creating Database--

-- =============================================
-- 31. Create ProtiDinHisab: Define database with growth and file size control for inventory
-- =============================================

CREATE DATABASE ProtiDinHisab
ON PRIMARY 
(
    NAME = ProtiDinHisab_Data,
    FILENAME = 'D:\\ProtiDinHisab.mdf',
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5%
)
LOG ON
(
    NAME = ProtiDinHisab_Log,
    FILENAME = 'D:\\ProtiDinHisab_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
);
GO

-----Creating Tables------

use ProtiDinHisab;
CREATE TABLE Students (
    student_id INT PRIMARY KEY IDENTITY(1,1),
    full_name VARCHAR(100) NOT NULL,
    class_level VARCHAR(50),
    guardian_name VARCHAR(100),
    phone_number VARCHAR(20),
    is_residential BIT,
    enrollment_date DATE
);

CREATE TABLE StudentDues (
    due_id INT PRIMARY KEY IDENTITY(1001,1),
    student_id INT,
    billing_month DATE,
    amount_due DECIMAL(10, 2),
    due_date DATE,
    amount_paid DECIMAL(10, 2) DEFAULT 0,
    payment_status AS
        CASE 
            WHEN amount_paid >= amount_due THEN 'Paid'
            WHEN amount_paid > 0 THEN 'Partially Paid'
            ELSE 'Unpaid'
         END,

    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

CREATE TABLE FeePayments (
    payment_id INT PRIMARY KEY IDENTITY(2001,1),
    due_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10, 2),
    payment_method VARCHAR(50),
    transaction_ref VARCHAR(100),
    FOREIGN KEY (due_id) REFERENCES StudentDues(due_id)
);

CREATE TABLE Donors (
    donor_id INT PRIMARY KEY IDENTITY(3001,1),
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    [address] VARCHAR(200)
);

CREATE TABLE Donations (
    donation_id INT PRIMARY KEY IDENTITY(5001,1),
    donor_id INT,
    amount DECIMAL(10, 2),
    donation_type VARCHAR(20) CHECK (donation_type IN ('Zakat', 'Sadaqa', 'Lillah', 'Other')),
    purpose_tag VARCHAR(100),
    donation_date DATE,
    transaction_ref VARCHAR(100),
    FOREIGN KEY (donor_id) REFERENCES Donors(donor_id)
);

CREATE TABLE Expenses (
    expense_id INT PRIMARY KEY IDENTITY(6001,1),
    expense_name VARCHAR(100),
    category VARCHAR(50),
    amount_spent DECIMAL(10, 2),
    funded_by VARCHAR(20) CHECK(funded_by IN ('Donation', 'Fee', 'Other')),
    source_id INT,
    expense_date DATE,
    approved_by VARCHAR(100),
    remarks VARCHAR(200)
);

CREATE TABLE Staff (
    staff_id INT PRIMARY KEY IDENTITY(7001,1),
    full_name VARCHAR(100),
    position VARCHAR(50),
    salary DECIMAL(10, 2),
    bank_account VARCHAR(50),
    join_date DATE,
	payment_status VARCHAR(20) CHECK (payment_status IN ('Active', 'Inactive', 'Resigned'))
);

-- =============================================
-- SOLUTIONS TO CASE STUDY PROBLEMS USING SQL
-- =============================================


-- 3. Real-Time Report Generation
-- View: Monthly donation summary
CREATE VIEW vw_MonthlyDonationSummary AS
SELECT CONVERT(CHAR(7), donation_date, 120) AS Month,
       SUM(amount) AS TotalAmount
FROM Donations
GROUP BY CONVERT(CHAR(7), donation_date, 120);
GO

-- =============================================
-- ALTER TABLE
-- =============================================
ALTER TABLE Donors
ADD national_id VARCHAR(20);

-- =============================================
-- DROP COMUMN
-- =============================================
ALTER TABLE Donors
DROP COLUMN national_id;

-- =============================================
-- VIEWS
-- =============================================
-- View: Students with Dues Summary
CREATE VIEW vw_StudentDueStatus AS
SELECT s.full_name, s.class_level, s.phone_number,
       d.billing_month, d.amount_due, d.amount_paid, d.payment_status
FROM Students s
JOIN StudentDues d ON s.student_id = d.student_id;
GO


-- View: Donation Summary by Type
CREATE VIEW vw_DonationSummary AS
SELECT donation_type, COUNT(*) AS donation_count, SUM(amount) AS total_amount
FROM Donations
GROUP BY donation_type;
GO

-- =============================================
-- INDEXES
-- =============================================
-- Index: Speed up lookups on Students by phone number
CREATE NONCLUSTERED INDEX idx_Students_PhoneNumber
ON Students (phone_number);
GO

