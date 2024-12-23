/****** Object:  StoredProcedure [onprc_ehr].[ExpiredProtocolUpdate]
  Script Date: 12/20/2024 9:09:09 AM
Modified 20241223 to handle issue that origin was enddating Approvd Protocols
The modification changed the where clause and did not include Approved Protocols in the outpiut
******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [onprc_ehr].[ExpiredProtocol20241223]
    AS
BEGIN

WITH ApprovedProtocols AS (
    SELECT
        BaseProtocol,
        MAX(Approval_Date) AS maxApprovalDate
    FROM
        onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    WHERE
        Protocol_State IN ('approved','expired', 'terminated', 'withdrawn')
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
                                AND p.Approval_Date = ap.maxApprovalDate)
        ,
     ExpiredProtocol as (
         Select d.*,p.protocol,p.enddate from DistinctProtocols d inner join ehr.protocol p on d.BaseProtocol = p.external_ID
         where (d.Protocol_StaTe != 'Approved' and p.enddate is Null))

Update p
Set p.enddate = getDate() , p.contacts = 'EndDated based on Protocol_State ' + e.PROTOCOL_State

    from ehr.protocol p inner join expiredProtocol e on p.external_id = e.BaseProtocol