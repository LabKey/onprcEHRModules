SELECT p.rowid,
       p.Protocol_ID,
       len(p.protocol_id) as TotalCharacters,
       Case when len(p.protocol_id) = 15 then 'Renewed'
            When len(p.protocol_id) =  10 then 'original'
           End as ProtocolIdType,
       Case when len(p.protocol_id) = 15 then substring(p.protocol_id,6,10)
            When len(p.protocol_id) =  10 then substring(p.protocol_id,1,10)
           end as OriginalProtocol,
       Case when len(p.protocol_id) = 15 then substring(p.protocol_id,1,4)
            When len(p.protocol_id) =  10 then '0'
           end as RenewalNumber,
       template_oid



FROM eIACUC_PRIME_VIEW_PROTOCOLS p