-- Add three fields to Onprc_EHR to processing with ehr.protoocol
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD BaseProtocol varchar(75);
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD RenewalNumber varchar(75);
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD LatestRenewal Bit;