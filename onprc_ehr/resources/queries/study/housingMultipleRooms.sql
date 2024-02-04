/*
 * Copyright (c) 2011-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * This query was created to replace study.housingProblems.sql for ColonyAlertsNotifications.java
 * It concatenates the rooms instead of object IDs
 */
SELECT *
FROM (
         SELECT h.id,
                group_concat(h.room) AS room,
                count(*) AS count1
         FROM study.housing AS h
         WHERE h.isActive = true
         GROUP BY h.id
     ) h
WHERE h.count1 > 1