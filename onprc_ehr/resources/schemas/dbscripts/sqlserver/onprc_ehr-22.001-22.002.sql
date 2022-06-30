--added to allow department descignation for R & L
--Modified 2022-06-30 Added to Separate Feature Branch for Processing
EXEC core.fn_dropifexists 'Investigators', 'onprc_ehr', 'COLUMN', 'Department';
GO
ALTER TABLE onprc_ehr.investigators ADD [Department] varchar(250) Null;
