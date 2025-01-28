-- SQL Server 2012 Schema (with more deprecated features)

-- 1. Customer Table (TEXT, IMAGE, deprecated stored procedure for history)
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    CustomerAddress TEXT NULL,        -- Deprecated: VARCHAR(MAX)
    ProfilePicture IMAGE NULL,         -- Deprecated: VARBINARY(MAX)
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);



-- 2. Product Table (ROWGUIDCOL, deprecated collation)
CREATE TABLE Product (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, -- Deprecated:  Consider newer collations
    ProductDescription VARCHAR(255) NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    ProductGUID UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL DEFAULT NEWID() -- Deprecated
);




-- 4. Orders Table (extended properties)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL
);

-- Extended Property (Deprecated Usage) - Example
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'This table stores customer orders.', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'Orders';

-- 5. Regions Table
CREATE TABLE Regions (
    RegionID INT PRIMARY KEY IDENTITY(1,1),
    RegionName VARCHAR(50) NOT NULL
);

-- 6. Stores Table (NOLOCK, deprecated DATETIME2 with lower precision)
CREATE TABLE Stores (
    StoreID INT PRIMARY KEY IDENTITY(1,1),
    RegionID INT FOREIGN KEY REFERENCES Regions(RegionID),
    StoreName VARCHAR(100) NOT NULL,
    StoreAddress VARCHAR(255) NULL,
    OpenDate DATETIME2(0) NULL -- Deprecated:  Use higher precision if needed.
);

-- 3. Sales Table (implicit date conversion, deprecated table hint)
CREATE TABLE Sales (
    SalesID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    OrderDate DATETIME NOT NULL,       -- Implicit conversion issues
    Quantity INT NOT NULL,
    StoreID INT FOREIGN KEY REFERENCES Stores(StoreID) -- Added StoreID
);

-- 7. Employee Table (Deprecated data type for large objects)
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeName VARCHAR(100) NOT NULL,
    Resume NTEXT NULL -- Deprecated: Use NVARCHAR(MAX)
);

-- 8. Log Table (deprecated function for string manipulation)
CREATE TABLE LogTable (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    LogMessage VARCHAR(200) NULL,
    LogTime DATETIME NOT NULL DEFAULT GETDATE()
);



