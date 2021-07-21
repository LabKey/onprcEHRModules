ALTER TABLE onprc_ehr.AvailableBloodVolume ALTER COLUMN Id nvarchar(32) NOT NULL;
GO

ALTER TABLE onprc_ehr.AvailableBloodVolume ADD CONSTRAINT PK_AvailableBloodVolume PRIMARY KEY (Id);
GO
