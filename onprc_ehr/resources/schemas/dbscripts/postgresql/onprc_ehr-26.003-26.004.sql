/*
     PostgreSQL equivalent of the sqlserver onprc_ehr-26.003-26.004.sql script.

     Two translation notes:
       - SQL Server stored procedures are implemented as zero-argument plpgsql functions here, so each
         EXEC core.fn_dropifexists '<name>','<schema>','PROCEDURE' becomes DROP FUNCTION IF EXISTS <schema>.<name>().
       - The objects the sqlserver script drops out of 'dbo', and the onprc_ehr_compliancedb procedure, have no
         PostgreSQL counterpart -- nothing on this platform ever created them. They are left as comments below,
         in the same order as the sqlserver script, so the two files still read side by side.
 */
---Dropping user defined sql queries
--- ComplianceProcedureRecenttTestsorg.sql
---- ComplianceProcedureRecentTestsorg  --> directory and xml files

--- ComplianceRecenttTestsorg.sql
---- ComplianceRecentTestsorg  --> directory and xml files


----Drop corresponding temp tables
---- No temp tables to include here
--Drop stored procedures
DROP FUNCTION IF EXISTS onprc_ehr.sp_Compliance_requirementname_Update_Process();

----Drop corresponding temp tables

--Drop stored procedures
DROP FUNCTION IF EXISTS onprc_ehr.s_JmacRemovalDateProcess();

DROP TABLE IF EXISTS onprc_ehr.Rpt_TempJmacDate;

DROP TABLE IF EXISTS onprc_ehr.JmacRemovalDate;

----Drop corresponding temp tables
  ---- No temp tables to include here
--Drop stored procedures
DROP FUNCTION IF EXISTS onprc_ehr.p_EnvironmentalHistoricalUpdates();

----Drop corresponding temp tables
  ---- No temp tables to include here
--Drop stored procedures
DROP FUNCTION IF EXISTS onprc_ehr.p_Environmental_Update_Process();

--Drop stored procedures
---- sqlserver only: dbo.sp_RpSLASummaryCensus was never created on PostgreSQL

----Drop corresponding temp tables
---- sqlserver only: dbo.Rpt_SLaCensus was never created on PostgreSQL


--Drop stored procedures
---- sqlserver only: dbo.RptMergeChargetypeUpdateSP was never created on PostgreSQL

----Drop corresponding temp tables
---- sqlserver only: dbo.Rpt_Labwork_MergeUpdate was never created on PostgreSQL
---- sqlserver only: dbo.Rpt_Labwork_MergeUpdatelog was never created on PostgreSQL


--Drop stored procedures
DROP FUNCTION IF EXISTS onprc_ehr.s_MasterProblemHistoricalProcess();


----Drop corresponding temp tables
---- No temp tables to include here
--Drop stored procedures
---- sqlserver only: the onprc_ehr_compliancedb schema has no PostgreSQL dbscripts, so
---- p_ComplianceTranslatestringUpdate does not exist on this platform

----Drop corresponding temp tables
DROP TABLE IF EXISTS onprc_ehr.Rpt_TempProblemList;

DROP TABLE IF EXISTS onprc_ehr.Rpt_TempProblemListMaster;
