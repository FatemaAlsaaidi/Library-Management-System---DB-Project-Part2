-- ============================== Advanced Aggregations ================
use LibrarySystem
-- HAVING for filtering aggregates 
Select count(l.loan_id) as NumberOfLoan, mem.F_name 
from member mem join loan l 
on mem.member_id = l.member_id
group by mem.F_name
having count(l.loan_id) >2

-- Subqueries for complex logic (e.g., max price per genre)
select b.*
from books b
where b.price = (
    select MAX(price)
    from books
    where genre = b.genre
);

-- Occupancy rate calculations 
-- Occupancy Rate (%) = (Number of Issued Books / Total Number of Books) * 100
select 
    l.library_id,
    l.name,
    COUNT(CASE WHEN b.avail_status = 1 THEN 1 END) * 100.0 / NULLIF(COUNT(b.book_id), 0) AS occupancy_rate
from libraries l
join books b ON l.library_id = b.library_id
group by l.library_id, l.name;

--  Members with loans but no fine 
SELECT DISTINCT m.member_id, m.F_name -- DISTINCT To avoid duplication if the member has more than one loan
FROM member m
JOIN loan l ON m.member_id = l.member_id
WHERE NOT EXISTS (
    SELECT 1
    FROM loan_pay lp
    JOIN payments p ON lp.pay_id = p.pay_id
    WHERE lp.member_id = m.member_id
);
-- Genres with high average ratings 
SELECT 
    b.genre,
    AVG(r.rating) AS avg_rating
FROM books b
JOIN MemberBookReviews mbr ON b.book_id = mbr.book_id
JOIN reviews r ON mbr.review_number = r.review_number
GROUP BY b.genre
HAVING AVG(r.rating) >= 4.0 
ORDER BY avg_rating DESC;

