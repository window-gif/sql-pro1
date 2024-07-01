CREATE DATABASE bank_system;
USE bank_system;

CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(15)
);

CREATE TABLE Account (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_type ENUM('Checking', 'Savings'),
    balance DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Transaction (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer'),
    amount DECIMAL(10, 2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    related_account_id INT,
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

-- 存款
DELIMITER //
CREATE PROCEDURE deposit(IN acc_id INT, IN amt DECIMAL(10, 2))
BEGIN
    UPDATE Account
    SET balance = balance + amt
    WHERE account_id = acc_id;

    INSERT INTO Transaction (account_id, transaction_type, amount)
    VALUES (acc_id, 'Deposit', amt);
END //
DELIMITER ;

-- 取款
DELIMITER //
CREATE PROCEDURE withdraw(IN acc_id INT, IN amt DECIMAL(10, 2))
BEGIN
    UPDATE Account
    SET balance = balance - amt
    WHERE account_id = acc_id;

    INSERT INTO Transaction (account_id, transaction_type, amount)
    VALUES (acc_id, 'Withdrawal', amt);
END //
DELIMITER ;

-- 转账
DELIMITER //
CREATE PROCEDURE transfer(IN from_acc INT, IN to_acc INT, IN amt DECIMAL(10, 2))
BEGIN
    UPDATE Account
    SET balance = balance - amt
    WHERE account_id = from_acc;

    UPDATE Account
    SET balance = balance + amt
    WHERE account_id = to_acc;

    INSERT INTO Transaction (account_id, transaction_type, amount, related_account_id)
    VALUES (from_acc, 'Transfer', amt, to_acc);
END //
DELIMITER ;

INSERT INTO Customer (first_name, last_name, email, phone_number) VALUES
('Alice', 'Smith', 'alice.smith@example.com', '123-456-7890'),
('Bob', 'Johnson', 'bob.johnson@example.com', '098-765-4321'),
('Charlie', 'Brown', 'charlie.brown@example.com', '555-123-4567');

INSERT INTO Account (customer_id, account_type, balance) VALUES
(1, 'Checking', 1000.00),
(1, 'Savings', 5000.00),
(2, 'Checking', 2000.00),
(3, 'Checking', 1500.00),
(3, 'Savings', 3000.00);

CALL deposit(1, 500.00);  -- 为账户ID为1的账户存入500

CALL withdraw(2, 300.00);  -- 从账户ID为2的账户取出300

CALL transfer(3, 1, 200.00);  -- 从账户ID为3的账户转账200到账户ID为1的账户

SELECT c.first_name, c.last_name, a.account_type, a.balance
FROM Customer c
JOIN Account a ON c.customer_id = a.customer_id
WHERE c.customer_id = 1;

SELECT t.transaction_type, t.amount, t.transaction_date
FROM Transaction t
WHERE t.account_id = 1;