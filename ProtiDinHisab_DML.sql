
-- DML: Input Data for Darul Uloom Madrasah

-- Students
INSERT INTO Students (full_name, class_level, guardian_name, phone_number, is_residential, enrollment_date)
VALUES 
('Rahim Uddin', 'Dakhil', 'Karim Uddin', '017xxxxxxxx', TRUE, '2023-01-10'),
('Hasan Ali', 'Maktab', 'Jalal Ali', '018xxxxxxxx', FALSE, '2023-02-15'),
('Nur Islam', 'Ebtedayi', 'Rahmat Islam', '019xxxxxxxx', TRUE, '2023-03-20'),
('Salma Khatun', 'Dakhil', 'Alam Khatun', '017yyyyyyyy', FALSE, '2023-01-01'),
('Rokeya Begum', 'Maktab', 'Fazlul Begum', '016zzzzzzzz', TRUE, '2023-04-12');

-- Student Dues
INSERT INTO StudentDues (student_id, billing_month, amount_due, due_date, amount_paid)
VALUES
(1, '2023-07-01', 2000.00, '2023-07-10', 2000.00),
(2, '2023-07-01', 1800.00, '2023-07-10', 1000.00),
(3, '2023-07-01', 1500.00, '2023-07-10', 0.00),
(4, '2023-07-01', 2000.00, '2023-07-10', 2000.00),
(5, '2023-07-01', 1800.00, '2023-07-10', 1800.00);

-- Fee Payments
INSERT INTO FeePayments (due_id, payment_date, amount_paid, payment_method, transaction_ref)
VALUES
(1, '2023-07-05', 2000.00, 'bKash', 'TX123'),
(2, '2023-07-06', 1000.00, 'Cash', 'TX124'),
(4, '2023-07-07', 2000.00, 'Nagad', 'TX125'),
(5, '2023-07-08', 1800.00, 'bKash', 'TX126');

-- Donors
INSERT INTO Donors (full_name, phone_number, email, address)
VALUES
('Mohammad Ali', '01711111111', 'ali@example.com', 'Dhaka'),
('Fatema Begum', '01822222222', 'fatema@example.com', 'Chittagong');

-- Donations
INSERT INTO Donations (donor_id, amount, donation_type, purpose_tag, donation_date, transaction_ref)
VALUES
(1, 5000.00, 'Zakat', 'Orphan Support', '2023-06-15', 'DNTX001'),
(2, 3000.00, 'Lillah', 'Library', '2023-06-18', 'DNTX002');

-- Expenses
INSERT INTO Expenses (expense_name, category, amount_spent, funded_by, source_id, expense_date, approved_by, remarks)
VALUES
('Library Books', 'Education', 2500.00, 'Donation', 2, '2023-07-01', 'Principal', 'Books for students'),
('Electric Bill', 'Utility', 1500.00, 'Fee', NULL, '2023-07-03', 'Accountant', 'Monthly bill');

-- Staff
INSERT INTO Staff (full_name, position, salary, bank_account, join_date, status)
VALUES
('Abdul Karim', 'Teacher', 12000.00, '1234567890', '2020-01-01', 'Active'),
('Rokibul Hasan', 'Accountant', 15000.00, '9876543210', '2019-06-01', 'Active');





-- =============================================
-- SOLUTIONS TO CASE STUDY PROBLEMS USING SQL
-- =============================================

-- 1. Increasing Fee Collection Rate
-- Show all students with unpaid or partial dues

SELECT s.full_name, d.billing_month, d.amount_due, d.amount_paid,
       CASE 
           WHEN d.amount_paid >= d.amount_due THEN 'Paid'
           WHEN d.amount_paid > 0 THEN 'Partially Paid'
           ELSE 'Unpaid'
       END AS PaymentStatus
FROM Students s
JOIN StudentDues d ON s.student_id = d.student_id
WHERE d.status IN ('Unpaid', 'Partially Paid');
GO

-- 2. Boosting Annual Donations
-- ===================Rank top donors by total donation amount

SELECT d.full_name, SUM(n.amount) AS total_donated,
       RANK() OVER (ORDER BY SUM(n.amount) DESC) AS donor_rank
FROM Donors d
JOIN Donations n ON d.donor_id = n.donor_id
GROUP BY d.full_name;
GO

-- 3. Real-Time Report Generation
-- ====================View: Monthly donation summary

