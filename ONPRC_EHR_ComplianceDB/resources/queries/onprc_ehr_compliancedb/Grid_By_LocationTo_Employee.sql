
select
    coalesce(jj.requirementname, '') as requirementname,
    jj.employeeid as employeeid

from onprc_ehr_compliancedb.employeeTraining_details  jj where jj.grid_type = 'area'


group by   jj.employeeid, jj.requirementname, jj.grid_type
    PIVOT   requirementname by employeeid