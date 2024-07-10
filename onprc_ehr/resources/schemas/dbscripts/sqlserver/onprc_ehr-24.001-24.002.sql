Select protocol_id,
       Case when len(protocol_id) > 10 then substring(protocol_id, 6,16)
            else protocol_Id
           end as BaseProtocol,
       Case when len(protocol_id) > 10 then substring(protocol_id, 1,4)
            Else 'Initial'
           end as Revision,
       e.Protocol_State,
       e.template_oid,
       e.Last_Modified
from [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS] e