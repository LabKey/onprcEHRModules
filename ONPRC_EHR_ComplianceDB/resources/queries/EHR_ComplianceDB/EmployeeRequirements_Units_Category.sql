select b.employeeid,
       a.requirementname,
       b.unit as unit,
       b.category as category

from  ehr_compliancedb.requirementspercategory a, employeeperUnit b
where (a.unit = b.unit or a.category = b.category)
group by b.employeeid,a.requirementname, b.unit, b.category
order by b.unit, b.category