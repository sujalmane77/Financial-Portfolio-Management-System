# Financial Portfolio Management System
### A MySQL Portfolio Project (BTSA / Fresher-Level SQL Skills)

A relational database that models a simplified stock brokerage: users, companies, tradable stocks, portfolios, holdings, buy/sell transactions, and watchlists — built to demonstrate clean schema design and practical SQL proficiency, not enterprise complexity.

---
## Tech Stack
- MySQL 8 / MySQL Workbench (built and tested here against MariaDB 10.11, which is wire-compatible with MySQL 8 for every feature used)
- Pure SQL — no application code, no APIs, no frontend

## Schema Overview

8 tables, normalized to 3NF:

| Table | Purpose |
|---|---|
| `users` | Platform account holders |
| `companies` | Company profile data (name, sector, exchange, country) |
| `stocks` | Tradable ticker + live price, 1:1 with companies |
| `portfolios` | A user can own multiple portfolios |
| `holdings` | Current position per portfolio+stock (maintained via procedures) |
| `transactions` | Immutable BUY/SELL trade history |
| `watchlist` | Many-to-many junction: users tracking stocks they don't own |
| `transaction_log` | Audit trail, auto-populated by trigger |

Full ER diagram and normalization notes: [`01_Database_Design/02_ER_Diagram.md`](01_Database_Design/02_ER_Diagram.md)

## Folder Structure

```
Financial_Portfolio_System/
├── 01_Database_Design/     Requirements + ER diagram
├── 02_SQL/                 Database + table creation, sample data
├── 03_Queries/             CRUD, joins, aggregates, subqueries
├── 04_Views/                2 reporting views
├── 05_Stored_Procedures/    sp_buy_stock, sp_sell_stock
├── 06_Triggers/             Transaction audit-logging trigger
├── 07_Indexes/              Indexes + before/after EXPLAIN
├── 08_Documentation/        Concept-by-concept explanations
├── PROJECT_STATE.md         Session/progress tracker
└── README.md                This file
```

## How to Run (MySQL Workbench or CLI)

Run these files **in order**:

```
1. 02_SQL/01_create_database.sql
2. 02_SQL/02_create_tables.sql
3. 02_SQL/03_insert_sample_data.sql
4. 04_Views/views.sql
5. 05_Stored_Procedures/procedures.sql
6. 06_Triggers/trigger.sql
7. 07_Indexes/indexes_and_explain.sql
```

Then explore anything in `03_Queries/` freely — they're read-only reporting queries.

**CLI equivalent:**
```bash
mysql -u root -p < 02_SQL/01_create_database.sql
mysql -u root -p < 02_SQL/02_create_tables.sql
mysql -u root -p < 02_SQL/03_insert_sample_data.sql
mysql -u root -p < 04_Views/views.sql
mysql -u root -p < 05_Stored_Procedures/procedures.sql
mysql -u root -p < 06_Triggers/trigger.sql
mysql -u root -p < 07_Indexes/indexes_and_explain.sql
```

## Sample Data Scale
- 20 users
- 30 companies / 30 stocks (mix of NSE India + NASDAQ/NYSE US large-caps)
- ~29 portfolios
- 300 buy/sell transactions (quantity-safe — sells never exceed running holdings)
- 255 derived holdings
- 40 watchlist entries

## Verified Working (tested against a live MariaDB 10.11 instance)
- All 8 tables create cleanly with FK constraints enforced
- Sample data loads without constraint violations
- `sp_buy_stock` / `sp_sell_stock` correctly sync the `holdings` table and reject over-selling via `SIGNAL SQLSTATE '45000'`
- `trg_log_transaction` fires automatically on every transaction insert
- Both views return correct aggregated data
- Indexes measurably change `EXPLAIN` plans (see `07_Indexes/indexes_and_explain.sql` for real before/after output, including an honest case where MySQL's optimizer ignores a valid index on a small table)

## Skills Demonstrated
Database design (ER modeling, PK/FK, 3NF) · CRUD · WHERE/ORDER BY/GROUP BY/HAVING/DISTINCT/LIMIT · INNER/LEFT/RIGHT JOIN · Aggregate functions · Subqueries (scalar, IN, correlated) · Views · Stored procedures with error handling · Triggers · Indexing + EXPLAIN

## Roadmap / Not Yet Included
- **Backup & Recovery** — intentionally deferred as a bonus, post-deliverable enhancement (mysqldump strategy, point-in-time recovery notes) to keep this core deliverable lean and interview-ready first.
- Deliberately excluded per project scope: window functions, recursive CTEs, JSON columns, partitioning, events, roles/permissions, Docker, cloud deployment.
