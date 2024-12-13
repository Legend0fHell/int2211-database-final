-- TRANSACTIONS CHO THÊM, XÓA, SỬA DỮ LIỆU TRONG USERS
DELIMITER $$

DROP PROCEDURE IF EXISTS InsertUser $$
CREATE PROCEDURE InsertUser(
    IN userID INT,
    IN fullName VARCHAR(50),
    IN email VARCHAR(50),
    IN phone VARCHAR(15),
    IN address VARCHAR(100),
    IN provinceID INT,
    IN districtID INT,
    IN role ENUM('Customer', 'Employee'),
    IN storeID INT
)
BEGIN
    -- Bắt đầu giao dịch
    START TRANSACTION;

    BEGIN
        -- Thêm người dùng mới
        INSERT INTO users (userID, fullName, email, phone, address, provinceID, districtID, role, storeID)
        VALUES (userID, fullName, email, phone, address, provinceID, districtID, role, storeID);

        -- Kiểm tra nếu thêm không thành công
        IF ROW_COUNT() = 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Insert failed. Rolling back transaction.';
        END IF;
    END;

    -- Xác nhận giao dịch
    COMMIT;
END $$

DROP PROCEDURE IF EXISTS UpdateUser $$
CREATE PROCEDURE UpdateUser(
    IN userID INT,
    IN fullName VARCHAR(50),
    IN email VARCHAR(50),
    IN phone VARCHAR(15),
    IN address VARCHAR(100),
    IN provinceID INT,
    IN districtID INT,
    IN role ENUM('Customer', 'Employee'),
    IN storeID INT
)
BEGIN
    -- Bắt đầu giao dịch
    START TRANSACTION;

    BEGIN
        -- Cập nhật thông tin người dùng
        UPDATE users
        SET fullName = fullName,
            email = email,
            phone = phone,
            address = address,
            provinceID = provinceID,
            districtID = districtID,
            role = role,
            storeID = storeID
        WHERE userID = userID;

        -- Kiểm tra nếu cập nhật không thành công
        IF ROW_COUNT() = 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Update failed. Rolling back transaction.';
        END IF;
    END;

    -- Xác nhận giao dịch
    COMMIT;
END $$

DROP PROCEDURE IF EXISTS DeleteUser $$
CREATE PROCEDURE DeleteUser(IN userID INT)
BEGIN
    -- Bắt đầu giao dịch
    START TRANSACTION;

    BEGIN
        -- Xóa người dùng
        DELETE FROM users
        WHERE userID = userID;

        -- Kiểm tra nếu xóa không thành công
        IF ROW_COUNT() = 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Delete failed. Rolling back transaction.';
        END IF;
    END;

    -- Xác nhận giao dịch
    COMMIT;
END $$


-- TRANSACTIONS CHO THÊM, SỬA DỮ LIỆU TRONG PHONE


DROP PROCEDURE IF EXISTS InsertPhone $$
CREATE PROCEDURE InsertPhone(
    IN phoneID INT,
    IN ownedByUserID INT,
    IN warrantyID INT,
    IN inStoreID INT,
    IN phoneModelID INT,
    IN phoneModelOptionID INT,
    IN phoneCondition ENUM('New', 'Used', 'Refurbished'),
    IN customPrice INT,
    IN imei VARCHAR(15),
    IN status ENUM('Active', 'InStore', 'Inactive'),
    IN warrantyUntil DATE
)

BEGIN
    -- Bắt đầu giao dịch
    START TRANSACTION;

    BEGIN
        -- Thêm điện thoại mới
        INSERT INTO phone (phoneID, ownedByUserID, warrantyID, inStoreID, phoneModelID, phoneModelOptionID, phoneCondition, customPrice, imei, status, warrantyUntil)
        VALUES (phoneID, ownedByUserID, warrantyID, inStoreID, phoneModelID, phoneModelOptionID, phoneCondition, customPrice, imei, status, warrantyUntil);

        -- Kiểm tra nếu thêm không thành công
        IF ROW_COUNT() = 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Insert failed. Rolling back transaction.';
        END IF;
    END;

    -- Xác nhận giao dịch
    COMMIT;
