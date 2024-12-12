--This build is a stored procedure that uses a temp table and then updates onprc_ehronprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
CREATE Procedure onprc_ehr.ExpiredProtocols

    AS
--Create a Temp Table that creates Base Protocol and Revision Number
WITH ExpiredProtocol AS (
    SELECT
    p.rowID,
    p.BaseProtocol,
    p.Protocol_ID,
    p.revisionNumber,
    p.Protocol_State,
   p. Approval_Date,
    p.Last_Modified,
    p.Three_Year_Expiration
FROM
    onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
WHERE
    p.Protocol_State IN ('expired', 'terminated', 'withdrawn')
   AND p.Approval_Date in
    (Select Max(e.Approval_Date) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e where p.baseProtocol = e.BaseProtocol )

)
--This will update the onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS inserting the BaseProtocol and RevisionNumber
--Match expoired protocols to records in ehr.protocol
--Select * from ExpiredProtocol p1, ehr.protocol ehr
--where (p1.BaseProtocol = ehr.external_Id and ehr.enddate is Null)

Update e
set e.enddate = p.Approval_Date, e.contacts = 'Protocol enddated based on eiACUC Status ' + p.Protocol_State
    From ehr.protocol e, ExpiredProtocol p
where e.external_id = p.BaseProtocol

