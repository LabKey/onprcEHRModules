/*
Created by: Kolli on 10/24/2019
This query filters all the PMIC events
*/
SELECT
    r.name as resourceid,
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
FROM Events e, Resources r
--Where r.id = e.resourceid and e.container = 'E1CFA5B8-FAD2-1034-A87D-5107380A72B9' And CAST(e.startDate AS DATE) = curdate() --for testing
Where r.id = e.resourceid
  and e.container = '783D2EA5-C6AC-1036-A33C-BD25D0574070' And CAST(e.startDate AS DATE) = curdate() --Show only PMIC events