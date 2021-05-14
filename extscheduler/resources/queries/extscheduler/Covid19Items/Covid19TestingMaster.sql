--Convert the time in the xlm to the correct format
SELECT
--t.EntityId,
--t.Key,
--t.ResourceID,
r.name as ResourceGroup,
--e.StartDate,
--Convert(e.startDate as Date),
CONVERT(e.startDate, date) as ScheduledDate,
CONVERT(e.startDate, time) as ScheduledTime,
--Substring(CONVERT(e.startDate,time),4,12),
--t.EventID,
--t.ScheduledDate,
--t.ScheduledTime,
--t.UserName,
(u.LastName + ', ' + u.FirstName) as ParticipantName,
t.UserID,
t.EmployeeID,
--t.Created,
--t.CreatedBy,
--t.Modified,
--t.ModifiedBy,
t.Recorded,
t.RecordedBy,
t.ComplianceUpdated,
t.DateCompleted
FROM Covid19Testing t join events e on t.eventid = e.id
                      Left outer join core.siteusers u on u.userid = t.userid
                      Left Outer Join resources r on r.id = t.resourceId
where t.employeeID != 0