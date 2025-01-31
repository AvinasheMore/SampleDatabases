-- Oracle 12c Schema with Deprecated Features
-- Table Definitions with Relationships and Deprecated Features

-- Table: Users
CREATE TABLE Users (
    UserID NUMBER PRIMARY KEY,
    UserName VARCHAR2(100),
    UserEmail VARCHAR2(100),
    UserProfile LONG, -- Deprecated in Oracle 21c; replace with CLOB
    UserPassword RAW(2000) -- Deprecated in favor of VARCHAR2 with encryption
);

-- Table: Products
CREATE TABLE Products (
    ProductID NUMBER PRIMARY KEY,
    ProductName VARCHAR2(100),
    ProductDescription LONG, -- Deprecated in Oracle 21c; replace with CLOB
    Price NUMBER(10, 2),
    ProductImage BFILE -- Deprecated in Oracle 21c; replace with SecureFile LOB
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID NUMBER PRIMARY KEY,
    UserID NUMBER REFERENCES Users(UserID),
    OrderDate DATE,
    Comments LONG RAW -- Deprecated in Oracle 21c; replace with BLOB
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID NUMBER PRIMARY KEY,
    OrderID NUMBER REFERENCES Orders(OrderID),
    ProductID NUMBER REFERENCES Products(ProductID),
    Quantity NUMBER(10, 2),
    Notes UROWID -- Deprecated in Oracle 21c; consider replacing with VARCHAR2 or CLOB
);

-- Table: Categories
CREATE TABLE Categories (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(100),
    Description LONG -- Deprecated in Oracle 21c; replace with CLOB
);

-- Table: ProductCategories
CREATE TABLE ProductCategories (
    ProductID NUMBER REFERENCES Products(ProductID),
    CategoryID NUMBER REFERENCES Categories(CategoryID),
    PRIMARY KEY (ProductID, CategoryID)
);

-- Table: AuditLogs (Using Flashback, Deprecated Syntax Example)
CREATE TABLE AuditLogs (
    LogID NUMBER PRIMARY KEY,
    Action VARCHAR2(50),
    ActionDate DATE DEFAULT SYSDATE
) ENABLE ROW MOVEMENT; -- ENABLE ROW MOVEMENT syntax is discouraged in Oracle 21c

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID NUMBER PRIMARY KEY,
    DiscountCode VARCHAR2(50),
    DiscountAmount NUMBER(10, 2),
    ExpiryDate DATE,
    Metadata LONG RAW -- Deprecated in Oracle 21c; replace with BLOB
);

-- Sample Stored Procedure with Deprecated Features
CREATE OR REPLACE PROCEDURE ProcessOrder (p_OrderID NUMBER) AS
    v_TotalPrice NUMBER(10, 2);
BEGIN
    -- Using UTL_FILE (partially deprecated in favor of DBMS_CLOUD in 21c)
    DECLARE
        v_File UTL_FILE.FILE_TYPE;
    BEGIN
        v_File := UTL_FILE.FOPEN('LOG_DIR', 'OrderLog.txt', 'W');
        UTL_FILE.PUT_LINE(v_File, 'Processing Order: ' || p_OrderID);
        UTL_FILE.FCLOSE(v_File);
    END;

    -- Deprecated feature: Implicit conversion of LONG to VARCHAR2
    SELECT SUM(od.Quantity * p.Price)
    INTO v_TotalPrice
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = p_OrderID;

    DBMS_OUTPUT.PUT_LINE('Total Price for Order ' || p_OrderID || ': ' || v_TotalPrice);
END;
/

-- Comment: Replace LONG, LONG RAW, RAW, BFILE, UROWID with modern alternatives in Oracle 21c

-- Oracle 21c Upgrade Script
-- Replace LONG with CLOB, modify deprecated features

-- Table: Users
CREATE TABLE Users (
    UserID NUMBER PRIMARY KEY,
    UserName VARCHAR2(100),
    UserEmail VARCHAR2(100),
    UserProfile CLOB, -- Replaced LONG with CLOB
    UserPassword VARCHAR2(2000) ENCRYPT -- Replaced RAW with encrypted VARCHAR2
);

-- Table: Products
CREATE TABLE Products (
    ProductID NUMBER PRIMARY KEY,
    ProductName VARCHAR2(100),
    ProductDescription CLOB, -- Replaced LONG with CLOB
    Price NUMBER(10, 2),
    ProductImage BLOB -- Replaced BFILE with SecureFile LOB
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID NUMBER PRIMARY KEY,
    UserID NUMBER REFERENCES Users(UserID),
    OrderDate DATE,
    Comments BLOB -- Replaced LONG RAW with BLOB
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID NUMBER PRIMARY KEY,
    OrderID NUMBER REFERENCES Orders(OrderID),
    ProductID NUMBER REFERENCES Products(ProductID),
    Quantity NUMBER(10, 2),
    Notes CLOB -- Replaced UROWID with CLOB
);

-- Table: Categories
CREATE TABLE Categories (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(100),
    Description CLOB -- Replaced LONG with CLOB
);

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID NUMBER PRIMARY KEY,
    DiscountCode VARCHAR2(50),
    DiscountAmount NUMBER(10, 2),
    ExpiryDate DATE,
    Metadata BLOB -- Replaced LONG RAW with BLOB
);

-- Modify Stored Procedure for Oracle 21c Compatibility
CREATE OR REPLACE PROCEDURE ProcessOrder (p_OrderID NUMBER) AS
    v_TotalPrice NUMBER(10, 2);
BEGIN
    -- Replaced UTL_FILE with DBMS_CLOUD.FILE_WRITE
    DBMS_CLOUD.FILE_WRITE(
        credential_name => 'LOG_CRED',
        file_uri => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/log/b/orderlogs',
        content => 'Processing Order: ' || p_OrderID
    );

    SELECT SUM(od.Quantity * p.Price)
    INTO v_TotalPrice
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = p_OrderID;

    DBMS_OUTPUT.PUT_LINE('Total Price for Order ' || p_OrderID || ': ' || v_TotalPrice);
END;
/ -- End of Script
