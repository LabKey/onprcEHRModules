Select
    rowid,
    Case
        when len(protocol_id) < 11 then protocol_id
        else substring(protocol_id,6,15)
        End
        as BaseProtocol,
    Case
        when len(protocol_id) < 11 then 'initial'
        else substring(protocol_id,1,4)
        End
        as RevisionNumber,
    protocol_id,
    Protocol_title,
    Protocol_state
from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS