SELECT
    proj.project,

    group_concat(distinct proj.protocol,chr(10)),
    group_concat(distinct proj.investigatorid,chr(10)),
    group_concat(distinct proj.startdate,chr(10)),
    group_concat(distinct proj.enddate,chr(10)),

    max(cps.date_posted) as previousdate

FROM ehr.project proj, onprc_ehr.CenterProjectsTemp cps
WHERE (proj.enddate is null or proj.enddate >= now()  And proj.modified >= cast(now() as date) )
  And proj.project = cps.project
  And cps.date_posted <= proj.modified

group by proj.project

