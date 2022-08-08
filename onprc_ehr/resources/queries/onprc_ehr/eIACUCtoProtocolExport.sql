/* Added change to make it work */
SELECT p.rowid,
p.Protocol_ID as protocol,
p.Template_OID,
p.Protocol_OID,
p.Protocol_Title as Title,
p.PI_ID as investigatorID,
p.PI_First_Name,
p.PI_Last_Name,
p.PI_Email,
p.PI_Phone,
p.USDA_Level,
p.Approval_Date as approve,
p.Annual_Update_Due,
p.Three_year_Expiration,
p.Last_Modified,
p.created,
p.modifiedby,
p.modified,
p.PROTOCOL_State,
p.PPQ_Numbers,
p.Description
FROM eIACUC_PRIME_VIEW_PROTOCOLS p
where len(p.PI_ID) > 3