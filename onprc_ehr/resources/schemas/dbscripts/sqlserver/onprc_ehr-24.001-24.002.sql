--added to allow insert of calculated fields from eIACUC

--2024-12-13 In development need to use a drop if exists statement for these to run

ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [BaseProtocol] varchar(100) Null;
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [RevisionNumber] varchar(100) Null;
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [NewestRecord] INT Null;