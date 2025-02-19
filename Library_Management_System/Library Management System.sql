/*The project will involve creating a database schema for a library management system 
that tracks books, authors, publishers, borrowers, and loans. 
It will also involve writing PL/SQL code to create tables, insert sample data, write queries
and create views, functions, triggers, and procedures.*/

CREATE DATABASE Library_Management_System; --database schema created

USE Library_Management_System; 

--Here are the table specifications for the library management system:
CREATE TABLE Author(
	author_id INT PRIMARY KEY,
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	date_of_birth DATE);
	 
CREATE TABLE Publisher(
	publisher_id INT PRIMARY KEY,
	name VARCHAR(50),
	address VARCHAR(100));

CREATE TABLE Book(
	book_id INT PRIMARY KEY,
	title VARCHAR(50),
	author_id INT FOREIGN KEY REFERENCES Author(author_id),
	publisher_id INT FOREIGN KEY REFERENCES Publisher(publisher_id),
	publisher_dare DATE);

CREATE TABLE Borrower(
    borrower_id INT PRIMARY KEY,
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	address VARCHAR(100),
	phone VARCHAR(10));

CREATE TABLE Loan(
	loan_id INT PRIMARY KEY,
	book_id INT FOREIGN KEY REFERENCES Book(book_id),
	borrower_id INT FOREIGN KEY REFERENCES Borrower(borrower_id),
	loan_date DATE,
	return_date DATE);


--inserting sample data in all tables
INSERT INTO Author VALUES(101, 'Pablo', 'Cohlo', '1889-03-24'); 
INSERT INTO Author VALUES(102, 'Akshat', 'Gupta', '1987-05-31'); 
INSERT INTO Author VALUES(103, 'Ankush', 'Wariku', '1989-11-12'); 
INSERT INTO Author VALUES(104, 'P. L.', 'Deshpande', '1967-06-09'); 
Select * from Author;


INSERT INTO Publisher VALUES(111, 'Penguien', 'Bandra, Mumbai');
INSERT INTO Publisher VALUES(112, 'Prabhat Prakashan Pvt. Ltd.', 'Off Queens Road, Bengaluru');
INSERT INTO Publisher VALUES(113, 'Mouj Prakashan', 'Vile Parle West, Mumbai');
select * from Publisher;


INSERT INTO Book VALUES(1, 'The Alchemist', 101, 111, '1909-03-24');
INSERT INTO Book VALUES(2, 'Hidden Hindu', 102, 112, '2000-03-09');
INSERT INTO Book VALUES(3, 'Do Epic Shit', 103, 111, '2015-08-17');
INSERT INTO Book VALUES(4, 'Batatyachi Chal', 104, 113, '1999-06-12');
INSERT INTO Book VALUES(5, 'Veronika Decides To Die', 101, 111, '1923-03-24');
select * from Book;


INSERT INTO Borrower VALUES(1001, 'Sneha', 'Kasat', 'Shastri Nagar, Selu', '9168462700');
INSERT INTO Borrower VALUES(1002, 'Gaurav', 'Kasat', 'Shastri Nagar, Selu', '9156145944');
INSERT INTO Borrower VALUES(1003, 'Sanjay', 'Toshniwal', 'Aurangabad', '9403628721');
INSERT INTO Borrower VALUES(1004, 'Swapnali', 'Kabra', 'Hadapsar, Pune', '9156147759');
select * from Borrower;


INSERT INTO Loan VALUES(001, 1, 1001, '2024-09-04','');
INSERT INTO Loan VALUES(002, 2, 1001, '2024-05-04','2024-07-07');
INSERT INTO Loan VALUES(003, 3, 1003, '2024-07-07','2024-08-08');
INSERT INTO Loan VALUES(004, 4, 1002, '2024-01-08','2024-08-31');
INSERT INTO Loan VALUES(005, 2, 1004, '2024-02-04','2024-08-17');
INSERT INTO Loan(loan_id, book_id, borrower_id, loan_date) VALUES(006, 4, 1001, '2024-02-04');
select * from Loan;

