DELIMITER $
$


-- QUẢN LÝ SẢN PHẨM 


-- 1. LỌC SẢN PHẨM THEO MANUFACTURER
DROP PROCEDURE IF EXISTS GetPhonesByManufacturer
$$

CREATE PROCEDURE GetPhonesByManufacturer(IN manufacturerName VARCHAR
(50))
BEGIN
    SELECT pm.name AS PhoneName, pm.countView, pm.countSold, mf.name AS Manufacturer
    FROM phone_model pm
        JOIN manufacturer mf ON pm.manufacturerID = mf.manufacturerID
    WHERE mf.name = manufacturerName;
END
$$

-- 2. LỌC SẢN PHẨM THEO GIÁ TIỀN
DROP PROCEDURE IF EXISTS GetPhonesByPrice
$$
CREATE PROCEDURE GetPhonesByPrice(IN minPrice INT, IN maxPrice INT)
BEGIN
    SELECT
        pm.name AS PhoneModel, pmo.name AS OptionName,
        pmo.price AS Price, mf.name AS Manufacturer
    FROM phone_model pm
        JOIN phone_model_option pmo ON pm.phoneModelID = pmo.phoneModelID
        JOIN manufacturer mf ON pm.manufacturerID = mf.manufacturerID
    WHERE pmo.price BETWEEN minPrice AND maxPrice
    ORDER BY pmo.price ASC;
END
$$

-- 3. LỌC SẢN PHẨM BÁN CHẠY TRONG THÁNG
DROP PROCEDURE IF EXISTS GetBestSellingPhones
$$
CREATE PROCEDURE GetBestSellingPhones(IN targetMonth INT, IN targetYear INT)
BEGIN
    SELECT
        pm.name AS PhoneModel, pmo.name AS OptionName,
        SUM(od.quantity) AS TotalSold
    FROM phone_model pm
        JOIN phone_model_option pmo ON pm.phoneModelID = pmo.phoneModelID
        JOIN order_detail od ON pmo.phoneModelOptionID = od.phoneModelOptionID
        JOIN orders o ON od.orderID = o.orderID
    WHERE MONTH(o.orderTime) = targetMonth AND YEAR(o.orderTime) = targetYear
    GROUP BY pm.phoneModelID
    ORDER BY TotalSold DESC;
END
$$


-- QUẢN LÝ CỬA HÀNG


-- 4. TÌM KIẾM ĐỊA CHỈ GẦN NGƯỜI DÙNG NHẤT 
DROP PROCEDURE IF EXISTS GetNearbyStores
$$

CREATE PROCEDURE GetNearbyStores(IN userLongitude DECIMAL
(10, 5), IN userLatitude DECIMAL
(10, 5))
BEGIN
    SELECT
        storeID,
        name AS StoreName,
        address,
        phoneNumber,
        SQRT(POW(gps_longitude - userLongitude, 2) + POW(gps_latitude - userLatitude, 2)) AS Distance
    FROM store
    ORDER BY Distance ASC;
END
$$

-- 5. LẤY SẢN PHẨM ĐANG GIẢM GIÁ TRONG NGÀY
DROP PROCEDURE IF EXISTS GetDiscountedProducts
$$

CREATE PROCEDURE GetDiscountedProducts(IN sDate DATE, IN eDate DATE)
BEGIN
    SELECT
        pm.name AS ProductName,
        pmo.price AS OriginalPrice,
        pmd.discountPercent AS DiscountPercent,
        (pmo.price - (pmo.price * pmd.discountPercent / 100)) AS DiscountedPrice
    FROM promotion_detail_phone pmd
        JOIN phone_model pm ON pm.phoneModelID = pmd.phoneModelID
        JOIN phone_model_option pmo ON pmo.phoneModelOptionID = pmd.phoneModelOptionID
        JOIN promotion p ON p.promotionID = pmd.promotionID
    WHERE p.startDate <= sDate AND p.endDate >= eDate;
END
$$


-- QUẢN LÝ KINH DOANH


-- 6. LẤY DOANH THU HÀNG NGÀY
DROP PROCEDURE IF EXISTS GetDailyRevenue
$$

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
END
$$

DELIMITER ;