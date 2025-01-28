-- SQL Server 2012 Schema 

-- 1. Customer Table 
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    CustomerAddress TEXT NULL,    
    ProfilePicture IMAGE NULL,        
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);



-- 2. Product Table 
CREATE TABLE Product (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    ProductDescription VARCHAR(255) NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    ProductGUID UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL DEFAULT NEWID() 
);




-- 4. Orders Table (extended properties)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL
);

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'This table stores customer orders.', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'Orders';

-- 5. Regions Table
CREATE TABLE Regions (
    RegionID INT PRIMARY KEY IDENTITY(1,1),
    RegionName VARCHAR(50) NOT NULL
);

-- 6. Stores Table 
CREATE TABLE Stores (
    StoreID INT PRIMARY KEY IDENTITY(1,1),
    RegionID INT FOREIGN KEY REFERENCES Regions(RegionID),
    StoreName VARCHAR(100) NOT NULL,
    StoreAddress VARCHAR(255) NULL,
    OpenDate DATETIME2(0) NULL 
);

-- 3. Sales Table 
CREATE TABLE Sales (
    SalesID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    OrderDate DATETIME NOT NULL,       -- Implicit conversion issues
    Quantity INT NOT NULL,
    StoreID INT FOREIGN KEY REFERENCES Stores(StoreID) -- Added StoreID
);

-- 7. Employee Table 
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeName VARCHAR(100) NOT NULL,
    Resume NTEXT NULL
);

-- 8. Log Table 
CREATE TABLE LogTable (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    LogMessage VARCHAR(200) NULL,
    LogTime DATETIME NOT NULL DEFAULT GETDATE()
);



-- Stored Procedure 1: Get Customer Order Summary (using VARCHAR(MAX) and VARBINARY(MAX))
CREATE PROCEDURE GetCustomerOrderSummary
AS
BEGIN
    SELECT
        c.CustomerID,
        c.FirstName,
        c.LastName,
        c.CustomerAddress,  
        c.ProfilePicture, 
        o.OrderID,
        o.OrderDate,
        o.TotalAmount
    FROM
        Customer c
    INNER JOIN
        Orders o ON c.CustomerID = o.CustomerID;
END;
GO


CREATE PROCEDURE SalesPerformanceAnalysis
AS
BEGIN
    SELECT
        p.ProductName,
        s.StoreName,
        SUM(s.Quantity * p.UnitPrice) AS TotalSales
    FROM
        Sales s
    INNER JOIN
        Product p ON s.ProductID = p.ProductID
    INNER JOIN
        Stores s2 ON s.StoreID = s2.StoreID
    WHERE s.OrderDate >= CAST('2023-01-01' AS DATETIME) AND s.OrderDate < CAST('2024-01-01' AS DATETIME) 
    GROUP BY
        p.ProductName, s.StoreName
    ORDER BY
        TotalSales DESC;
END;
GO


CREATE PROCEDURE EmployeeResumeSearch (@Keyword VARCHAR(100))
AS
BEGIN
    SELECT
        EmployeeID,
        EmployeeName
    FROM
        Employee
    WHERE
        CONTAINS(Resume, @Keyword); 
END;
GO


CREATE PROCEDURE LogReport (@StartTime DATETIME, @EndTime DATETIME)
AS
BEGIN
    SELECT
        LogMessage,
        COUNT(*) AS LogCount
    FROM
        LogTable
    WHERE
        LogTime BETWEEN @StartTime AND @EndTime
    GROUP BY
        LogMessage
    ORDER BY
        LogCount DESC;
END;
GO


CREATE TYPE OrderItemType AS TABLE (
    ProductID INT,
    Quantity INT
);
GO


CREATE PROCEDURE ProcessOrder (@CustomerID INT, @OrderItems OrderItemType READONLY)  -- Use TVP
AS
BEGIN

    IF @CustomerID IS NULL 
    BEGIN
        RAISERROR('Invalid input parameters.', 16, 1)
        RETURN
    END

    -- Begin transaction (for data consistency)
    BEGIN TRANSACTION

    BEGIN TRY
        -- Get customer details
        SELECT * FROM Customer WHERE CustomerID = @CustomerID;

        -- Process each product in the order (using the TVP)
        DECLARE @TotalAmount DECIMAL(18,2) = 0;

        SELECT p.ProductID, p.UnitPrice, oi.Quantity, (p.UnitPrice * oi.Quantity) AS ItemTotal,  @TotalAmount + (p.UnitPrice * oi.Quantity) as TotalAmount 
        INTO #OrderItems --Temporary table to hold the calculated values
        FROM @OrderItems oi
        INNER JOIN Product p ON oi.ProductID = p.ProductID;

        --Insert into Orders table
        INSERT INTO Orders(CustomerID, OrderDate, TotalAmount)
        VALUES (@CustomerID, GETDATE(), @TotalAmount);

        DECLARE @OrderID INT = SCOPE_IDENTITY(); --Get the last inserted order ID

        --Insert into Sales table
        INSERT INTO Sales(CustomerID, ProductID, OrderDate, Quantity, StoreID)
        SELECT @CustomerID, ProductID, GETDATE(), Quantity, 1 -- Assuming StoreID = 1 for now. You might need to adjust this.
        FROM #OrderItems;

        DROP TABLE #OrderItems; -- Drop the temporary table

        -- Commit transaction
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        -- Raise error
        THROW;  -- Re-throw the caught exception
        RETURN
    END CATCH
END;
GO


