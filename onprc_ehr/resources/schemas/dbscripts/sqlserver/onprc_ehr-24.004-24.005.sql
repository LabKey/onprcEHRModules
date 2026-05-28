/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
GO
/****** Object:  StoredProcedure [onprc_ehr].[ExpiredProtocolUpdate]    Script Date: 12/20/2024 9:09:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [onprc_ehr].[ExpiredProtocolUpdate]
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
            where d.Protocol_State != 'Approved' and p.enddate is Null)

Update p
    Set p.enddate = getDate()
    from ehr.protocol p inner join expiredProtocol e on p.external_id = e.BaseProtocol
END
