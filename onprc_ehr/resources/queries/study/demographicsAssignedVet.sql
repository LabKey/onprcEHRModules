SELECT
  d.Id,
  COALESCE(a.vetNames, h.vetNames) as assignedVet,
  CASE
    WHEN a.vetNames IS NOT NULL THEN 'Assignment'
    WHEN h.vetNames IS NOT NULL THEN 'Location'
    ELSE 'None'
  END as assignmentType,
  a.protocols,
  h.areas

FROM study.demographics d

LEFT JOIN (
  SELECT
    a.Id,
    group_concat(distinct v.userId.userId.displayName) as vetNames,
    group_concat(distinct a.project.protocol.displayName) as protocols
  FROM study.assignment a
  JOIN onprc_ehr.vet_assignment v ON (a.project.protocol = v.protocol)
  WHERE a.enddateCoalesced >= curdate() OR a.enddate = a.Id.demographics.death
  GROUP BY a.Id
) a ON (a.Id = d.Id)

LEFT JOIN (
  SELECT
    h.Id,
    group_concat(distinct v.userId.userId.displayName) as vetNames,
    group_concat(distinct h.room.area) as areas

  FROM study.housing h
  JOIN onprc_ehr.vet_assignment v ON (v.area = h.room.area)
  WHERE h.enddateTimeCoalesced >= now() OR h.enddate = h.Id.demographics.death
  GROUP BY h.Id
) h ON (h.Id = d.Id)