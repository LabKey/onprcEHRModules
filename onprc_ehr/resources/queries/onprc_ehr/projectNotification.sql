
SELECT  proj.project,
        group_concat(proj.name) as name,
        group_concat(proj.protocol) as protocol,
        group_concat(proj.investigatorid) as investigatorid,
        group_concat(proj.startdate) as startdate,
        group_concat(proj.enddate) as enddate,
        group_concat(cps.enddate) as previousdate,
        group_concat(proj.protocol.external_iD) as protocolID

FROM ehr.project proj, onprc_ehr.CenterProjectsTemp cps
WHERE (proj.enddate is null or proj.enddate >= now() )
  And proj.modified >= cast(now() as date)
  And proj.project = cps.project
  And cps.date_posted in (select max(j.date_posted)
                          from onprc_ehr.CenterProjectsTemp j where j.project = proj.project )


group by proj.project