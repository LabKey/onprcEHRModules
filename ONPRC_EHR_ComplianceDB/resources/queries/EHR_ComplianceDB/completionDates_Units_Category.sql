select e.employeeid,
       (Select k.Lastname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as lastname,
       (Select k.Firstname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as firstname,
       (Select k.majorudds from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as host,
       (Select k.enddate from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as enddate,

       (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid   ) as completiondate,

       b.requirementname,

       (Select group_concat(distinct k.type, chr(10)) from ehr_compliancedb.requirements k where k.requirementname = b.requirementname) as type,
       group_concat(distinct e.unit, chr(10)) as unit,
       group_concat(distinct e.category, chr(10)) as category,

       (select group_concat(distinct k.result, chr(10)) from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                                                  And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as result,

       (select group_concat(distinct k.comment, chr(10)) from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                                                   And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as comment,

       (select group_concat(distinct k.filename, chr(10)) from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                                                    And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as filename,

       (select group_concat(distinct k.trainer, chr(10)) from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                                                   And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as trainer,

       (select group_concat(distinct k.snooze_date, chr(10)) from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                                                       And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as snooze_date


from  ehr_compliancedb.requirementspercategory b, ehr_compliancedb.employeeperUnit e
Where  (b.unit = e.unit or b.category = e.category )
  And e.employeeid  in (select distinct kk.employeeid from ehr_compliancedb.Employees kk where kk.enddate is null)


group by e.employeeid, b.requirementname
