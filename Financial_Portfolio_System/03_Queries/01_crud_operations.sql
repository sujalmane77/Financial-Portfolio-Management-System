-- =====================================================
-- Phase 6: CRUD Operations
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- CREATE (INSERT)
-- ------------------------------------------------------
-- Add a new user
INSERT INTO users (first_name, last_name, email, phone, city)
VALUES ('Rahul', 'Verma', 'rahul.verma.new@example.com', '9876543210', 'Mumbai');

-- Give that user a portfolio
INSERT INTO portfolios (user_id, portfolio_name)
VALUES (LAST_INSERT_ID(), 'My First Portfolio');

-- ------------------------------------------------------
-- READ (SELECT)
-- ------------------------------------------------------
-- Basic select with filtering, sorting, limiting
SELECT user_id, first_name, last_name, city
FROM users
WHERE city = 'Mumbai'
ORDER BY first_name ASC
LIMIT 5;

-- Distinct list of sectors represented in the companies table
SELECT DISTINCT sector FROM companies ORDER BY sector;

-- ------------------------------------------------------
-- UPDATE
-- ------------------------------------------------------
-- Update a stock's current price (simulating a market move)
UPDATE stocks
SET current_price = current_price * 1.02,
    last_updated = NOW()
WHERE ticker_symbol = 'TCS';

-- Update a user's contact info
UPDATE users
SET phone = '9000011111', city = 'Pune'
WHERE email = 'rahul.verma.new@example.com';

-- ------------------------------------------------------
-- DELETE
-- ------------------------------------------------------
-- Remove a stock from a user's watchlist (safe: junction table only)
DELETE FROM watchlist
WHERE user_id = (SELECT user_id FROM users WHERE email = 'rahul.verma.new@example.com')
  AND stock_id = 1;

-- Clean up the demo user created above (cascades to their portfolio via FK ON DELETE CASCADE)
DELETE FROM users WHERE email = 'rahul.verma.new@example.com';
