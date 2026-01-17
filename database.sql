MYSQL CODE
CREATE DATABASE INVEN;
USE  INVEN;
-- DDL: Create Tables and Define Relationships
-- Drop tables in reverse order for a clean setup
DROP TABLE IF EXISTS Report;
DROP VIEW IF EXISTS High_Value_Customer_View;
DROP VIEW IF EXISTS Admin_Activity_Report_View;
DROP VIEW IF EXISTS Supplier_Delivery_Report_View;
DROP VIEW IF EXISTS Current_Inventory_Status_View;
DROP VIEW IF EXISTS Purchase_Summary_View;
DROP PROCEDURE IF EXISTS Place_Purchase_Order;
DROP FUNCTION IF EXISTS Get_Reorder_Status;
DROP TRIGGER IF EXISTS trg_Purchase_Stock_OUT;
DROP TRIGGER IF EXISTS trg_Supply_Stock_IN;
DROP TRIGGER IF EXISTS trg_Update_PurchaseOrder_Total;
DROP TRIGGER IF EXISTS trg_Update_SupplyOrder_Total;

DROP TABLE IF EXISTS PurchaseOrderDetail;
DROP TABLE IF EXISTS SupplyOrderDetail;
DROP TABLE IF EXISTS PurchaseOrder;
DROP TABLE IF EXISTS SupplyOrder;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Supplier;
DROP TABLE IF EXISTS Admin;

-- Admin Table
CREATE TABLE Admin (
    AdminID INT PRIMARY KEY,
    AdminName VARCHAR(100) NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
Role VARCHAR(50)
);
-- Customer Table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(255)
);
-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(255)
);
-- Product Table (Includes FK to AdminID)
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10, 2) NOT NULL,
    QuantityInStock INT DEFAULT 0,
    AdminID INT,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);
