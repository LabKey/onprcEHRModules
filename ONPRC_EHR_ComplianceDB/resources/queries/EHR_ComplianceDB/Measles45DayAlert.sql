--update kollil 2021-02-04

SELECT
    emp.employeeid,
    emp.Name,
    emp.email,
    emp.unit,
    emp.category,
    emp.location,
    emp.majorudds,
    emp.notes,
    emp.requirementname,
    --c.date,
    Case
        When (c.requirementname is null) Then emp.date
        When (c.requirementname is not null) Then c.date
        ELSE ''
        End AS DateCompleted,
    emp.comment,
    emp.trainer,
    Case
        When (c.requirementname is null) Then TIMESTAMPDIFF('SQL_TSI_DAY', emp.date, now())
        When (c.requirementname is not null) Then -1
        End As DaysOverDue
FROM ehr_compliancedb.completiondates c
         RIGHT JOIN (
    SELECT
        c1.employeeid,
        emp.email,
        emp.Firstname + ' ' + emp.Lastname as Name,
        emp.unit,
        emp.category,
        emp.location,
        emp.majorudds,
        emp.notes,
        emp.isActive,
        c1.requirementname,
        c1.date,
        c1.result,
        c1.comment,
        c1.trainer
    FROM ehr_compliancedb.completiondates c1, ehr_compliancedb.employees emp
    Where c1.employeeid = emp.employeeid
      And c1.requirementname like 'Occupational Health - Measles Compliant - Initial'
      And emp.endDate is null
) emp
                    ON c.employeeid = emp.employeeid
                        And c.requirementname like 'Occupational Health - Measles Compliant'
