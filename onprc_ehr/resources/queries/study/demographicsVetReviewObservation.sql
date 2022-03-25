select dem.*,
       dem.mostRecentClinicalObservations.observations as mostRecentClinicalObservations,
       dem.mostRecentClinicalObservations.date as mostRecentClinicalObservationsdate,

       ( select group_concat(DISTINCT 'BCS: ' + j.observation, chr(10))  from "Clinical Observations" j where j.id = dem.id  and j.category = 'BCS' and j.QCState.Label = 'Completed'   and j.date >= (select max(k.date)
                                                                             from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as mostRecentBCSScore,

      ( select group_concat(DISTINCT q.procedureid.name  + ' : ' + q.remark , chr(10)) from "Clinical Encounters" q where q.id = dem.id  and q.QCState.Label = 'Completed' and q.type.value = 'Procedure'
              and q.procedureid.name  in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus','Dental prophylaxis','Palpation, bimanual') and q.date >= (select max(k.date)
              from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as mostRecentProcedure,

       ( select  group_concat(DISTINCT 'Observations: ' + t.remark, chr(10))  from "Clinical Observations" t where t.id = dem.id  and t.category = 'Observations' and t.remark is not null
                     and t.QCState.Label = 'Completed' and t.date >= (select max(k.date)
                                        from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as observationremarks,

       ( select group_concat(DISTINCT s.remark, chr(10))  from "Clinical Remarks" s where s.id = dem.id and s.QCState.Label = 'Completed'  and s.date >= (select max(k.date)
                                                      from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as clinicalremarks



from study.demographics dem
  Where  dem.id in (Select cln.id from "Clinical Observations" cln where cln.category = 'Observations' and cln.remark is not null and cln.QCState.Label = 'Completed'
                  and cln.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                       and r.Id = cln.Id)  )

    Or dem.id in (Select cln.id from "Clinical Observations" cln where cln.category = 'BCS' and cln.observation is not null and cln.QCState.Label = 'Completed'
                  and cln.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                       and r.Id = cln.Id)  )

   Or dem.id in (Select rem.id from "Clinical Remarks" rem where rem.category = 'Clinical' and rem.QCState.Label = 'Completed'
     and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
    and rem.id = r.Id)  )

     Or dem.id in (Select rems.id from "Clinical Encounters" rems where rems.type.value = 'Procedure' and rems.QCState.Label = 'Completed' and rems.procedureid.name
      in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus','Dental prophylaxis','Palpation, bimanual')
                                                                  and rems.date >= (select max(x.date) from "Clinical Observations" x where x.category = 'Vet Review' and x.QCState.Label = 'Completed'
                                                                                                                                       and rems.Id = x.Id)  )


