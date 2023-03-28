select a.employeeid,
       a.date,
       a.requirementname,
       (select group_Concat(distinct t.category,chr(10)) from ehr_compliancedb.employeeperUnit k, ehr_compliancedb.requirementspercategory t where  t.requirementname = a.requirementname and k.category = t.category and k.employeeid = a.employeeid) as category,
       (select group_concat(distinct j.unit,chr(10)) from ehr_compliancedb.employeeperUnit k, ehr_compliancedb.requirementspercategory j
        where j.requirementname = a.requirementname and k.unit = j.unit and k.employeeid = a.employeeid) as unit,
       a.result,
       a.comment,
       a.filename,
       a.trainer,
       a.snooze_date


from  ehr_compliancedb.completiondates a

Where a.employeeId in ( select distinct h.employeeId from ehr_compliancedb.employees h where h.enddate is null)