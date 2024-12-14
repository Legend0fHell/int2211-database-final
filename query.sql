USE thegioididong;
-- CÓ VẺ LÀ TRONG QUERY SẼ LÀ LÀM THỐNG KÊ CÁC DỮ LIỆU TỪ CÁC BẢNG KHÁC NHAU

-- Lấy danh sách tất cả các điện thoại và thông tin khuyến mãi (nếu có), bao gồm cả các điện thoại không có khuyến mãi.
SELECT 
    pm.name AS PhoneModelName,
    p.name AS PromotionName,
    CONCAT(p.startDate, ' - ', p.endDate) AS PromotionDate
FROM 
    phone_model pm
LEFT OUTER JOIN 
    promotion_detail_phone pdp ON pm.phoneModelID = pdp.phoneModelID
LEFT OUTER JOIN 
    promotion p ON pdp.promotionID = p.promotionID;

-- Lấy danh sách tất cả các điện thoại có số lượng bán > 50
SELECT 
    pm.name AS PhoneModelName,
    COUNT(od.phoneID) AS TotalSold
FROM
    phone_model pm
INNER JOIN
    phone p ON pm.phoneModelID = p.phoneModelID
INNER JOIN
    order_detail od ON p.phoneID = od.phoneID
GROUP BY
    pm.name
HAVING
    TotalSold > 50;

-- Lấy tổng doanh thu của từng cửa hàng từ bảng orders và order_detail.
SELECT 
    s.name AS StoreName,
    SUM(od.finalPrice) AS TotalRevenue
FROM 
    orders o
INNER JOIN 
    order_detail od ON o.orderID = od.orderID
INNER JOIN 
    store s ON o.fromStoreID = s.storeID
GROUP BY 
    s.name
ORDER BY 
    TotalRevenue DESC;

-- Lấy số lượng điện thoại tồn kho
SELECT 
    s.name AS StoreName,
    COUNT(p.phoneID) AS TotalPhonesLeft
FROM
    phone p
INNER JOIN
    store s ON p.inStoreID = s.storeID
WHERE p.status = 'InStore'
GROUP BY
    s.name
ORDER BY
    TotalPhonesLeft DESC;

-- LẤY DANH SÁCH ĐIỆN THOẠI VÀ RATING TRUNG BÌNH CỦA NÓ
SELECT 
    pm.name AS PhoneModelName,
    COUNT(pr.reviewID) AS TotalReviews,
    AVG(pr.rating) AS AverageRating
FROM
    phone_review pr
INNER JOIN
    phone_model pm ON pr.phoneModelID = pm.phoneModelID
GROUP BY
    pm.name
ORDER BY
    AverageRating DESC;

-- TRÍCH XUẤT THÔNG TIN TECH_SPEC CỦA CÁC ĐIỆN THOẠI
SELECT 
    pm.name AS PhoneModelName,
    ts.name AS TechSpecName,
    pts.infoText AS InfoText,
    pts.infoNum AS InfoNum
FROM
    phone_tech_spec pts
INNER JOIN
    phone_model_option pmo ON pts.phoneModelOptionID = pmo.phoneModelOptionID
INNER JOIN
    phone_model pm ON pmo.phoneModelID = pm.phoneModelID
INNER JOIN
    technical_spec ts ON pts.techSpecID = ts.techSpecID
ORDER BY
    pm.name, ts.name;

-- TRÍCH XUẤT THÔNG TIN CỦA CÁC BÀI VIẾT
SELECT articleID, content
FROM article;

-- Lấy danh sách các điện thoại có giá lớn hơn mức giá trung bình sử dụng where.
SELECT 
    pmo.name AS PhoneOptionName,
    pmo.price AS Price
FROM
    phone_model_option pmo
WHERE 
    pmo.price > (SELECT AVG(price) FROM phone_model_option);


    
