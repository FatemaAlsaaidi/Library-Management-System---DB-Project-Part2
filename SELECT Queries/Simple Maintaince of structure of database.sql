drop table BookLoans


SELECT
  table_name,
  constraint_type,
  constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'loan_pay';

ALTER TABLE loan_pay
DROP CONSTRAINT FK__loan_pay__5CD6CB2B;

alter table loan_pay
add foreign key(loan_id, book_id, member_id) references loan(loan_id, book_id, member_id)
