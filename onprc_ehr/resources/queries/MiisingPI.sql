SELECT distinct p.pi_id,p.PI_last_Name,i.rowid

FROM eIACUC_PRIME_VIEW_PROTOCOLS p left outer join  onprc_ehr.investigators i on p.pi_id = i.employeeID
where  p.protocol_state = 'approved' and i.rowid is Null