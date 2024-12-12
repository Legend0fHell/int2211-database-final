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

-- LẤY DOANH THU HÀNG NGÀY
DROP PROCEDURE IF EXISTS GetDailyRevenue $$
CREATE PROCEDURE GetDailyRevenue(IN targetDate DATE)
BEGIN
    SELECT
        DATE(o.orderTime) AS OrderDate,
        COUNT(DISTINCT o.orderID) AS TotalOrders,
        SUM(od.finalPrice) AS TotalRevenue
    FROM orders o
    JOIN order_detail od ON o.orderID = od.orderID
    WHERE DATE(o.orderTime) = targetDate
    GROUP BY OrderDate;
END $$

-- XUẤT HÓA ĐƠN
DROP PROCEDURE IF EXISTS ExportInvoice $$
CREATE PROCEDURE ExportInvoice(IN orderID INT)
BEGIN
    SELECT
        o.orderID AS OrderID,
        CASE 
            WHEN od.serviceID = 0 THEN pmo.name
            ELSE sd.description
        END AS ItemName,
        o.orderTime AS OrderTime,
        od.originalPrice AS OriginalPrice,
        od.finalPrice AS FinalPrice,
        p.name AS DiscountName
    FROM orders o
    JOIN order_detail od ON o.orderID = od.orderID -- MAI CHECK LOGIC JOIN TÙM LUM
    JOIN phone ph on ph.orderID = od.orderID
    LEFT JOIN phone_model_option pmo ON ph.phoneModelOptionID = pmo.phoneModelOptionID
    LEFT JOIN service_detail sd ON od.serviceID = sd.serviceID
    LEFT JOIN promotion p ON od.promotionID = p.promotionID
    WHERE o.orderID = orderID;
END $$

DELIMITER ;

CALL ExportInvoice(1);