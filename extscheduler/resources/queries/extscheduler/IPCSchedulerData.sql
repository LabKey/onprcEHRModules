/*
Created by: Kolli on 4/7/2025
This query filters all the IPC events
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
Where r.id = e.resourceid and e.container = '1B228A13-F54C-103D-93DF-BD9E1F3EF027' --Show only IPC events