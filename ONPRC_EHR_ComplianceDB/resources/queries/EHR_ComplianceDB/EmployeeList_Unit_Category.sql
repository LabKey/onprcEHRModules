-- Created: 10-20-2025  R. Blasa    Employee list to Employee unit/Category

select a.employeeid, a.lastname, a.firstname,a.category employee_category,a.unit employee_unit,
       a.majorudds,b.category, b.unit,
       a.startdate,a.enddate,a.title,a.supervisor
from ehr_compliancedb.employees a, ehr_compliancedb.employeeperunit b
where a.employeeid = b.employeeid and a.enddate is null

order by a.employeeid