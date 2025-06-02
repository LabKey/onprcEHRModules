--This update allow sthe end date of the row to contain a null value
ALTER TABLE ogasynchIR
ALTER COLUMN EndDate DATE NULL;
