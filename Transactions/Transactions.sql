-- ================== Transactions ================ Real-world transactional flows: 
use LibrarySystem

-- ======== 1. Borrowing a book (loan insert + update availability)
select * from loan 
select *from books
ALTER TABLE Loan
ALTER COLUMN due_date DATE NULL

BEGIN TRANSACTION;

BEGIN TRY
    -- 1.inseart new loan
    INSERT INTO loan (loan_id, book_id, member_id, loan_date, due_date, return_date, status)
	VALUES (14, 2, 2, '2025-06-07', '2025-06-20', '2025-06-25', 'issued');
	
	-- EXEC sp_help loan;

    -- 2. update available of book to be unvailable
    UPDATE books
    SET avail_status = 1 
    WHERE book_id = 1;

    COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Display the massege of error
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH;



-- =========== 2. Returning a book (update status, return date, availability)



BEGIN TRANSACTION;

BEGIN TRY
	--1. UPDATE LOAN STATUS , UPDATE RETURN DATA IN LOAN TABLE
	UPDATE loan
	set return_date = CAST(GETDATE() AS DATE)
    WHERE book_id = 1 AND status = 'issued';

	--2 UPDATA THE AVAILABLITY IN BOOKS TABLE 
	UPDATE books
    SET avail_status = 1
    WHERE book_id = 1;
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Display the massege of error
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH;

-- =========== 3. Registering a payment (with validation)
BEGIN TRANSACTION;

BEGIN TRY
    -- Verify that the loan exists
    IF NOT EXISTS (
        SELECT 1 FROM loan
        WHERE loan_id = @loan_id AND book_id = @book_id AND member_id = @member_id
    )
    BEGIN
        RAISERROR('Loan does not exist.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Check of member bank amount
    IF @amount <= 0
    BEGIN
        RAISERROR('Invalid payment amount.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 1. Payments registration
    INSERT INTO Payments (pay_id, amount, pay_date)
    VALUES (@pay_id, @amount, GETDATE());

    -- 2. Link the payment to the loan
    INSERT INTO loan_pay (loan_id, book_id, member_id, pay_id)
    VALUES (@loan_id, @book_id, @member_id, @pay_id);

    COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH;

-- ================= 4. Batch loan insert with rollback on failure 
BEGIN TRANSACTION;

BEGIN TRY
    -- Example batch: inserting multiple loans for different books
    -- Assumes the variables are declared or passed from an external app/script

    -- Insert loan #1
    INSERT INTO loan (loan_id, book_id, member_id, loan_date, return_date, status)
    VALUES (14, 1, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'issued');

    -- Insert loan #2
    INSERT INTO loan (loan_id, book_id, member_id, loan_date, return_date, status)
    VALUES (15, 2, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'issued');

    -- Insert loan #3 (example with potential issue)
    INSERT INTO loan (loan_id, book_id, member_id, loan_date, return_date, status)
    VALUES (16, 9, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'issued'); 
    -- If book_id 9 does not exist → this fails

    -- If all inserts succeed, commit the transaction
    COMMIT TRANSACTION;
    PRINT 'Batch loan insert successful.';

END TRY
BEGIN CATCH
    -- Rollback all inserts if any one fails
    ROLLBACK TRANSACTION;

    -- Print error message
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'Error occurred: ' + @ErrMsg;
    RAISERROR(@ErrMsg, 16, 1);
END CATCH;