CREATE VIEW vw_MonthlyDonationSummary AS
SELECT FORMAT(donation_date, 'yyyy-MM') AS Month,
       SUM(amount) AS TotalAmount
FROM Donations
GROUP BY FORMAT(donation_date, 'yyyy-MM');
GO

-- 4. Eliminating Salary Disputes
-- ================Show staff salaries with status

SELECT full_name, salary,
       CASE 
           WHEN status = 'Active' THEN 'Eligible'
           ELSE 'Inactive'
       END AS PaymentEligibility
FROM Staff;
GO

-- 5. Enhancing Donor Transparency
-- ==================View donor info with optional email fallback

SELECT full_name, 
       COALESCE(email, 'no-email@provided.com') AS ContactEmail,
       amount, donation_date
FROM Donors d
JOIN Donations n ON d.donor_id = n.donor_id;
GO

-- 6. Budgeting & Expense Controls
-- =====================Compare monthly expense totals per category

SELECT FORMAT(expense_date, 'yyyy-MM') AS Month, category,
       SUM(amount_spent) AS TotalSpent
FROM Expenses
GROUP BY FORMAT(expense_date, 'yyyy-MM'), category;
GO

-- 7. Risk Management from Manual Cash
-- =======================View recent mobile/cash transactions

SELECT * FROM FeePayments
WHERE payment_method IN ('Mobile', 'Cash') 
  AND payment_date >= DATEADD(MONTH, -1, GETDATE());
GO

-- 8. Full Digital System
-- ==================Check all critical data tables with record counts

SELECT 'Students' AS TableName, COUNT(*) AS RecordCount FROM Students
UNION ALL
SELECT 'StudentDues', COUNT(*) FROM StudentDues
UNION ALL
SELECT 'FeePayments', COUNT(*) FROM FeePayments
UNION ALL
SELECT 'Donors', COUNT(*) FROM Donors
UNION ALL
SELECT 'Donations', COUNT(*) FROM Donations
UNION ALL
SELECT 'Expenses', COUNT(*) FROM Expenses
UNION ALL
SELECT 'Staff', COUNT(*) FROM Staff;
GO




-- =============================================
-- 1. SELECT: List all students
-- =============================================
SELECT * FROM Students;
GO

-- =============================================
-- 2. SELECT Specific Columns
-- =============================================
SELECT full_name, class_level, phone_number FROM Students;
GO

-- =============================================
-- 3. WHERE Clause: Get residential students
-- =============================================
SELECT * FROM Students WHERE is_residential = 1;
GO

-- =============================================
-- 4. ORDER BY: Recent enrollments
-- =============================================
SELECT * FROM Students ORDER BY enrollment_date DESC;
GO

-- =============================================
-- 5. GROUP BY with Aggregation: Student count per class
-- =============================================
SELECT class_level, COUNT(*) AS total_students FROM Students GROUP BY class_level;
GO

-- =============================================
-- 6. HAVING: Classes with more than 1 student
-- =============================================
SELECT class_level, COUNT(*) AS student_count FROM Students GROUP BY class_level HAVING COUNT(*) > 1;
GO

-- =============================================
-- 7. INNER JOIN: Students with dues
-- =============================================
SELECT s.full_name, d.amount_due FROM Students s
JOIN StudentDues d ON s.student_id = d.student_id;
GO

-- =============================================
-- 8. LEFT JOIN: Students with or without dues
-- =============================================
SELECT s.full_name, d.amount_due FROM Students s
LEFT JOIN StudentDues d ON s.student_id = d.student_id;
GO

-- =============================================
-- 9. RIGHT JOIN: All dues with student info
-- =============================================
SELECT s.full_name, d.amount_due FROM StudentDues d
RIGHT JOIN Students s ON s.student_id = d.student_id;
GO

-- =============================================
-- 10. FULL OUTER JOIN: All student-dues combinations
-- =============================================
SELECT s.full_name, d.amount_due FROM Students s
FULL OUTER JOIN StudentDues d ON s.student_id = d.student_id;
GO

-- =============================================
-- 11. SCALAR Subquery: Dues per student
-- =============================================
SELECT full_name,
       (SELECT COUNT(*) FROM StudentDues d WHERE d.student_id = s.student_id) AS due_count
FROM Students s;
GO

