/*
Created by: Kolli on 11/14/2019
Weekly report: This query filters all the PMIC events from today to the next 7 days
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
  --And e.container = '783D2EA5-C6AC-1036-A33C-BD25D0574070' -- PMIC container
  And CAST(e.startDate AS DATE) BETWEEN curdate() and TIMESTAMPADD('SQL_TSI_DAY', 7, curdate())
