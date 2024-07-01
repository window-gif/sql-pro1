/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80032 (8.0.32)
 Source Host           : localhost:3306
 Source Schema         : bank_system

 Target Server Type    : MySQL
 Target Server Version : 80032 (8.0.32)
 File Encoding         : 65001

 Date: 01/07/2024 12:41:16
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for account
-- ----------------------------
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account`  (
  `account_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NULL DEFAULT NULL,
  `account_type` enum('Checking','Savings') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `balance` decimal(10, 2) NULL DEFAULT NULL,
  PRIMARY KEY (`account_id`) USING BTREE,
  INDEX `customer_id`(`customer_id` ASC) USING BTREE,
  CONSTRAINT `account_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of account
-- ----------------------------
INSERT INTO `account` VALUES (1, 1, 'Checking', 1700.00);
INSERT INTO `account` VALUES (2, 1, 'Savings', 4700.00);
INSERT INTO `account` VALUES (3, 2, 'Checking', 1800.00);
INSERT INTO `account` VALUES (4, 3, 'Checking', 1500.00);
INSERT INTO `account` VALUES (5, 3, 'Savings', 3000.00);

-- ----------------------------
-- Table structure for customer
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer`  (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone_number` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`customer_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer
-- ----------------------------
INSERT INTO `customer` VALUES (1, 'Alice', 'Smith', 'alice.smith@example.com', '123-456-7890');
INSERT INTO `customer` VALUES (2, 'Bob', 'Johnson', 'bob.johnson@example.com', '098-765-4321');
INSERT INTO `customer` VALUES (3, 'Charlie', 'Brown', 'charlie.brown@example.com', '555-123-4567');

-- ----------------------------
-- Table structure for transaction
-- ----------------------------
DROP TABLE IF EXISTS `transaction`;
CREATE TABLE `transaction`  (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NULL DEFAULT NULL,
  `transaction_type` enum('Deposit','Withdrawal','Transfer') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `amount` decimal(10, 2) NULL DEFAULT NULL,
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `related_account_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`transaction_id`) USING BTREE,
  INDEX `account_id`(`account_id` ASC) USING BTREE,
  CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of transaction
-- ----------------------------
INSERT INTO `transaction` VALUES (1, 1, 'Deposit', 500.00, '2024-07-01 12:39:57', NULL);
INSERT INTO `transaction` VALUES (2, 2, 'Withdrawal', 300.00, '2024-07-01 12:39:59', NULL);
INSERT INTO `transaction` VALUES (3, 3, 'Transfer', 200.00, '2024-07-01 12:40:02', 1);

-- ----------------------------
-- Procedure structure for deposit
-- ----------------------------
DROP PROCEDURE IF EXISTS `deposit`;
delimiter ;;
CREATE PROCEDURE `deposit`(IN acc_id INT, IN amt DECIMAL(10, 2))
BEGIN
    UPDATE Account
    SET balance = balance + amt
    WHERE account_id = acc_id;

    INSERT INTO Transaction (account_id, transaction_type, amount)
    VALUES (acc_id, 'Deposit', amt);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for transfer
-- ----------------------------
DROP PROCEDURE IF EXISTS `transfer`;
delimiter ;;
CREATE PROCEDURE `transfer`(IN from_acc INT, IN to_acc INT, IN amt DECIMAL(10, 2))
BEGIN
    UPDATE Account
    SET balance = balance - amt
    WHERE account_id = from_acc;

    UPDATE Account
    SET balance = balance + amt
    WHERE account_id = to_acc;

    INSERT INTO Transaction (account_id, transaction_type, amount, related_account_id)
    VALUES (from_acc, 'Transfer', amt, to_acc);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for withdraw
-- ----------------------------
DROP PROCEDURE IF EXISTS `withdraw`;
delimiter ;;
CREATE PROCEDURE `withdraw`(IN acc_id INT, IN amt DECIMAL(10, 2))
BEGIN
    UPDATE Account
    SET balance = balance - amt
    WHERE account_id = acc_id;

    INSERT INTO Transaction (account_id, transaction_type, amount)
    VALUES (acc_id, 'Withdrawal', amt);
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
