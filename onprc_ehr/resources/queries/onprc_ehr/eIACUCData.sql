/*This dataset combines eIACUCFields and eIACUCDetails
     Includes fields from eiACUC2
     Updated 3/4/2024 jonesga*/


SELECT p.rowid,
       p.Protocol_ID,
       Case
           when len(p.protocol_id) > 10 then substring(p.protocol_ID, 6,15)
           else protocol_id
           End as BaseProtocol,
       Case
           when len(p.protocol_id) > 10 then substring(p.protocol_ID, 1,4)
           else 'First'
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
       p.PROTOCOL_State,
       p.PPQ_Numbers,
       p.Description
FROM eIACUC_PRIME_VIEW_PROTOCOLS p