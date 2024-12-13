DELIMITER $$

-- QUẢN LÝ SẢN PHẨM

-- LỌC SẢN PHẨM THEO MANUFACTURER
DROP PROCEDURE IF EXISTS GetPhonesByManufacturer $$
CREATE PROCEDURE GetPhonesByManufacturer(IN manufacturerName VARCHAR(50))
BEGIN
    SELECT 
        pm.name AS PhoneName, 
        pm.countView, 
        pm.countSold, 
        mf.name AS Manufacturer
    FROM phone_model pm
    JOIN manufacturer mf ON pm.manufacturerID = mf.manufacturerID
    WHERE mf.name = manufacturerName;
END $$

-- LỌC SẢN PHẨM THEO GIÁ TIỀN
DROP PROCEDURE IF EXISTS GetPhonesByPrice $$
CREATE PROCEDURE GetPhonesByPrice(IN minPrice INT, IN maxPrice INT)
BEGIN
    SELECT
        pm.name AS PhoneModel, 
        pmo.name AS OptionName,
        pmo.price AS Price, 
        mf.name AS Manufacturer
    FROM phone_model pm
    JOIN phone_model_option pmo ON pm.phoneModelID = pmo.phoneModelID
    JOIN manufacturer mf ON pm.manufacturerID = mf.manufacturerID
    WHERE pmo.price BETWEEN minPrice AND maxPrice
    ORDER BY pmo.price ASC;
END $$

-- ĐỀ XUẤT CÁC SẢN PHẨM TƯƠNG TỰ DỰA TRÊN ID VỚI PHONE CONDITION KHÁC NHAU
DROP PROCEDURE IF EXISTS GetSimilarPhones $$
CREATE PROCEDURE GetSimilarPhones(IN phoneID INT)
BEGIN
	SELECT DISTINCT pmo.name as PhoneName,
    p.customPrice, p.phoneCondition
    FROM phone p
    JOIN phone_model_option pmo ON pmo.phoneModelID = p.phoneModelID
    WHERE p.phoneModelID IN 
		(SELECT p1.phoneModelID FROM phone p1 
		WHERE p1.phoneID = phoneID);
END $$


-- QUẢN LÝ CỬA HÀNG


-- TÌM KIẾM ĐỊA CHỈ GẦN NGƯỜI DÙNG NHẤT
DROP PROCEDURE IF EXISTS GetNearbyStores $$
CREATE PROCEDURE GetNearbyStores(IN userLongitude DECIMAL(10, 5), IN userLatitude DECIMAL(10, 5))
BEGIN
    SELECT
        storeID,
        name AS StoreName,
        address,
        phoneNumber,
        SQRT(POW(gps_longitude - userLongitude, 2) + POW(gps_latitude - userLatitude, 2)) AS Distance
    FROM store
    ORDER BY Distance ASC;
END $$


-- QUẢN LÝ KINH DOANH


-- THỐNG KÊ CHI TIẾT DOANH THU HÀNG THÁNG
DROP PROCEDURE IF EXISTS ListMonthlyRevenue $$
CREATE PROCEDURE ListMonthlyRevenue(IN targetMonth INT, IN targetYear INT)
BEGIN
    SELECT
        DATE(o.orderTime) AS OrderDate,
        COUNT(DISTINCT o.orderID) AS TotalOrders,
        SUM(od.finalPrice) AS DailyRevenue
    FROM orders o
    JOIN order_detail od ON o.orderID = od.orderID
    WHERE YEAR(o.orderTime) = targetYear AND MONTH(o.orderTime) = targetMonth
    GROUP BY OrderDate
    ORDER BY OrderDate;
END $$

-- TÍNH TỔNG SỐ ĐƠN HÀNG VÀ TỔNG SỐ TIỀN NHÂN ĐƯỢC CỦA THÁNG
DROP PROCEDURE IF EXISTS GetMonthlyRevenue $$
CREATE PROCEDURE GetMonthlyRevenue(IN targetMonth INT, IN targetYear INT)
BEGIN
    SELECT
        MONTH(o.orderTime) AS Month,
        COUNT(DISTINCT o.orderID) AS TotalOrders,
        SUM(od.finalPrice) AS MonthlyRevenue
    FROM orders o
    JOIN order_detail od ON o.orderID = od.orderID
    WHERE YEAR(o.orderTime) = targetYear AND MONTH(o.orderTime) = targetMonth
    GROUP BY Month;
END $$

-- XUẤT HÓA ĐƠN
DROP PROCEDURE IF EXISTS ExportInvoice $$
CREATE PROCEDURE ExportInvoice(IN orderID INT)
BEGIN
    SELECT
        o.orderID AS OrderID,
        CASE 
            WHEN od.serviceID = 0 THEN pmo.name
            ELSE s.name
        END AS ItemName,
        o.orderTime AS OrderTime,
        od.originalPrice AS OriginalPrice,
        od.finalPrice AS FinalPrice,
        p.name AS DiscountName
    FROM orders o
    JOIN order_detail od ON o.orderID = od.orderID
    JOIN phone ph on ph.phoneID = od.phoneID
    LEFT JOIN phone_model_option pmo ON ph.phoneModelOptionID = pmo.phoneModelOptionID
    LEFT JOIN services s ON od.serviceID = s.serviceID
    LEFT JOIN promotion p ON od.promotionID = p.promotionID
    WHERE o.orderID = orderID;
END $$

-- TỔNG SỐ TIỀN PHẢI THANH TOÁN
DROP PROCEDURE IF EXISTS TotalMoneyCustomerHaveToPay $$
CREATE PROCEDURE TotalMoneyCustomerHaveToPay(IN orderID INT)
BEGIN
    SELECT
        o.orderID AS OrderID,
		u1.fullName AS EmployeeName,
        u2.fullName AS CustomerName,
        sto.name AS StoreName,
        sto.address AS StoreAdress,
        o.orderTime AS OrderTime,
        SUM(od.originalPrice) AS OriginalPrice,
        SUM(od.finalPrice) AS FinalPrice,
        SUM(od.originalPrice) - SUM(od.finalPrice) AS TotalMoneySaved 
    FROM orders o
    JOIN store sto on sto.storeID = o.FromStoreID
	JOIN users u1 on u1.userID = o.employeeID
    JOIN users u2 on u2.userID = o.userID
    JOIN order_detail od ON o.orderID = od.orderID
    GROUP BY o.orderID
    HAVING o.orderID = orderID;
END $$
DELIMITER ;

CALL GetMonthlyRevenue(2,2023);
CALL ListMonthlyRevenue(2,2023);
CALL TotalMoneyCustomerHaveToPay(3);
CALL ExportInvoice(3);