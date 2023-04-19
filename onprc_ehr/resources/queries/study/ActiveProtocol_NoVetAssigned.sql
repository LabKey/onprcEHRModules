SELECT p.protocol,
p.title,
p.investigatorId,
p.approve,
p.lastAnnualReview,
p.enddate,
p.external_id,
p.ibc_approval_num,
p.usda_level,
p.PROTOCOL_State,
p.Approval_Date,
p.Annual_Update_Due,
v.UserID as Assigned_Vet
FROM protocol p left outer join onprc_ehr.vet_assignment v on p.protocol = v.protocol
where (p.enddate is Null or p.enddate > Now())