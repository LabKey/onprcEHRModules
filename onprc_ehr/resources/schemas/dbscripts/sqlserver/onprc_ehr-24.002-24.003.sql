-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
--   Added updatge for Latest Renewal in the Stored Procedure
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonesga
-- Create date: 2024/07/25
-- Description:	Iniitial Stage of update of eIACUC to protocol processing
    -- Stored Procedure did not process, will retry
-- =============================================
--DROP PROCEDURE onprc_ehr.eIACUCBaseProtocol;
EXEC core.fn_dropifexists 'eIACUCBaseProtocol', 'onprc_ehr', 'PROCEDURE';

Go
CREATE PROCEDURE onprc_ehr.eIACUCBaseProtocol

    AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Drop Temporary Table #eIACUCBaseProtocol
--DROP TABLE #eIACUCBaseProtocol
-- Insert statements for procedure here
cREATE tABLE #eIACUCBaseProtocol
(BaseProtocol varchar(50) Not Null,
 RenewalNumber varchar(20) Not Null,
 Protocol_Id varchar(50) Not Null,
 Last_Modified varchar(30) not null ,
 LatestREnewal varchar (30) Not Null);

--Populate the temporary table from query
Insert INTO #eIACUCBaseProtocol(BaseProtocol,RenewalNumber,Protocol_id,Last_Modified,LatestRenewal)
Select

    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 6,15)
         else p.protocol_id
        End as BaseProtocol,
    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 1,4)
         else 'Original'
        End as RenewalNumber,
    protocol_id,
    Last_Modified,
    ' ' as LatestRenewal

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p

Update p1
Set p1.BaseProtocol = e.BaseProtocol

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 join #eIACUCBaseProtocol e on p1.protocol_id = e.Protocol_Id

Update p1
Set p1.ReNewalNumber = e.ReNewalNumber

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 join #eIACUCBaseProtocol e on p1.protocol_id = e.Protocol_Id

Update p
Set p.LatestRenewal = 1

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
where (p.BaseProtocol is not null and p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS  p1 where p1.BaseProtocol = p.BaseProtocol))

END
GO