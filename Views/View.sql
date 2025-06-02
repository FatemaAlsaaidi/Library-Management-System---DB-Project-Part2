use LibrarySystem

-- ============================ ViewPopularBooks ==============================
-- Books with average rating > 4.5 + total loans
CREATE VIEW ViewPopularBooks AS
SELECT 
    b.title,
    AVG(r.rating) AS avg_rating,
    SUM(p.amount) AS total_fines
FROM books b
JOIN MemberBookReviews mbr ON b.book_id = mbr.book_id
JOIN reviews r ON r.review_number = mbr.review_number
JOIN loan l ON b.book_id = l.book_id
JOIN loan_pay lp ON 
    l.loan_id = lp.loan_id AND 
    l.book_id = lp.book_id AND 
    l.member_id = lp.member_id
JOIN Payments p ON p.pay_id = lp.pay_id
GROUP BY b.title
having AVG(r.rating)> 4.5

select * from ViewPopularBooks

-- ========================== ViewMemberLoanSummary ===========================
-- Member loan count + total fines paid
create view ViewMemberLoanSummary as
select mem.F_name, count(loan.member_id) as loan_count ,  SUM(pay.amount) AS total_fines
from member mem join loan 
on mem.member_id = loan.member_id
JOIN loan_pay lp ON 
    loan.loan_id = lp.loan_id AND 
    loan.book_id = lp.book_id AND 
    loan.member_id = lp.member_id
join Payments pay
on pay.pay_id = lp.pay_id
group by mem.F_name

select * from ViewMemberLoanSummary

-- =================================== ViewAvailableBooks ===================
-- Available books grouped by genre, ordered by price

CREATE VIEW ViewAvailableBooks AS
SELECT 
    genre,
    title,
    price
FROM books
WHERE avail_status = 0;


select * from ViewAvailableBooks 

-- =========================== ViewLoanStatusSummary =========================
-- Loan stats (issued, returned, overdue) per library 
create view ViewLoanStatusSummary as 
select count(CASE WHEN loan.status = 'issued' THEN 1 END ) as IssuedCount,
count(CASE WHEN loan.status = 'returned' THEN 1 END ) as ReturnedCount,
count(CASE WHEN loan.status = 'issued' AND loan.return_date > loan.due_date THEN 1 END ) as overdueCount,
lib.name

from loan join books
on books.book_id = loan.book_id
join libraries lib 
on lib.library_id = books.library_id
group by lib.name

select * from ViewLoanStatusSummary

-- =================================== ViewPaymentOverview =======================
-- Payment info with member, book, and status

create view ViewPaymentOverview as 
select pay.*, loan.status, books.title, mem.F_name
from Payments pay join loan_pay lp
on pay.pay_id = lp.pay_id
join loan
ON 
    loan.loan_id = lp.loan_id AND 
    loan.book_id = lp.book_id AND 
    loan.member_id = lp.member_id
join member mem 
on mem.member_id  = loan.member_id
join books
on books.book_id = loan.book_id

select * from ViewPaymentOverview