
select
        q.id,
         q.date,
       group_concat(DISTINCT cast(cast(month(q.date) as varchar(2)) + '/' + cast(dayofmonth(q.date) as varchar(2)) + ' ' + q.procedureid.name  + ' : ' + coalesce(q.remark,'')
           as varchar(1000)) , chr(10))    mostRecentClinicalProcedures

from "Clinical Encounters" q
where  q.QCState.Label = 'Completed'and q.type = 'Procedure'
 and q.procedureid.name  in ('Ultrasound','Ultrasound - Ovaries','Ultrasound - Pregnancy', 'Ultrasound - Uterus')
            nd q.date >= (select max(k.date)
            from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and q.id = k.id)
