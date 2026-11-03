
select
    coalesce(jj.requirementname, '') as requirementname,
    jj.employeeid as employeeid

from onprc_ehr_compliancedb.employeeTraining_details  jj where jj.grid_type = 'area'


group by   jj.requirementname, jj.employeeid
           PIVOT   employeeid by  requirementname