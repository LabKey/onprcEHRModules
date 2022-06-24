SELECT e.rowid,
e.Protocol_ID,
e.Template_OID,
e.Protocol_OID,
e.Protocol_Title,
e.PI_ID,
e.PI_First_Name,
e.PI_Last_Name,
e.PI_Email,
e.PI_Phone,
e.USDA_Level,
e.Approval_Date,
e.Annual_Update_Due,
e.Three_year_Expiration,
e.Last_Modified,
e.createdby,
e.created,
e.modifiedby,
e.modified,
e.PROTOCOL_State,
e.PPQ_Numbers,
e.Description
FROM eIACUC_PRIME_VIEW_PROTOCOLS e
where  TIMESTAMPDIFF('SQL_TSI_DAY',e.Last_modified, Now()) <= 2