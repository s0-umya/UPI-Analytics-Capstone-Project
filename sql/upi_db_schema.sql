-- Initial Setup for UPI Transaction Analysis Database
-- Setting up the schema from scratch for MySQL

CREATE DATABASE upi_analytics;
USE upi_analytics;

-- 1. Create the master table for our customers
CREATE TABLE customer_master (
    customer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL UNIQUE,
    age INT,
    gender VARCHAR(20),
    region VARCHAR(50),
    date_joined DATE NOT NULL,
    is_business_user BOOLEAN DEFAULT FALSE,
    risk_score FLOAT CHECK (risk_score >= 0 AND risk_score <= 1)
);

-- 2. Store information about the merchants on our platform
CREATE TABLE merchant_info (
    merchant_id VARCHAR(50) PRIMARY KEY,
    merchant_name VARCHAR(255) NOT NULL,
    merchant_type VARCHAR(100),
    region VARCHAR(50),
    onboard_date DATE NOT NULL,
    risk_score FLOAT CHECK (risk_score >= 0 AND risk_score <= 1)
);

-- 3. Track UPI accounts linked to our customers
CREATE TABLE upi_account_details (
    upi_id VARCHAR(100) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50),
    date_added DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

-- 4. Keep track of devices used by customers (useful for catching fraud on rooted devices)
CREATE TABLE device_info (
    device_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    app_version VARCHAR(50),
    is_rooted BOOLEAN DEFAULT FALSE,
    last_active DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

-- 5. Main transaction ledger - links everything together
CREATE TABLE upi_transaction_history (
    transaction_id VARCHAR(50) PRIMARY KEY,
    upi_id VARCHAR(100) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL,
    amount FLOAT NOT NULL CHECK (amount > 0),
    transaction_type VARCHAR(50) NOT NULL,
    merchant_id VARCHAR(50) NULL,
    counterparty_upi VARCHAR(100) NULL,
    status VARCHAR(50) NOT NULL,
    device_id VARCHAR(50) NOT NULL,
    device_type VARCHAR(50),
    channel VARCHAR(50),
    fraud_flag BOOLEAN DEFAULT FALSE,
    reversal_flag BOOLEAN DEFAULT FALSE,
    failure_reason VARCHAR(255) NULL,
    FOREIGN KEY (upi_id) REFERENCES upi_account_details(upi_id),
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id),
    FOREIGN KEY (merchant_id) REFERENCES merchant_info(merchant_id),
    FOREIGN KEY (device_id) REFERENCES device_info(device_id)
);

-- 6. Log all fraud alerts raised against transactions
CREATE TABLE fraud_alert_history (
    alert_id VARCHAR(50) PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    alert_type VARCHAR(100) NOT NULL,
    alert_date DATETIME NOT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    resolution_date DATETIME NULL,
    remarks VARCHAR(500) NULL,
    FOREIGN KEY (transaction_id) REFERENCES upi_transaction_history(transaction_id)
);

-- 7. Store survey responses and feedback from customers
CREATE TABLE customer_feedback_surveys (
    feedback_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    date_submitted DATE NOT NULL,
    feedback_text VARCHAR(500),
    satisfaction_score INT CHECK (satisfaction_score BETWEEN 1 AND 5),
    issue_type VARCHAR(100),
    resolved BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);
