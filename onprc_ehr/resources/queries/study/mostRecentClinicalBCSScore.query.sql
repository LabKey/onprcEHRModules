select
        j.id,
        j.date,

         group_concat(DISTINCT cast(cast(month(j.date) as varchar(2)) + '/' + cast(dayofmonth(j.date) as varchar(2)) + 'BCS: ' + j.observation as varchar(500)), chr(10)) as mostRecentBCSScore,
 from "Clinical Observations" j where j.id = dem.id  and j.category = 'BCS' and j.QCState.Label = 'Completed'
            and j.date >= (select max(k.date)
from  "Clinical Observations" k where k.category = 'Vet Review' and k.QCState.Label = 'Completed' and j.id = k.id) )
