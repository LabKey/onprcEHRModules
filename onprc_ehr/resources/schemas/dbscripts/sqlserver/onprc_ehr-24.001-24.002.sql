SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jonesga
-- Create date: 2024-11-18
-- Description:	This Stored Preocduer is deigned to
----Compare current Prime Protocols to eiACUC Protocols
----and end Date the Protocols in Prime that have a
----Protocol State of expired, terminated or withdrawn
--Update -for Github to Buidl 23.11 New Build
-- =============================================
CREATE PROCEDURE onprc_ehr.eIACUCtoPRIMEProtocolProcessing
    -- No Parameters are used
    AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--Step One
--Determine the Base Protocol and Revision Number in eIACUC Protocols
--Creates temp Table #PRIMEProtocolstoEndDate

Select rowid,
       Protocol_ID,
       CASE
           WHEN len(Protocol_ID) > 10 then substring(Protocol_ID,6,15)
           ELSE Protocol_ID
           END as BaseProtocol,
       CASE
           WHEN len(Protocol_ID) > 10 then substring(Protocol_ID,1,4)
           ELSE 'Original'
           END as RevisionNumber,
       Protocol_Title,
       Template_OID,
       Approval_Date,
       last_modified,
       Three_year_Expiration,
       Protocol_State
INTO  #PRIMEProtocolstoEndDate
from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--Step Two
--Using Values in Step 1 limits tghe records returned to newest record for a base protocol
--Vtrsrd tempt Table  #DistincteIACUCProtocolv
SELECT
    rowid,
    BaseProtocol,
    RevisionNumber,
    Protocol_Title,
    Template_OID,
    Approval_Date,
    last_modified,
    Three_year_Expiration,
    Protocol_State
INTO #DistincteIACUCProtocol
from  #PRIMEProtocolstoEndDate
where rowID  =
      (Select Max(rowID) from #PRIMEProtocolstoEndDate p1 where p1.BaseProtocol = #PRIMEProtocolstoEndDate.BaseProtocol)
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--Step Three
-- Determine what records in ehr.prtotocol (##TestingProtocol) here need to be enddated
--we will use the three year renewal date as the end date of the protocol
--Creates Temp Table  #PRIMEProtocolstoEndDate
--DROP TABLE #PRIMEProtocolstoEndDate
Select
    p.protocol,
    p.external_id,
    p.approve,
    p.enddate,
    d.BaseProtocol,
    d.RevisionNumber,
    d.PROTOCOL_State,
    d.Three_year_Expiration
into #endDatePrimeProtocols
From ehr.protocol p join #DistincteIACUCProtocol d on p.external_Id = d.baseProtocol
--Select * from  #PRIMEProtocolstoEndDate
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--Step Four
-- Update of Records Identified in Step 3
--we will use the three year renewal date as the end date of the protocol
--
Update p
Set p.enddate = e.Three_year_Expiration,p.contacts = 'Protocol enddate based on eIACUC Record PROTOCOL STATE = ' + e.Protocol_State
--Select p.*
    from ehr.protocol p join #endDatePrimeProtocols e on p.protocol = e.protocol


END
GO
