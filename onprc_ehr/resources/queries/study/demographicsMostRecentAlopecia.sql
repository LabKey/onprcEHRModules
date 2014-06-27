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
  WHERE co.qcstate.publicdata = true AND co.category = 'Alopecia Score'
  GROUP BY co.Id
) co2 ON (co.Id = co2.Id AND co.date = co2.maxDate)

WHERE co.qcstate.publicdata = true AND co.category = 'Alopecia Score'
GROUP BY co.Id




