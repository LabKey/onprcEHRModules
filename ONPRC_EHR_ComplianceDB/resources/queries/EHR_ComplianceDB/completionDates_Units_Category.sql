select a.employeeid,
       (Select j.lastname + ', ' + j.firstname from ehr_compliancedb.employees j where j.employeeid = a.employeeid) as Name,
       b.requirementname,
       (select max(j.date) from ehr_compliancedb.completiondates j where j.employeeid = a.employeeid and j.requirementname = b.requirementname) as date,
       a.unit,
       a.category



from  ehr_compliancedb.employeeperUnit a, ehr_compliancedb.requirementspercategory b

Where a.employeeId in ( select distinct h.employeeId from ehr_compliancedb.employees h where h.enddate is null)
  and (a.unit = b.unit or a.category = b.category)

order by employeeid