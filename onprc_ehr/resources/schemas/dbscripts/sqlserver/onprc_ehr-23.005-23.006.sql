



-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Stored procedure program to allow cage status settings to be updated by default to "Normal".


CREATE Procedure [onprc_ehr].[p_CageStatusupdates]

AS

BEGIN

If exists (select * from ehr_lookups.cage)
  BEGIN
    --- Set Cage status to Normal                       )

     Update ehr_lookups.cage
          Set status = 'Normal'
         Where status is null


    If @@Error <> 0
	  GoTo Err_Proc

END

 RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO


-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Temp table for cage information audit history.

CREATE TABLE [onprc_ehr].[CageAuditLog](
    [searchid] [int] IDENTITY(100,1) NOT NULL,
    [rowid] [int] NULL,
    [location] [nvarchar](100) NULL,
    [room] [varchar](200) NULL,
    [cage] [varchar](200) NULL,
    [divider] [int] NULL,
    [cage_type] [varchar](100) NULL,
    [hasTunnel] [bit] NULL,
    [status] [varchar](200) NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [area] [varchar](500) NULL,
    [housingtype] [varchar](500) NULL,
    [housingcondition] [varchar](500) NULL,
    [date_created] [smalldatetime] NULL
    ) ON [PRIMARY]

    GO










-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Stored procedure program to provide historical cage information audit history.


CREATE Procedure [onprc_ehr].[p_CageAuditHistoryProcess]

AS


BEGIN

    --- Create historical cage data
If exists (select * from onprc_ehr.CageAuditLog)
BEGIN
Insert into onprc_ehr.CageAuditLog
Select  rowid,
        a.location,
        a.room,
        a.cage,
        a.divider,
        a.cage_type,
        a.hasTunnel,
        a.status,
        a.container,
        (select h.area from ehr_lookups.rooms h where h.room = a.room) as area,
        (select s.value from ehr_lookups.rooms h, ehr_lookups.lookups s where h.room = a.room and s.rowid = h.housingtype) as housingtype,
        (select s.value from ehr_lookups.rooms h, ehr_lookups.lookups s  where h.room = a.room and s.rowid = h.housingcondition) as housingcondition,
        getdate()

from ehr_lookups.cage a

    If @@Error <> 0
	  GoTo Err_Proc

END  --- if exists

 RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO