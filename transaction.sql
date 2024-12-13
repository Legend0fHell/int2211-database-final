-- TRANSACTIONS CHO THÊM, XÓA, SỬA DỮ LIỆU TRONG USERS


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
    IN warrantyUntil DATE,
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
    IN status ENUM('Active', 'InStore', 'Inactive'),
    IN warrantyUntil DATE,
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


DELIMITER ;




