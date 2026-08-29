
select
    coalesce(jj.requirementname, '') as requirementname,
    jj.employeeid as employeeid

from onprc_ehr_compliancedb.employeeTraining_details  jj where
    jj.requirementname in (select distinct ss.requirementname from ehr_compliancedb.requirements ss where ss.requirementname like 'Area Training%' and ss.requirementname <> '' )


group by   jj.employeeid, jj.requirementname
    PIVOT   requirementname by employeeid