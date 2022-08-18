/*select
p.protocol,
e.Protocol_ID,
e.protocol_state */

update [ehr].[protocol]
set project_type = 'eIACUCSource'
where protocol in (Select p.protocol
from [ehr].[protocol] p, [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS] e
where p.protocol = e.protocol_id)