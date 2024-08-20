SELECT
    e.Protocol_State,
    e.PPQ_Numbers,
    e.Last_Modified,
    e.Template_OID,
    p.protocol

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e left outer join ehr.protocol p on e.BaseProtocol = p.external_ID