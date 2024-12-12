DELIMITER $$

-- CẬP NHẬT SỐ LƯỢNG ĐÃ BÁN CỦA PHONE_MODEL
DROP TRIGGER IF EXISTS after_order_insert $$
CREATE TRIGGER after_order_insert
AFTER INSERT ON order_detail
FOR EACH ROW
BEGIN
    -- Cập nhật số lượng đã bán của phone model
    UPDATE phone_model
    SET countSold = countSold + 1
    WHERE phoneModelID = (
        SELECT phoneModelID
        FROM phone
        WHERE phoneID = NEW.phoneID
    );
END $$

-- CẬP NHẬT GIÁ TIỀN ĐIỆN THOẠI NẾU NHƯ CÓ THÔNG TIN DISCOUNT MỚI
DROP TRIGGER IF EXISTS CalculateDiscountPrice $$

CREATE TRIGGER CalculateDiscountPrice
BEFORE INSERT ON order_detail
FOR EACH ROW
BEGIN
    DECLARE discountPercent DECIMAL(4,2);
    DECLARE discountFixed INT;
    DECLARE fixedNewPrice INT;

    -- Lấy thông tin giảm giá từ bảng promotion_detail_phone
    SELECT p.discountPercent, p.discountFixed, p.fixedNewPrice
    INTO discountPercent, discountFixed, fixedNewPrice
    FROM promotion_detail_phone p
    WHERE p.promotionID = NEW.promotionID 
      AND p.phoneModelID = (
        SELECT phoneModelID
        FROM phone
        WHERE phoneID = NEW.phoneID
      )
      AND p.phoneModelOptionID = (
        SELECT phoneModelOptionID
        FROM phone
        WHERE phoneID = NEW.phoneID
      )
    LIMIT 1;

    -- Tính toán giá trị finalPrice dựa trên thông tin giảm giá
    IF fixedNewPrice IS NOT NULL THEN
        SET NEW.finalPrice = fixedNewPrice;
    ELSEIF discountPercent IS NOT NULL THEN
        SET NEW.finalPrice = NEW.originalPrice - (NEW.originalPrice * discountPercent / 100);
    ELSEIF discountFixed IS NOT NULL THEN
        SET NEW.finalPrice = NEW.originalPrice - discountFixed;
    ELSE
        SET NEW.finalPrice = NEW.originalPrice; -- Không có giảm giá
    END IF;
END $$

-- TỰ ĐỘNG KÍCH HOẠT BẢO HÀNH CHO SẢN PHẨM MỚI MUA

DELIMITER ;
