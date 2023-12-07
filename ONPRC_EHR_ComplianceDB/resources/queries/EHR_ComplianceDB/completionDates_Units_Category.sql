select e.employeeid,
       (Select k.Lastname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as lastname,
       (Select k.Firstname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as firstname,
       (Select k.majorudds from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as host,
       (Select k.enddate from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as enddate,

       (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid   ) as completiondate,

       (select k.requirementname from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                           And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid )) as requirementname,

       (Select k.type from ehr_compliancedb.requirements k where k.requirementname = b.requirementname) as type,

       (select k.category from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as category,

       (select k.unit from ehr_compliancedb.employees k where k.employeeid = e.employeeid)  as unit,

       (select k.result from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                  And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as result,

       (select k.comment from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                   And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as comment,

       (select k.filename from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                    And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as filename,

       (select k.trainer from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                   And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as trainer,

       (select k.snooze_date from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                       And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as snooze_date


from  ehr_compliancedb.requirementspercategory b, ehr_compliancedb.employeeperUnit e
Where  (b.unit = e.unit or b.category = e.category)


group by e.employeeid, b.requirementname


union

select j.employeeid,
       null as lastname,
       null as firstname,
       null as host,
       null as enddate,
       null as completiondate,
       j.requirementname,
       null as type,
       null as category,
       null as unit,
       null as result,
       null as comment,
       null as filename,
       null as trainer,
       null as snooze_date

from  ehr_compliancedb.RequirementsPerEmployee j
Where j.requirementname NOT in (select z.requirementname from ehr_compliancedb.completiondates z where z.requirementname = j.requirementname
                                                                                                   and z.employeeid = j.employeeid and z.date is not null)
  And j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where p.enddate is null)


group by j.employeeid, j.requirementname