-- PurchaseOrder Table
CREATE TABLE PurchaseOrder (
    PurchaseOrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
-- SupplyOrder Table
CREATE TABLE SupplyOrder (
    SupplyOrderID INT PRIMARY KEY,
    SupplierID INT,
    OrderDate DATE NOT NULL,
    TotalCost DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);
-- Report Table
CREATE TABLE Report (
    ReportID INT PRIMARY KEY,
    AdminID INT,
    ReportDate DATE NOT NULL,
    ReportType VARCHAR(50),
    Description LONGTEXT, -- Corrected to LONGTEXT for MySQL compatibility
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);
-- Junction Table for PurchaseOrder (Many-to-Many)
CREATE TABLE PurchaseOrderDetail (
    PurchaseOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    SalePrice DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (PurchaseOrderID, ProductID),
    FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrder(PurchaseOrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
-- Junction Table for SupplyOrder (Many-to-Many)
CREATE TABLE SupplyOrderDetail (
    SupplyOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitCost DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (SupplyOrderID, ProductID),
    FOREIGN KEY (SupplyOrderID) REFERENCES SupplyOrder(SupplyOrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- DML: Insert Sample Data
INSERT INTO Admin VALUES (1, 'Ayesha Ahmad', 'ayesha_admin', 'admin123', 'Manager');
INSERT INTO Admin VALUES (2, 'Zain Raza', 'zain_admin', 'admin456', 'Supervisor');
INSERT INTO Admin VALUES (3, 'Faizan Malik', 'faizan_admin', 'admin789', 'Data Analyst');
INSERT INTO Admin VALUES (4, 'Mehwish Noor', 'mehwish_admin', 'mehwish321', 'Inventory Manager');

INSERT INTO Customer VALUES (1, 'Ali Khan', '03123456789', 'ali@gmail.com', 'Karachi');
INSERT INTO Customer VALUES (2, 'Sara Iqbal', '03214567890', 'sara@gmail.com', 'Lahore');
INSERT INTO Customer VALUES (3, 'Bilal Ahmad', '03335678901', 'bilal@yahoo.com', 'Islamabad');
INSERT INTO Customer VALUES (4, 'Nida Farooq', '03001234567', 'nida.farooq@gmail.com', 'Rawalpindi');
INSERT INTO Customer VALUES (5, 'Usman Tariq', '03451112223', 'usman@yahoo.com', 'Peshawar');
INSERT INTO Customer VALUES (6, 'Hira Sajjad', '03111223344', 'hira@live.com', 'Multan');

INSERT INTO Supplier VALUES (1, 'Tech Supply Co.', '03211234567', 'supply@tech.com', 'Lahore');
INSERT INTO Supplier VALUES (2, 'Office Solutions', '03456789012', 'office@supplies.com', 'Faisalabad');
INSERT INTO Supplier VALUES (3, 'Pak IT Distributors', '03118889900', 'sales@pakit.com', 'Quetta');
INSERT INTO Supplier VALUES (4, 'Galaxy Supplies', '03229997766', 'contact@galaxysupplies.pk', 'Sialkot');

INSERT INTO Product (ProductID, ProductName, Category, Price, QuantityInStock, AdminID)
VALUES
(101, 'Wireless Mouse', 'Electronics', 1200.00, 150, 4),
(102, 'Mechanical Keyboard', 'Electronics', 3500.00, 100, 4),
(103, 'Laptop Stand', 'Accessories', 2200.00, 75, 4),
(104, 'USB-C Hub', 'Accessories', 1800.00, 90, 4),
(105, 'Webcam HD', 'Electronics', 3000.00, 60, 4),
(106, 'Bluetooth Speaker', 'Audio', 4500.00, 40, 4),
(107, 'LED Monitor 24"', 'Displays', 17000.00, 30, 4);
-- TotalAmount will be updated by Triggers (Initial value 0.00)
INSERT INTO PurchaseOrder (PurchaseOrderID, CustomerID, OrderDate) VALUES
(201, 1, '2024-06-01'),
(202, 2, '2024-06-05'),
(203, 3, '2024-06-08'),
(204, 4, '2024-06-10'),
(205, 5, '2024-06-11'),
(206, 6, '2024-06-12');
-- Inserting details triggers stock decrease and TotalAmount calculation
INSERT INTO PurchaseOrderDetail VALUES (201, 101, 2, 1200.00);
INSERT INTO PurchaseOrderDetail VALUES (202, 102, 1, 3500.00);
INSERT INTO PurchaseOrderDetail VALUES (203, 103, 1, 2200.00);
INSERT INTO PurchaseOrderDetail VALUES (203, 104, 1, 1800.00);
INSERT INTO PurchaseOrderDetail VALUES (204, 105, 1, 3000.00);
INSERT INTO PurchaseOrderDetail VALUES (204, 106, 1, 4500.00);
INSERT INTO PurchaseOrderDetail VALUES (205, 107, 1, 12000.00);
INSERT INTO PurchaseOrderDetail VALUES (206, 101, 1, 1000.00);
INSERT INTO PurchaseOrderDetail VALUES (206, 103, 1, 1000.00);
-- TotalCost will be updated by Triggers (Initial value 0.00)
INSERT INTO SupplyOrder (SupplyOrderID, SupplierID, OrderDate) VALUES
(301, 1, '2024-05-25'),
(302, 2, '2024-06-02'),
(303, 3, '2024-06-03'),
(304, 4, '2024-06-04');
-- Inserting details triggers stock increase and TotalCost calculation
INSERT INTO SupplyOrderDetail VALUES (301, 101, 50, 500.00);
INSERT INTO SupplyOrderDetail VALUES (301, 102, 50, 700.00);
INSERT INTO SupplyOrderDetail VALUES (302, 103, 20, 1500.00);
INSERT INTO SupplyOrderDetail VALUES (302, 104, 10, 1500.00);
INSERT INTO SupplyOrderDetail VALUES (303, 105, 20, 2000.00);
INSERT INTO SupplyOrderDetail VALUES (303, 106, 10, 1500.00);
INSERT INTO SupplyOrderDetail VALUES (304, 107, 2, 15000.00);

INSERT INTO Report VALUES (401, 1, '2024-06-01', 'Purchase', 'Purchase order report for June 1st');
INSERT INTO Report VALUES (402, 2, '2024-06-05', 'Supply', 'Supply order from Office Solutions on June 2nd');
INSERT INTO Report VALUES (403, 3, '2024-06-10', 'Purchase', 'Customer purchase log generated by Faizan');
INSERT INTO Report VALUES (404, 4, '2024-06-12', 'Supply', 'June supply overview generated by Mehwish');
-- TRIGGERS: Automated stock and total updates
DELIMITER //
-- 1. Decrease Stock on New Purchase Order Detail
CREATE TRIGGER trg_Purchase_Stock_OUT
AFTER INSERT ON PurchaseOrderDetail
FOR EACH ROW
BEGIN
    UPDATE Product
    SET QuantityInStock = QuantityInStock - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END //
-- 2. Increase Stock on New Supply Order Detail
CREATE TRIGGER trg_Supply_Stock_IN
AFTER INSERT ON SupplyOrderDetail
FOR EACH ROW
BEGIN
    UPDATE Product
    SET QuantityInStock = QuantityInStock + NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END //
-- 3. Update PurchaseOrder Total Amount (ensures data in one relation updates data in others)
CREATE TRIGGER trg_Update_PurchaseOrder_Total
AFTER INSERT ON PurchaseOrderDetail
FOR EACH ROW
BEGIN
    UPDATE PurchaseOrder
    SET TotalAmount = (
        SELECT SUM(Quantity * SalePrice)
        FROM PurchaseOrderDetail
        WHERE PurchaseOrderID = NEW.PurchaseOrderID )
    WHERE PurchaseOrderID = NEW.PurchaseOrderID;
END //
-- 4. Update SupplyOrder Total Cost (ensures data in one relation updates data in others)
CREATE TRIGGER trg_Update_SupplyOrder_Total
AFTER INSERT ON SupplyOrderDetail
FOR EACH ROW
BEGIN
    UPDATE SupplyOrder
    SET TotalCost = (
        SELECT SUM(Quantity * UnitCost)
        FROM SupplyOrderDetail
        WHERE SupplyOrderID = NEW.SupplyOrderID  )
    WHERE SupplyOrderID = NEW.SupplyOrderID;
END //
DELIMITER ;
-- STORED PROCEDURE: Handle Order Placement Transaction (with stock check)
DELIMITER //
CREATE PROCEDURE Place_Purchase_Order (
    IN p_PurchaseOrderID INT,
    IN p_CustomerID INT,
    IN p_OrderDate DATE,
    IN p_ProductID INT,
    IN p_Quantity INT)
BEGIN
    DECLARE v_Price DECIMAL(10, 2);
    DECLARE v_Stock INT;
    SELECT Price, QuantityInStock INTO v_Price, v_Stock
    FROM Product
    WHERE ProductID = p_ProductID;
    -- Check for sufficient stock
    IF v_Stock >= p_Quantity THEN
        -- 1. Insert or ignore into main PurchaseOrder (if it doesn't exist)
        INSERT IGNORE INTO PurchaseOrder (PurchaseOrderID, CustomerID, OrderDate, TotalAmount)
        VALUES (p_PurchaseOrderID, p_CustomerID, p_OrderDate, 0.00);
        -- 2. Insert into PurchaseOrderDetail (Triggers will handle stock and total update)
        INSERT INTO PurchaseOrderDetail (PurchaseOrderID, ProductID, Quantity, SalePrice)
        VALUES (p_PurchaseOrderID, p_ProductID, p_Quantity, v_Price);
        SELECT 'SUCCESS: Order placed and inventory updated.' AS Status;
    ELSE
        SELECT CONCAT('FAILED: Insufficient stock for ProductID ', p_ProductID, '. Available: ', v_Stock) AS Status;
    END IF;
END //
DELIMITER ;

-- VIEWS: Simplify Reporting and Data Access
-- V1: Purchase_Summary_View
CREATE VIEW Purchase_Summary_View AS
SELECT
    PO.PurchaseOrderID,
    PO.OrderDate,
    C.CustomerName,
    PO.TotalAmount,
    COUNT(POD.ProductID) AS TotalItems,
    A.AdminName AS InventoryManager
FROM
    PurchaseOrder PO
JOIN
    Customer C ON PO.CustomerID = C.CustomerID
LEFT JOIN
    PurchaseOrderDetail POD ON PO.PurchaseOrderID = POD.PurchaseOrderID
LEFT JOIN
    Product P ON POD.ProductID = P.ProductID
LEFT JOIN
    Admin A ON P.AdminID = A.AdminID
GROUP BY
PO.PurchaseOrderID, PO.OrderDate, C.CustomerName, PO.TotalAmount, A.AdminName;

-- V2: Current_Inventory_Status_View (Uses the custom function)
CREATE VIEW Current_Inventory_Status_View AS
SELECT
    P.ProductID,
    P.ProductName,
    P.Category,
    P.QuantityInStock,
    P.Price,
    Get_Reorder_Status(P.ProductID) AS InventoryStatus
FROM
    Product P;
-- V3: Supplier_Delivery_Report_View
CREATE VIEW Supplier_Delivery_Report_View AS
SELECT
    SO.SupplyOrderID,
    SO.OrderDate AS DeliveryDate,
    S.SupplierName,
    SO.TotalCost,
    COUNT(SOD.ProductID) AS UniqueProductsSupplied
FROM
    SupplyOrder SO
JOIN
    Supplier S ON SO.SupplierID = S.SupplierID
LEFT JOIN
    SupplyOrderDetail SOD ON SO.SupplyOrderID = SOD.SupplyOrderID
GROUP BY
    SO.SupplyOrderID, SO.OrderDate, S.SupplierName, SO.TotalCost;
-- V4: Admin_Activity_Report_View
CREATE VIEW Admin_Activity_Report_View AS
SELECT
    R.ReportID,
    R.ReportDate,
    A.AdminName,
    A.Role AS AdminRole,
    R.ReportType,
    R.Description
FROM
    Report R
JOIN
    Admin A ON R.AdminID = A.AdminID;
-- V5: High_Value_Customer_View
CREATE VIEW High_Value_Customer_View AS
SELECT
    C.CustomerID,
    C.CustomerName,
    C.Email,
    SUM(PO.TotalAmount) AS TotalSpent
FROM
    Customer C
JOIN
    PurchaseOrder PO ON C.CustomerID = PO.CustomerID
GROUP BY
    C.CustomerID, C.CustomerName, C.Email
HAVING
    SUM(PO.TotalAmount) > 5000.0;



