select dem.*,
       (select s.observations from study.mostRecentClinicalObservationsForAnimal s  where s.id = dem.id) as mostRecentClinicalObservations,

       (select s.date from study.mostRecentClinicalObservationsForAnimal s  where s.id = dem.id) as mostRecentClinicalObservationsdate,

       ( select group_concat(DISTINCT j.observation, chr(10))  from "Clinical Observations" j where j.id = dem.id  and j.category = 'BCS'  and j.date >= (select max(k.date)
                                                                                     from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.Id) ) as mostRecentBCSScore,

      ( select   group_concat(DISTINCT q.procedureid.name, chr(10))  from "Clinical Encounters" q where q.id = dem.id  and q.type.value = 'Procedure'
              and q.procedureid.name  in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus','Dental prophylaxis')and q.date >= (select max(k.date)
                                                                             from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.Id) ) as mostRecentProcedure,

       ( select  group_concat(DISTINCT t.remark, chr(10))  from "Clinical Observations" t where t.id = dem.id  and t.category = 'Observations' and t.remark is not null and t.date >= (select max(k.date)
                                                      from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.Id) ) as observationremarks,

       ( select group_concat(DISTINCT s.remark, chr(10))  from "Clinical Remarks" s where s.id = dem.id and s.description is not null  and s.date >= (select max(k.date)
                                                      from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.id) ) as clinicalremarks



from study.demographics dem
  Where  dem.id in (Select cln.id from "Clinical Observations" cln where cln.category in ('Observations', 'BCS') and (cln.remark is not null or cln.observation is not null)
                  and cln.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                       and r.Id = cln.Id)  )
   Or dem.id in (Select rem.id from "Clinical Remarks" rem where rem.category = 'Clinical' and rem.description is not null
     and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
    and rem.id = r.Id)  )

     Or dem.id in (Select rems.id from "Clinical Encounters" rems where rems.type.value = 'Procedure' and rems.procedureid.name
      in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus','Dental prophylaxis')
                                                                  and rems.date >= (select max(x.date) from "Clinical Observations" x where x.category = 'Vet Review' and x.QCState.Label = 'Completed'
                                                                                                                                       and rems.Id = x.Id)  )


