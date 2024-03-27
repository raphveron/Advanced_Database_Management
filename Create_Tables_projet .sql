
DROP TABLE PurchaseOrderDetail;
DROP TABLE PurchaseOrderHeader;
DROP TABLE ProductVendor;
DROP TABLE Vendor;
DROP TABLE Transaction_History;
--TABLE Vendor  
CREATE TABLE Vendor (
    BusinessEntityID NUMBER PRIMARY KEY,
    AccountNumber VARCHAR2(50),
    Name VARCHAR2(100),
    CreditRating NUMBER,
    PreferredVendorStatus VARCHAR2(10),
    ActiveFlag VARCHAR2(10),
    PurchasingWebServiceURL VARCHAR2(150),
    ModifiedDate DATE,
    FOREIGN KEY (BusinessEntityID) REFERENCES Vendor(BusinessEntityID)
);

--Table ProductVendor
CREATE TABLE ProductVendor (
    ProductID NUMBER,
    BusinessEntityID NUMBER,
    AverageLeadTime NUMBER,
    StandardPrice NUMBER,
    LastReceiptCost NUMBER,
    LastReceiptDate DATE,
    MinOrderQty NUMBER,
    MaxOrderQty NUMBER,
    OnOrderQty NUMBER,
    UnitMeasureCode VARCHAR2(10),
    ModifiedDate DATE,
    PRIMARY KEY (ProductID, BusinessEntityID),
    FOREIGN KEY (BusinessEntityID) REFERENCES Vendor(BusinessEntityID)
);

--Table PurchaseOrderDetail
CREATE TABLE PurchaseOrderDetail (
    PurchaseOrderID NUMBER,
    PurchaseOrderDetailID NUMBER PRIMARY KEY,
    DueDate DATE,
    OrderQty NUMBER,
    ProductID NUMBER,
    BusinessEntityID NUMBER,
    UnitPrice NUMBER,
    ReceivedQty NUMBER,
    RejectedQty NUMBER,
    ModifiedDate DATE,
    FOREIGN KEY (ProductID, BusinessEntityID) REFERENCES ProductVendor(ProductID, BusinessEntityID)
);


--Table PurchaseOrderHeader
CREATE TABLE PurchaseOrderHeader (
    PurchaseOrderID NUMBER PRIMARY KEY,
    RevisionNumber NUMBER,
    Status NUMBER,
    EmployeeID NUMBER,
    VendorID NUMBER,
    ShipMethodID NUMBER,
    OrderDate DATE,
    ShipDate DATE,
    Subtotal NUMBER,
    TaxAmt NUMBER,
    Freight NUMBER,
    ModifiedDate DATE,
    FOREIGN KEY (VendorID) REFERENCES Vendor(BusinessEntityID)
);

--Transaction_History
CREATE TABLE Transaction_History AS
SELECT * FROM PurchaseOrderDetail WHERE 1=2;


--Testing BEFORE_UPDATE_POD Trigger:
UPDATE PurchaseOrderDetail
SET OrderQty = 100  -- Change this to a suitable value for your test
WHERE PurchaseOrderDetailID = 1;  -- Use an existing PurchaseOrderDetailID

--Testing BEFORE_UPDATE_POH Trigger:
UPDATE PurchaseOrderHeader
SET Subtotal = 2000  -- Set this to a new value for testing
WHERE PurchaseOrderID = 1;  -- Use an existing PurchaseOrderID

