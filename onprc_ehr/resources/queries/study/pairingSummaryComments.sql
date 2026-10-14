/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  p.Id,
 (SELECT group_concat(distinct p2.Id, ' ') AS Ids FROM study.pairings p2 WHERE p.Id != p2.id AND p.pairId = p2.pairId) as otherIds,
  p.pairid,
  p.date,
  (Select j.gender from study.demographics j where j.Id = p.Id) as sex,
  p.lowestCage,
  p.room,
  p.cage,
  p.eventType,
  p.category,
  p.goal,
  p.observation,
  p.outcome,
  p.separationreason,
  p.remark,
  p.remark2,
  p.enddate,
  p.endeventType,
  p.performedby,
  p.taskid,
  TIMESTAMPDIFF('SQL_TSI_DAY', p.date, coalesce(p.enddate,curdate())) as duration,
  p.qcstate,
  p.lsid,
  p.other_infant,
  p.infant_id,
  p.housingtype,
  p.priorgrouphousing

FROM study.pairings p
where p.eventtype in ('General Comment', 'Pair monitor')