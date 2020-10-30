


SELECT

  d.Id.curLocation.area as Area,
  d.Id.curLocation.room as Room,
  d.Id.curLocation.cage as Cage,
  d.Id,
   (select e.groupId.name from study.animal_group_members  e where e.Id = d.id and e.qcstate = 18 And e.enddate is null) as Project, ------- assigned groups,
   d.gender.meaning as gender,
   d.calculated_status.code as livestatus,
   d.birth as birthdate,
   d.Id.MostRecentWeight.MostRecentWeight as currentweight ,
   d.Id.MostRecentWeight.MostRecentWeightDate as weightdate,

  coalesce(b.dam, '') as observeddam,
  coalesce(p2.parent, '') as geneticdam,
  coalesce(p3.parent, '') as fosterdam


FROM study.demographics d

LEFT JOIN (
  select p2.id, min(p2.method) as method, max(p2.parent) as parent
  FROM study.parentage p2
  WHERE (p2.method = 'Genetic' OR p2.method = 'Provisional Genetic') AND p2.relationship = 'Dam' --AND p2.enddate IS NULL
  GROUP BY p2.Id
) p2 ON (d.Id = p2.id)
LEFT JOIN (
  select p3.id, min(p3.method) as method, max(p3.parent) as parent
  FROM study.parentage p3
  WHERE p3.relationship = 'Foster Dam'
  GROUP BY p3.Id
) p3 ON (d.Id = p3.id)
LEFT JOIN study.birth b ON (b.id = d.id )
Where d.calculated_status.code = 'Alive' And  d.qcstate = 18