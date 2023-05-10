/*This process removes two tables being reported as not be defined in the related xml
This was reviewed by ISE Dev team and determined not to be needed
2023-05-10 jonesga running on prime2303 to determine if it clears the errors

USE [Labkey_upgrade]
GO

/****** Object:  Table [sla].[vendors_new]    Script Date: 5/10/2023 6:44:44 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[sla].[vendors_new]') AND type in (N'U'))
DROP TABLE [sla].[vendors_new]
GO

/****** Object:  Table [sla].[requestors_new]    Script Date: 5/10/2023 6:45:03 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[sla].[requestors_new]') AND type in (N'U'))
DROP TABLE [sla].[requestors_new]
GO