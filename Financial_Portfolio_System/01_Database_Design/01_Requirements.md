# Phase 1 — Requirements
## Financial Portfolio Management System (MySQL Portfolio Project)

### 1. Purpose
A simplified database system that lets a brokerage track **users**, the **companies/stocks** they can trade, the **portfolios** users own, what **holdings** sit inside those portfolios, the **buy/sell transactions** that create those holdings, and a **watchlist** of stocks users are monitoring but haven't bought.

This mirrors the kind of relational modeling a BTSA (Business Technology Solutions Associate) is expected to reason about — entities, relationships, and the SQL to query them — without enterprise-scale complexity.

### 2. Core Entities

| Entity | Description |
|---|---|
| **Users** | People who hold accounts on the platform |
| **Companies** | Publicly traded companies (e.g., Apple, Infosys) |
| **Stocks** | The tradable stock/ticker tied to a company, with current price |
| **Portfolios** | A user can have one or more portfolios (e.g., "Retirement", "Growth") |
| **Holdings** | Aggregated position of a stock within a portfolio (derived from transactions) |
| **Transactions** | Individual BUY/SELL trade records |
| **Watchlist** | Stocks a user is tracking without owning |

### 3. Relationships (Business Rules)

- One **User** → many **Portfolios** (1:M)
- One **Company** → one **Stock** (1:1, kept as separate tables for normalization — company profile data vs. tradable stock data)
- One **Portfolio** → many **Holdings** (1:M)
- One **Stock** → many **Holdings** across different portfolios (1:M)
- One **Portfolio** → many **Transactions** (1:M)
- One **Stock** → many **Transactions** (1:M)
- One **User** → many **Watchlist** entries, each pointing to one **Stock** (M:M between Users and Stocks, resolved via the Watchlist junction table)

### 4. Functional Requirements

1. Users can be created, updated, and removed.
2. Each user can create multiple portfolios.
3. Buying a stock creates a transaction and updates (or creates) a holding.
4. Selling a stock creates a transaction and reduces (or removes) a holding.
5. Users can add/remove stocks from a personal watchlist.
6. The system must be able to report:
   - Portfolio value per user
   - Top-performing stocks
   - Most active traders
   - Sector-wise investment distribution
   - Transaction history per portfolio

### 5. Non-Functional Requirements

- Must run on **MySQL 8**, buildable entirely in **MySQL Workbench**.
- Schema normalized to **3NF** (no repeating groups, no partial/transitive dependencies).
- Must support realistic sample data (20 users, 30 companies, ~300 transactions).
- Must include indexes on frequently filtered/joined columns.
- Must include 1 trigger for transaction logging, 2 views, 2 stored procedures.

### 6. Out of Scope (Deliberately Excluded)

- Real-time market data / APIs
- Authentication / password hashing
- Frontend or reporting UI
- Window functions, recursive CTEs, JSON columns, partitioning, events, roles/permissions
- Backup & Recovery — **flagged for later, once the core deliverable is complete**

---
### Interview Questions (Phase 1)
1. Why model `Companies` and `Stocks` as two tables instead of one?
2. Why is `Holdings` a separate table instead of just summing `Transactions` every time?
3. How would you resolve a many-to-many relationship like Users↔Stocks (watchlist)?
4. What's the difference between a functional requirement and a non-functional requirement?

### Common Mistakes
- Merging Company and Stock data into one table (violates 3NF if a company later has multiple stock classes, and mixes slowly-changing profile data with fast-changing price data).
- Treating Holdings as unnecessary and always calculating from Transactions live (fine at small scale, but bad practice to not demonstrate — this project intentionally keeps Holdings as a maintained summary table, updated via the trigger/procedure, to demonstrate derived-data management).
- Forgetting the Watchlist is a many-to-many relationship and trying to store multiple stock IDs in one column (violates 1NF).
