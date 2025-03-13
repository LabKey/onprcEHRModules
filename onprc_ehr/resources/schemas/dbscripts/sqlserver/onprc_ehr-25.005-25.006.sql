GO
/****** Object:  StoredProcedure [onprc_ehr].[ExpiredProtocolUpdate]    Script Date: 3/6/2025 10:33:07 AM
* This is designed to handle two types of action on Protocols in Prime based on eIACUC Data
* Type 1 is Expired
* Type 2 is Renewal.
NOTE in the first deployment of the process the update is only designed to handle enddate of Protocols that are not approved.
******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [onprc_ehr].[eIACUCtoPRIMEProtocolUpdates]
    AS
BEGIN

WITH ApprovedProtocols AS (
    SELECT
        BaseProtocol,
        MAX(Approval_Date) AS maxApprovalDate
    FROM
        onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    WHERE
        Protocol_State IN ('approved','expired', 'terminated')
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
             p.Annual_Update_Due,
             p.Last_Modified,
             p.Three_Year_Expiration
         FROM
             onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
                 INNER JOIN ApprovedProtocols ap ON p.BaseProtocol = ap.BaseProtocol
                 AND p.Approval_Date = ap.maxApprovalDate),
     ExpiredProtocol AS (
         Select
             d.*,
             p.protocol,
             p.enddate
         from DistinctProtocols d inner join ehr.protocol p on d.BaseProtocol = p.external_ID
         where d.Protocol_State != 'Approved' and p.enddate is Null),
    ProtocolRenewal as (
Select
    d.BaseProtocol,
    d.Approval_Date,
    d.PROTOCOL_State,
    d.Annual_Update_Due,
    p.external_id,
    p.approve,
    p.enddate,
    Case
    when Cast(d.approval_date as Date) != Cast(p.approve as Date)then 'Needs Update'
    when Cast(d.approval_date as Date) = Cast(p.approve as Date)then 'Is Current'
    End As ProtocolStatus


from DistinctProtocols d left outer join ehr.protocol p on d.BaseProtocol = p.external_ID
where d.Protocol_State Not In ('terminated','withdrawn', 'expired')
    )

Select * from ProtocolRenewal
/*Update p
Set p.enddate = getDate()
    from ehr.protocol p inner join expiredProtocol e on p.external_id = e.BaseProtocol*/
END