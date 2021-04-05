SELECT
r.Id,
r.name as resourceName,
r.color,
r.room,
r.bldg,
r.Container,
c.name as FolderName
FROM Resources r, core.Containers c
Where c.EntityId = r.container
And c.name like 'PMIC Scheduler'

