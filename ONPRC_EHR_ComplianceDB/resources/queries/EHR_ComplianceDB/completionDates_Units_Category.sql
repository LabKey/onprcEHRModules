select b.employeeid,
       (select Case when` max(t.date) is not null then max(t.date) else null end  from ehr_compliancedb.completiondates t where t.requirementname = a.requirementname and t.employeeid = b.employeeid) as completiondate,
       a.requirementname,
       b.unit as unit,
       b.category as category

from  ehr_compliancedb.requirementspercategory a, ehr_compliancedb.employeeperUnit b
where (a.unit = b.unit or a.category = b.category)
group by b.employeeid,a.requirementname, b.unit, b.category


union

select j.employeeid,
      null as completiondate,
    j.requirementname,
    null as unit,
    null as category

from  ehr_compliancedb.RequirementsPerEmployee j
Where j.requirementname NOT in (select z.requirementname from ehr_compliancedb.completiondates z where z.requirementname = j.requirementname
                                                                                               and z.employeeid = j.employeeid and z.date is not null)
  And j.employeeid in (select p.employeeid from ehr_compliancedb.employees p where p.enddate is null)


group by j.employeeid, j.requirementname
