select dem.id,
       dem.Id.curLocation.cage,

       (select group_concat(DISTINCT cast(s.category  + ':' + coalesce(s.observation,' ')  as varchar(1000)), chr(13))
          from  "Clinical Observations" s where  s.id = dem.id and s.date in (select max(p.date)
        from  "Clinical Observations" p where not(p.category in ('menses', 'Incision','Vet Review','Alopecia Score','Alopecia Regrowth','Fecal Smear')) and  p.id = dem.id and p.date >= (select max(k.date)
     from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id)) ) as  mostRecentClinicalObservations,

       (select max(s.date) from  "Clinical Observations" s where not(s.category in ('menses', 'Incision','Vet Review','Alopecia Score','Alopecia Regrowth','Fecal Smear')) and s.id = dem.id and s.date >= (select max(k.date)
                                                                                                                                                from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as  mostRecentClinicalObservationsdate,
       dem.remarksEnteredSinceReview,
       dem.mostRecentHx,
       dem.Id.curLocation.room,
       dem.Id.activeCases.categories,
       dem.Id.utilization.use,
       dem.lastVetReview,
       dem.lsid,
       dem.objectid,

       ( select group_concat(DISTINCT cast(cast(month(j.date) as varchar(2)) + '/' + cast(dayofmonth(j.date) as varchar(2)) + 'BCS: ' + j.observation as varchar(500)), chr(10))  from "Clinical Observations" j where j.id = dem.id  and j.category = 'BCS' and j.QCState.Label = 'Completed'   and j.date >= (select max(k.date)
                                                                                                                                                                                    from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as mostRecentBCSScore,

       ( select group_concat(DISTINCT cast(cast(month(q.date) as varchar(2)) + '/' + cast(dayofmonth(q.date) as varchar(2)) + ' ' + q.procedureid.name  + ' : ' + coalesce(q.remark,q.description,'') as varchar(1000)) , chr(10)) from "Clinical Encounters" q where q.id = dem.id  and q.QCState.Label = 'Completed' and q.type = 'Procedure'
                                                                                                     and q.procedureid.name  in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus') and q.date >= (select max(k.date)
                                                                                                from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as mostRecentProcedure,


       null as observationremarks



from study.demographics dem
where dem.id in (Select rem.id from "Clinical Remarks" rem where rem.category in ('Clinical', 'Behavior') and rem.QCState.Label = 'Completed'
            and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                 and rem.id = r.Id)  )


union
select dem.id,
       dem.Id.curLocation.cage,

       null as  mostRecentClinicalObservations,

       null as  mostRecentClinicalObservationsdate,
       dem.remarksEnteredSinceReview,
       dem.mostRecentHx,
       dem.Id.curLocation.room,
       dem.Id.activeCases.categories,
       dem.Id.utilization.use,
       dem.lastVetReview,
       dem.lsid,
       dem.objectid,

       ( select group_concat(DISTINCT cast(cast(month(j.date) as varchar(2)) + '/' + cast(dayofmonth(j.date) as varchar(2)) + 'BCS: ' + j.observation as varchar(500)), chr(10))  from "Clinical Observations" j where j.id = dem.id  and j.category = 'BCS' and j.QCState.Label = 'Completed'   and j.date >= (select max(k.date)
                                                                                          from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as mostRecentBCSScore,

       null as mostRecentProcedure,
       null as observationremarks



from study.demographics dem
where dem.id in (Select cln.id from "Clinical Observations" cln where cln.category = 'BCS' and cln.observation is not null and cln.QCState.Label = 'Completed'
                                                                  and cln.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                                                                       and r.Id = cln.Id)  )
  And (Select count(*) from "Clinical Remarks" rem where rem.category in ('Clinical', 'Behavior') and rem.QCState.Label = 'Completed'
                                                     and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                                                          and rem.id = r.Id)  ) = 0

union
select dem.id,
       dem.Id.curLocation.cage,
       null as  mostRecentClinicalObservations,
       null as  mostRecentClinicalObservationsdate,
       dem.remarksEnteredSinceReview,
       dem.mostRecentHx,
       dem.Id.curLocation.room,
       dem.Id.activeCases.categories,
       dem.Id.utilization.use,
       dem.lastVetReview,
       dem.lsid,
       dem.objectid,

       null as mostRecentBCSScore,

       ( select group_concat(DISTINCT cast(cast(month(q.date) as varchar(2)) + '/' + cast(dayofmonth(q.date) as varchar(2)) + ' ' + q.procedureid.name  + ' : ' + coalesce(q.remark,'') as varchar(1000)) , chr(10)) from "Clinical Encounters" q where q.id = dem.id  and q.QCState.Label = 'Completed' and q.type = 'Procedure'
                                                                                          and q.procedureid.name  in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus') and q.date >= (select max(k.date)
                                                                                                                                                                                                                                                                                                                                                             from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and dem.id = k.id) ) as mostRecentProcedure,
       null as observationremarks


from study.demographics dem
where dem.id in (Select rems.id from "Clinical Encounters" rems where rems.type = 'Procedure' and rems.QCState.Label = 'Completed' and rems.procedureid.name
    in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus')
                 and rems.date >= (select max(x.date) from "Clinical Observations" x where x.category = 'Vet Review' and x.QCState.Label = 'Completed'
                                                                                                                                        and rems.Id = x.Id)  )
    And (Select count(*) from "Clinical Remarks" rem where rem.category in ('Clinical', 'Behavior') and rem.QCState.Label = 'Completed'
                                                     and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.QCState.Label = 'Completed'
                                                                                                                          and rem.id = r.Id)  ) = 0



