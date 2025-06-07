🧠 Developer Reflection
1. What part was hardest and why?
One of the most difficult parts of this project was managing data consistency across related tables, especially when implementing transactions and triggers. Ensuring that every loan, payment, and review was properly linked and did not violate any constraints required a lot of debugging and careful analysis. Another challenge was writing stored procedures that handled complex logic like updating statuses, validating dates, or aggregating financial reports.

2. Which concept helped you think like a backend developer?
The concept of transactions and stored procedures played a crucial role in developing a backend-oriented mindset. Thinking about rollback safety, atomic operations, and how to encapsulate logic at the database level gave me insight into how real-world applications handle business rules and data integrity. Using views and functions also taught me to think in layers — separating presentation, business logic, and storage.

3. How would you test this if it were a live web app?
If this were a live web app, I would follow a multi-layered testing strategy:

✅ Functional Testing
Verify that borrowing, returning, and reviewing books behave as expected.
+
Test edge cases like borrowing a book that is already loaned out.

Make sure status updates and book availability reflect accurately in the UI.

✅ Database Integrity Testing
Manually insert test data to see how constraints and triggers behave.

Delete members or books and verify cascading or blocking behavior.

Check for orphan records in intermediate tables like loan_pay.

✅ UI Integration Testing
Simulate user actions through the frontend and verify backend responses.

Ensure that availability, loan statuses, and payments display correctly.

✅ Performance Testing
Stress test by inserting multiple loan transactions at once.

Monitor how the system behaves under concurrent access to the same records.

✅ Security Testing
Make sure SQL injection is prevented by using parameterized queries.

Test access control: only authorized users can perform insert/update/delete operations.
