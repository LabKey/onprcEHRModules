select b.employeeid,
       (select Case when` max(t.date) is not null then max(t.date) else null end  from ehr_compliancedb.completiondates t where t.requirementname = a.requirementname and t.employeeid = b.employeeid) as completiondate,
        a.requirementname,
       b.unit as unit,
       b.category as category




from  ehr_compliancedb.requirementspercategory a, employeeperUnit b
where (a.unit = b.unit or a.category = b.category)
group by b.employeeid,a.requirementname, b.unit, b.category
order by b.unit, b.category