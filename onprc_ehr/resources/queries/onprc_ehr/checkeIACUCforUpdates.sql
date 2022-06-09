SELECT e.rowid,
e.Protocol_ID,
e.Template_OID,
e.Protocol_OID,
e.Protocol_Title,
Case
	when len(e.protocol_ID) > 10 then substring(e.Protocol_Id, 6,15)
	else e.protocol_ID
	end  newalID,
Case when e.Protocol_ID != p.external_id then 'New Record'
	 when e.Protocol_ID = p.external_ID then 'Record exists'
	 when substring(e.Protocol_Id, 6,15) = p.external_ID then 'Renewal'
	 else 'Undetermined'
	 End as RecordStatus,
p.external_ID as PRIMEProtocol,
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
FROM eiACUCImport.eIACUC_PRIME_VIEW_PROTOCOLS e left outer join PRIMe_Protocols.protocol p on e.protocol_id = p.external_id