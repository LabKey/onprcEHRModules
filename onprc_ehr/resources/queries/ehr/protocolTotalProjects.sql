/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

 --we find total projects assigned to this protocol
SELECT
  p.protocol,
  count(*) as totalProjects,
  group_concat(DISTINCT p.investigatorId.lastName, chr(10)) as investigators

FROM ehr.protocol p
LEFT JOIN ehr.project p2 ON (p.protocol = p2.protocol)
GROUP BY p.protocol
