-- =====================================================
-- Phase 7: JOIN Queries
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- INNER JOIN: portfolio holdings with stock + company detail
-- ------------------------------------------------------
SELECT
    u.first_name, u.last_name,
    p.portfolio_name,
    c.company_name,
    s.ticker_symbol,
    h.quantity,
    h.avg_buy_price,
    s.current_price,
    ROUND((s.current_price - h.avg_buy_price) * h.quantity, 2) AS unrealized_gain_loss
FROM holdings h
INNER JOIN portfolios p ON h.portfolio_id = p.portfolio_id
INNER JOIN users u       ON p.user_id = u.user_id
INNER JOIN stocks s      ON h.stock_id = s.stock_id
INNER JOIN companies c   ON s.company_id = c.company_id
ORDER BY unrealized_gain_loss DESC
LIMIT 10;

-- ------------------------------------------------------
-- LEFT JOIN: every user, with portfolio count (including users with zero portfolios, if any)
-- ------------------------------------------------------
SELECT
    u.user_id, u.first_name, u.last_name,
    COUNT(p.portfolio_id) AS portfolio_count
FROM users u
LEFT JOIN portfolios p ON u.user_id = p.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY portfolio_count DESC;

-- ------------------------------------------------------
-- LEFT JOIN: every stock, with whether it appears on any watchlist
-- ------------------------------------------------------
SELECT
    s.ticker_symbol,
    c.company_name,
    COUNT(w.watchlist_id) AS times_watchlisted
FROM stocks s
LEFT JOIN watchlist w ON s.stock_id = w.stock_id
INNER JOIN companies c ON s.company_id = c.company_id
GROUP BY s.stock_id, s.ticker_symbol, c.company_name
ORDER BY times_watchlisted DESC
LIMIT 10;

-- ------------------------------------------------------
-- RIGHT JOIN: every company, right-joined from stocks
-- (demonstrates RIGHT JOIN; equivalent LEFT JOIN would be more idiomatic,
--  included here purely to showcase the syntax as required)
-- ------------------------------------------------------
SELECT
    c.company_name,
    c.sector,
    s.ticker_symbol,
    s.current_price
FROM stocks s
RIGHT JOIN companies c ON s.company_id = c.company_id
ORDER BY c.sector, c.company_name;

-- ------------------------------------------------------
-- Multi-table JOIN: full transaction history with names
-- ------------------------------------------------------
SELECT
    t.transaction_date,
    u.first_name, u.last_name,
    p.portfolio_name,
    s.ticker_symbol,
    t.transaction_type,
    t.quantity,
    t.price_per_share,
    ROUND(t.quantity * t.price_per_share, 2) AS total_value
FROM transactions t
INNER JOIN portfolios p ON t.portfolio_id = p.portfolio_id
INNER JOIN users u      ON p.user_id = u.user_id
INNER JOIN stocks s     ON t.stock_id = s.stock_id
ORDER BY t.transaction_date DESC
LIMIT 15;
