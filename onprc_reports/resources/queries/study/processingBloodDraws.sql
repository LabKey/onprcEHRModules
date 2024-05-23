SELECT
  d.Id,
  ---g.isU42,
  s.spfStatus,
 --- Case when g.isU42 = 'Y' And (s.bloodVol > 0 ) then 2
 ---   ELSE
  --     0
  ---End as PCRBloodVolume,
  s.bloodVol as serologyBloodVol,
 -- g.parentageBloodDrawVol,
 -- g.mhcBloodDrawVol,
 -- g.dnaBloodDrawVol,
 -- g.totalBloodDrawVol as geneticsBloodVol,
 -- coalesce(s.bloodVol, 0) +  Case when g.isU42 = 'Y'And (s.bloodVol > 0 )  then 2
 --   ELSE
 --      0
 -- End + coalesce(g.totalBloodDrawVol, 0) as totalBloodDrawVol

FROM study.demographics d

LEFT JOIN study.processingSerology s ON (d.Id = s.Id)
--LEFT JOIN study.processingGeneticsBloodDraws g ON (g.Id = s.Id)