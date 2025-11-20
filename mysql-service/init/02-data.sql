USE travel;

INSERT INTO users (name, email, password) VALUES
('Alice Singh','alice@example.com','pass1'),
('Bob Kumar','bob@example.com','pass2'),
('Carol Jose','carol@example.com','pass3');

INSERT INTO search_items (type, title, location, price) VALUES
('flight','Flight: BLR -> GOA','Goa',199.99),
('hotel','Hotel: Beachside Resort','Goa',89.99),
('package','Weekend: Goa Special','Goa',259.99),
('flight','Flight: DEL -> MUM','Mumbai',129.00);

INSERT INTO bookings (user_id, item_id, status) VALUES
(1,1,'CONFIRMED'),
(2,2,'CREATED');

INSERT INTO payments (booking_id, amount, status) VALUES
(1,199.99,'COMPLETED'),
(2,89.99,'PENDING');

INSERT INTO notifications (user_id, message, sent) VALUES
(1,'Booking confirmed for item 1',1),
(2,'Booking created for item 2',0),
(1,'Payment received for booking 1',1);
