SELECT
  d.Id,
  CASE
      WHEN (a.Id IS NULL) THEN 'N'
      ELSE 'Y'
      END as isU42,
 Case when (a.Id IS NOT NULL)  And (s.PCRbloodVol > 0 ) then 2
   ELSE
    0
 End as PCRBloodVolume,

  s.srvBloodVol as serologyBloodVol,

  Case when (a.Id IS NOT NULL)  And (s.ESPFBloodVol > 0 ) then 4
       ELSE
           0
      End as ESPFBloodVol,


 ( coalesce(s.CBCbloodVol1,0) +  coalesce(s.CBCbloodVol2,0) +  coalesce(s.CBCbloodVol3,0) +  coalesce(s.CBCbloodVol4,0) +  coalesce(s.CBCbloodVol5,0) ) as totalCBCVol,
 (coalesce(s.CChembloodVol1,0) + coalesce(s.CChembloodVol2,0) + coalesce(s.CChembloodVol3,0) + coalesce(s.CChembloodVol4,0) )  as totalCompChemBloodVol,
 (coalesce(s.BChembloodVol,0) )  as BasicChemBloodVol,

  g.parentageBloodDrawVol,
  g.mhcBloodDrawVol,
  g.dnaBloodDrawVol,
  g.totalBloodDrawVol as geneticsBloodVol,

  coalesce(s.srvBloodVol, 0) +
  Case when (a.Id IS NOT NULL)   And (s.pcrbloodVol > 0 )  then 2
   ELSE
     0
   End +
  Case when (a.Id IS NOT NULL)  And (s.ESPFBloodVol > 0 ) then 4
  ELSE
      0
  End +
  coalesce(s.CBCbloodVol1,0) +   coalesce(s.CBCbloodVol3,0) +  coalesce(s.CBCbloodVol4,0) +  coalesce(s.CBCbloodVol5,0) +
  coalesce(s.CChembloodVol1,0) + coalesce(s.CChembloodVol2,0) + coalesce(s.CChembloodVol3,0) + coalesce(s.CChembloodVol4,0) +
  coalesce(s.BChembloodVol,0) +
  coalesce(g.totalBloodDrawVol, 0) as totalBloodDrawVol,

    (select k.room  from study.housing k where k.Id =d.Id And k.enddate is null) as currentlocationroom,
    (select coalesce(k.cage, ' ') from study.housing k where k.Id =d.Id And k.enddate is null) as currentlocationcage,

FROM study.demographics d

LEFT JOIN study.processingSerology s ON (d.Id = s.Id)
LEFT JOIN study.processingGeneticsBloodDraws g ON (g.Id = s.Id)
LEFT JOIN (SELECT
    a.Id

FROM study.assignment a
WHERE a.isActive = true and a.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.U42_PROJECT')
GROUP BY a.Id
    ) a ON (a.Id = d.Id)
