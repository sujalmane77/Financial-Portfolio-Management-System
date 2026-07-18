-- =====================================================
-- Phase 12: Trigger
-- =====================================================
USE financial_portfolio_system;

-- ------------------------------------------------------
-- TRIGGER: trg_log_transaction
-- Fires AFTER every INSERT on `transactions` and writes a human-readable
-- audit line into `transaction_log`. This is the "who did what, when" trail
-- that a portfolio system needs regardless of which procedure/app path
-- created the transaction.
-- ------------------------------------------------------
DROP TRIGGER IF EXISTS trg_log_transaction;

DELIMITER $$

CREATE TRIGGER trg_log_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    INSERT INTO transaction_log (transaction_id, log_message)
    VALUES (
        NEW.transaction_id,
        CONCAT(
            NEW.transaction_type, ' of ', NEW.quantity,
            ' share(s) on stock_id=', NEW.stock_id,
            ' at price ', NEW.price_per_share,
            ' for portfolio_id=', NEW.portfolio_id
        )
    );
END$$

DELIMITER ;

-- ------------------------------------------------------
-- Verification
-- ------------------------------------------------------
-- INSERT INTO transactions (portfolio_id, stock_id, transaction_type, quantity, price_per_share)
-- VALUES (1, 2, 'BUY', 5, 100.00);
-- SELECT * FROM transaction_log ORDER BY log_id DESC LIMIT 1;
