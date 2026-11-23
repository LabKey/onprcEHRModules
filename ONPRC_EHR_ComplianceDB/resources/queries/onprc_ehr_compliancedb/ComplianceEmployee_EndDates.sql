select cds.employeeid,
       cds.requirementname,
       cds.date
from ehr_compliancedb.CompletionDates cds where cds.date < TIMESTAMPADD('SQL_TSI_YEAR',-2,cast(curdate() as date) )
        And cds.date in (select max(date) from ehr_compliancedb.CompletionDates cmp where  cds.employeeid = cmp.employeeid
                                      And cmp.employeeid in (select employeeid from ehr_compliancedb.Employees emp where enddate is null
                                                            AND emp.location in ('ONPRC','VGTI')
                                                            AND emp.category in ('Volunteer', 'Visitors', 'Visiting Scientists', 'Research Staff/Faculty', 'Facilities',
                                                                                                         'EHS', 'DCM - Main', 'DCM', 'Administration') ) )
