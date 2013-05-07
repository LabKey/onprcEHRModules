PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  t1.lsid,
  t1.groupId,
  t1.Id,
  max(t1.date) as problemOpen,
  max(t1.enddate) as problemEnd,
  t1.category,
  t1.problemId,

  max(StartDate) as StartDate,
  max(EndDate) as Enddate,

FROM (
  SELECT
    gm.Id,
    gm.groupId,

    mp.lsid,
    mp.date,
    mp.enddate,
    mp.category,
    mp.Id as problemId,
  FROM ehr.animal_group_members gm

  JOIN (
    SELECT
      p.lsid,
      p.Id,
      p.dateOnly as date,
      p.enddate,
      p.enddateCoalesced,
      p.category,
      p.history,
    FROM study.problem p

    UNION ALL

    SELECT
      d.lsid,
      d.Id,
      d.dateOnly,
      d.date as enddate,
      d.dateOnly as enddateCoalesced,
      cast(('Death: ' || d.cause) as varchar) as category,
      d.history,
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

GROUP BY t1.lsid, t1.Id, t1.problemId, t1.groupId, t1.category