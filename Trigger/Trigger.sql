-- ============================== Trigger ===========================
use LibrarySystem

--================================= trg_UpdateBookAvailability ====================
-- After new loan → set book to unavailable
CREATE TRIGGER trg_UpdateBookAvailability
ON loan
AFTER INSERT
AS
BEGIN

    UPDATE books
    SET avail_status = 1  -- 1 = Unavailable
    FROM books
    JOIN inserted i ON books.book_id = i.book_id;
END;

--======================== trg_CalculateLibraryRevenue  ======================
-- After new payment → update library revenue

--add new column on libraries table 
alter table libraries
add revenue decimal (5,2)

select * from libraries

CREATE TRIGGER trg_CalculateLibraryRevenue
on Payments
AFTER INSERT 
as
begin
	UPDATE lib
    SET revenue = rev.total_amount
    FROM libraries lib
    JOIN (
        SELECT 
            b.library_id,
            SUM(p.amount) AS total_amount
        FROM books b
        JOIN loan l ON b.book_id = l.book_id
        JOIN loan_pay lp ON 
            l.loan_id = lp.loan_id AND
            l.book_id = lp.book_id AND
            l.member_id = lp.member_id
        JOIN Payments p ON p.pay_id = lp.pay_id
        GROUP BY b.library_id
    ) AS rev
    ON lib.library_id = rev.library_id;
END;

--====================== trg_LoanDateValidation ============
-- Prevents invalid return dates on insert 

/*

trg_LoanDateValidation which prevents invalid return dates 
(i.e. return_date must be greater than or equal to loan_date) 
when inserting a new row into the loan table.

*/

CREATE TRIGGER trg_LoanDateValidation
ON loan
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for invalid return dates
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE return_date IS NOT NULL AND return_date < loan_date
    )
    BEGIN
        RAISERROR('Return date cannot be earlier than loan date.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- If the dates are correct, the listing is complete.
    INSERT INTO loan (loan_id, book_id, member_id, loan_date, return_date, status)
    SELECT loan_id, book_id, member_id, loan_date, return_date, status
    FROM inserted;
END;
