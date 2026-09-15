/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

select
  co.Id,
  max(co2.maxDate) as date,
  group_concat(DISTINCT co.observation) as score
from study.clinical_observations co
join (
  SELECT
    co.Id,
    max(co.date) as maxDate
  FROM study.clinical_observations co
  WHERE co.qcstate.publicdata = true AND LOWER(co.category) = 'bcs'
  GROUP BY co.Id
) co2 ON (co.Id = co2.Id AND co.date = co2.maxDate)

WHERE co.qcstate.publicdata = true AND LOWER(co.category) = 'bcs'
And co.observation = (Select Min(b1.observation) from study.clinical_observations b1 where b1.id =co.id
And co.date = b1.date and LOWER(b1.category) = 'bcs' and b1.observation is not null)
GROUP BY co.Id




-- when count more than 1 use smallest value
-- need to determine when 2 bcs scores are entered for the same date, then use min bCS

