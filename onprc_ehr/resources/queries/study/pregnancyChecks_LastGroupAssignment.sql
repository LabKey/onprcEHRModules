Select Id, MAX(enddate) as endDate --, TIMESTAMPDIFF('SQL_TSI_DAY', enddate, now()) as DaysSinceLastGroupAssignment
From animal_group_members
Where enddate is not null
And (TIMESTAMPDIFF('SQL_TSI_DAY', enddate, now()) >= 21 and TIMESTAMPDIFF('SQL_TSI_DAY', enddate, now()) <= 175)
Group by id