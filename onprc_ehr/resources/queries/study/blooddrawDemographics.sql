/****
2017/1-/15 Issue with Blank G
Tores o resolve the issue of BCS Score being blank, I changed the source from the demographcis Table to a direct read from BCS


*** */


select
d.id,
d.species,
d.gender,
Case
  when b.date is not null then  TIMESTAMPDIFF('SQL_TSI_Day', b.date,Now())
  else (Select TIMESTAMPDIFF('SQL_TSI_Day', a.date,Now()) from study.arrival a where a.id = d.id  )
  End as  DaysAge,
--d.id.age.ageinDays as DaysAge,
w.MostRecentWeight,
w.MostRecentWeightDate,

--d.Id.mostRecentBCS.date,
--d.Id.mostRecentBCS.score,
mbcs.date,
mbcs.score,
d.species.max_draw_pct ,
d.species.blood_draw_interval,
 d.species.blood_per_kg


from study.demographics d
  left outer join study.birth b on d.id = b.id
 left outer join study.demographicsMostRecentWeight w on d.id = w.id
  left outer join demographicsMostRecentBCS mbcs on mbcs.id = d.id
where d.calculated_status = 'Alive'
and d.ID not like '[a-z]%'