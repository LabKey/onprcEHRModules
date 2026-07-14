/*
     Created: 7-16-2026   R. Blasa   Process to removed temp tables, and stored prcoedure that are no longer needed

 */
---Dropping user defined sql queries
 --- ComplianceProcedureRecenttTestsorg.sql
---- ComplianceProcedureRecentTestsorg  --> directory and xml files

--- ComplianceRecenttTestsorg.sql
---- ComplianceRecentTestsorg  --> directory and xml files


EXEC core.fn_dropifexists 's_JmacRemovalDateProcess','onprc_ehr','TABLE';


----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'sp_Compliance_requirementname_Update_Process','onprc_ehr','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 's_JmacRemovalDateProcess','onprc_ehr','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'p_EnvironmentalHistoricalUpdates','onprc_ehr','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'p_Environmental_Update_Process','onprc_ehr','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'sp_RpSLASummaryCensus','dbo','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'RptMergeChargetypeUpdateSP','dbo','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'RptMergeChargetypeUpdateSP','dbo','PROCEDURE';

----Drop corresponding temp tables

--Drop stored procedures
EXEC core.fn_dropifexists 'p_ComplianceTranslatestringUpdate','onprc_ehr_compliancedb','PROCEDURE';




GO





