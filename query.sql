USE thegioididong;

-- ĐỀ XUẤT 5 MẪU MÁY BÁN CHẠY NHẤT TỪ TRƯỚC ĐẾN GIỜ
SELECT 
        pm.name AS PhoneModel, 
        pm.countSold, 
        mf.name AS Manufacturer
    FROM phone_model pm
    JOIN manufacturer mf ON pm.manufacturerID = mf.manufacturerID
    ORDER BY pm.countSold DESC;

-- Lấy danh sách tất cả các điện thoại và thông tin khuyến mãi (nếu có), bao gồm cả các điện thoại không có khuyến mãi.
SELECT 
    pm.name AS PhoneModelName,
    p.name AS PromotionName,
    p.discountPercent AS Discount
FROM 
    phone_model pm
LEFT OUTER JOIN 
    promotion_detail_phone pdp ON pm.phoneModelID = pdp.phoneModelID
LEFT OUTER JOIN 
    promotion p ON pdp.promotionID = p.promotionID;

-- Lấy danh sách các điện thoại có giá lớn hơn mức giá trung bình.
SELECT 
    pmo.name AS PhoneOptionName,
    pmo.price AS Price
FROM 
    phone_model_option pmo
WHERE 
    pmo.price > (SELECT AVG(price) FROM phone_model_option);

-- Tính tổng số lượng bán ra cho từng nhà sản xuất dựa trên bảng tạm thời được tạo từ phone_model.
SELECT 
    mf.name AS ManufacturerName,
    SUM(temp.countSold) AS TotalSold
FROM 
    (SELECT manufacturerID, countSold FROM phone_model) temp
INNER JOIN 
    manufacturer mf ON temp.manufacturerID = mf.manufacturerID
GROUP BY 
    mf.name;

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
