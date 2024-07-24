SELECT e.rowid,
       e.Protocol_ID,
       e.Template_OID,
       e.Protocol_OID,
       e.Protocol_Title,
       e.USDA_Level,
       e.Approval_Date,
       e.Annual_Update_Due,
       e.Three_year_Expiration,
       e.Last_Modified,
       e.PROTOCOL_State,
       e.BaseProtocol,
       e.RevisionNumber,
       Case
           When p.external_id is Null then 'No Longer in Prime'
           When (p.enddate is null and e.Protocol_State != 'Approved')then 'Still Active in Prime'
           when (p.enddate is not null and p.external_id is not null) then 'Active in Prime'
           End as ProtocolStatus,
       p.external_ID,
       p.enddate
FROM eIACUC_PRIME_VIEW_PROTOCOLS e left join ehr.protocol p on e.BaseProtocol = p.external_id