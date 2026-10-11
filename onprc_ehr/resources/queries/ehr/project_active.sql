/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT project.name,
project.protocol,
project.investigatorId,
project.title,
project.use_category,
project.startdate,
project.enddate,
project.shortname,
project.container,
project.displayName,
project.account,
project.project
FROM project
where (enddate is null or enddate >= Now())