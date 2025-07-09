
SELECT  proj.project,
        group_concat(proj.name) as name,
        group_concat(proj.protocol) as protocol,
        group_concat(proj.project) as project,
        group_concat(proj.investigatorid) as investigatorid,
        group_concat(proj.startdate) as startdate,
        group_concat(proj.enddate) as enddate,
        group_concat(proj.protocol.external_iD) as protocolID,
        ( select group_concat(cps.enddate) from onprc_ehr.CenterProjectsTemp cps Where cps.project =proj.project And cps.date_posted in (select max(j.date_posted)
                                                          from onprc_ehr.CenterProjectsTemp j where j.project = proj.project )  ) as previousdate

FROM ehr.project proj
WHERE (proj.enddate is null or proj.enddate >= now() )
  And proj.modified >= cast(now() as date)

group by proj.project