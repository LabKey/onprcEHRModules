select e.employeeid,
       (Select k.Lastname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as lastname,
       (Select k.Firstname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as firstname,
       (Select k.majorudds from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as host,
       (Select k.enddate from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as enddate,
       group_concat(distinct e.date, chr(10)) as completiondate ,
       e.requirementname,
       (Select hj.type from ehr_compliancedb.requirements  hj where hj.requirementname = e.requirementname) as type,


       group_concat(distinct e.result, chr(10)) as result,
       group_concat(distinct e.comment, chr(10)) as comment,
       group_concat(distinct e.filename, chr(10)) as filename,
       group_concat(distinct e.trainer, chr(10)) as trainer,
       group_concat(distinct e.snooze_date, chr(10)) as snooze_date,
       (select group_concat(distinct sk.unit, chr(10)) from ehr_compliancedb.requirementspercategory jb, ehr_compliancedb.employeeperUnit sk where jb.requirementname = e.requirementname
                                                                                                                                               and sk.employeeid = e.employeeid    And  (jb.unit = sk.unit  )) as Unit,

       (select group_concat(distinct jk.category, chr(10)) from ehr_compliancedb.requirementspercategory b, ehr_compliancedb.employeeperUnit jk where b.requirementname = e.requirementname
                                                                                                                                                  and jk.employeeid = e.employeeid  And  (b.category = jk.category ) ) as  category


from ehr_compliancedb.completiondates e
----
Where e.employeeid  in (select distinct kk.employeeid from ehr_compliancedb.Employees kk where kk.enddate is null)

group by e.employeeid, e.requirementname

