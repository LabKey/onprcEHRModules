/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 * updated 9/4/2017 by Kolli to adjust issue of multiple bcs on same date
 * results verified in Test and readyfor Production
 */
Select DISTINCT
a.id,
CAST(a.date AS DATE) as date,
a.score
From
(Select b.id, b.date, b.score
  From study.BCS_Recent_Score b
  Where  b.score = (Select  Min(b1.score) from study.BCS_Recent_Score b1 where b1.id =b.id)
) AS a




/* code as of 9/1/2017
Select
b.id,
b.date,
b.observation as score
from study.clinical_observations b
where b.category = 'bcs'
and b.created >  TIMESTAMPADD('SQL_TSI_MONTH', -18, Now())
and b.date = (Select Max(b2.date) from study.clinical_observations b2 where b2.id =b.id and b2.category = 'bcs' and b2.observation is not null)
and b.observation = (Select Min(b1.observation) from study.clinical_observations b1 where b1.id =b.id and b1.category = 'bcs' and b1.observation is not null)
and b.observation  is not null
 and b.id not like '[a-z]%'*/





-- when coiunt more than 1 use smallest value
-- need to determine when 2 bcs scores are entered for the same date, then use min bCS

