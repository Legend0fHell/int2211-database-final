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



-- TỰ ĐỘNG KÍCH HOẠT BẢO HÀNH CHO SẢN PHẨM MỚI MUA
DROP TRIGGER IF EXISTS after_order_detail_insert $$
CREATE TRIGGER after_order_detail_insert
AFTER INSERT ON order_detail
FOR EACH ROW
BEGIN
    -- Lấy ngày hiện tại
    DECLARE v_current_date DATE;
    SET v_current_date = CURDATE();

    -- Lấy ngày hết hạn bảo hành
    DECLARE v_warranty_end_date DATE;
    SET v_warranty_end_date = DATE_ADD(v_current_date, INTERVAL 12 MONTH);

    -- Thêm bảo hành cho sản phẩm
    INSERT INTO warranty
    VALUES (NEW.orderDetailID, v_current_date, v_warranty_end_date);
END $$


-- KIỂM TRA DỮ LIỆU TRƯỚC KHI THÊM VÀO BẢNG ORDERS
DROP TRIGGER IF EXISTS before_insert_orders $$

CREATE TRIGGER before_insert_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Kiểm tra userID
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE userID = NEW.userID AND role = 'Customer'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid userID: Must be a Customer';
    END IF;

    -- Kiểm tra employeeID
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE userID = NEW.employeeID AND role = 'Employee'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid employeeID: Must be an Employee';
    END IF;
END$$

DELIMITER ;
