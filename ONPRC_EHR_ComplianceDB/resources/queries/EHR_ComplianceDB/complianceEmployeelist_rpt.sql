select a.employeeid, a.unit, null as category, a.enddate, a.lastName, a.firstName, a.email, a.type, a.title, a.category
from ehr_compliancedb.employees a
where a.unit not in (select unit from ehr_compliancedb.employeeperUnit j where j.EmployeeId = a.employeeid)
and a.unit is not null
and a.enddate is null



group by a.employeeid, a.unit, a.enddate, a.lastName, a.firstName,  a.email, a.type, a.title, a.category


union

select a.employeeid, null as unit, a.category, a.enddate, a.lastName,
       a.firstName, a.email, a.type, a.title, a.category
from ehr_compliancedb.employees a where
    a.category not in (select category from ehr_compliancedb.employeeperUnit j where j.EmployeeId = a.employeeid)
and a.category is not null
and a.enddate is null

group by a.employeeid, a.category, a.enddate, a.lastName, a.firstName,  a.email, a.type, a.title, a.category

order by a.employeeid