--Write a query that retrieves the title and author name of all books borrowed by a specific borrower
SELECT 
  b.title AS Book_Title, 
  CONCAT(a.firstname,' ', a.lastname) AS Author_Name,
  CONCAT(bo.firstname,' ', bo.lastname) AS Borrower
  FROM 
	Book b 
	INNER JOIN Author a ON b.author_id = a.author_id
	INNER JOIN Loan l ON b.book_id = l.book_id
	INNER JOIN Borrower bo ON l.borrower_id = bo.borrower_id;
	--WHERE bo.borrower_id = [specific_borrower_id];

--Create a view that displays the loan history of a specific borrower
CREATE VIEW BorrowerLoanHistory AS
SELECT 
  CONCAT(bo.firstname, ' ', bo.lastname) AS Borrower,
  b.title AS Book_Title, 
  CONCAT(a.firstname, ' ', a.lastname) AS Author_Name,
  l.loan_date AS Loan_Date,
  l.return_date AS Return_Date
FROM 
  Book b 
  INNER JOIN Author a ON b.author_id = a.author_id
  INNER JOIN Loan l ON b.book_id = l.book_id
  INNER JOIN Borrower bo ON l.borrower_id = bo.borrower_id
WHERE 
  bo.borrower_id = 1001;

select * from BorrowerLoanHistory;

--Create a function that retrieves the number of books borrowed by a specific borrower
CREATE FUNCTION GetBorrowedBooksCount(@borrower_id INT)
RETURNS INT
BEGIN
  DECLARE @books_count INT;

  SELECT @books_count = COUNT(*)
  FROM Loan
  WHERE borrower_id = @borrower_id;

  RETURN @books_count;
END;

Select dbo.GetBorrowedBooksCount(1001); 

--Create a procedure that allows borrowers to return books
CREATE PROCEDURE ReturnBook
  @borrower_id INT,
  @book_id INT,
  @return_date DATE
AS
BEGIN
  -- Check if the loan exists
  IF EXISTS (SELECT 1 FROM Loan WHERE borrower_id = @borrower_id AND book_id = @book_id AND return_date IS NULL)
  BEGIN
    -- Update the return date for the loan
    UPDATE Loan
    SET return_date = @return_date
    WHERE borrower_id = @borrower_id AND book_id = @book_id AND return_date IS NULL;

    PRINT 'Book returned successfully.';
  END
  ELSE
  BEGIN
    PRINT 'No active loan found for this borrower and book.';
  END
END;

ALTER PROCEDURE ReturnBook
@borrower_id INT,
  @return_date DATE
AS
BEGIN
  -- Check if the loan exists
  IF EXISTS (SELECT 1 FROM Loan WHERE borrower_id = @borrower_id AND return_date IS NULL)
  BEGIN
    -- Update the return date for the loan
    UPDATE Loan
    SET return_date = @return_date
    WHERE borrower_id = @borrower_id AND return_date IS NULL;

    PRINT 'Book returned successfully.';
  END
  ELSE
  BEGIN
    PRINT 'No active loan found for this borrower and book.';
  END
END;

EXEC ReturnBook @borrower_id = 1001, @return_date = '2024-09-03';


--Create a trigger that logs all loan transactions. Hint: You must create a ‘transaction_log’ table for this.
CREATE TABLE Transaction_Log (
    log_id INT PRIMARY KEY IDENTITY(1,1),--The IDENTITY(1,1) property in SQL is used to create an auto-incrementing column.
    loan_id INT FOREIGN KEY REFERENCES Loan(loan_id),
    transaction_date DATE DEFAULT GETDATE(),
    amount DECIMAL(10, 2)
);

CREATE TRIGGER trgLogLoanTransactions
ON Loan
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log inserted transactions
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO Transaction_Log (loan_id, transaction_date, amount)
        SELECT loan_id, GETDATE(), null
        FROM inserted
        WHERE loan_id IN (SELECT loan_id FROM Loan);
    END

    -- Log updated transactions
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Transaction_Log (loan_id, transaction_date, amount)
        SELECT loan_id, GETDATE(), null
        FROM inserted
        WHERE loan_id IN (SELECT loan_id FROM Loan);
    END

    -- Log deleted transactions
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Transaction_Log (loan_id, transaction_date, amount)
        SELECT loan_id, GETDATE(), null
        FROM deleted
        WHERE loan_id IN (SELECT loan_id FROM Loan);
    END
END;

DELETE FROM Loan
WHERE loan_id = 6;

SELECT * From Loan;