-- =============================================
-- 12. CORRELATED Subquery: Students with dues
-- =============================================
SELECT full_name FROM Students s
WHERE EXISTS (
    SELECT 1 FROM StudentDues d WHERE d.student_id = s.student_id AND d.amount_due > 0
);
GO

-- =============================================
-- 13. EXISTS: Student has fee payments
-- =============================================
SELECT full_name FROM Students s
WHERE EXISTS (
    SELECT 1 FROM FeePayments p
    WHERE p.due_id IN (SELECT due_id FROM StudentDues WHERE student_id = s.student_id)
);
GO

-- =============================================
-- 14. IN: Specific classes
-- =============================================
SELECT * FROM Students WHERE class_level IN ('Dakhil', 'Ebtedayi');
GO

-- =============================================
-- 15. NOT IN: Exclude Maktab
-- =============================================
SELECT * FROM Students WHERE class_level NOT IN ('Maktab');
GO

-- =============================================
-- 16. BETWEEN: Moderate dues
-- =============================================
SELECT * FROM StudentDues WHERE amount_due BETWEEN 1500 AND 2500;
GO

-- =============================================
-- 17. LIKE: Names starting with R
-- =============================================
SELECT * FROM Students WHERE full_name LIKE 'R%';
GO

-- =============================================
-- 18. IS NOT NULL: Guardian info available
-- =============================================
SELECT * FROM Students WHERE guardian_name IS NOT NULL;
GO

-- =============================================
-- 19. UNION: Combine students and staff names
-- =============================================
SELECT full_name FROM Students
UNION
SELECT full_name FROM Staff;
GO

-- =============================================
-- 20. UNION ALL: All names with duplicates
-- =============================================
SELECT full_name FROM Students
UNION ALL
SELECT full_name FROM Staff;
GO

-- =============================================
-- 21. INTERSECT: Names that are both student and staff
-- =============================================
SELECT full_name FROM Students
INTERSECT
SELECT full_name FROM Staff;
GO

-- =============================================
-- 22. EXCEPT: Students not staff
-- =============================================
SELECT full_name FROM Students
EXCEPT
SELECT full_name FROM Staff;
GO

-- =============================================
-- 23. Simple CASE: Class groupings
-- =============================================
SELECT full_name,
       CASE class_level
           WHEN 'Maktab' THEN 'Beginner'
           WHEN 'Ebtedayi' THEN 'Intermediate'
           ELSE 'Advanced'
       END AS level_group
FROM Students;
GO

-- =============================================
-- 24. Searched CASE: Fee status
-- =============================================
SELECT full_name,
       CASE
           WHEN amount_paid >= amount_due THEN 'Paid'
           WHEN amount_paid > 0 THEN 'Partial'
           ELSE 'Unpaid'
       END AS payment_status
FROM StudentDues;
GO

-- Remaining 25–36 will be appended next...

-- =============================================
-- 25. CASE Function: Categorize donors based on donation amount (e.g., Platinum, Gold)
-- =============================================
SELECT full_name, amount,
       CASE 
           WHEN amount >= 10000 THEN 'Platinum'
           WHEN amount >= 5000 THEN 'Gold'
           WHEN amount >= 1000 THEN 'Silver'
           ELSE 'Supporter'
       END AS DonorLevel
FROM Donations d
JOIN Donors r ON d.donor_id = r.donor_id;
GO

-- =============================================
-- 26. IIF and CHOOSE Functions: Simplify conditional logic and map class_level to names
-- =============================================
SELECT full_name, 
       IIF(amount_paid >= amount_due, 'Paid', 'Due') AS PaymentStatus,
       CHOOSE(class_level, 'Maktab', 'Ebtedayi', 'Dakhil', 'Alim', 'Fazil') AS ClassName
FROM Students s
JOIN StudentDues d ON s.student_id = d.student_id;
GO

-- =============================================
-- 27. COALESCE and ISNULL Functions: Handle null values in donor contacts
-- =============================================
SELECT full_name,
       COALESCE(email, 'unknown@example.com') AS ValidEmail,
       ISNULL(phone_number, 'N/A') AS ValidPhone
FROM Donors;
GO

-- =============================================
-- 28. GROUPING Function: Aggregate donations by type and include a grand total row
-- =============================================
SELECT GROUPING(donation_type) AS IsTotal,
       donation_type, SUM(amount) AS TotalAmount
FROM Donations
GROUP BY GROUPING SETS ((donation_type), ());
GO

