use LibrarySystem
-- =============== Reference ===============
--https://www.scaler.com/topics/clustered-and-non-clustered-index/
-- ========================== Library Table ========================
select * from libraries
-- Non-clustered on Name → Search by name
	select * from libraries
	-- Note: if  i want create cluster for the library table it will show error becouse already there is cluster in the table which primary key.
	Create NONCLUSTERED Index Library_name ON libraries(name ASC);
	
	select * from libraries
	where name = 'NPL'

-- Non-clustered on Location → Filter by location
	Create NONCLUSTERED Index Library_Location ON libraries(location ASC);

	select * from libraries
	where location = 'Salalah'

-- ======================= Book Table =====================
	select * from libraries
	select * from books
-- Clustered on LibraryID, ISBN → Lookup by book in specific library 

	--CREATE CLUSTERED INDEX LibraryID_ISBM ON books (library_id,ISBM);
	-- NOTE: The previous code show me error becouse , can not remove the exist cluster and create new one, becouse the exist clustor is primary key which other tables dependen on it 
	CREATE NONCLUSTERED INDEX LibraryID_ISBM ON books (library_id,ISBM);

	SELECT *
	FROM books
	WHERE library_id = 3 AND ISBM = '9781005';

-- Non-clustered on Genre → Filter by genre 
	CREATE NONCLUSTERED INDEX IndexGenre ON books(genre ASC);

	SELECT *
	FROM books
	WHERE genre = 'Reference' ;

-- ====================================== Loan Table  ==============================
-- Non-clustered on MemberID → Loan history 
	CREATE NONCLUSTERED INDEX Index_MemberID ON loan(member_id);

	select * from loan
	where member_id =1;

-- Non-clustered on Status → Filter by status 
	CREATE NONCLUSTERED INDEX Index_status ON loan(status);

	select * from loan
	where status ='issued';

-- Composite index on BookID, LoanDate, ReturnDate → Optimize overdue checks 

	CREATE NONCLUSTERED INDEX BookID_LoanDate_ReturnDate
	ON loan (book_id, loan_date, return_date);

	SELECT *
	FROM loan
	WHERE book_id = 6 AND return_date >= '2025-05-17' AND due_date >= '2025-05-17';
