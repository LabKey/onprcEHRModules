/*
Created by: Kolli on 11/14/2019
Weekly report: This query filters all the PMIC events from today to the next 7 days
Change by Kolli, 5/5/21: This query filters all the PMIC events from next day to the next 7 days.
The Daily events will cover the current day events, no need to duplicate same day events again in the weekly report.
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
--And CAST(e.startDate AS DATE) BETWEEN curdate() and TIMESTAMPADD('SQL_TSI_DAY', 7, curdate())
And CAST(e.startDate AS DATE) BETWEEN TIMESTAMPADD('SQL_TSI_DAY', 1, curdate()) and TIMESTAMPADD('SQL_TSI_DAY', 7, curdate())
Order by e.startdate



