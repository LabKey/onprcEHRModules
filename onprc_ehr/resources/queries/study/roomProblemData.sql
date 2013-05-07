PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  t1.lsid,
  t1.room,
  t1.id,
  t1.problemId,
  max(t1.problemOpen) as problemOpen,
  max(t1.problemEnd) as problemEnd,
  t1.category,
  (select count(distinct m.id) FROM study.housing m WHERE (m.dateOnly <= EndDate AND m.enddateCoalesced >= StartDate AND m.room = t1.room)) as totalIdsInRoom,
  StartDate,
  EndDate,
FROM (
  SELECT
    gm.Id,
    gm.room,
    gm.date,
    gm.enddate,
    gm.enddateCoalesced,

    mp.lsid,
    mp.Id as problemId,
    mp.date as problemOpen,
    mp.enddate as problemEnd,
    mp.category,
  FROM study.housing gm

  JOIN (
    SELECT
      p.lsid,
      p.Id,
      p.dateOnly as date,
      p.enddate,
      p.enddateCoalesced,
      p.category,
    FROM study.problem p

    UNION ALL

    SELECT
      d.lsid,
      d.Id,
      d.dateOnly,
      d.date as enddate,
      d.dateOnly as enddateCoalesced,
      cast(('Death: ' || d.cause) as varchar) as category,
    FROM study.deaths d

    ) mp ON (
      mp.date <= gm.endDateCoalesced AND
      mp.enddateCoalesced >= gm.date AND
      mp.date <= EndDate AND
      mp.date >= StartDate AND
      gm.id = mp.Id
    )

  WHERE (
    gm.date <= EndDate AND
    gm.enddateCoalesced >= StartDate
  )
) t1

GROUP BY t1.lsid, t1.Id, t1.problemId, t1.room, t1.category