/*
     Created: 7-16-2026   R. Blasa   Process to removed temp tables, and stored prcoedure that are no longer needed

 */
---Dropping user defined sql queries
 --- ComplianceProcedureRecenttTestsorg.sql
---- ComplianceProcedureRecentTestsorg  --> directory and xml files

--- ComplianceRecenttTestsorg.sql
---- ComplianceRecentTestsorg  --> directory and xml files


----Drop corresponding temp tables
  ---- No temp tables to include here
--Drop stored procedures
EXEC core.fn_dropifexists 'sp_Compliance_requirementname_Update_Process','onprc_ehr','PROCEDURE';
GO
----Drop corresponding temp tables
EXEC core.fn_dropifexists 'Rpt_TempJmacDate','onprc_ehr','TABLE';
GO

EXEC core.fn_dropifexists 'JmacRemovalDate','onprc_ehr','TABLE';
GO
--Drop stored procedures
EXEC core.fn_dropifexists 's_JmacRemovalDateProcess','onprc_ehr','PROCEDURE';
GO
----Drop corresponding temp tables
  ---- No temp tables to include here
--Drop stored procedures
EXEC core.fn_dropifexists 'p_EnvironmentalHistoricalUpdates','onprc_ehr','PROCEDURE';
GO
----Drop corresponding temp tables
  ---- No temp tables to include here
--Drop stored procedures
EXEC core.fn_dropifexists 'p_Environmental_Update_Process','onprc_ehr','PROCEDURE';
GO
----Drop corresponding temp tables
EXEC core.fn_dropifexists 'Rpt_SLaCensus','dbo','TABLE';
GO
--Drop stored procedures
EXEC core.fn_dropifexists 'sp_RpSLASummaryCensus','dbo','PROCEDURE';
GO

----Drop corresponding temp tables
EXEC core.fn_dropifexists 'Rpt_Labwork_MergeUpdate','dbo','TABLE';
GO
EXEC core.fn_dropifexists 'Rpt_Labwork_MergeUpdatelog','dbo','TABLE';
GO
--Drop stored procedures
EXEC core.fn_dropifexists 'RptMergeChargetypeUpdateSP','dbo','PROCEDURE';
GO


----Drop corresponding temp tables
---- No temp tables to include here
--Drop stored procedures
EXEC core.fn_dropifexists 'p_ComplianceTranslatestringUpdate','onprc_ehr_compliancedb','PROCEDURE';
GO





