SELECT
    e.BaseProtocol,
    e.RenewalNumber,
    e.Protocol_state,
    e.LatestRenewal,
    p.protocol

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e join  ehr.protocol p on e.BaseProtocol = p.external_id
where e.latestRenewal = true