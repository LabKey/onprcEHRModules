SELECT
  a.project.protocol,
  a.id.curLocation.room,
  count(distinct a.id) as totalAnimals

FROM study.assignment a
WHERE a.enddateCoalesced >= curdate()
GROUP BY a.project.protocol, a.id.curLocation.room