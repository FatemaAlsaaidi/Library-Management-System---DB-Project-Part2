use LibrarySystem

-- 1. GET /loans/overdue → List all overdue loans with member name, book title, due date 
select loan.* , Mem.F_name + ' ' + Mem.L_name as Full_Name, books.title
from member Mem join loan 
on Mem.member_id = loan.member_id 
join books 
on books.book_id = loan.book_id

-- 2. GET /books/unavailable → List books not available  

select * from books
where avail_status = 0

--3. GET /members/top-borrowers → Members who borrowed >2 books

select count(loan.member_id) as Number_Borrows , Mem. F_name + ' ' + Mem.L_name as Full_Name 
from member Mem join loan
on Mem.member_id = loan.member_id
group by  Mem. F_name + ' ' + Mem.L_name
having count(loan.member_id) >2

--4. GET /books/:id/ratings → Show average rating per book

select avg(Rev.rating) as average_Rating , books.title
from books join MemberBookReviews MBR
on books.book_id = MBR.book_id
join reviews Rev
on Rev.review_number = MBR.review_number
group by books.title

--5. GET /libraries/:id/genres → Count books by genre 

select count(book_id) as Book_Number , genre
from books
group by genre

--6. GET /members/inactive → List members with no loans  
insert into member values ('Noor', 'Salim' ,'Alsaaidi', 'noor.h@gmail.com', '78965412', '2023-01-15' )

select * from member
select * from loan 

SELECT *
FROM member m
WHERE NOT EXISTS (
    SELECT 1
    FROM loan 
    WHERE m.member_id = loan.member_id
);

--7. GET /payments/summary → Total fine paid per member 
select * from member
select * from loan
select * from loan_pay
select * from Payments

select sum(pay.amount) as Total_Paid , mem.F_name + ' ' + mem.L_name as Full_Name 
from member mem join loan
on mem.member_id = loan.member_id
join loan_pay LP
on loan.loan_id = LP.loan_id and loan.book_id = LP.book_id and loan.member_id= LP.member_id
join Payments pay
on pay.pay_id = LP.pay_id
group by mem.F_name + ' ' + mem.L_name

--8. GET /reviews → Reviews with member and book info 
-- 8. GET /reviews → Reviews with member and book info
SELECT 
    rev.review_number,
    rev.rating,
    rev.review_date,
    rev.commands,
    mem.member_id,
    mem.F_name, 
    mem.L_name, 
    mem.member_email,
    mem.member_phone,
    mem.mem_start_date,
    b.book_id,
    b.title,
    b.genre,
    b.price,
    b.avail_status,
    b.shelf_location
FROM reviews rev
JOIN MemberBookReviews MBR ON rev.review_number = MBR.review_number
JOIN member mem ON mem.member_id = MBR.member_id
JOIN books b ON b.book_id = MBR.book_id;

--9. GET /books/popular → List top 3 books by number of times they were loaned 
select top 3 count(loan.book_id) as Loan_Times , books.title
from books join loan
on books.book_id  = loan.book_id
group by books.title

-- 10. GET /members/:id/history → Retrieve full loan history of a specific member including book title, loan & return dates
select loan.*, mem.F_name+ ' '+ mem.L_name as Full_Name, loan.loan_date, loan.return_date
from member mem full join loan 
on mem.member_id = loan.member_id

--11. GET /books/:id/reviews → Show all reviews for a book with member name and comments 
select b.*, mem.F_name+ ' '+ mem.L_name as Full_Name, rev.commands
FROM reviews rev
JOIN MemberBookReviews MBR ON rev.review_number = MBR.review_number
JOIN member mem ON mem.member_id = MBR.member_id
JOIN books b ON b.book_id = MBR.book_id; 

--12. GET /libraries/:id/staff → List all staff working in a given library 
select staff.* , lib.name
from libraries lib join staff
on lib.library_id = staff.library_id
where lib.name ='SQU Lib'

--13. GET /books/price-range?min=5&max=15 → Show books whose prices fall within a given range
select * from books 
where price > 3.000 and price < 6.000

