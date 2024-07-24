Select p.baseProtocol,
        p.RevisionNumber,
        p.Protocol_State,
        p.PPQ_Numbers,
        p.Last_Modified,
        p.USDA_Level
 from  onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
 --where p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 where p1.BaseProtocol = p.BaseProtocol))