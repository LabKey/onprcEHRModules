
SELECT proj.project,
        proj.name,
        proj.protocol,
        proj.investigatorid,
        proj.startdate,
        proj.enddate,
        (select j.enddate from onprc_ehr.CenterProjectsTemp j where j.project = proj.project and j.date_posted in (select max(cps.date_posted)
                                from onprc_ehr.CenterProjectsTemp cps where cps.date_posted <= proj.modified ) ) as previousdate

 FROM ehr.project proj
 WHERE (proj.enddate is null or proj.enddate >= now() )
 And proj.modified >= cast(now() as date))
 group by proj.project
