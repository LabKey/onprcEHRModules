SELECT
  h.Id,
  h.date,
  h.formSort,
  'Histology' as type,
  h.tissue,
  h.codes,
  h.lsid,
  h.objectid,
  h.parentid,
  h.parentid.caseno as caseno

FROM study.histology h
WHERE h.qcstate.publicdata = true and h.codes IS NOT NULL

UNION ALL

SELECT
  h.Id,
  h.date,
  h.formSort,
  'Diagnosis' as type,
  null as tissue,
  h.codes,
  h.lsid,
  h.objectid,
  h.parentid,
  h.parentid.caseno as caseno

FROM study.pathologyDiagnoses h
WHERE h.qcstate.publicdata = true