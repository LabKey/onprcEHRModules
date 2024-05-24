SELECT
  d.Id,
  ---g.isU42,
  case when g.Id != Null then 'U42 = Y'
       Else
         'U42 = N'
  End as isU42,
 Case when g.Id <> null And (s.PCRbloodVol > 0 ) then 2
   ELSE
    0
 End as PCRBloodVolume,
  s.SRVbloodVol as serologyBloodVol,
 -- g.parentageBloodDrawVol,
 -- g.mhcBloodDrawVol,
 -- g.dnaBloodDrawVol,
 -- g.totalBloodDrawVol as geneticsBloodVol,
  coalesce(s.srvbloodVol, 0) +  Case when g.Id <> Null And (s.pcrbloodVol > 0 )  then 2
   ELSE
     0
  End + 0 as totalBloodDrawVol

FROM study.demographics d

LEFT JOIN study.processingSerology s ON (d.Id = s.Id)
--LEFT JOIN study.processingGeneticsBloodDraws g ON (g.Id = s.Id)
LEFT JOIN (
    SELECT
        a.Id
        --count(*) as total
    FROM study.assignment a
    WHERE a.isActive = true and a.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.U42_PROJECT')
    GROUP BY a.Id
) g ON (g.Id = d.Id)