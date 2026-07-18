-- =====================================================
-- Phase 8: Aggregate Queries (COUNT, SUM, AVG, MAX, MIN, GROUP BY, HAVING)
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- Total portfolio value per user (SUM + JOIN + GROUP BY)
-- ------------------------------------------------------
SELECT
    u.user_id, u.first_name, u.last_name,
    SUM(h.quantity * s.current_price) AS total_portfolio_value
FROM users u
JOIN portfolios p ON u.user_id = p.user_id
JOIN holdings h    ON p.portfolio_id = h.portfolio_id
JOIN stocks s       ON h.stock_id = s.stock_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_portfolio_value DESC;

-- ------------------------------------------------------
-- Most active traders (COUNT transactions per user), only those with 10+ trades
-- ------------------------------------------------------
SELECT
    u.first_name, u.last_name,
    COUNT(t.transaction_id) AS total_trades
FROM users u
JOIN portfolios p    ON u.user_id = p.user_id
JOIN transactions t  ON p.portfolio_id = t.portfolio_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(t.transaction_id) >= 10
ORDER BY total_trades DESC;

-- ------------------------------------------------------
-- Sector-wise investment distribution (SUM + GROUP BY)
-- ------------------------------------------------------
SELECT
    c.sector,
    COUNT(DISTINCT h.holding_id) AS holdings_count,
    SUM(h.quantity * s.current_price) AS sector_investment_value
FROM holdings h
JOIN stocks s     ON h.stock_id = s.stock_id
JOIN companies c  ON s.company_id = c.company_id
GROUP BY c.sector
ORDER BY sector_investment_value DESC;

-- ------------------------------------------------------
-- Stock price stats: MAX, MIN, AVG across all stocks
-- ------------------------------------------------------
SELECT
    MAX(current_price) AS highest_price,
    MIN(current_price) AS lowest_price,
    ROUND(AVG(current_price), 2) AS average_price
FROM stocks;

-- ------------------------------------------------------
-- Top 5 highest-value transactions ever recorded
-- ------------------------------------------------------
SELECT
    t.transaction_id, s.ticker_symbol, t.transaction_type,
    t.quantity, t.price_per_share,
    (t.quantity * t.price_per_share) AS total_value
FROM transactions t
JOIN stocks s ON t.stock_id = s.stock_id
ORDER BY total_value DESC
LIMIT 5;

-- ------------------------------------------------------
-- Average transaction size per stock, only stocks traded 5+ times (HAVING)
-- ------------------------------------------------------
SELECT
    s.ticker_symbol,
    COUNT(t.transaction_id) AS trade_count,
    ROUND(AVG(t.quantity), 1) AS avg_qty_per_trade,
    ROUND(AVG(t.price_per_share), 2) AS avg_price
FROM transactions t
JOIN stocks s ON t.stock_id = s.stock_id
GROUP BY s.stock_id, s.ticker_symbol
HAVING COUNT(t.transaction_id) >= 5
ORDER BY trade_count DESC;
