-- =====================================================
-- Phase 4: Create Tables
-- Financial Portfolio Management System
-- Run 01_create_database.sql first.
-- =====================================================

USE financial_portfolio_system;

-- ---------------------------------------------------
-- 1. USERS
-- ---------------------------------------------------
CREATE TABLE users (
    user_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    phone       VARCHAR(20),
    city        VARCHAR(50),
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------
-- 2. COMPANIES
-- ---------------------------------------------------
CREATE TABLE companies (
    company_id    INT AUTO_INCREMENT PRIMARY KEY,
    company_name  VARCHAR(100) NOT NULL,
    sector        VARCHAR(50)  NOT NULL,
    exchange      VARCHAR(20)  NOT NULL,
    country       VARCHAR(50)  NOT NULL
);

-- ---------------------------------------------------
-- 3. STOCKS  (1:1 with companies)
-- ---------------------------------------------------
CREATE TABLE stocks (
    stock_id       INT AUTO_INCREMENT PRIMARY KEY,
    company_id     INT NOT NULL UNIQUE,
    ticker_symbol  VARCHAR(10) NOT NULL UNIQUE,
    current_price  DECIMAL(12,2) NOT NULL,
    last_updated   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stocks_company
        FOREIGN KEY (company_id) REFERENCES companies(company_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------
-- 4. PORTFOLIOS
-- ---------------------------------------------------
CREATE TABLE portfolios (
    portfolio_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    portfolio_name  VARCHAR(100) NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_portfolios_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------
-- 5. HOLDINGS  (derived/summary table)
-- ---------------------------------------------------
CREATE TABLE holdings (
    holding_id     INT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id   INT NOT NULL,
    stock_id       INT NOT NULL,
    quantity       INT NOT NULL DEFAULT 0,
    avg_buy_price  DECIMAL(12,2) NOT NULL DEFAULT 0,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                   ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_holdings_portfolio
        FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_holdings_stock
        FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_holdings_portfolio_stock UNIQUE (portfolio_id, stock_id)
);

-- ---------------------------------------------------
-- 6. TRANSACTIONS
-- ---------------------------------------------------
CREATE TABLE transactions (
    transaction_id    INT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id      INT NOT NULL,
    stock_id          INT NOT NULL,
    transaction_type  ENUM('BUY','SELL') NOT NULL,
    quantity           INT NOT NULL,
    price_per_share    DECIMAL(12,2) NOT NULL,
    transaction_date   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_portfolio
        FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_transactions_stock
        FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_transactions_qty CHECK (quantity > 0)
);

-- ---------------------------------------------------
-- 7. WATCHLIST  (junction table resolving Users<->Stocks M:M)
-- ---------------------------------------------------
CREATE TABLE watchlist (
    watchlist_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    stock_id      INT NOT NULL,
    added_date    DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_watchlist_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_watchlist_stock
        FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_watchlist_user_stock UNIQUE (user_id, stock_id)
);

-- ---------------------------------------------------
-- 8. TRANSACTION_LOG  (populated automatically by trigger, Phase 12)
-- ---------------------------------------------------
CREATE TABLE transaction_log (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id  INT NOT NULL,
    log_message     VARCHAR(255) NOT NULL,
    log_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON DELETE CASCADE
);

SHOW TABLES;
