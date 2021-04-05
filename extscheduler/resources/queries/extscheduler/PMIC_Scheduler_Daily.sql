/*
Created by: Kolli on 10/24/2019
This query filters all the PMIC daily events
*/
SELECT
    r.resourceName,
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
FROM Events e, PMIC_getContainerPath r
Where r.id = e.resourceid
  --And e.container = '783D2EA5-C6AC-1036-A33C-BD25D0574070'
  And CAST(e.startDate AS DATE) = curdate() --Show only PMIC events