--added to allow insert of calculated fields from eIACUC

ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [BaseProtocol] varchar(100) Null;
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [RevisionNumber] varchar(100) Null;
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [NewestRecord] INT Null;