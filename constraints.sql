use thegioididong;

ALTER TABLE phone_model
ADD FOREIGN KEY (manufacturerID) REFERENCES manufacturer(manufacturerID),
ADD FOREIGN KEY (warrantyID) REFERENCES warranty(warrantyID),
ADD FOREIGN KEY (articleID) REFERENCES article(articleID);

ALTER TABLE phone_model_option
ADD FOREIGN KEY (phoneModelID) REFERENCES phone_model(phoneModelID),
ADD FOREIGN KEY (hexColorID) REFERENCES color(hexColorID);

ALTER TABLE phone_tech_spec
ADD FOREIGN KEY (phoneModelOptionID) REFERENCES phone_model_option(phoneModelOptionID),
ADD FOREIGN KEY (techSpecID) REFERENCES technical_spec(techSpecID);

ALTER TABLE phone_review
ADD FOREIGN KEY (phoneModelID) REFERENCES phone_model(phoneModelID),
ADD FOREIGN KEY (phoneModelOptionID) REFERENCES phone_model_option(phoneModelOptionID);

ALTER TABLE phone_review_detail
ADD FOREIGN KEY (reviewID) REFERENCES phone_review(reviewID);

ALTER TABLE phone
ADD FOREIGN KEY (phoneModelID) REFERENCES phone_model(phoneModelID),
ADD FOREIGN KEY (phoneModelOptionID) REFERENCES phone_model_option(phoneModelOptionID);

ALTER TABLE store
ADD FOREIGN KEY (provinceID) REFERENCES province(provinceID),
ADD FOREIGN KEY (districtID) REFERENCES district(districtID);

ALTER TABLE district
ADD FOREIGN KEY (provinceID) REFERENCES province(provinceID);

ALTER TABLE services
ADD FOREIGN KEY (serviceTypeID) REFERENCES service_type(serviceTypeID);

ALTER TABLE service_detail
ADD FOREIGN KEY (serviceID) REFERENCES services(serviceID);

ALTER TABLE users
ADD FOREIGN KEY (provinceID) REFERENCES province(provinceID),
ADD FOREIGN KEY (districtID) REFERENCES district(districtID);

ALTER TABLE order_detail
ADD FOREIGN KEY (orderID) REFERENCES orders(orderID);

ALTER TABLE promotion_detail_phone
ADD FOREIGN KEY (promotionID) REFERENCES promotion(promotionID);

ALTER TABLE promotion_detail_service
ADD FOREIGN KEY (promotionID) REFERENCES promotion(promotionID);

# Add default constraint to tables
ALTER TABLE orders
ALTER COLUMN status SET DEFAULT 'Pending';

ALTER TABLE users
ALTER COLUMN role SET DEFAULT 'Customer';

ALTER TABLE store
ALTER COLUMN openTime SET DEFAULT '08:00',
ALTER COLUMN closeTime SET DEFAULT '22:30';

# Add INDEX constraint to tables
ALTER TABLE phone_model
ADD INDEX idx_phoneModelID (phoneModelID);

ALTER TABLE phone_model_option
ADD INDEX idx_phoneModelOptionID (phoneModelOptionID);

ALTER TABLE technical_spec
ADD INDEX idx_techSpecID (techSpecID);

ALTER TABLE manufacturer
ADD INDEX idx_manufacturerID (manufacturerID);

ALTER TABLE color
ADD INDEX idx_hexColorID (hexColorID);

ALTER TABLE warranty
ADD INDEX idx_warrantyID (warrantyID);

ALTER TABLE article
ADD INDEX idx_articleID (articleID);

ALTER TABLE phone_review
ADD INDEX idx_reviewID (reviewID);

ALTER TABLE phone
ADD INDEX idx_phoneID (phoneID);

ALTER TABLE store
ADD INDEX idx_storeID (storeID);

ALTER TABLE services
ADD INDEX idx_serviceID (serviceID);

ALTER TABLE service_type
ADD INDEX idx_serviceTypeID (serviceTypeID);

ALTER TABLE users
ADD INDEX idx_userID (userID);

ALTER TABLE orders
ADD INDEX idx_orderID (orderID);

ALTER TABLE promotion
ADD INDEX idx_promotionID (promotionID);

# Add check constraint
ALTER TABLE phone_review
ADD CHECK (rating >= 1 AND rating <= 5);

ALTER TABLE phone
ADD CHECK (customPrice >= 0);

ALTER TABLE order_detail
ADD CHECK (originalPrice >= 0 AND finalPrice >= 0);

