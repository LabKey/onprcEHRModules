SELECT p.Protocol_ID,
       Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 6,15)
            else p.protocol_id
           End as BaseProtocol,
       Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 1,4)
            else 'Original'
           End as RevisionNumber,

       p.Date_Modified,
       p.Template_OID,
       p.OID,
       p.Protocol_Title,
       p.Protocol_State,
       p.PI_ID,
       p.PI_First_Name,
       p.PI_Last_Name,
       p.PI_Email,
       p.PI_Phone,
       p.USDA_Level,
       p.PPQ_Numbers,
       p.Approval_date,
       p.Annual_Update_Last_Approved,
       p.Annual_Update_Due,
       p.Three_Year_Expiration,
       p.Last_Modified
FROM PRIME_VIEW_PROTOCOLS p