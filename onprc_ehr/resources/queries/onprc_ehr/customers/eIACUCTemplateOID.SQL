Select
    p.template_oid,
    Case
        When len(p.protocol_id) > 10 then substring(protocol_id,6,15)
        When len(p.Protocol_id) < 11 then protocol_id
        End
        As Protocol

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
where p.protocol_state = 'Approved'