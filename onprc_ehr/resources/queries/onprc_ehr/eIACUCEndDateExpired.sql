--I want to expand this to show dall dates in ehr.protocol
SELECT
    e.Protocol_State,
    e.Last_Modified as EndDate,
    p.external_id

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e join  ehr.protocol p on e.BaseProtocol = p.external_id
where (e.LatestRenewal = 1 and e.Protocol_State = 'Expired' and p.enddate is Null)