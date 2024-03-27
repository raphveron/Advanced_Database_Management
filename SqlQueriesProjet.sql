--SQL QUERIES
-- A. Vendors with Credit Rating 5 and ProductID > 500
SELECT V.Name, PV.ProductID
FROM Vendor V
JOIN ProductVendor PV ON V.BusinessEntityID = PV.BusinessEntityID
WHERE V.CreditRating = 5 AND PV.ProductID > 500;

-- B. Purchase Orders with Qty > 500
SELECT POH.PurchaseOrderID, POH.OrderDate, POD.PurchaseOrderDetailID, POD.OrderQty, POD.ProductID
FROM PurchaseOrderHeader POH
JOIN PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
WHERE POD.OrderQty > 500;

-- C. Orders 1400 to 1600
SELECT POH.PurchaseOrderID, POH.VendorID, POD.PurchaseOrderDetailID, POD.ProductID, POD.UnitPrice
FROM PurchaseOrderHeader POH
JOIN PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
WHERE POH.PurchaseOrderID BETWEEN 1400 AND 1600;

-- D. Orders and Cost per Vendor
SELECT V.BusinessEntityID, COUNT(POH.PurchaseOrderID) AS NumberOfOrders, SUM(POD.UnitPrice * POD.OrderQty) AS TotalCost
FROM Vendor V
JOIN PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
GROUP BY V.BusinessEntityID
ORDER BY TotalCost DESC;

-- E. Average Orders and Cost Across Vendors
SELECT AVG(NumberOfOrders) AS AvgOrders, AVG(TotalCost) AS AvgCost
FROM (
    SELECT V.BusinessEntityID, COUNT(POH.PurchaseOrderID) AS NumberOfOrders, SUM(POD.UnitPrice * POD.OrderQty) AS TotalCost
    FROM Vendor V
    JOIN PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
    JOIN PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
    GROUP BY V.BusinessEntityID
) VendorOrders;

-- F. Top 10 Vendors by Rejected Items Percentage
SELECT V.BusinessEntityID, (SUM(POD.RejectedQty) / SUM(POD.ReceivedQty)) * 100 AS RejectionPercentage
FROM Vendor V
JOIN PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
GROUP BY V.BusinessEntityID
ORDER BY RejectionPercentage DESC
FETCH FIRST 10 ROWS ONLY;

-- G. Top 10 Vendors by Largest Orders
SELECT V.BusinessEntityID, SUM(POD.OrderQty) AS TotalQuantity
FROM Vendor V
JOIN PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
GROUP BY V.BusinessEntityID
ORDER BY TotalQuantity DESC
FETCH FIRST 10 ROWS ONLY;

-- H. Top 10 Products by Quantity Purchased
SELECT POD.ProductID, SUM(POD.OrderQty) AS TotalQuantity
FROM PurchaseOrderDetail POD
GROUP BY POD.ProductID
ORDER BY TotalQuantity DESC
FETCH FIRST 10 ROWS ONLY;

-- I. Complex Queries with Analytic Functions (Example)
-- Example query to illustrate the use of analytic functions
SELECT ProductID, SUM(OrderQty) OVER (PARTITION BY ProductID) AS TotalOrdersPerProduct
FROM PurchaseOrderDetail
ORDER BY ProductID;

-- Triggers
-- J. Trigger for Transaction_History and PurchaseOrderDetail Updates
CREATE OR REPLACE TRIGGER Before_Update_POD
BEFORE UPDATE ON PurchaseOrderDetail
FOR EACH ROW
BEGIN
    INSERT INTO Transaction_History VALUES (:NEW.PurchaseOrderID, :NEW.PurchaseOrderDetailID, :NEW.DueDate, :NEW.OrderQty, :NEW.ProductID, :NEW.BusinessEntityID, :NEW.UnitPrice, :NEW.ReceivedQty, :NEW.RejectedQty, SYSDATE);
    UPDATE PurchaseOrderDetail
    SET ModifiedDate = SYSDATE
    WHERE PurchaseOrderDetailID = :NEW.PurchaseOrderDetailID;
END;

-- K. Trigger to Ensure SubTotal Consistency
CREATE OR REPLACE TRIGGER Before_Update_POH
BEFORE UPDATE OF Subtotal ON PurchaseOrderHeader
FOR EACH ROW
DECLARE
    TotalDetailAmount NUMBER;
BEGIN
    SELECT SUM(UnitPrice * OrderQty) INTO TotalDetailAmount
    FROM PurchaseOrderDetail
    WHERE PurchaseOrderID = :NEW.PurchaseOrderID;
    IF TotalDetailAmount != :NEW.Subtotal THEN
        RAISE_APPLICATION_ERROR(-20001, 'Subtotal not consistent with PurchaseOrderDetail data.');
    END IF;
END;
