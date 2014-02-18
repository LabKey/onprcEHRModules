SELECT
  t.Id,
  t.lsid,
  GROUP_CONCAT(DISTINCT t.roomAtOpen) as roomAtOpen,
  GROUP_CONCAT(DISTINCT t.cageAtOpen) as cageAtOpen,
  GROUP_CONCAT(DISTINCT t.cagemate, chr(10)) as cagematesAtOpen,
  GROUP_CONCAT(DISTINCT t.location, chr(10)) as cagemateCurrentLocations,

FROM (
SELECT
  c.Id,
  c.lsid,
  h.room as roomAtOpen,
  h.cage as cageAtOpen,
  h2.Id as cagemate,
  CAST((h2.Id || ': ' || cl.location) as varchar(500)) as location
FROM study.cases c

--find housing at time
LEFT JOIN study.housing h ON (h.Id = c.Id AND h.date <= c.date AND (h.enddate > c.date OR h.enddate IS NULL))

--then cagemates
LEFT JOIN study.housing h2 ON (
  h2.Id != h.Id AND
  h2.date <= c.date AND
  (h2.enddate > c.date OR h2.enddate IS NULL) AND
  h2.room = h.room AND
  isequal(h2.cage, h.cage) AND
  h2.room.housingType.value IN ('Cage Location', 'Group Location') --only consider caged
)

--current location for each cagemate
LEFT JOIN study.demographicsCurlocation cl ON (cl.Id = h2.Id)

) t

GROUP BY t.lsid, t.Id