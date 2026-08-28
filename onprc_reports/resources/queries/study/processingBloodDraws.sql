SELECT
  d.Id,
  CASE
      WHEN (a.Id IS NULL) THEN 'N'
      ELSE 'Y'
      END as isU42,  --- 0492-02
  CASE
      WHEN (b.Id IS NULL) THEN 'N'
      ELSE 'Y'
      END as isU24,   --- 0492-03
 Case when (a.Id IS NOT NULL)  And (s.PCRbloodVol > 0 ) then 2
   ELSE
    0
 End as PCRBloodVolume,

  s.srvBloodVol as serologyBloodVol,

--   Case when ( b.Id IS NOT NULL )  And (s.ESPFBloodVol > 0 ) then 4
--        ELSE
--            0
--   End as ESPFBloodVol,


 coalesce(s.CBCbloodVol,0) as totalCBCVol,
 coalesce(s.CChembloodVol,0)   as totalCompChemBloodVol,
 coalesce(s.BChembloodVol,0)   as BasicChemBloodVol,

  g.parentageBloodDrawVol,
  g.mhcBloodDrawVol,
  g.dnaBloodDrawVol,
  g.totalBloodDrawVol as geneticsBloodVol,



  coalesce(s.srvBloodVol, 0) +
  Case when (a.Id IS NOT NULL)   And (s.pcrbloodVol > 0 )  then 2
   ELSE
     0
   End +
--   Case when (b.Id IS NOT NULL)  And (s.ESPFBloodVol > 0 ) then 4
--   ELSE
--       0
--   End +
  coalesce(s.CBCbloodVol,0)  +
  coalesce(s.CChembloodVol,0) + coalesce(s.BChembloodVol,0) +
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

LEFT JOIN (SELECT
               b.Id

           FROM study.assignment b
           WHERE b.isActive = true and b.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.U24_PROJECT')
           GROUP BY b.Id
) b ON (b.Id = d.Id)


