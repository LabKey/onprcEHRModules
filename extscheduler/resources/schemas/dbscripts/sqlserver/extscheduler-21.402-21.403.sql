/*
 * Copyright (c) 2003-2005 Fred Hutchinson Cancer Research Center
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * Created 2020-06-09
 * Created by jonesga
 * Purpose -  View joining Scheduler Resources, Events and the User Data
 */
EXEC core.fn_dropifexists 'vw_Covid19DCMSchedule', 'extScheduler', 'VIEW', NULL;
GO

CREATE VIEW extScheduler.vw_Covid19DCMSchedule AS
SELECT extscheduler.Events.Id AS SChedulerID, extscheduler.Events.ResourceId, extscheduler.Resources.Name AS ResourceName, extscheduler.Events.Name, extscheduler.Events.StartDate, extscheduler.Events.UserId,
    extscheduler.Events.CreatedBy, extscheduler.Events.Created, extscheduler.Events.Quantity, core.UsersData.IM AS EmployeeID
    FROM     extscheduler.Events LEFT OUTER JOIN
    core.UsersData ON extscheduler.Events.UserId = core.UsersData.UserId LEFT OUTER JOIN
    extscheduler.Resources ON extscheduler.Events.ResourceId = extscheduler.Resources.Id
    WHERE  (extscheduler.Resources.Name LIKE 'DCM%')
