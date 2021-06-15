ALTER TABLE geneticscore.mhc_data DROP CONSTRAINT PK_mhc_data;
ALTER TABLE geneticscore.mhc_data ALTER COLUMN objectid entityid NOT NULL;
GO
ALTER TABLE geneticscore.mhc_data ADD CONSTRAINT PK_mhc_data PRIMARY KEY (objectid);