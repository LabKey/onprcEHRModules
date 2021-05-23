/*
Created by:jonesga on 05/21/2021
This query filters all the Covid daily events
*/
SELECT
    e.id as EventID,
    r.id,
    e.startdate,
    e.enddate,
    e.name,
    e.alias,
    e.quantity,
    e.comments,
    e.created,
    e.createdby,
    e.modifiedby,
    e.modified
FROM Events e, Covid_getFolderID r
Where r.container = e.Container
  And CAST(e.startDate AS DATE) = curdate() --Show only PMIC events