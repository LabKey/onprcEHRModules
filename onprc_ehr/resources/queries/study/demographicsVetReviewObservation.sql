select dem.*,
       ( select j.observation + ':   ' +  j.remark  from "Clinical Observations" j where j.id = dem.id  and j.category = 'Observations' and j.remark is not null and j.date >= (select max(k.date)
                                                                                                                                                      from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.Id) ) as observationremarks,
       ( select group_concat(DISTINCT s.remark, chr(10))  from "Clinical Remarks" s where s.id = dem.id and s.remark is not null  and s.date >= (select max(k.date)
                                                                                                                                                 from  "Clinical Observations" k where k.category = 'Vet Review' and dem.id = k.id) ) as clinicalremarks


from demographics dem
Where
        dem.id in (Select cln.id from "Clinical Observations" cln where cln.category = 'Observations' and cln.remark is not null
                                                                    and cln.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.qcstate = 18
                                                                                                                                         and r.id = cln.id)  )
   Or dem.id in (Select rem.id from "Clinical Remarks" rem where  rem.remark is not null
                                                             and rem.date >= (select max(r.date) from "Clinical Observations" r where r.category = 'Vet Review' and r.qcstate = 18
                                                                                                                                  and rem.id = r.id)  )


