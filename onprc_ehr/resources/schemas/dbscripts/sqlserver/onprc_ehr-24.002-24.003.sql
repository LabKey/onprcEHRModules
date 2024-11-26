--Created 2024-11-26
--Adding Fields to Table

ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD  BaseProtocol varchar(25);
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD  RevisionNumber varchar(25);
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD  RN int;