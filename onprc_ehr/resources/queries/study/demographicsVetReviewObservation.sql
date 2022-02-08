select dem.*,
       (select s.observations from study.mostRecentClinicalObservationsForAnimal s  where s.id = dem.id) as mostRecentClinicalObservations,
       (select s.date from study.mostRecentClinicalObservationsForAnimal s  where s.id = dem.id) as mostRecentClinicalObservationsdate,
       ( select cast(cast(j.date as date) as varchar(20)) + '-' + j.category + ':' + group_concat(DISTINCT j.remark, chr(10))  from "Clinical Observations" j where j.id = dem.id  and j.category = 'Observations' and j.remark is not null and j.date >= (select max(k.date)
                                                      from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.Id) group by j.date, j.category) as observationremarks,
       ( select group_concat(DISTINCT s.remark, chr(10))  from "Clinical Remarks" s where s.id = dem.id and s.description is not null  and s.date >= (select max(k.date)
                                                      from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.id) ) as clinicalremarks


from study.demographics dem
  Where  dem.id in (Select cln.id from "Clinical Observations" cln where cln.category = 'Observations' and cln.remark is not null
                  and cln.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                       and r.id = cln.id)  )
   Or dem.id in (Select rem.id from "Clinical Remarks" rem where rem.category = 'Clinical' and rem.description is not null
     and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
    and rem.id = r.id)  )


