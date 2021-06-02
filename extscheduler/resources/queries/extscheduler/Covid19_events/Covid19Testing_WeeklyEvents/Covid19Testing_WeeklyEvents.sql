SELECT e.Id,

       e.ResourceID,
--e.startDate,
       Cast(e.startDate as date) EventDate,
       Cast(e.startDate as time ) EventTime,
       (Select LastName+ ', ' + FirstName from core.users where userID = e.userID) as PartipantName,
       e.Name,
       e.UserID,
       e.EmployeeID,
       e.Created,
       e.CreatedBy,
       e.Modified,
       e.ModifiedBy,
       e.Recorded,
       e.RecordedBy,
       e.ComplianceUpdated,
       e.DateCompleted
FROM events e
where (week(e.StartDate) = week(Now())
    and e.datedisabled is null and e.ResourceID not in (69,77))