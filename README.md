# ✈️ KahaUdoge – Flight Booking System

**KahaUdoge** is a GUI-based flight booking system that allows users to search, book, and manage domestic and international flight reservations. Built using **Python (Tkinter)** and **MySQL**, it features payment validation, booking history, and a clean multi-tab interface.

---

## 📌 Features

- 🔍 **Search Flights** by origin and destination
- 🧾 **Book Tickets** with payment validation (Card/UPI)
- 📜 **View Bookings** and update or cancel reservations
- 🕓 **History Tab** to view full booking and cancellation records
- 🎯 **Home Page** with offers, info, and recommended flights
- 📂 MySQL-backed database with normalized schema and stored procedures

---

## 🛠️ Tech Stack

| Layer         | Technology               |
|---------------|---------------------------|
| GUI           | Python (Tkinter)          |
| Backend DB    | MySQL                     |
| Language      | Python 3.x                |
| DB Access     | mysql-connector-python    |

---

## 🖥️ Installation

### 1. Clone this repository:

git clone https://github.com/niksyaduvanshi/KahaUdoge.git
cd KahaUdoge

### 2. Install dependencies

pip install mysql-connector-python

### 3. Import the database
Open MySQL CLI or Workbench

Run the SQL file:

SOURCE KahaUdogeSQL.sql;
This will create the flight_booking_system6 database with tables, stored procedures, and sample data.

### 4. Run the application

python KahaUdogegui.py
Make sure the KahaUdoge.ico file is in the same directory for the custom window icon.

### ⚙️ Configuration
Update your MySQL connection in KahaUdogegui.py if needed:

db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="your_password",
    database="flight_booking_system6"
)

### 🚀 Planned Features
🔐 Admin authentication

📊 Reporting dashboard

📎 PDF ticket generation

🌐 Multi-language support