ALTER TABLE onprc_ehr.tissue_recipients RENAME TO customers;

ALTER TABLE onprc_ehr.vet_assignment DROP COLUMN priority;
ALTER TABLE onprc_ehr.vet_assignment add priority bool;