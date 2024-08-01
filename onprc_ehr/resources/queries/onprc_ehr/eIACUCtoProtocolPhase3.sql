SELECT

    e.RenewalNumber,
    e.Protocol_state,
    e.LatestRenewal,
    p.protocol,
    p.enddate

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e join  ehr.protocol p on e.BaseProtocol = p.external_id
where (e.latestRenewal = true and p.enddate is Null and e.Protocol_State = 'expired')