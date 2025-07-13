-- Create the database
CREATE DATABASE flight_booking_system6;

-- Use the created database
USE flight_booking_system6;

-- Table: flights (stores information about flights)
CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(10) NOT NULL,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    seats_available INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Table: bookings (stores flight bookings by passengers)
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    passport_number VARCHAR(20) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status VARCHAR(20),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE
);

-- Table: reviews (stores flight reviews and ratings by passengers)
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- Table: payments (handles payment information for bookings)
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    card_number VARCHAR(16) NOT NULL,
    expiry_date VARCHAR(5) NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- Table: history (stores booking and cancellation history)
CREATE TABLE history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    flight_id INT,
    action VARCHAR(20) NOT NULL CHECK (action IN ('BOOKED', 'CANCELLED')),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE
);

-- Stored Procedure: BookFlight (books a flight and reduces seat availability)
DELIMITER //
CREATE PROCEDURE BookFlight(
    IN flight_id INT, 
    IN full_name VARCHAR(100), 
    IN dob DATE, 
    IN passport_number VARCHAR(20), 
    IN gender VARCHAR(10), 
    IN email VARCHAR(100), 
    IN phone VARCHAR(15)
)
BEGIN
    DECLARE available_seats INT;
    
    -- Check available seats
    SELECT seats_available INTO available_seats FROM flights WHERE flight_id = flight_id;
    IF available_seats > 0 THEN
        -- Insert booking information into the bookings table
        INSERT INTO bookings (flight_id, full_name, dob, passport_number, gender, email, phone)
        VALUES (flight_id, full_name, dob, passport_number, gender, email, phone);

        -- Update seat availability
        UPDATE flights 
        SET seats_available = seats_available - 1 
        WHERE flight_id = flight_id;

        -- Record the booking in the history table
        INSERT INTO history (booking_id, flight_id, action)
        VALUES (LAST_INSERT_ID(), flight_id, 'BOOKED');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No seats available';
    END IF;
END //
DELIMITER ;

-- Stored Procedure: CancelBooking (cancels a booking and restores seat availability)
DELIMITER //
CREATE PROCEDURE CancelBooking(IN booking_id INT)
BEGIN
    DECLARE flight_id INT;
    
    -- Retrieve flight ID from the booking
    SELECT flight_id INTO flight_id 
    FROM bookings WHERE booking_id = booking_id;

    -- Restore seat availability
    UPDATE flights 
    SET seats_available = seats_available + 1 
    WHERE flight_id = flight_id;

    -- Delete the booking from the bookings table
    DELETE FROM bookings WHERE booking_id = booking_id;

    -- Record the cancellation in the history table
    INSERT INTO history (booking_id, flight_id, action)
    VALUES (booking_id, flight_id, 'CANCELLED');
END //
DELIMITER ;

-- Stored Procedure: ProcessPayment (handles payment for a booking)
DELIMITER //
CREATE PROCEDURE ProcessPayment(
    IN booking_id INT, 
    IN card_number VARCHAR(16), 
    IN expiry_date VARCHAR(5), 
    IN cvv VARCHAR(3), 
    IN amount_paid DECIMAL(10, 2)
)
BEGIN
    -- Insert payment information into the payments table
    INSERT INTO payments (booking_id, card_number, expiry_date, cvv, amount_paid)
    VALUES (booking_id, card_number, expiry_date, cvv, amount_paid);
END //
DELIMITER ;

-- Stored Procedure: SubmitReview (allows users to submit a review for a booking)
DELIMITER //
CREATE PROCEDURE SubmitReview(
    IN booking_id INT, 
    IN rating INT, 
    IN review_text TEXT
)
BEGIN
    -- Insert review information into the reviews table
    INSERT INTO reviews (booking_id, rating, review_text)
    VALUES (booking_id, rating, review_text);
END //
DELIMITER ;


INSERT INTO flights (flight_id, flight_number, origin, destination, departure_time, arrival_time, seats_available, price)
VALUES (101, 'AI123', 'New York', 'London', '2024-10-20 10:00:00', '2024-10-20 18:00:00', 10, 500);

INSERT INTO bookings (flight_id, full_name, dob, passport_number, gender, email, phone, booking_status)
VALUES (101, 'John Doe', '1990-01-01', 'ABC123456', 'Male', 'johndoe@gmail.com', '+1234567890', 'Booked');

