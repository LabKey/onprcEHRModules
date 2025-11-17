select a.employeeid, a.unit, null as category, a.enddate
from ehr_compliancedb.Employees a where
    a.unit not in (select unit from ehr_compliancedb.EmployeePerUnit j where j.EmployeeId = a.employeeid)
                                                                                             and a.unit is not null
---and a.EndDate is null


group by a.employeeid, a.unit, a.enddate


union

select a.employeeid, null as unit, a.category, a.enddate
from ehr_compliancedb.Employees a where
    category not in (select category from ehr_compliancedb.EmployeePerUnit j where j.EmployeeId = a.employeeid)
    a.                                                                                         and a.category is not null
---and a.EndDate is null

group by a.employeeid, a.category, a.enddate

order by a.employeeid