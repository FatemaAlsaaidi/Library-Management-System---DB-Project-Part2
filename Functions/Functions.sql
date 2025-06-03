use LibrarySystem
-- =========================== GetBookAverageRating(BookID) =====================
-- Returns average rating of a book 
-- =========================== GetBookAverageRating(BookID) =====================
-- Returns average rating of a book 

CREATE FUNCTION GetBookAverageRating(@BookID INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @avg_rating DECIMAL(5,2);

    SELECT @avg_rating = AVG(CAST(r.rating AS DECIMAL(5,2)))
    FROM reviews r
    JOIN MemberBookReviews mbr ON r.review_number = mbr.review_number
    WHERE mbr.book_id = @BookID;

    RETURN ISNULL(@avg_rating, 0);
END;


SELECT dbo.GetBookAverageRating(1) AS AverageRating;

-- ========================= GetNextAvailableBook(Genre, Title, LibraryID) ===========================
-- Fetches the next available book 
CREATE FUNCTION GetNextAvailableBook(
    @Genre VARCHAR(50), 
    @Title VARCHAR(100), 
    @LibraryID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @NextAvailableBook INT;

    SELECT TOP 1 @NextAvailableBook = book_id
    FROM books
    WHERE 
        genre = @Genre 
        AND title = @Title 
        AND library_id = @LibraryID 
        AND avail_status = 0
    ORDER BY book_id;

    RETURN ISNULL(@NextAvailableBook, -1); -- -1 to indicate no book found
END;

select * from books

SELECT dbo.GetNextAvailableBook('Reference', 'Desert Tales', 2) AS NextAvailableBook;

-- ====================================== CalculateLibraryOccupancyRate(LibraryID)  =============
-- add new column to library table 
ALTER TABLE libraries
ADD total_capacity INT;
-- Insert values into the new total_capacity column

select * from libraries
select * from loan
UPDATE libraries
SET total_capacity = 1000
WHERE library_id = 1;

UPDATE libraries
SET total_capacity = 500
WHERE library_id = 2;

UPDATE libraries
SET total_capacity = 750
WHERE library_id = 3;


CREATE FUNCTION dbo.CalculateLibraryOccupancyRate(@Library_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @borrowed_books INT;
    DECLARE @capacity INT;
    DECLARE @rate DECIMAL(5,2);

	-- Count borrowed books (based on availability status)
    SELECT @borrowed_books = COUNT(*)
    FROM books 
    WHERE library_id = @Library_id AND avail_status = 1;

	-- Get the library's total capacity
    SELECT @capacity = total_capacity 
    FROM libraries
    WHERE library_id = @Library_id;

	-- Avoid division by zero
    IF @capacity = 0 OR @capacity IS NULL
        RETURN 0;
	-- Calculate occupancy rate
    SET @rate = (CAST(@borrowed_books AS DECIMAL(5,2)) / @capacity) * 100;

    RETURN @rate;
END;

SELECT dbo.CalculateLibraryOccupancyRate(1) AS OccupancyRate;

--==================================== fn_GetMemberLoanCount  =========================
-- Return the total number of loans made by a given member. 

create function dbo.fn_GetMemberLoanCount(@member_id int)
returns int
as 
begin
	declare @Total_Loan int;
	select @Total_Loan = count(loan_id) 
	from loan 
	where member_id = @member_id;
	return @Total_Loan;
end;

SELECT dbo.fn_GetMemberLoanCount(1) AS LoanCount;


-- ======================== fn_GetLateReturnDays  ==================================
-- Return the number of late days for a loan (0 if not late)
select * from loan 

create function dbo.fn_GetLateReturnDays ( @book_id int)
returns int
as 
begin

	declare @LateDays int;
	-- declare variable will get its value from the return_date column from loan table 
	DECLARE @ReturnDate DATE;
	declare @today date = CAST(GETDATE() AS DATE);

	select TOP 1 @ReturnDate =  return_date
	from loan 
	where book_id = @book_id
	ORDER BY loan_date DESC;
	
	-- Calculate the difference only if the book is overdue
    IF @ReturnDate IS NOT NULL AND @today > @ReturnDate
        SET @LateDays = DATEDIFF(DAY, @ReturnDate, @Today);
    ELSE
        SET @LateDays = 0;

	return  @LateDays;
end;

SELECT dbo.fn_GetLateReturnDays(2) AS LateDays;


-- =================================== fn_ListAvailableBooksByLibrary ===============================
-- Returns a table of available books from a specific library. 
create function dbo.fn_ListAvailableBooksByLibrary(@library_id int)
RETURNS TABLE
as
RETURN
(

	select * 
	from books 
	where library_id = @library_id  and avail_status = 0
	 

);

SELECT * FROM dbo.fn_ListAvailableBooksByLibrary(1);


-- ================================= fn_GetTopRatedBooks  ================================
-- Returns books with average rating ≥ 4.5 
create function fn_GetTopRatedBooks(@library_id int)
returns table 
as 
return
(
	select avg(rev.rating) AS average_rating, books.title
	from books join MemberBookReviews MBR
	on books.book_id = MBR.book_id
	JOIN reviews rev
	on rev.review_number = MBR.review_number
	where books.library_id = @library_id
	group by  books.title
	HAVING avg(rating) >= 4.5

);
SELECT * FROM dbo.fn_GetTopRatedBooks(1);


-- ============================ fn_FormatMemberName  =====================
-- Returns the full name formatted as "LastName, FirstName" 
create function dbo.fn_FormatMemberName (@member_id int)
returns varchar(20)
as 
 
begin
	declare @FullName varchar(20);

	select @FullName = (mem.F_name + ' ' + mem.L_name)
	from member mem
	where mem.member_id = @member_id;

	return @FullName;
end;

SELECT dbo.fn_FormatMemberName(1) AS FormattedName;
