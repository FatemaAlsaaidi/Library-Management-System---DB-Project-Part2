-- =================== Stored Procedures ======================
use LibrarySystem

-- ==================== sp_MarkBookUnavailable(BookID) ================
-- Updates availability after issuing 
CREATE PROCEDURE sp_MarkBookUnavailable @BookID int
AS
BEGIN

    UPDATE books
    SET avail_status = 1 -- 1 maen the book is unavailable
    WHERE book_id = @BookID;
END;

EXEC sp_MarkBookUnavailable @BookID = 1;

-- idea : Automatically update a book's status to "Available" when returned in SQL Server

-- ======================== sp_UpdateLoanStatus()=============
-- Checks dates and updates loan statuses 

CREATE PROCEDURE sp_UpdateLoanStatus
    @book_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @loan_id INT;
    DECLARE @return_date DATE;

    -- We get the last loan for this book.
    SELECT TOP 1
        @loan_id = loan_id,
        @return_date = return_date
    FROM loan
    WHERE book_id = @book_id
    ORDER BY loan_date DESC;

    -- If there is a loan
    IF @loan_id IS NOT NULL
    BEGIN
        IF @return_date IS NULL OR @return_date > @today
        BEGIN
            -- The loan is still active.
            UPDATE loan
            SET status = 'issued'
            WHERE loan_id = @loan_id;
        END
        ELSE
        BEGIN
            -- The book has been returned.
            UPDATE loan
            SET status = 'returned'
            WHERE loan_id = @loan_id;
        END
    END
    ELSE
    BEGIN
        PRINT 'No loan found for this book.';
    END
END;


-- drop procedure sp_UpdateLoanStatus
select * from loan 

EXEC sp_UpdateLoanStatus @book_id = 3;

select * from loan 

-- ================================ sp_RankMembersByFines()  ===========================
-- Ranks members by total fines paid


CREATE PROCEDURE sp_RankMembersByFines
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        m.member_id,
        m.F_name + ' ' + m.L_name as FullName ,
        SUM(p.amount) AS total_fines,
        RANK() OVER (ORDER BY SUM(p.amount) DESC) AS fine_rank
    FROM member m
    JOIN loan l ON m.member_id = l.member_id
    JOIN loan_pay lp ON l.loan_id = lp.loan_id
    JOIN payments p ON lp.pay_id = p.pay_id
    GROUP BY m.member_id, m.F_name + ' ' + m.L_name
    ORDER BY total_fines DESC;
END;

EXEC sp_RankMembersByFines;

