# Marriage Compatibility Management System

## Overview

This project is an Oracle SQL and PL/SQL-based database application designed to manage and evaluate marriage compatibility based on predefined zodiac sign combinations and successful marriage criteria.

The system stores marriage records, validates compatibility rules, identifies successful marriages, removes unsuccessful ones, and provides a centralized error handling and logging mechanism.

The project was developed to strengthen practical skills in database design, Oracle PL/SQL programming, data processing, exception handling, and bulk operations.

---

## Features

- Relational database design with primary and foreign key constraints
- Marriage compatibility validation based on zodiac signs
- Successful marriage identification and storage
- Automatic removal of unsuccessful marriages
- Custom exception handling framework
- Error logging system
- Oracle PL/SQL packages
- Stored procedures and functions
- Bulk data processing using `BULK COLLECT` and `FORALL`
- Transaction management and autonomous error logging

---

## Database Structure

### Main Tables

| Table | Description |
|---------|-------------|
| `zenklas` | Stores zodiac signs and descriptions |
| `sekmingiVyruMetai` | Successful years for male zodiac signs |
| `sekmingiMoteruMetai` | Successful years for female zodiac signs |
| `sekmingaPora` | Compatible zodiac sign pairs |
| `santuoka` | Registered marriages |
| `sekmingaSantuoka` | Successful marriages |

### Error Management Tables

| Table | Description |
|---------|-------------|
| `error_message` | Stores custom application error messages |
| `error_log` | Logs application errors and diagnostics |

---

## PL/SQL Packages

### `errors_pkg`

Provides centralized error management functionality:

- Custom exception definitions
- Error message retrieval
- Error raising procedures
- Error logging procedures
- Autonomous transaction logging

### `marriage_pkg`

Provides marriage processing functionality:

- Validation of zodiac signs
- Compatibility checking
- Successful marriage identification
- Bulk loading of successful marriages
- Insertion of validated marriages
- Removal of unsuccessful marriages

---

## Technologies Used

- Oracle Database
- SQL
- PL/SQL
- Packages
- Stored Procedures
- Functions
- Cursors
- Exception Handling
- BULK COLLECT
- FORALL
- Autonomous Transactions

---

## Example Workflow

1. Create database tables.
2. Load sample data.
3. Populate successful marriages.
4. Add new successful marriages.
5. Validate zodiac compatibility.
6. Remove unsuccessful marriages.
7. Log and handle errors automatically.

---

## Learning Outcomes

Through this project I gained practical experience in:

- Relational database design
- Oracle SQL development
- PL/SQL programming
- Package creation
- Stored procedures and functions
- Cursor management
- Bulk processing techniques
- Error handling and logging
- Database management and optimization concepts

---

## Author

**Kamil Grigorovič**

Data Science Student at Vilnius University

### Areas of Interest

- Data Engineering
- Database Development
- Data Analysis
- Big Data Technologies
- SQL and PL/SQL Programming
