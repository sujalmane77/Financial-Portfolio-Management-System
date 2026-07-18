-- =====================================================
-- Phase 9: Subqueries
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- Scalar subquery: users whose portfolio value is above the platform average
-- ------------------------------------------------------
SELECT user_id, first_name, last_name, total_value FROM (
    SELECT
        u.user_id, u.first_name, u.last_name,
        SUM(h.quantity * s.current_price) AS total_value
    FROM users u
    JOIN portfolios p ON u.user_id = p.user_id
    JOIN holdings h    ON p.portfolio_id = h.portfolio_id
    JOIN stocks s       ON h.stock_id = s.stock_id
    GROUP BY u.user_id, u.first_name, u.last_name
) AS user_totals
WHERE total_value > (
    SELECT AVG(sub.total_value) FROM (
        SELECT SUM(h.quantity * s.current_price) AS total_value
        FROM holdings h
        JOIN stocks s ON h.stock_id = s.stock_id
        GROUP BY h.portfolio_id
    ) AS sub
)
ORDER BY total_value DESC;

-- ------------------------------------------------------
-- IN subquery: stocks currently held by anyone (appear in holdings)
-- ------------------------------------------------------
SELECT ticker_symbol, current_price
FROM stocks
WHERE stock_id IN (SELECT DISTINCT stock_id FROM holdings)
ORDER BY ticker_symbol;

-- ------------------------------------------------------
-- NOT IN subquery: stocks never traded at all
-- ------------------------------------------------------
SELECT ticker_symbol
FROM stocks
WHERE stock_id NOT IN (SELECT DISTINCT stock_id FROM transactions);

-- ------------------------------------------------------
-- Correlated subquery: each portfolio's most recent transaction date
-- ------------------------------------------------------
SELECT
    p.portfolio_id, p.portfolio_name,
    (SELECT MAX(t.transaction_date)
     FROM transactions t
     WHERE t.portfolio_id = p.portfolio_id) AS last_trade_date
FROM portfolios p
ORDER BY last_trade_date DESC;

-- ------------------------------------------------------
-- Subquery in WHERE: find the single most expensive stock currently held by each user
-- (via a subquery that finds the max current_price per user)
-- ------------------------------------------------------
SELECT u.first_name, u.last_name, s.ticker_symbol, s.current_price
FROM users u
JOIN portfolios p ON u.user_id = p.user_id
JOIN holdings h    ON p.portfolio_id = h.portfolio_id
JOIN stocks s       ON h.stock_id = s.stock_id
WHERE s.current_price = (
    SELECT MAX(s2.current_price)
    FROM holdings h2
    JOIN portfolios p2 ON h2.portfolio_id = p2.portfolio_id
    JOIN stocks s2 ON h2.stock_id = s2.stock_id
    WHERE p2.user_id = u.user_id
)
ORDER BY s.current_price DESC;
