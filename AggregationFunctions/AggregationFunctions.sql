-- ==================== Aggregation Functions ======================
use LibrarySystem
-- ======================= Total fines per member============
select sum(p.amount) as Total_Fines , mem.F_name + ' ' + mem.L_name as FullName
from Payments p join loan_pay lp
on p.pay_id = lp.pay_id
join loan l
on 
	l.loan_id = lp.loan_id AND
	l.book_id = lp.book_id AND
	l.member_id = lp.member_id
join member mem
on mem.member_id = l.member_id
group by mem.F_name + ' ' + mem.L_name

-- ===============  Most active libraries (by loan count)  =========
select count(l.loan_id) as MostActiveLibraries, lib.library_id
from libraries lib join books
on lib.library_id = books.library_id
join loan l 
on books.book_id = l.book_id
group by lib.library_id
order by count(l.loan_id) DESC

--====================== Avg book price per genre  ================
select avg(price) as Average_Price, genre
from books
group by genre

-- ================== Top 3 most reviewed books =============
select top 3 count(rev.review_number) as Top3MostReviewed , books.title
from reviews rev join MemberBookReviews MBR
on rev.review_number = MBR.review_number
join books
on books.book_id = MBR.book_id
group by books.title

--================== Library revenue report ==========
SELECT 
    lib.library_id,
    lib.name,
    SUM(p.amount) AS total_revenue,
    COUNT(p.pay_id) AS total_payments,
    AVG(p.amount) AS avg_payment,
    MAX(p.amount) AS highest_payment,
    MIN(p.amount) AS lowest_payment
FROM libraries lib
JOIN books b ON lib.library_id = b.library_id
JOIN loan l ON b.book_id = l.book_id
JOIN loan_pay lp ON 
    l.loan_id = lp.loan_id AND
    l.book_id = lp.book_id AND
    l.member_id = lp.member_id
JOIN Payments p ON lp.pay_id = p.pay_id
GROUP BY lib.library_id, lib.name
ORDER BY total_revenue DESC;


--=================== Member activity summary (loan + fines) =========
SELECT 
    m.member_id,
    m.F_name + ' ' + m.L_name as FullName,
    COUNT(l.loan_id) AS total_loans,
    SUM(p.amount) AS total_fines_paid
FROM member m
LEFT JOIN loan l ON m.member_id = l.member_id
LEFT JOIN loan_pay lp ON 
    l.loan_id = lp.loan_id AND
    l.book_id = lp.book_id AND
    l.member_id = lp.member_id
LEFT JOIN payments p ON lp.pay_id = p.pay_id
GROUP BY m.member_id,  m.F_name + ' ' + m.L_name
ORDER BY total_loans DESC;
