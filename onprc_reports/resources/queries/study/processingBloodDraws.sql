SELECT
  d.Id,
--   g.isU42,
  CASE when a.Id != Null then 'Y'
  ELSE 'N'
  END as isU42,

 Case when (a.Id != nULL  And (s.PCRbloodVol > 0 )) then 2
   ELSE
    0
 End as PCRBloodVolume,

  s.srvBloodVol as serologyBloodVol,
  s.CompbloodVol as compBloodVol,
  g.parentageBloodDrawVol,
  g.mhcBloodDrawVol,
  g.dnaBloodDrawVol,
  g.totalBloodDrawVol as geneticsBloodVol,

  coalesce(s.srvBloodVol, 0) + coalesce(s.CompbloodVol, 0) +  Case when g.isU42 = 'Y' And (s.pcrbloodVol > 0 )  then 2
   ELSE
     0
   End + coalesce(g.totalBloodDrawVol, 0) as totalBloodDrawVol

FROM study.demographics d

LEFT JOIN study.processingSerology s ON (d.Id = s.Id)
LEFT JOIN study.processingGeneticsBloodDraws g ON (g.Id = s.Id)
LEFT JOIN (SELECT
    a.Id
    --count(*) as total
FROM study.assignment a
WHERE a.isActive = true and a.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.U42_PROJECT')
GROUP BY a.Id
    ) a ON (a.Id = d.Id)
