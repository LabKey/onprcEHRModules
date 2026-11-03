
select
    coalesce(jj.requirementname, '') as requirementname,
    jj.employeeid as employeeid

from onprc_ehr_compliancedb.employeeTraining_details  jj where jj.grid_type = 'skills'


group by   jj.employeeid, jj.requirementname
    PIVOT   requirementname by employeeid