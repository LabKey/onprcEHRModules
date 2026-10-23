USe LabKey_Audit

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