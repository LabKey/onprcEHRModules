SELECT
  v.userId,
  group_concat(DISTINCT v.area, chr(10)) as areas,
  group_concat(DISTINCT v.room, chr(10)) as rooms,
  group_concat(DISTINCT (v.protocol.displayName || ' (' || v.protocol.investigatorid.lastname || ')'), chr(10)) as protocols

FROM onprc_ehr.vet_assignment v
GROUP BY v.userId