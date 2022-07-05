--added to allow department descignation for R & L
EXEC core.fn_dropifexists 'Investigators', 'onprc_ehr', 'COLUMN', 'Department';
GO
ALTER TABLE onprc_ehr.investigators ADD [Department] varchar(250) Null;
