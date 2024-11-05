SELECT  Id,
        project,
        date,
        projectedRelease,
        enddate,
        assignmentType,
        (Select meaning from ehr_lookups.animal_condition where code = assignment.assignCondition) as assignCondition,
        (Select meaning from ehr_lookups.animal_condition where code = assignment.projectedReleaseCondition) as projectedReleaseCondition,
        (Select meaning from ehr_lookups.animal_condition where code = assignment.releaseCondition) as releaseCondition,
        releaseType,
        remark,
        description
FROM assignment
Where projectedReleaseCondition = 206 --'Terminal'
And date <= curdate() and date >= timestampadd(SQL_TSI_DAY, -35, curdate())

