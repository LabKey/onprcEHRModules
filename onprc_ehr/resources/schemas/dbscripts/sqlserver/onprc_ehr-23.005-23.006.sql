--added to allow department descignation for R & L
EXEC core.fn_dropifexists 'protocol_logs', 'onprc_ehr', 'COLUMN', 'Protocol_State';
GO

ALTER TABLE onprc_ehr.protocol_logs ADD [Protocol_State] varchar(250) Null;
ALTER TABLE onprc_ehr.protocol_logs ADD [PPQ_Numbers] varchar(250) Null;
ALTER TABLE onprc_ehr.protocol_logs ADD [Template_OID] varchar(250) Null;