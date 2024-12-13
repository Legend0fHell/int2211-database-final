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
    IN status ENUM('Active', 'InStore', 'Inactive', 'Repairing'),
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

-- THEO DÕI SỐ LƯỢNG TỔN KHO CỦA TỪNG MẪU ĐIỆN THOẠI Ở MỖI CỦA HÀNG
drop procedure if exists checkStockLevel $$
create procedure checkStockLevel(in phoneModelID int)
begin
    select pm.name as PhoneModel, 
           s.name as StoreName, 
           count(p.phoneID) as StockLevel
    from phone p
    join phone_model pm on p.phoneModelID = pm.phoneModelID
    join store s on p.inStoreID = s.storeID
    where pm.phoneModelID = phoneModelID 
      and p.status = 'InStore'
    group by pm.name, s.name;
end $$

-- QUẢN LÝ SỐ LƯỢNG ĐƯỢC BÁN RA CỦA TỪNG MẪU ĐIỆN THOẠI
drop procedure if exists checkSoldLevel $$
create procedure checkSoldLevel(in phoneModelID int)
begin
    select pm.name as PhoneModel, 
           count(distinct od.orderID) as TotalOrders, 
           sum(od.quantity) as TotalSold
    from phone_model pm
    join phone p on pm.phoneModelID = p.phoneModelID
    join order_detail od on p.phoneID = od.phoneID
    where pm.phoneModelID = phoneModelID
    group by pm.name;
end $$


-- lỊCH SỬ MUA HÀNG CỦA KHÁCH HÀNG
drop procedure if exists checkOrderHistory $$
create procedure checkOrderHistory(in userID int)
begin
    SELECT o.userID, u.fullName, o.orderID, o.orderTime, o.status, o.shippedTime, SUM(od.finalPrice) AS TotalPrice
    FROM 
        orders o
    JOIN order_detail od ON o.orderID = od.orderID
    JOIN users u ON u.userID = o.userID
    WHERE o.userID = 21
    GROUP BY o.orderID;
    end $$

DELIMITER ;




