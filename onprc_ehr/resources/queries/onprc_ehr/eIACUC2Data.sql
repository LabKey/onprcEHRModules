SELECT p.rowid,
       p.Protocol_ID,
       len(p.protocol_id) as CharacterCount,
       Case when Len(p.protocol_ID) > 10
                then substring(p.protocol_id, 6,15)
            else p.protocol_ID
           End As BaseProtocol,
       Case When Len(p.protocol_ID) > 10
                then substring(p.protocol_ID,1,4)
            Else 'Original'
           End as RevisionNumber,
       p.Template_OID,
       p.Protocol_OID,
       p.Protocol_Title,
       p.PI_ID,
       p.PI_First_Name,
       p.PI_Last_Name,
       p.PI_Email,
       p.PI_Phone,
       p.USDA_Level,
       p.Approval_Date,
       p.Annual_Update_Due,
       p.Three_year_Expiration,
       p.Last_Modified,
       p.createdby,
       p.created,
       p.modifiedby,
       p.modified,
       p.Protocol_State,
       p.PPQ_Numbers,
       p.Description
FROM eIACUC_PRIME_VIEW_PROTOCOLS p