END $$

DROP PROCEDURE IF EXISTS UpdatePhone $$
CREATE PROCEDURE UpdatePhone(
    IN phoneID INT,
    IN ownedByUserID INT,
    IN warrantyID INT,
    IN inStoreID INT,
    IN phoneModelID INT,
    IN phoneModelOptionID INT,
    IN phoneCondition ENUM('New', 'Used', 'Refurbished'),
    IN customPrice INT,
    IN imei VARCHAR(15),
    IN status ENUM('Active', 'InStore', 'Inactive', 'Repairing'),
    IN warrantyUntil DATE
)

BEGIN
    -- Bắt đầu giao dịch
    START TRANSACTION;

    BEGIN
        -- Cập nhật thông tin điện thoại
        UPDATE phone
        SET ownedByUserID = ownedByUserID,
            warrantyID = warrantyID,
            inStoreID = inStoreID,
            phoneModelID = phoneModelID,
            phoneModelOptionID = phoneModelOptionID,
            phoneCondition = phoneCondition,
            customPrice = customPrice,
            imei = imei,
            status = status,
            warrantyUntil = warrantyUntil
        WHERE phoneID = phoneID;

        -- Kiểm tra nếu cập nhật không thành công
        IF ROW_COUNT() = 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Update failed. Rolling back transaction.';
        END IF;
    END;

    -- Xác nhận giao dịch
    COMMIT;
END $$

-- THÊM VÀO ĐƠN HÀNG ĐIỆN THOẠI MỚI MUA
DROP PROCEDURE IF EXISTS PurchasePhone $$
CREATE PROCEDURE PurchasePhone(
    IN p_phoneModelID INT,
    IN p_phoneID INT,
    IN p_serviceID INT,
    IN p_userID INT,
    IN p_fromStoreID INT,
    IN p_employeeID INT,
    IN p_originalPrice INT,
    IN p_finalPrice INT
)
BEGIN
    START TRANSACTION;
    UPDATE phone_model
    SET countSold = countSold + 1
    WHERE phoneModelID = p_phoneModelID;

    INSERT INTO orders (orderTime, status, userID, fromStoreID, employeeID)
    VALUES (NOW(), 'Pending', p_userID, p_fromStoreID, p_employeeID);

    SET @newOrderID = LAST_INSERT_ID();
    INSERT INTO order_detail (orderID, phoneID, serviceID, originalPrice, finalPrice)
    VALUES (@newOrderID, p_phoneID, p_serviceID, p_originalPrice, p_finalPrice);
    COMMIT;
END $$

-- CẬP NHẬT TRẠNG THÁI ĐƠN HÀNG
DROP PROCEDURE IF EXISTS UpdateOrderStatusToDelivering $$
CREATE PROCEDURE UpdateOrderStatusToDelivering(
    IN p_orderID INT
)
BEGIN
    START TRANSACTION;
    UPDATE orders
    SET status = 'Delivering', shippedTime = NOW()
    WHERE orderID = p_orderID AND status = 'Preparing';

    COMMIT;
END $$

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;

CALL InsertUser(
    NULL, -- userID (NULL để AUTO_INCREMENT nếu userID là tự động)
    'Nguyen Van A', -- fullName
    'example@gmail.com', -- email
    '0912345678', -- phone
    '123 Example Street', -- address
    5, -- provinceID
    NULL, -- districtID
    'Customer', -- role
    23 -- storeID (NULL nếu không liên kết với store)
);

CALL PurchasePhone(
    2, -- phoneModelID
    5, -- phoneID
    6, -- sẻviceID
    1, -- userID
    1, -- fromStoreID
    1, -- employeeID
    15000000, -- originalPrice
    14000000 -- finalPrice
);


CALL UpdateOrderStatusToDelivering(1); -- orderID



