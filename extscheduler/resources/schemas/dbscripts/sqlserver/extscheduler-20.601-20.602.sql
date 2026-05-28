/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/*
 * Created 2020-06-09
 * Created by jonesga
 * Purpose -  View joining Scheduler Resources, Events and the User Data
 */
EXEC core.fn_dropifexists 'vw_Covid19Research', 'extScheduler', 'VIEW', NULL;
GO

CREATE VIEW extScheduler.vw_Covid19Research AS
SELECT extscheduler.Events.Id AS SChedulerID, extscheduler.Events.ResourceId, extscheduler.Resources.Name AS ResourceName, extscheduler.Events.Name, extscheduler.Events.StartDate, extscheduler.Events.UserId,
       extscheduler.Events.CreatedBy, extscheduler.Events.Created, extscheduler.Events.Quantity, core.UsersData.IM AS EmployeeID
FROM     extscheduler.Events LEFT OUTER JOIN
         core.UsersData ON extscheduler.Events.UserId = core.UsersData.UserId LEFT OUTER JOIN
         extscheduler.Resources ON extscheduler.Events.ResourceId = extscheduler.Resources.Id
WHERE  (extscheduler.Events.ResourceId = 67)
