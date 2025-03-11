select
       e.employeeid,
     (Select k.Lastname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as lastname,
      (Select k.Firstname from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as firstname,
      (Select k.majorudds from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as host,
    (Select k.enddate from ehr_compliancedb.employees k where k.employeeid = e.employeeid) as enddate,
       e.date,
     e.requirementname,
     (Select hj.type from ehr_compliancedb.requirements  hj where hj.requirementname = e.requirementname) as type,


     e.result,
     e.comment,
    e.filename,
    e.trainer,
    e.snooze_date,
   (select  group_concat(distinct sk.unit,chr(10))from ehr_compliancedb.requirementspercategory jb, ehr_compliancedb.employeeperUnit sk where jb.requirementname = e.requirementname
                                                                                                                                         and sk.employeeid = e.employeeid    And  (jb.unit = sk.unit  )) as Unit,

  (select  group_concat(distinct jk.category,chr(10)) from ehr_compliancedb.requirementspercategory b, ehr_compliancedb.employeeperUnit jk where b.requirementname = e.requirementname
                                                                                                                                          and jk.employeeid = e.employeeid  And  (b.category = jk.category  ) ) as  category

from ehr_compliancedb.completiondates e