-- =============================================
-- 29. Ranking Functions: Rank students based on how much dues they paid
-- =============================================
SELECT full_name, amount_paid,
       ROW_NUMBER() OVER (ORDER BY amount_paid DESC) AS RowNum,
       RANK() OVER (ORDER BY amount_paid DESC) AS RankPos,
       DENSE_RANK() OVER (ORDER BY amount_paid DESC) AS DenseRank,
       NTILE(4) OVER (ORDER BY amount_paid DESC) AS Quartile
FROM StudentDues d
JOIN Students s ON d.student_id = s.student_id;
GO

-- =============================================
-- 30. Analytic Functions: Analyze donation trends with FIRST, LAST, LAG, LEAD, and ranks
-- =============================================
SELECT donor_id, amount, donation_date,
       FIRST_VALUE(amount) OVER (PARTITION BY donor_id ORDER BY donation_date) AS FirstDonation,
       LAST_VALUE(amount) OVER (PARTITION BY donor_id ORDER BY donation_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LastDonation,
       LEAD(amount) OVER (PARTITION BY donor_id ORDER BY donation_date) AS NextDonation,
       LAG(amount) OVER (PARTITION BY donor_id ORDER BY donation_date) AS PrevDonation,
       PERCENT_RANK() OVER (PARTITION BY donor_id ORDER BY amount) AS PercentRank,
       CUME_DIST() OVER (PARTITION BY donor_id ORDER BY amount) AS CumeDist
FROM Donations;
GO

-- =============================================
-- 31. Create InventoryDB: Define database with growth and file size control for inventory
-- =============================================
CREATE DATABASE InventoryDB
ON PRIMARY (
    NAME = InventoryDB_Data_1,
    FILENAME = 'D:\InventoryDB_Data_1.mdf',
    SIZE = 25MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5%
)
LOG ON (
    NAME = InventoryDB_Log_1,
    FILENAME = 'D:\InventoryDB_Log_1.ldf',
    SIZE = 2MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 1MB
);
GO

-- =============================================
-- 32. Stored Procedure for FK Table: Insert/Update/Delete with FK support
-- =============================================
-- See: sp_ManageFeePayment (already created above)
GO

-- =============================================
-- 33. Use Transactions in Procedure: Ensure atomicity in donor or fee payment updates
-- =============================================
-- Already included inside sp_ManageFeePayment (BEGIN TRAN / COMMIT / ROLLBACK)
GO

-- =============================================
-- 34. Encrypted, Schema-Bound View: Secure and lock structure of expense view
-- =============================================
CREATE VIEW vw_ExpenseAudit
WITH SCHEMABINDING, ENCRYPTION
AS
SELECT expense_name, amount_spent, approved_by FROM dbo.Expenses;
GO

-- =============================================
-- 35. UDFs: Define reusable functions for donation and expense analysis
-- =============================================

-- 35.1 Scalar Function
CREATE FUNCTION fn_GetTotalDonations(@DonorId INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);
    SELECT @total = SUM(amount) FROM Donations WHERE donor_id = @DonorId;
    RETURN ISNULL(@total, 0);
END;
GO

-- 35.2 Inline Table-Valued Function
CREATE FUNCTION fn_GetDonationsByDonor(@DonorId INT)
RETURNS TABLE
AS
RETURN (
    SELECT * FROM Donations WHERE donor_id = @DonorId
);
GO

-- 35.3 Multi-Statement Table-Valued Function
CREATE FUNCTION fn_GetRecentExpenses(@DaysBack INT)
RETURNS @Result TABLE (
    expense_name VARCHAR(100),
    amount_spent DECIMAL(10,2),
    expense_date DATE
)
AS
BEGIN
    INSERT INTO @Result
    SELECT expense_name, amount_spent, expense_date
    FROM Expenses
    WHERE expense_date >= DATEADD(DAY, -@DaysBack, GETDATE());
    RETURN;
END;
GO

-- =============================================
-- 36. INSTEAD OF Trigger: Prevent bulk updates/deletes to protect critical student data
-- =============================================
CREATE TRIGGER trg_PreventBulkChange
ON Students
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    IF (SELECT COUNT(*) FROM DELETED) > 1
    BEGIN
        RAISERROR ('Bulk updates/deletes not allowed.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT * FROM INSERTED)
            UPDATE s SET full_name = i.full_name
            FROM Students s
            JOIN INSERTED i ON s.student_id = i.student_id;
        ELSE
            DELETE FROM Students WHERE student_id = (SELECT student_id FROM DELETED);
    END
END;
GO




-- =============================================
-- VIEWS
-- =============================================
-- View: Students with Dues Summary
CREATE VIEW vw_StudentDueStatus AS
SELECT s.full_name, s.class_level, s.phone_number,
       d.billing_month, d.amount_due, d.amount_paid, d.status
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
-- STORED PROCEDURES
-- =============================================
-- Procedure: Get student dues by student_id
CREATE PROCEDURE sp_GetStudentDues
    @studentId INT
AS
BEGIN
    SELECT * FROM StudentDues WHERE student_id = @studentId;
END;
GO

-- Procedure: Insert a new donor and donation
CREATE PROCEDURE sp_AddDonation
    @full_name VARCHAR(100),
    @phone_number VARCHAR(20),
    @email VARCHAR(100),
    @address TEXT,
    @amount DECIMAL(10,2),
    @donation_type VARCHAR(20),
    @purpose_tag VARCHAR(100),
    @donation_date DATE,
    @transaction_ref VARCHAR(100)
AS
BEGIN
    DECLARE @new_donor_id INT;
    INSERT INTO Donors (full_name, phone_number, email, address)
    VALUES (@full_name, @phone_number, @email, @address);
    
    SET @new_donor_id = SCOPE_IDENTITY();
    
    INSERT INTO Donations (donor_id, amount, donation_type, purpose_tag, donation_date, transaction_ref)
    VALUES (@new_donor_id, @amount, @donation_type, @purpose_tag, @donation_date, @transaction_ref);
END;
GO

-- =============================================
-- SCALAR FUNCTION
-- =============================================
-- Function: Get total donation by donor_id
CREATE FUNCTION fn_GetTotalDonation (@donorId INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);
    SELECT @total = SUM(amount) FROM Donations WHERE donor_id = @donorId;
    RETURN ISNULL(@total, 0);
END;
GO

-- =============================================
-- VARIABLE EXAMPLE
-- =============================================
-- Example: Declare and use a variable to get total expense
DECLARE @total_expense DECIMAL(10,2);
SELECT @total_expense = SUM(amount_spent) FROM Expenses;
PRINT 'Total Expense: ' + CAST(@total_expense AS VARCHAR);
GO


-- =============================================
-- TRIGGERS
-- =============================================
-- Trigger: Log expense when a donation is added (for audit simulation)
CREATE TRIGGER trg_LogDonation
ON Donations
AFTER INSERT
AS
BEGIN
    PRINT 'A new donation was recorded. Trigger executed successfully.';
END;
GO

-- =============================================
-- INDEXES
-- =============================================
-- Index: Speed up lookups on Students by phone number
CREATE NONCLUSTERED INDEX idx_Students_PhoneNumber
ON Students (phone_number);
GO

-- =============================================
-- COMMON TABLE EXPRESSIONS (CTE)
-- =============================================
-- CTE: Get top 3 students by total dues paid
WITH CTE_TopStudents AS (
    SELECT s.full_name, SUM(d.amount_paid) AS total_paid,
           RANK() OVER (ORDER BY SUM(d.amount_paid) DESC) AS rank_order
    FROM Students s
    JOIN StudentDues d ON s.student_id = d.student_id
    GROUP BY s.full_name
)
SELECT * FROM CTE_TopStudents WHERE rank_order <= 3;
GO

-- =============================================
-- JOINS
-- =============================================
-- Query: Show donor names with their donation amounts and purposes
SELECT d.full_name, dn.amount, dn.donation_type, dn.purpose_tag
FROM Donors d
JOIN Donations dn ON d.donor_id = dn.donor_id;
GO

-- =============================================
-- ADVANCED FUNCTION
-- =============================================
-- Scalar function: Return donor category based on total amount donated
CREATE FUNCTION fn_DonorCategory (@donorId INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @amount DECIMAL(10,2)
    SELECT @amount = SUM(amount) FROM Donations WHERE donor_id = @donorId

    IF @amount >= 10000
        RETURN 'Platinum'
    ELSE IF @amount >= 5000
        RETURN 'Gold'
    ELSE IF @amount >= 1000
        RETURN 'Silver'
    ELSE
        RETURN 'Supporter'
END;
GO