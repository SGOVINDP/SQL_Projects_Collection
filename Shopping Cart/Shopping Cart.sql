Create Database Shopping_Cart;
Use Shopping_Cart;

-- Create User table
CREATE TABLE [User](
    UserID int PRIMARY KEY,
    FirstName varchar(20),
    LastName varchar(20),
    Email varchar(20),
    Password varchar(10),
    Address varchar(50),
    Phone varchar(10)
);

-- Create Product table
CREATE TABLE Product (
    ProductID int PRIMARY KEY,
    Name varchar(20),
    Description varchar(20),
    Price money
);

-- Create Cart table
CREATE TABLE Cart (
    CartID int PRIMARY KEY,
    UserID int,
    CreatedAt datetime,
    UpdatedAt datetime,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- Create CartItem table
CREATE TABLE CartItem (
    CartItemID int PRIMARY KEY,
    CartID int,
    ProductID int,
    Quantity int,
    SubTotal int,
    FOREIGN KEY (CartID) REFERENCES Cart(CartID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Create Order table
CREATE TABLE [Order] (
    OrderID int PRIMARY KEY,
    UserID int,
    OrderDate datetime,
    TotalAmount money,
    ShippingAddress varchar(50),
    Status varchar(10),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- Create OrderItem table
CREATE TABLE OrderItem (
    OrderItemID int PRIMARY KEY,
    OrderID int,
    ProductID int,
    Quantity int,
    SubTotal int,
    FOREIGN KEY (OrderID) REFERENCES [Order],
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Insert sample records into User table
INSERT INTO [User] (UserID, FirstName, LastName, Email, Password, Address, Phone) VALUES
(1, 'John', 'Doe', 'john@example.com', 'password12', '123 Main St', '1234567890'),
(2, 'Jane', 'Smith', 'jane@example.com', 'password45', '456 Elm St', '0987654321');

-- Insert sample records into Product table
INSERT INTO Product (ProductID, Name, Description, Price) VALUES
(1, 'Laptop', 'High performance pc', 1000.00),
(2, 'Smartphone', 'Latest model phone', 700.00);

-- Insert sample records into Cart table
INSERT INTO Cart (CartID, UserID, CreatedAt, UpdatedAt) VALUES
(1, 1, '2024-08-28 10:00:00', '2024-08-28 10:30:00'),
(2, 2, '2024-08-28 11:00:00', '2024-08-28 11:30:00');

-- Insert sample records into CartItem table
INSERT INTO CartItem (CartItemID, CartID, ProductID, Quantity, SubTotal) VALUES
(1, 1, 1, 1, 1000.00),
(2, 2, 2, 2, 1400.00);

-- Insert sample records into Order table
INSERT INTO [Order] (OrderID, UserID, OrderDate, TotalAmount, ShippingAddress, Status) VALUES
(1, 1, '2024-08-28 12:00:00', 1000.00, '123 Main St', 'Shipped'),
(2, 2, '2024-08-28 13:00:00', 1400.00, '456 Elm St', 'Processing');

-- Insert sample records into OrderItem table
INSERT INTO OrderItem (OrderItemID, OrderID, ProductID, Quantity, SubTotal) VALUES
(1, 1, 1, 1, 1000.00),
(2, 2, 2, 2, 1400.00);

-- This query sets the default value of the Status column to 'Pending' for any new records inserted into the Order table.
ALTER TABLE [Order]
ADD CONSTRAINT DF_Order_Status DEFAULT 'Pending' FOR Status;

-- This will add a CHECK constraint to both the CartItem and OrderItem tables, ensuring that the Quantity column has a value of at least 1.
ALTER TABLE CartItem
ADD CONSTRAINT CHK_CartItem_Quantity CHECK (Quantity >= 1);

ALTER TABLE OrderItem
ADD CONSTRAINT CHK_OrderItem_Quantity CHECK (Quantity >= 1);

-- Add DiscountPercentage column to Product table
--It is defined as a DECIMAL data type with a precision of 5 and a scale of 2, allowing for percentages like 12.34.  
--The DEFAULT 0 sets the default value of the column to 0. 
--The CHECK constraint ensures that the discount percentage is between 0 and 100. 
ALTER TABLE Product
ADD DiscountPercentage DECIMAL(5, 2) DEFAULT 0
    CONSTRAINT CHK_Product_DiscountPercentage CHECK (DiscountPercentage BETWEEN 0 AND 100);

--Write a query which retrieves information about users who have placed orders, along with the total number of orders each user has placed (Hint: Use Subquery) 
SELECT 
    U.UserID,  U.FirstName, U.LastName, U.Email,
    (SELECT COUNT(*) FROM [Order] O 
     WHERE O.UserID = U.UserID) AS TotalOrders
FROM 
    [User] U
WHERE 
    U.UserID IN (SELECT DISTINCT UserID FROM [Order]);

--Write a query which will retrieve information about products in a user's cart (Hint: Use Join) 
SELECT 
    U.UserID, U.FirstName, U.LastName, P.ProductID, P.Name AS ProductName, P.Description, P.Price, CI.Quantity, CI.SubTotal
FROM 
    [User] U
JOIN 
    Cart C ON U.UserID = C.UserID
JOIN 
    CartItem CI ON C.CartID = CI.CartID
JOIN 
    Product P ON CI.ProductID = P.ProductID
WHERE 
    U.UserID = 1;

--Using self-join on the OrderItems table write a query which will find products that have been ordered together in the same order. 
SELECT 
    OI1.OrderID, OI1.ProductID AS Product1, OI2.ProductID AS Product2
FROM 
    OrderItem OI1
JOIN 
    OrderItem OI2 ON OI1.OrderID = OI2.OrderID AND OI1.ProductID < OI2.ProductID
ORDER BY 
    OI1.OrderID, OI1.ProductID, OI2.ProductID;

--Write a query to retrieve all combinations of products and users (Hint: Use Cross Join) 
SELECT 
    U.UserID, U.FirstName, U.LastName, P.ProductID, P.Name AS ProductName, P.Description, P.Price
FROM 
    [User] U
CROSS JOIN 
    Product P
ORDER BY 
    U.UserID, P.ProductID;


--Write a query that retrieves users who have placed at least one order (Hint: Use Exists) 
SELECT 
    U.UserID, U.FirstName, U.LastName, U.Email
FROM 
    [User] U
WHERE 
    EXISTS (SELECT 1 FROM [Order] O  WHERE O.UserID = U.UserID);


--Write a query that finds products that have been ordered at least once (Hint: Use Any operator) 
SELECT 
    P.ProductID, P.Name AS ProductName, P.Description, P.Price
FROM 
    Product P
WHERE 
    P.ProductID = ANY (SELECT OI.ProductID FROM OrderItem OI);


--Total Sales for Each Product:
SELECT ProductID, SUM(Quantity) AS TotalSales
FROM OrderItem
GROUP BY ProductID;


--Average Order Value for Each User:
SELECT o.UserID, AVG(o.TotalAmount) AS AvgOrderValue
FROM [Order] o
GROUP BY o.UserID;


--Number of Orders per User and Order Status:
SELECT o.UserID, o.Status, COUNT(*) AS OrderCount
FROM [Order] o
GROUP BY o.UserID, o.Status;


--Total Revenue for Each Month:
SELECT DATEPART(YEAR, o.OrderDate) AS Year,
       DATEPART(MONTH, o.OrderDate) AS Month,
       SUM(o.TotalAmount) AS TotalRevenue
FROM [Order] o
GROUP BY DATEPART(YEAR, o.OrderDate), DATEPART(MONTH, o.OrderDate);

--Top-Selling Products:
SELECT p.ProductID, p.Name, SUM(oi.Quantity) AS TotalQuantitySold
FROM Product p
JOIN OrderItem oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalQuantitySold DESC;


--Total Revenue for Each Month, Each User, and Overall Total:
SELECT
    DATEPART(YEAR, o.OrderDate) AS Year,
    DATEPART(MONTH, o.OrderDate) AS Month,
    o.UserID,
    SUM(o.TotalAmount) AS TotalRevenue
FROM
    [Order] o
GROUP BY
    GROUPING SETS ((DATEPART(YEAR, o.OrderDate), DATEPART(MONTH, o.OrderDate), o.UserID), ());


--Number of Orders per User, Per Order Status, and Overall Total:
SELECT
    o.UserID,
    o.Status,
    COUNT(*) AS OrderCount
FROM
    [Order] o
GROUP BY
    GROUPING SETS ((o.UserID, o.Status), ());

--Creating an Index for the Email Column in the Users Table:
CREATE INDEX idx_email ON [User] (Email);


--Creating a View for All Orders Information:
CREATE VIEW OrdersInfo AS
SELECT
    o.OrderID,
    o.UserID,
    o.OrderDate,
    o.TotalAmount,
    o.ShippingAddress,
    o.Status,
    u.FirstName,
    u.LastName
FROM
    [Order] o
JOIN
    [User] u ON o.UserID = u.UserID;

-------------------------------------------------
select * from [OrderItem];
BEGIN TRANSACTION;

DECLARE @OrderID int, @UserID int, @OrderItemId int, @ProductID INT, @Quantity INT;;
SET @OrderID = 4;
SET @UserID = 1;
SET @OrderItemId = 4;
SET @ProductID = 1;
SET @Quantity = 1;

-- Insert a new order into the Orders table
INSERT INTO [Order] (OrderID, UserID, OrderDate)
VALUES (@OrderID, @UserID, GETDATE());

BEGIN
    -- Insert into OrderItems table
    INSERT INTO OrderItem (OrderItemID,OrderID, ProductID, Quantity)
    VALUES (@OrderItemId, @OrderID, @ProductID, @Quantity);

END

-- Commit the transaction
COMMIT TRANSACTION;

Select * from [Order];

Select * from OrderItem;

Select * from Product;