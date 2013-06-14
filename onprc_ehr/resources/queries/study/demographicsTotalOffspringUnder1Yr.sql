/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d.id,
group_concat(DISTINCT d2.id, chr(10)) as offspringUnder1Yr,
count(DISTINCT d2.id)  AS totalOffspringUnder1Yr

FROM study.Demographics d

JOIN study.Demographics d2
  ON (d.Id = d2.sire OR d.Id = d2.dam)

WHERE d2.Id.age.ageInYears <= 1.0 and d2.calculated_status = 'Alive'

GROUP BY d.id

