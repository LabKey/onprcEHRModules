--This update allow sthe end date of the row to contain a null value
--Revised 2025-0630
ALTER TABLE ogasynchIR
ALTER COLUMN EndDate DATE NULL;
