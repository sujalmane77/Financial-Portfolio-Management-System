-- =====================================================
-- Phase 11: Stored Procedures
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- PROCEDURE 1: sp_buy_stock
-- Records a BUY transaction AND keeps the holdings table in sync
-- (insert new holding, or update quantity + weighted avg_buy_price if one exists).
-- Why: This is the single entry point the application layer should call for a
-- "buy" action, so transaction history and holdings summary never drift apart.
-- ------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_buy_stock;

DELIMITER $$

CREATE PROCEDURE sp_buy_stock (
    IN p_portfolio_id INT,
    IN p_stock_id      INT,
    IN p_quantity      INT,
    IN p_price         DECIMAL(12,2)
)
BEGIN
    DECLARE v_existing_qty INT DEFAULT 0;
    DECLARE v_existing_avg DECIMAL(12,2) DEFAULT 0;

    -- 1. Record the transaction (the AFTER INSERT trigger will log it automatically)
    INSERT INTO transactions (portfolio_id, stock_id, transaction_type, quantity, price_per_share)
    VALUES (p_portfolio_id, p_stock_id, 'BUY', p_quantity, p_price);

    -- 2. Sync the holdings table
    SELECT quantity, avg_buy_price INTO v_existing_qty, v_existing_avg
    FROM holdings
    WHERE portfolio_id = p_portfolio_id AND stock_id = p_stock_id;

    IF v_existing_qty IS NULL THEN
        -- No existing holding: create one
        INSERT INTO holdings (portfolio_id, stock_id, quantity, avg_buy_price)
        VALUES (p_portfolio_id, p_stock_id, p_quantity, p_price);
    ELSE
        -- Existing holding: recompute weighted average buy price
        UPDATE holdings
        SET quantity = v_existing_qty + p_quantity,
            avg_buy_price = ROUND(
                ((v_existing_qty * v_existing_avg) + (p_quantity * p_price))
                / (v_existing_qty + p_quantity), 2)
        WHERE portfolio_id = p_portfolio_id AND stock_id = p_stock_id;
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------
-- PROCEDURE 2: sp_sell_stock
-- Records a SELL transaction, validates enough quantity is held, and reduces
-- (or removes) the holding. avg_buy_price is untouched by a sell (cost-basis
-- of the remaining shares doesn't change when you sell some of them).
-- ------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_sell_stock;

DELIMITER $$

CREATE PROCEDURE sp_sell_stock (
    IN p_portfolio_id INT,
    IN p_stock_id      INT,
    IN p_quantity      INT,
    IN p_price         DECIMAL(12,2)
)
BEGIN
    DECLARE v_existing_qty INT DEFAULT 0;

    SELECT quantity INTO v_existing_qty
    FROM holdings
    WHERE portfolio_id = p_portfolio_id AND stock_id = p_stock_id;

    IF v_existing_qty IS NULL OR v_existing_qty < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot sell more shares than currently held.';
    END IF;

    -- 1. Record the transaction (trigger logs it automatically)
    INSERT INTO transactions (portfolio_id, stock_id, transaction_type, quantity, price_per_share)
    VALUES (p_portfolio_id, p_stock_id, 'SELL', p_quantity, p_price);

    -- 2. Sync holdings: reduce quantity, delete the row if it hits zero
    IF v_existing_qty = p_quantity THEN
        DELETE FROM holdings
        WHERE portfolio_id = p_portfolio_id AND stock_id = p_stock_id;
    ELSE
        UPDATE holdings
        SET quantity = v_existing_qty - p_quantity
        WHERE portfolio_id = p_portfolio_id AND stock_id = p_stock_id;
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------
-- Usage examples
-- ------------------------------------------------------
-- CALL sp_buy_stock(1, 5, 10, 152.50);
-- CALL sp_sell_stock(1, 5, 4, 160.00);
