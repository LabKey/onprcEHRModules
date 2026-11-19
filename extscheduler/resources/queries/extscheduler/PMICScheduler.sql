/*
Created by: Kolli on 10/24/2019
This query filters all the PMIC events
*/
SELECT
    e.resourceid,
    e.startdate,
    e.enddate,
    e.name,
--e.userid,
    e.alias,
    e.quantity,
    e.comments,
    r.color,
    r.room,
    r.bldg
FROM Events e, Resources r
Where r.id = e.resourceid and e.container = '783D2EA5-C6AC-1036-A33C-BD25D0574070' --Show only PMIC events