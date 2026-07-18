-- =====================================================
-- Phase 10: Views
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- VIEW 1: vw_portfolio_summary
-- One row per portfolio: owner, total holdings value, number of distinct stocks held.
-- Why: This is the query the "My Portfolio" dashboard screen would run constantly.
-- Wrapping it in a view means the app just does `SELECT * FROM vw_portfolio_summary`
-- instead of repeating a 4-table JOIN everywhere.
-- ------------------------------------------------------
DROP VIEW IF EXISTS vw_portfolio_summary;

CREATE VIEW vw_portfolio_summary AS
SELECT
    p.portfolio_id,
    p.portfolio_name,
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS owner_name,
    COUNT(DISTINCT h.stock_id) AS distinct_stocks_held,
    COALESCE(SUM(h.quantity * s.current_price), 0) AS current_portfolio_value
FROM portfolios p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN holdings h ON p.portfolio_id = h.portfolio_id
LEFT JOIN stocks s   ON h.stock_id = s.stock_id
GROUP BY p.portfolio_id, p.portfolio_name, u.user_id, owner_name;

-- ------------------------------------------------------
-- VIEW 2: vw_stock_performance
-- One row per stock: company info, current price, total quantity currently held
-- across all portfolios, and total buy/sell trade counts.
-- Why: Powers a "Markets" screen showing which stocks are most popular/traded,
-- without exposing raw transaction/holding tables to the reporting layer.
-- ------------------------------------------------------
DROP VIEW IF EXISTS vw_stock_performance;

CREATE VIEW vw_stock_performance AS
SELECT
    s.stock_id,
    s.ticker_symbol,
    c.company_name,
    c.sector,
    s.current_price,
    COALESCE(SUM(h.quantity), 0) AS total_quantity_held,
    (SELECT COUNT(*) FROM transactions t WHERE t.stock_id = s.stock_id AND t.transaction_type='BUY')  AS total_buys,
    (SELECT COUNT(*) FROM transactions t WHERE t.stock_id = s.stock_id AND t.transaction_type='SELL') AS total_sells
FROM stocks s
JOIN companies c ON s.company_id = c.company_id
LEFT JOIN holdings h ON s.stock_id = h.stock_id
GROUP BY s.stock_id, s.ticker_symbol, c.company_name, c.sector, s.current_price;

-- ------------------------------------------------------
-- Usage examples
-- ------------------------------------------------------
SELECT * FROM vw_portfolio_summary ORDER BY current_portfolio_value DESC LIMIT 5;
SELECT * FROM vw_stock_performance ORDER BY total_quantity_held DESC LIMIT 5;
