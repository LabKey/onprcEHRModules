--Intent to find protocols needing to be enddated
SELECT
    'Need to End Date' as PrImeACtion,
    p.rowid,
    p.Protocol_ID,
    e.external_id,
    p.Template_OID,
    p.Protocol_OID,
    p.Protocol_Title,
    p.PI_ID,
    p.PI_First_Name,
    p.PI_Last_Name,
    p.PI_Email,
    p.PI_Phone,
    p.USDA_Level,
    e.approve,
    cast(p.Approval_Date as Date),
    p.Annual_Update_Due,
    p.Three_year_Expiration,
    e.enddate,
    p.Last_Modified,
    p.createdby,
    p.created,
    p.modifiedby,
    p.modified,
    p.PROTOCOL_State,
    p.PPQ_Numbers,
    p.Description,
    p.baseProtocol,
    p.RenewalNumber,
    p.LatestRenewal
FROM eIACUC_PRIME_VIEW_PROTOCOLS p, ehr.protocol e
where (p.BaseProtocol = e.External_ID and
       p.LatestRenewal = 1 and p.Protocol_State in ('expired','terminated') and e.enddate is null)

Union

SELECT
    'Renewed Protocol' as PrImeACtion,
    p.rowid,
    p.Protocol_ID,
    e.external_id,
    p.Template_OID,
    p.Protocol_OID,
    p.Protocol_Title,
    p.PI_ID,
    p.PI_First_Name,
    p.PI_Last_Name,
    p.PI_Email,
    p.PI_Phone,
    p.USDA_Level,
    e.approve,
    cast(p.Approval_Date as Date),
    p.Annual_Update_Due,
    p.Three_year_Expiration,
    e.enddate,
    p.Last_Modified,
    p.createdby,
    p.created,
    p.modifiedby,
    p.modified,
    p.PROTOCOL_State,
    p.PPQ_Numbers,
    p.Description,
    p.baseProtocol,
    p.RenewalNumber,
    p.LatestRenewal
FROM eIACUC_PRIME_VIEW_PROTOCOLS p, ehr.protocol e
--Needs to be date only on approval date use Cast as Date
where (p.BaseProtocol = e.External_ID and

       p.LatestRenewal = 1 and p.Protocol_State in ('Approved')) and e.approve != cast(p.approval_date as date)

Union


SELECT
    'New Protocol' as PrImeACtion,
p.rowid,
    p.Protocol_ID,
    e.external_id,
p.Template_OID,
p.Protocol_OID,
    p.Protocol_Title,
p.PI_ID,
p.PI_First_Name,
p.PI_Last_Name,
p.PI_Email,
p.PI_Phone,
    p.USDA_Level,
    e.approve,
    cast(p.Approval_Date as Date),
    p.Annual_Update_Due,
    p.Three_year_Expiration,
    e.enddate,
p.Last_Modified,
p.createdby,
p.created,
p.modifiedby,
p.modified,
    p.PROTOCOL_State,
p.PPQ_Numbers,
p.Description,
    p.baseProtocol,
    p.RenewalNumber,
    p.LatestRenewal
FROM eIACUC_PRIME_VIEW_PROTOCOLS p, ehr.protocol e
--Needs to be date only on approval date use Cast as Date
where (p.BaseProtocol = e.External_ID and
       p.LatestRenewal = 1 and p.Protocol_State in ('Approved'))