    SELECT p.rowid,
       p.BaseProtocol,
       p.RevisionNumber,
       p.Protocol_Title,
       p.PROTOCOL_State,
       p.approval_Date,
       p.last_Modified
FROM onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
where p.Protocol_state IN ('expired', 'terminated', 'withdrawn')
group by p.BaseProtocol,
    p.rowid,p.revisionNumber,
    p.protocol_State,
    p.protocol_Title,
    p.approval_Date,
    p.last_Modified