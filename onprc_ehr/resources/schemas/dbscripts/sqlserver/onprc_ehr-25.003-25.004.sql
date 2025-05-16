
/** Update f to add Primary Key as suggested by Labkey **/
ALTER TABLE dbo.ArchiveAuditLog
    ADD CONSTRAINT PK_Logs PRIMARY KEY (LogID);
