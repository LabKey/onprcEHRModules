SELECT TOP (1000) [LogId]
     ,[RunId]
     ,[RunDate]
     ,[CheckType]
     ,[TableName]
     ,[ColumnName]
     ,[SourceDetail]
     ,[TargetDetail]
     ,[Severity]
     ,[Recommendation]
FROM [Labkey_testF].[dbo].[AuditFieldPreflightLog]

/*
**
**	 Created by	Date		Comment
**
** 	   blasa     4/10/2026    Process to update jmac Removal date
**
**
**
**/

CREATE  Procedure onprc_ehr.s_JmacRemovalDateProcess


AS



Alter Table audit.c3d307_experimentauditdomain Add TransactionID bigint;
Alter Table audit.c3d308_attachmentauditdomain Add ParentType nvarchar(4000);
Alter Table audit.c3d316_filesystemauditdomain add FieldName nvarchar(4000);
Alter Table audit.c3d316_filesystemauditdomain add ProvidedFileName nvarchar(4000);
Alter Table audit.c3d316_filesystemauditdomain add TransactionID bigint;
Alter Table audit.c3d319_listauditdomain Add TransactionID bigint;
Alter Table audit.c3d784_transactionauditdomain add TransactionDetails nvarchar(Max);
Alter Table audit.c3d787_samplesworkflowauditdomain add ActionId int;
Alter Table audit.c3d787_samplesworkflowauditdomain add ActionType nvarchar(4000);
Alter Table audit.c3d787_samplesworkflowauditdomain add TransactionID bigint;


 */