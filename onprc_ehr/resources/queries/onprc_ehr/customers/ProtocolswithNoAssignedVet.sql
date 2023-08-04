select
    p.protocol,
    p.title,
    p.investigatorID,
    p.approve as StartDate,
    p.enddate,
    p.activeANimals.TotalactiveAnimals,
    d.userID


from ehr.protocol as P left join onprc_ehr.vet_assignment As D on p.protocol = d.protocol
where p.enddate is null and d.userid is null