/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d.id as Id,
d.dam as Dam,
d.sire as Sire,

CASE (d.id.demographics.gender.origGender)
  WHEN 'm' THEN 1
  WHEN 'f' THEN 2
  ELSE 3
END AS gender,
d.id.demographics.gender as gender_code,
CASE (d.id.demographics.calculated_status)
  WHEN 'Alive' THEN 0
  ELSE 1
END
AS status,
d.id.demographics.calculated_status as status_code,
d.id.demographics.species,
'' as Display,
'Demographics' as source

FROM study.demographicsParents d
WHERE d.numParents > 0