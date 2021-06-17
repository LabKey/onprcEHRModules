SELECT e.Id,

       e.ResourceID,
--e.startDate,
       Cast(e.startDate as date) EventDate,
       Cast(e.startDate as time ) EventTime,

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
where (CAST(e.startDate AS DATE) = curdate()
    and e.datedisabled is null)