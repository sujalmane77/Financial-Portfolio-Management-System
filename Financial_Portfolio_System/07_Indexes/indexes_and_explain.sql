-- =====================================================
-- Phase 13: Indexes + EXPLAIN (Before / After)
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- BEFORE: run these first and note the `type` and `rows` columns
-- ------------------------------------------------------
-- EXPLAIN SELECT * FROM transactions WHERE transaction_date BETWEEN '2025-03-01' AND '2025-03-31';
-- -> type = ALL (full table scan), rows = 302   (scans every transaction)

-- EXPLAIN SELECT * FROM companies WHERE sector = 'Technology';
-- -> type = ALL (full table scan)               (scans every company row)

-- (fk_holdings_stock already exists automatically because InnoDB auto-indexes
--  foreign key columns — that lookup was already using an index before we do anything)

-- ------------------------------------------------------
-- CREATE INDEXES on columns used heavily in WHERE / JOIN / ORDER BY
-- ------------------------------------------------------

-- transactions.transaction_date: used constantly for date-range reporting
CREATE INDEX idx_transactions_date ON transactions (transaction_date);

-- companies.sector: used for sector-wise grouping/filtering (Phase 8 queries)
CREATE INDEX idx_companies_sector ON companies (sector);

-- stocks.ticker_symbol: already UNIQUE (auto-indexed), but explicitly named here
-- for clarity since it's the most common lookup column for a stock
-- (UNIQUE constraint in 02_create_tables.sql already covers this)

-- Composite index: transactions filtered by portfolio AND ordered by date
-- (covers "portfolio transaction history" queries used in Phase 7)
CREATE INDEX idx_transactions_portfolio_date ON transactions (portfolio_id, transaction_date);

-- users.email already UNIQUE (auto-indexed) - used for login/lookup

-- ------------------------------------------------------
-- AFTER: re-run the same EXPLAIN statements (actual measured results below)
-- ------------------------------------------------------

-- EXPLAIN SELECT * FROM companies WHERE sector = 'Technology';
-- -> type = ref, key = idx_companies_sector, rows = 6   (was: type=ALL, full scan)
-- Clear win: the optimizer now jumps straight to matching rows.

-- EXPLAIN SELECT * FROM transactions WHERE portfolio_id = 1 ORDER BY transaction_date DESC;
-- -> type = ref, key = idx_transactions_portfolio_date, rows = 10   (was: type=ALL)
-- Clear win: the composite index serves both the filter and the sort.

-- EXPLAIN SELECT * FROM transactions WHERE transaction_date BETWEEN '2025-03-01' AND '2025-03-31';
-- -> STILL shows type = ALL even after the index exists.
-- This is not a bug — it's the cost-based optimizer at work. With only 302 rows
-- in the table, MySQL estimates a full scan is cheaper than an index lookup +
-- row lookups, so it deliberately ignores the index. Forcing it proves the index
-- is valid and usable:
--   EXPLAIN SELECT * FROM transactions FORCE INDEX (idx_transactions_date)
--   WHERE transaction_date BETWEEN '2025-03-01' AND '2025-03-31';
--   -> type = range, key = idx_transactions_date, rows = 54
-- At production scale (100k+ rows) the optimizer would choose this index
-- automatically. This behavior is a common interview talking point: indexes
-- don't guarantee usage — the optimizer decides based on table statistics.

SHOW INDEX FROM transactions;
SHOW INDEX FROM companies;
