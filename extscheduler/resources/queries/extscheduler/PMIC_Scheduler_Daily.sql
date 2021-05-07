/*
Created by: Kolli on 10/24/2019
This query filters all the PMIC daily events
*/
SELECT
    r.resourceid,
    e.startdate,
    e.enddate,
    e.name,
    e.alias,
    e.quantity,
    e.comments,
    r.color,
    r.room,
    r.bldg,
    e.created,
    e.createdby,
    e.modifiedby,
    e.modified
FROM Events e, PMIC_getFolderInfo r
Where r.id = e.resourceid
  And CAST(e.startDate AS DATE) = curdate() --Show only PMIC events
  Order by e.startDate