-- Inserting Domestic Flights (within India)
INSERT INTO flights (flight_id, flight_number, origin, destination, departure_time, arrival_time, seats_available, price) VALUES
(1, 'AI101', 'Delhi', 'Mumbai', '2024-10-16 08:00:00', '2024-10-16 10:15:00', 30, 3000),
(2, '6E202', 'Mumbai', 'Bangalore', '2024-10-16 09:00:00', '2024-10-16 11:00:00', 25, 2500),
(3, 'AI203', 'Kolkata', 'Chennai', '2024-10-16 11:30:00', '2024-10-16 14:00:00', 40, 4000),
(4, 'SG303', 'Hyderabad', 'Delhi', '2024-10-16 13:00:00', '2024-10-16 15:30:00', 35, 3500),
(5, '6E404', 'Delhi', 'Goa', '2024-10-16 15:00:00', '2024-10-16 17:45:00', 20, 3500),
(6, 'AI505', 'Mumbai', 'Kolkata', '2024-10-17 06:00:00', '2024-10-17 08:30:00', 50, 3800),
(7, 'UK606', 'Chennai', 'Delhi', '2024-10-17 09:00:00', '2024-10-17 12:00:00', 15, 3200),
(8, 'SG707', 'Bangalore', 'Kochi', '2024-10-17 14:00:00', '2024-10-17 15:30:00', 30, 1800),
(9, '6E808', 'Jaipur', 'Mumbai', '2024-10-17 16:00:00', '2024-10-17 18:15:00', 28, 2700),
(10, 'AI909', 'Goa', 'Bangalore', '2024-10-17 18:00:00', '2024-10-17 20:00:00', 45, 2500),
(11, 'SG1010', 'Pune', 'Delhi', '2024-10-18 07:00:00', '2024-10-18 09:15:00', 60, 3500),
(12, '6E1111', 'Delhi', 'Chandigarh', '2024-10-18 10:00:00', '2024-10-18 11:15:00', 20, 1800),
(13, 'AI1212', 'Bangalore', 'Hyderabad', '2024-10-18 12:00:00', '2024-10-18 13:15:00', 25, 2000);

-- Inserting International Flights
INSERT INTO flights (flight_id, flight_number, origin, destination, departure_time, arrival_time, seats_available, price) VALUES
(14, 'AI1501', 'Delhi', 'New York', '2024-10-20 23:00:00', '2024-10-21 12:00:00', 20, 45000),
(15, 'BA1502', 'Mumbai', 'London', '2024-10-20 22:00:00', '2024-10-21 07:00:00', 25, 42000),
(16, 'AI1503', 'Chennai', 'Singapore', '2024-10-19 23:30:00', '2024-10-20 06:00:00', 15, 18000),
(17, '6E1504', 'Delhi', 'Dubai', '2024-10-21 20:00:00', '2024-10-21 22:30:00', 30, 15000),
(18, 'QR1505', 'Mumbai', 'Doha', '2024-10-22 02:00:00', '2024-10-22 04:30:00', 20, 16000),
(19, 'AI1506', 'Kolkata', 'Bangkok', '2024-10-22 11:00:00', '2024-10-22 15:00:00', 18, 13000),
(20, 'EK1507', 'Hyderabad', 'Dubai', '2024-10-23 03:00:00', '2024-10-23 06:00:00', 35, 14000),
(21, 'AI1508', 'Delhi', 'Toronto', '2024-10-23 22:30:00', '2024-10-24 08:00:00', 10, 50000),
(22, 'SQ1509', 'Bangalore', 'Singapore', '2024-10-24 12:30:00', '2024-10-24 19:00:00', 15, 20000),
(23, 'AI1510', 'Mumbai', 'Tokyo', '2024-10-24 23:59:00', '2024-10-25 11:30:00', 12, 55000),
(24, 'BA1511', 'Delhi', 'London', '2024-10-25 10:00:00', '2024-10-25 18:00:00', 18, 45000),
(25, 'AI1512', 'Mumbai', 'Sydney', '2024-10-26 09:00:00', '2024-10-27 06:00:00', 8, 65000);

ALTER TABLE bookings
ADD COLUMN status VARCHAR(20) DEFAULT 'Booked';
