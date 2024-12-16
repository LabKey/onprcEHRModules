/*
2024-12-13 this is an update based on recent changes from Brent
Explanation of process
ApprovedProtocols CTE:

This Common Table Expression (CTE) selects the BaseProtocol and the maximum Approval_Date for protocols that are in the states 'expired', 'terminated', or 'withdrawn'.
It groups the results by BaseProtocol to ensure each base protocol has only one entry with the latest approval date.
DistinctProtocols CTE:

This CTE selects distinct protocol records from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS that match the base protocols and approval dates identified in the ApprovedProtocols CTE.
It joins the onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS table with the ApprovedProtocols CTE on BaseProtocol and Approval_Date.
The result is a set of distinct protocols with their latest approval dates and other relevant details.
Select Statement:

This part of the procedure selects protocols from the ehr.protocol table that need to be updated.
It joins the ehr.protocol table with the DistinctProtocols CTE on external_id and BaseProtocol.
It filters the results to include only those protocols where enddate is NULL.
Update Statement:

This statement updates the enddate and contacts fields in the ehr.protocol table for the protocols identified in the previous step.
It sets the enddate to the Approval_Date from the ExpiredProtocol and updates the contacts field with a message indicating the protocol's status.
In summary, the procedure identifies protocols that have expired, terminated, or withdrawn statuses, finds the latest approval date for each base protocol, and updates the enddate and contacts fields in the ehr.protocol table accordingly. This ensures that the protocol records are up-to-date with their current status.

*/
CREATE PROCEDURE onprc_ehr.ExpiredProtocolUpdate
    AS
BEGIN
    -- Create a CTE to get the latest approval date for each base protocol
WITH ApprovedProtocols AS (
    SELECT
        BaseProtocol,
        MAX(Approval_Date) AS maxApprovalDate
    FROM
        onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    WHERE
        Protocol_State IN ('expired', 'terminated', 'withdrawn')
    GROUP BY
        BaseProtocol
),

     -- Create a CTE to get distinct protocols with the latest approval date
     DistinctProtocols AS (
         SELECT DISTINCT
             p.rowID,
             p.BaseProtocol,
             p.RevisionNumber,
             p.Protocol_State,
             p.Approval_Date,
             p.Last_Modified,
             p.Three_Year_Expiration
         FROM
             onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
                 INNER JOIN ApprovedProtocols ap
                            ON p.BaseProtocol = ap.BaseProtocol
                                AND p.Approval_Date = ap.maxApprovalDate
     ),

-- Select protocols that need to be updated
     ExpiredProtocol as
(SELECT
    p.Protocol,
    p.external_Id,
    d.BaseProtocol,
    d.RevisionNumber,
    d.Protocol_State,
    p.enddate
FROM
    ehr.protocol p
        INNER JOIN DistinctProtocols d
                   ON p.external_id = d.BaseProtocol
WHERE
    p.enddate IS NULL),

-- Update the end date and contacts for expired protocols
UPDATE e
SET
    e.enddate = p.Approval_Date,
    e.contacts = 'Protocol enddated based on eiACUC Status ' + p.Protocol_State
    FROM
        ehr.protocol e
    INNER JOIN ExpiredProtocol p
ON e.external_id = p.BaseProtocol;
END;