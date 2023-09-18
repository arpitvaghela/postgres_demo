CREATE TYPE t_type AS ENUM ('deposit', 'withdraw');

CREATE TABLE purchase(
    purchaseid SERIAL PRIMARY KEY,
    purchase TEXT NOT NULL,
    cost NUMERIC(10,2) NOT NULL,
    purchase_time TIMESTAMP NOT NULL
);

CREATE TABLE mystatement(
    transaction_id SERIAL PRIMARY KEY,
    transaction_type t_type,
    amount NUMERIC(10,2) NOT NULL,
    balance NUMERIC(10,2) NOT NULL,
    transaction_time TIMESTAMP NOT NULL
);

-- COPY tables here

CREATE OR REPLACE FUNCTION update_balance_trigger() RETURNS TRIGGER AS $$
DECLARE
    last_balance NUMERIC(10,2);
    new_balance NUMERIC(10,2);
BEGIN
    -- Get the last balance from the mystatement table
    IF ((SELECT COUNT(*) FROM mystatement) = 0)
    THEN
        last_balance := 0;
    ELSE
        SELECT balance INTO last_balance FROM mystatement
        ORDER BY transaction_time DESC
        LIMIT 1;
    END IF;

    -- Calculate the new balance based on the transaction type
    new_balance := last_balance - NEW.cost;
    

    -- Check if the new balance is non-negative before allowing the purchase
    IF new_balance >= 0 THEN
        -- Insert the new transaction into the mystatement table
        INSERT INTO mystatement (transaction_type, amount, balance, transaction_time)
        VALUES ('withdraw', NEW.cost, new_balance, NEW.purchase_time);
        RETURN NEW;
    ELSE
        -- Raise an exception to prevent the purchase if the balance is negative
        RAISE EXCEPTION 'Insufficient balance for the purchase';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER purchase_statement_trigger
AFTER INSERT ON purchase
FOR EACH ROW
EXECUTE FUNCTION update_balance_trigger();

CREATE OR REPLACE FUNCTION autofill_balance_trigger() RETURNS TRIGGER AS $$
DECLARE
    last_balance NUMERIC(10,2);
    new_balance NUMERIC(10,2);
BEGIN
    -- Get the last balance from the mystatement table
    IF ((SELECT COUNT(*) FROM mystatement) = 0)
    THEN
        last_balance := 0;
    ELSE
        SELECT balance INTO last_balance FROM mystatement
        ORDER BY transaction_time DESC
        LIMIT 1;
    END IF;

    -- Calculate the new balance based on the transaction type
    IF NEW.transaction_type = 'withdraw' THEN
        new_balance := last_balance - NEW.amount;
    ELSE
        new_balance := last_balance + NEW.amount;
    END IF;
    

    -- Check if the new balance is non-negative before allowing the purchase
    IF new_balance >= -1 THEN
        -- Insert the new transaction into the mystatement table
        NEW.balance := new_balance;
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Insufficient balance to withdraw';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER autofill_balance
BEFORE INSERT ON mystatement
FOR EACH ROW
EXECUTE FUNCTION autofill_balance_trigger();


-- INSERT INTO purchase (purchase, cost, purchase_time) VALUES ('apple_bill', 1.1, NOW());