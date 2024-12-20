USE [Labkey_GJ]
GO
/****** Object:  StoredProcedure [onprc_ehr].[ExpiredProtocolUpdate]    Script Date: 12/20/2024 9:09:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [onprc_ehr].[ExpiredProtocolUpdate]
    AS
BEGIN

WITH ApprovedProtocols AS (
    SELECT
        BaseProtocol,
        MAX(Approval_Date) AS maxApprovalDate
    FROM
        onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    WHERE
        Protocol_State IN ('approved','expired', 'terminated') --All protocols that have been approved
    GROUP BY
        BaseProtocol
),

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

     ExpiredProtocol as (
         SELECT
             p.Protocol,
             p.external_Id,
             d.BaseProtocol,
             d.RevisionNumber,
             d.Protocol_State,
             p.enddate,
             CURRENT_DATE() as LatestDate
         FROM
             ehr.protocol p
                 INNER JOIN DistinctProtocols d
                            ON p.external_id = d.BaseProtocol
         WHERE
             p.enddate IS NULL
             AND d.Protocol_State NOT LIKE 'approved')

UPDATE e
SET
    e.enddate = p.LatestDate,
    e.contacts = 'Protocol enddated based on eiACUC Status ' + p.Protocol_State --debug message to be removed before push to prod
    FROM
        ehr.protocol e
    INNER JOIN ExpiredProtocol p
ON e.external_id = p.BaseProtocol;
END;
