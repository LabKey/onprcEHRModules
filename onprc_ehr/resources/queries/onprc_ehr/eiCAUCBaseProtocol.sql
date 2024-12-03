Select
p.Protocol_ID,
Case
    When len(Protocol_id)> 10 then substring(Protocol_ID,6,15)
    Else Protocol_ID
end as BaseProtocol,
Case
    When len(Protocol_id)> 10 then substring(Protocol_ID,1,5)
    Else 'Original'
end as RevisionNumber,
p.Protocol_State,
p.approval_date,
p.Three_Year_Expiration,
p.Template_OID



from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p