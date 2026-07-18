# Documentation — Concepts Explained
## Financial Portfolio Management System

Every concept below follows: **What / Why / Syntax / Example / Where used in this project.**

---
## 1. Primary Keys & Foreign Keys

**What:** A Primary Key (PK) uniquely identifies every row in a table. A Foreign Key (FK) is a column that references a PK in another table, enforcing that a relationship must point to a real row.

**Why:** PKs prevent duplicate/ambiguous rows. FKs prevent orphaned data (e.g., a transaction pointing to a stock that doesn't exist) and let the database enforce relationships automatically.

**Syntax:**
```sql
CREATE TABLE child (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT,
    CONSTRAINT fk_name FOREIGN KEY (parent_id) REFERENCES parent(id)
);
```

**Where used:** Every table in `02_create_tables.sql`. E.g., `stocks.company_id` → `companies.company_id`.

---
## 2. Normalization (up to 3NF)

**What:** A set of rules for organizing tables to eliminate redundancy and update anomalies. 1NF = atomic columns, no repeating groups. 2NF = no partial dependency on part of a composite key. 3NF = no transitive dependency (non-key columns depend only on the key, the whole key, and nothing but the key).

**Why:** Prevents the same fact being stored in multiple places (e.g., a company's sector repeated on every transaction row), which would risk inconsistent updates.

**Example:** `sector` lives only on `companies`, not duplicated onto `stocks` or `transactions`.

**Where used:** Full schema design — see `01_Database_Design/02_ER_Diagram.md`, "Normalization Check" section.

---
## 3. CRUD Operations

**What:** Create (INSERT), Read (SELECT), Update (UPDATE), Delete (DELETE) — the four basic data operations.

**Why:** These are the fundamental building blocks every application performs against a database.

**Syntax:**
```sql
INSERT INTO table (col1, col2) VALUES (v1, v2);
SELECT col1, col2 FROM table WHERE condition;
UPDATE table SET col1 = value WHERE condition;
DELETE FROM table WHERE condition;
```

**Where used:** `03_Queries/01_crud_operations.sql`.

---
## 4. WHERE, ORDER BY, GROUP BY, HAVING, DISTINCT, LIMIT

| Clause | What | Why |
|---|---|---|
| `WHERE` | Filters rows before grouping | Restrict to relevant data |
| `ORDER BY` | Sorts result rows | Present data meaningfully |
| `GROUP BY` | Collapses rows into groups for aggregation | Summarize per category |
| `HAVING` | Filters groups *after* aggregation | `WHERE` can't filter on `SUM()`/`COUNT()` results — `HAVING` can |
| `DISTINCT` | Removes duplicate rows | Get unique values only |
| `LIMIT` | Caps the number of rows returned | Pagination, top-N queries |

**Example:**
```sql
SELECT sector, COUNT(*) FROM companies
GROUP BY sector
HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC
LIMIT 5;
```

**Where used:** Throughout `03_Queries/` and `08_Documentation`.

---
## 5. Joins

**What:** Combine rows from two or more tables based on a related column.

- **INNER JOIN** — only rows with a match in both tables.
- **LEFT JOIN** — all rows from the left table, matched rows from the right (NULL if no match).
- **RIGHT JOIN** — mirror of LEFT JOIN, all rows from the right table.

**Why:** Data is normalized across many tables; joins reassemble it for meaningful queries (e.g., transaction + user name + stock ticker in one row).

**Syntax:**
```sql
SELECT a.col, b.col FROM a
INNER JOIN b ON a.id = b.a_id;
```

**Where used:** `03_Queries/02_join_queries.sql`.

---
## 6. Aggregate Functions

**What:** `COUNT()`, `SUM()`, `AVG()`, `MAX()`, `MIN()` — functions that compute one value from many rows.

**Why:** Turn raw transaction/holding rows into business metrics (total portfolio value, average trade size, most active user).

**Example:**
```sql
SELECT stock_id, SUM(quantity) AS total_held
FROM holdings GROUP BY stock_id;
```

**Where used:** `03_Queries/03_aggregate_queries.sql`.

---
## 7. Subqueries

**What:** A query nested inside another query — as a scalar value, an `IN` list, or a correlated lookup that re-runs per outer row.

**Why:** Lets you filter or compute using a result that itself requires computation (e.g., "users above the average portfolio value").

**Example (correlated subquery):**
```sql
SELECT p.portfolio_id,
  (SELECT MAX(t.transaction_date) FROM transactions t
   WHERE t.portfolio_id = p.portfolio_id) AS last_trade
FROM portfolios p;
```

**Where used:** `03_Queries/04_subqueries.sql`.

---
## 8. Views

**What:** A saved, named SELECT query that behaves like a virtual table.

**Why:** Hides complex joins behind a simple name, keeps reporting logic centralized and reusable, and can restrict which columns/rows a consumer sees.

**Syntax:**
```sql
CREATE VIEW vw_name AS SELECT ... ;
SELECT * FROM vw_name;
```

**Where used:** `04_Views/views.sql` — `vw_portfolio_summary`, `vw_stock_performance`.

---
## 9. Stored Procedures

**What:** A named, precompiled block of SQL logic that can accept parameters and perform multiple statements (INSERT + UPDATE, conditional logic, error handling) as one callable unit.

**Why:** Encapsulates business logic (e.g., "buying a stock" always means: insert a transaction AND sync the holdings table) so the app never has to duplicate that logic or forget a step.

**Syntax:**
```sql
DELIMITER $$
CREATE PROCEDURE sp_name(IN p_param INT)
BEGIN
    -- statements
END$$
DELIMITER ;
CALL sp_name(5);
```

**Where used:** `05_Stored_Procedures/procedures.sql` — `sp_buy_stock`, `sp_sell_stock`.

---
## 10. Triggers

**What:** A block of SQL that runs automatically in response to an INSERT, UPDATE, or DELETE on a table.

**Why:** Guarantees an action always happens as a side effect of a data change — regardless of which application code path caused it — such as writing an audit log.

**Syntax:**
```sql
CREATE TRIGGER trg_name
AFTER INSERT ON table_name
FOR EACH ROW
BEGIN
    -- use NEW.column to access the inserted row
END;
```

**Where used:** `06_Triggers/trigger.sql` — `trg_log_transaction` fires after every transaction insert and writes to `transaction_log`.

---
## 11. Indexes & EXPLAIN

**What:** An index is a data structure (B-Tree) that lets MySQL find rows without scanning the whole table. `EXPLAIN` shows the execution plan MySQL will use for a query — which index (if any) it picks, and how many rows it expects to scan.

**Why:** Indexes are the single biggest lever for read performance on large tables. `EXPLAIN` is how you prove an index is actually being used rather than guessing.

**Syntax:**
```sql
CREATE INDEX idx_name ON table_name (column);
EXPLAIN SELECT ... ;
```

**Where used:** `07_Indexes/indexes_and_explain.sql` — includes real measured before/after `EXPLAIN` output, including the honest case where MySQL's optimizer skips a valid index on a small table.

---
### Interview Questions (Documentation-wide)
1. What's the practical difference between `WHERE` and `HAVING`?
2. When would you choose a view vs. a stored procedure?
3. Why might `EXPLAIN` show a full table scan even after you add an index?
4. What problem does 3NF solve that 1NF and 2NF don't?
5. Why use `SIGNAL SQLSTATE` inside a stored procedure?

### Common Mistakes
- Using `WHERE COUNT(*) > 5` instead of `HAVING COUNT(*) > 5` (aggregate filters must use HAVING).
- Assuming every index automatically speeds up every query — the optimizer decides based on table size/statistics.
- Writing business logic only in the application layer and skipping stored procedures/triggers, then having two code paths (batch job + app) fall out of sync on how they update `holdings`.
