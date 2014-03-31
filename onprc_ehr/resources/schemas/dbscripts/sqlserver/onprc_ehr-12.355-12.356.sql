EXEC sp_rename 'onprc_ehr.tissue_recipients', 'customers';

ALTER TABLE onprc_ehr.vet_assignment DROP COLUMN priority;
GO
ALTER TABLE onprc_ehr.vet_assignment add priority bit;
