================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonesga
-- Create date: 2024/07/18
-- Description:	Iniitial Stage of update of eIACUC to protocol processing
-- =============================================

CREATE PROCEDURE onprc_ehr.eIACUCBaseProtocol

    AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Drop Temporary Table
DROP TABLE #eIACUCBaseProtocol
-- Insert statements for procedure here
cREATE tABLE #eIACUCBaseProtocol
(BaseProtocol varchar(50) Not Null,
 RevisionNumber varchar(20) Not Null,
 Protocol_Id varchar(50) Not Null,
 Last_Modified varchar(30) not null ,
 LatestInstance varchar (30) Not Null);

--Populate the temporary table from query
Insert INTO #eIACUCBaseProtocol(BaseProtocol,RevisionNumber,Protocol_id,Last_Modified,LatestInstance)
Select

    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 6,15)
         else p.protocol_id
        End as BaseProtocol,
    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 1,4)
         else 'Original'
        End as RevisionNumber,
    protocol_id,
    Last_Modified,
    ' ' as LatestInstance

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p

Update p1
Set p1.BaseProtocol = e.BaseProtocol

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 join #eIACUCUpdate e on p1.protocol_id = e.Protocol_Id

Update p1
Set p1.RevisionNumber = e.RevisionNumber

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 join #eIACUCUpdate e on p1.protocol_id = e.Protocol_Id



--Now will limit the records to be inserted to most recent record


update p
Set p.updateStatus = 'Update'

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
where (p.BaseProtocol is not null and p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 where p1.BaseProtocol = p.BaseProtocol))





END
GO