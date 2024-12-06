GO
/****** Object:  StoredProcedure [onprc_ehr].[eIACUCtoPrimeEndDateProcessing]    Script Date: 11/21/2024 10:25:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
GO
/****** Object:  StoredProcedure [onprc_ehr].[eIACUCtoPrimeEndDateProcessing]    Script Date: 11/21/2024 10:25:00 AM ******
  2024-12-06 New Stored Proceddure designed to handle Max Row on a Base Protocol*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [onprc_ehr].[eIACUCtoPrimeProcessing]


AS
BEGIN

    DROP TABLE IF EXISTS #expiredProtocolMaxRow --do this duirng development only as the Temp table drops once the session is closed

CREATE TABLE #expiredProtocolMaxRow (
    BaseProtocol varchar(50) ,
    MaxRowID INT
)
-- THis populates the temp table with Highest Numbered Roaw for a base protocol
    Insert INTO #expiredProtocolMaxRow(BaseProtocol,MaxRowID)
    Select BaseProtocol,
       Max(RowID)
from [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS]
Group By BaseProtocol
Select
    p.BaseProtocol,
    p.RevisionNumber,
    p.Approval_Date,
    p.PROTOCOL_State
from [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS] p
where p.RowID in (Select r.MaxRowId from #expiredProtocolMaxRow  r where r.BaseProtocol = p.BaseProtocol)
Order by p.BaseProtocol

CREATE TABLE #ExpiredeIACUCProtocols(
    RowID INT,
    BaseProtocol varchar(50),
    RevisionNumber varchar(10),
    Approval_Date Date,
    Protocol_State varchar(50)
)
    Insert into #ExpiredeIACUCProtocols(
	RowID,
	BaseProtocol,
	RevisionNumber,
	Approval_Date,
	Protocol_State)
Select
    p.RowID,
    p.BaseProtocol,
    p.RevisionNumber,
    p.Approval_Date,
    p.PROTOCOL_State
from [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS] p
where p.RowID in (Select r.MaxRowId from #expiredProtocolMaxRow  r where r.BaseProtocol = p.BaseProtocol)
Order by p.BaseProtocol


Select * from #ExpiredeIACUCProtocols

Update p --this updated the ehr.protocol table by end dating the protocol setting enddate to last approvaldate
Set p.enddate = e.Approval_Date, p.contacts = 'End Dated based on eIACUC Protocol_State ' + e.Protocol_State
--Select e.*
from ehr.protocol p join #ExpiredeIACUCProtocols e on p.external_Id = e.BaseProtocol
where p.enddate is null

End