ALTER TABLE geneticscore.mhc_data DROP CONSTRAINT PK_mhc_data;
ALTER TABLE geneticscore.mhc_data ALTER COLUMN objectid SET NOT NULL;
ALTER TABLE geneticscore.mhc_data ADD CONSTRAINT PK_mhc_data PRIMARY KEY (objectid);