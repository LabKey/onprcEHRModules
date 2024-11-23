GO
/****** Object:  StoredProcedure [onprc_ehr].[eIACUCtoPrimeEndDateProcessing]    Script Date: 11/21/2024 10:25:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [onprc_ehr].[eIACUCtoPrimeProcessing]


AS
BEGIN


--Step 1 Identify eIACUC Records and extract Base Prtocol and Revision Number
-- Filter for Protocol State in Approved, Expired, Terminated or Withdrawn
--Note a review was completed and it was found that there were records in
-- Prime Protocol related to terminated or winthdrawn
--2024-11-22 Update to get the last Approval Record date


    SELECT rowid,
           Protocol_ID,
           CASE
               WHEN LEN(Protocol_ID) > 10 THEN SUBSTRING(Protocol_ID, 6, 15)
               ELSE Protocol_ID
               END AS BaseProtocol,
           CASE
               WHEN LEN(Protocol_ID) > 10 THEN SUBSTRING(Protocol_ID, 1, 4)
               ELSE 'Original'
               END AS RevisionNumber,
           Protocol_Title,
           Template_OID,
           Approval_Date,
           last_modified,
           Three_year_Expiration,
           Protocol_State,
           ROW_NUMBER() OVER (PARTITION BY
                   CASE
                       WHEN LEN(Protocol_ID) > 10 THEN SUBSTRING(Protocol_ID, 6, 15)
                       ELSE Protocol_ID
                   END
                   ORDER BY Approval_Date DESC) AS rn
    INTO #BaseProtocolDetails
    FROM onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    WHERE Protocol_State IN ('approved', 'expired', 'terminated', 'withdrawn')
)
SELECT *
Into #Step1EndDateCandidates
FROM #BaseProtocolDetails
where PROTOCOL_State != 'approved' and rn = 1

Select * from #Step1EndDateCandidates
--########################################################################
--Step 2
--Using #Step1EndDateCandidates we match to PrimeProtocols to determine records that
--should be end dated
--IfExists Drop Tanle Drop Table #Step2PrimeProtocoltoEnddate
Select
    p.external_id,
    p.protocol,
    p.title,
    p.enddate,
    s.BaseProtocol,
    s.PROTOCOL_State,
    s.Three_year_Expiration
INTO #Step2PrimeProtocoltoEnddate
from ehr.protocol p join #Step1EndDateCandidates s on p.external_id = s.BaseProtocol
where p.enddate is Null

--########################################################################
--Step 3
--Using #Step2PrimeProtocoltoEnddate we match to PrimeProtocols
--enddate the Protocol and place text in contacts field
Update p
set p.enddate = s.Three_year_Expiration, p.contacts = 'EndDate baseed on eIACUC Protocol State ' + s.PROTOCOL_State

    from ehr.protocol p join #Step2PrimeProtocoltoEnddate s  on p.external_ID = s.BaseProtocol

END