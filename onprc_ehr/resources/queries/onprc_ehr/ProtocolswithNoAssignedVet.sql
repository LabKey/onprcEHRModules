SELECT p.protocol,
       p.title,
--investigatorId,
       p.approve,
       p.enddate,
       usda_level,
--p.PPQ_Numbers,
       p.PROTOCOL_State,

--p.Approval_Date,
       p.displayName,
       a.protocol as VetProtocol,
--p.renewalDate,
       a.userID
FROM protocol p left outer join onprc_ehr.vet_assignment a on p.protocol = a.protocol
where (a.userID is null and p.enddate is null or p.enddate > Now())