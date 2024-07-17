-- ================================================
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
-- Create date: July 16,2024
-- Description:	SP to update teh eIACUC Protocols data with needed Base Protocol
-- =============================================
Alter PROCEDURE onprc_ehr.UpdateeIACUCDetails

    AS
BEGIN
CREATE TABLE #eIACUCUpdate
(rowid varchar(255) not Null,
 BaseProtocol varchar(50) Not Null,
 RevisionNumber varchar(20) Not Null,
 Protocol_Id varchar(50) Not Null,
 Last_Modified varchar(30) not null ,
 LatestInstance varchar (30) Not Null);

--Populate the tempary table from query
Insert INTO #eIACUCUpdate(rowid,BaseProtocol,RevisionNumber,Protocol_id,Last_Modified,LatestInstance)
Select
    rowid,
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

--Update Latest Instance Field after finding most recent record for a baseProtocol

--!@!Start cleanup here
update e
Set e.LatestInstance = 'Update'

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p left join #eIACUCUpdate e on p.protocol_id = e.Protocol_ID
where p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 where p1.BaseProtocol = p.BaseProtocol)
  and p.BaseProtocol is not null

update p
Set p.BaseProtocol = e1.protocol,
    p.revisionNumber  = e1.RevisionNumber
    p.Last_Modified = e.Last_Modified,
		p.Contacts = e1.

 from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p left join #eIACUCUpdate e1 on p.protocol_id = e1.Protocol_ID
where p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 where p1.BaseProtocol = e1.BaseProtocol)
  and p.BaseProtocol is not null


--Update onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
--  Select * from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS



--Drop Table #eIACUCUpdate
END
GO
