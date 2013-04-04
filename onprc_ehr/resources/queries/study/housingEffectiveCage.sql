SELECT
  h.lsid,
  pc.effectiveCage,

FROM study.housing h
LEFT JOIN ehr_lookups.pairedCages pc ON (h.room = pc.room and h.cage = pc.cage)
WHERE h.cage IS NOT NULL