-- 14. GET /loans/active → List all currently active loans (not yet returned) with member and book info
select loan.* , mem.F_name + ' ' + mem.L_name as Full_Name , mem.member_phone , mem.member_email, books.title ,books.price
from member mem join loan
on mem.member_id = loan.member_id
join books
on books.book_id = loan.book_id
where loan.status = 'issued'

-- 15. GET /members/with-fines → List members who have paid any fine 
SELECT
    m.member_id,
    m.F_name,
    m.M_name,
    m.L_name,
    m.member_email,
    m.member_phone,
    m.mem_start_date
FROM member m
JOIN loan_pay lp ON m.member_id = lp.member_id
JOIN Payments p ON lp.pay_id = p.pay_id
WHERE p.amount > 0;

-- 16. GET /books/never-reviewed →  List books that have never been reviewed 

SELECT DISTINCT books.*
FROM books
LEFT JOIN MemberBookReviews MBR ON books.book_id = MBR.book_id
LEFT JOIN reviews rev
on rev.review_number = MBR.review_number
WHERE MBR.book_id IS NULL;

select * from books
select * from MemberBookReviews
select * from reviews

-- 17. GET /members/:id/loan-history →Show a member’s loan history with book titles and loan status. 
SELECT books.title, loan.*
from books right join loan
on books.book_id = loan.book_id

--18. GET /members/inactive →List all members who have never borrowed any book.
select mem.* 
from member mem left join loan
on mem.member_id = loan.member_id

--19. GET /books/never-loaned → List books that were never loaned.
SELECT DISTINCT books.*
FROM books
LEFT JOIN loan ON books.book_id = loan.book_id
WHERE loan.book_id IS NULL;

select * from books
select * from loan 

--20. GET /payments →List all payments with member name and book title. 
SELECT pay.*, mem.F_name + ' ' + mem.L_name as Member_Name, books.title
from Payments pay left join loan_pay LP
on pay.pay_id = LP.pay_id
left join loan
on loan.loan_id = LP.loan_id
left join member mem
on mem.member_id = loan.member_id
left join books
on books.book_id = loan.book_id

select * from Payments

-- 21. GET /loans/overdue→ List all overdue loans with member and book details.
SELECT 
loan.*, 
mem.F_name + ' ' + mem.L_name as Member_Name, 
books.title, 
books.price,
books.genre
from loan left join member mem
on mem.member_id = loan.member_id
left join books
on books.book_id = loan.book_id

select * from loan

-- 22. GET /books/:id/loan-count → Show how many times a book has been loaned.
select count(loan.book_id) as Times_Loan, books.title
from loan join books
on books.book_id = loan.book_id
group by books.title

-- 23. GET /members/:id/fines → Get total fines paid by a member across all loans. 
select sum(pay.amount) as Total_payment,
mem.F_name + ' ' + mem.L_name as Member_Name
from Payments pay left join loan_pay LP
on pay.pay_id = LP.pay_id
left join loan
on loan.loan_id = LP.loan_id
left join member mem
on mem.member_id = loan.member_id
group by mem.F_name + ' ' + mem.L_name

select * from member
select * from Payments
select * from loan_pay
select * from loan

-- 24. GET /libraries/:id/book-stats → Show count of available and unavailable books in a library. 
select * from books 
select count(book_id) as Number_Books, avail_status
from books
group by avail_status -- 0 represents not avilable , 1 represents available

--25. GET /reviews/top-rated → Return books with more than 5 reviews and average rating > 4.5.
select * from books
SELECT * FROM MemberBookReviews
SELECT * FROM reviews

select count(MBR.review_number) AS NUMBER_REVIEWS, avg(rev.rating) ,MBR.book_id, books.title
from books join MemberBookReviews MBR
ON books.book_id =	MBR.book_id
join reviews rev
on rev.review_number = MBR.review_number
GROUP BY MBR.book_id , books.title
HAVING count(MBR.review_number) >=1 AND avg(rev.rating) > 4.5
