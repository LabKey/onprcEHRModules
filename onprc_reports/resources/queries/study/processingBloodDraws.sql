SELECT
  d.Id,
  g.isU42,

 Case when (g.isU42 = 'Y'  And (s.PCRbloodVol > 0 )) then 2
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
