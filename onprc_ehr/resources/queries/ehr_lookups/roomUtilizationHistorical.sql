PARAMETERS(ReportDate TIMESTAMP)

WITH RoomFirstUseData AS ( -- Find first use of each room
    SELECT
        room,
        MIN(date) AS firstUseDate
    FROM study.housing
    GROUP BY room
),
CageSpaceCountData AS ( -- Count *current* cage spaces in each room
    SELECT
        c.room,
        count(c.cage) AS cageSpaces
    FROM ehr_lookups.cages c
    GROUP BY c.room
),
AnimalCountData AS ( -- A modified version of study.HousingOverlapsReports that uses a single date parameter
    SELECT
        h.room,
        COUNT(h.id) AS totalAnimals
    FROM study.housing h
    WHERE
        COALESCE(REPORTDATE, CAST('1900-01-01 00:00:00.0' AS timestamp)) < COALESCE(h.enddate, now())
        AND COALESCE(REPORTDATE, now()) >= COALESCE(h.date, now())
    GROUP BY h.room
),
dateRange AS ( -- A modified version of ldk.dateRange that uses a single date parameter
    SELECT
        i.date,
        CAST(i.date AS DATE) AS dateOnly,
        CAST(dayofyear(i.date) AS INTEGER) AS DayOfYear,
        CAST(dayofmonth(i.date) AS INTEGER) AS DayOfMonth,
        CAST(dayofweek(i.date) AS INTEGER) AS DayOfWeek,
        ceiling(CAST(dayofmonth(i.date) AS FLOAT) / 7.0) AS WeekOfMonth,
        CAST(week(i.date) AS INTEGER) AS WeekOfYear,
        CAST(REPORTDATE AS TIMESTAMP) AS ReportDate
    FROM (
        SELECT timestampadd('SQL_TSI_DAY', i.value, CAST(COALESCE(REPORTDATE, curdate()) AS TIMESTAMP)) AS date
        FROM ldk.integers i
    ) i
    WHERE i.date <= REPORTDATE
),
PerDiemsEquivData AS ( -- A modified version of onprc_billing.perDiemsByDay that uses CTE dateRange and a single date parameter
    SELECT
        t.*,
        CASE
            WHEN t.overlappingProjects IS NULL THEN 1
            WHEN t.tmbAssignments > 0 then 0 -- An assignment overlapping with TMB is not charged per diems
            WHEN t.assignedProject IS NULL AND t.overlappingProjects IS NOT NULL THEN 0
            WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN 0
            WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN (1.0 / NULLIF((t.totalOverlappingProjects + 1), 0))
            WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN 1
            WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN (1.0 / NULLIF((t.totalOverlappingResearchProjects + 1), 0))
            ELSE 1
        END as effectiveDays,
        CASE
            WHEN (t.assignedProject IS NULL AND t.overlappingProjects IS NULL) THEN 'Base Grant'
            WHEN t.overlappingProjects IS NULL then 'Single Project'
            WHEN (t.tmbAssignments > 0) THEN 'Exempt By TMB'
            WHEN (t.isTMBProject = 1 AND t.overlappingProjects IS NOT NULL) THEN 'Exempt By TMB'
            WHEN t.assignedProject IS NULL AND t.overlappingProjects IS NOT NULL THEN 'Paid By Overlapping Project'
            WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN 'Paid By Overlapping Project'
            WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN 'Multiple Resources'
            WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN 'Single Project'
            WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN 'Multiple Research'
            ELSE 'Unknown'
        END as category,
        CASE
            WHEN (t.perDiemFeeCount > 1) THEN NULL -- Catch duplicate chargeIds
            WHEN (t.bottleFedRecordCount > 0 AND t.researchRecordCount > 0) THEN maxPdfChargeId -- Use the treatmentOrder to look for BottleFed
            WHEN (pdfChargeInfantCount > 0 AND maxPdfChargeId IS NOT NULL) THEN maxPdfChargeId -- If this item supports infants, charge that
            WHEN (perDiemAge < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.INFANT_PER_DIEM_AGE') AS INTEGER)) -- Otherwise, infants are a special rate
                THEN (SELECT ci.rowid FROM onprc_billing_public.chargeableItems ci WHERE ci.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.INFANT_PER_DIEM'))
            WHEN (quarantineFlagCount > 0) -- Add quarantine flags, which trump housing type
                THEN (SELECT ci.rowid FROM onprc_billing_public.chargeableItems ci WHERE ci.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.QUARANTINE_PER_DIEM'))
            ELSE maxPdfChargeId -- Finally, defer to housing condition
        END as chargeId,
        COALESCE(( -- Find overlapping tier flags on that day
            SELECT group_concat(DISTINCT f.flag.value) AS tier
            FROM study.flags f
            WHERE f.Id = t.Id AND f.enddateCoalesced >= t.dateOnly AND f.dateOnly <= t.dateOnly AND f.flag.category = 'Housing Tier' -- NOTE: allow flags that ended on this date
        ), 'Tier 2') AS tier
    FROM (
        SELECT
            i2.Id,
            CAST(CAST(i2.dateOnly AS DATE) AS TIMESTAMP) AS DATE,
            i2.dateOnly @hidden,
            COALESCE(a.project, (SELECT p.project FROM ehr.project p WHERE p.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_GRANT_PROJECT'))) AS project,
            a.projectName,
            a.project AS assignedProject,
            max(a.duration) AS duration,  -- should only have 1 value, no so need to include in grouping
            max(timestampdiff('SQL_TSI_DAY', d.birth, i2.dateOnly)) AS ageAtTime,
            a.project.use_Category AS ProjectType,
            count(*) AS totalAssignmentRecords,
            group_concat(DISTINCT a2.project.displayName) AS overlappingProjects,
            count(DISTINCT a2.project) AS totalOverlappingProjects,
            sum(CASE WHEN a2.project.use_Category = 'Research' THEN 1 ELSE 0 END) AS totalOverlappingResearchProjects,
            group_concat(DISTINCT a2.project.use_category) AS overlappingProjectsCategory,
            group_concat(DISTINCT a2.project.protocol) AS overlappingProtocols,
            count(h3.room) AS totalHousingRecords,
            group_concat(DISTINCT h3.room) AS rooms,
            group_concat(DISTINCT h3.cage) AS cages,
            group_concat(DISTINCT h3.objectid) AS housingRecords,
            group_concat(DISTINCT a.objectid) AS assignmentRecords,
            group_concat(DISTINCT h3.room.housingCondition.value) AS housingConditions,
            group_concat(DISTINCT h3.room.housingType.value) AS housingTypes,
            max(timestampdiff('SQL_TSI_DAY', d.birth, i2.dateOnly)) AS perDiemAge,
            count(DISTINCT pdf.chargeId) AS perDiemFeeCount,
            i2.researchRecordCount,
            i2.bottleFedRecordCount,
            count(CASE WHEN pdf.canChargeInfants = TRUE THEN 1 ELSE NULL END) AS pdfChargeInfantCount,
            max(pdf.chargeId) AS maxPdfChargeId,
            (SELECT count(*) AS c
                FROM study.flags q
                WHERE q.Id = i2.Id AND q.flag.value LIKE '%Quarantine%' AND q.dateOnly <= i2.dateOnly AND q.enddateCoalesced >= i2.dateOnly
            ) AS quarantineFlagCount,
            max(i2.ReportDate) AS ReportDate @hidden,
            count(tmb.Id) AS tmbAssignments,
            SUM(CASE WHEN a.projectName = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT') THEN 1 ELSE 0 END) AS isTMBProject
        FROM ( -- Find all distinct animals housed at the Center each day. This query is first to include all animals, not just assigned animals.
            SELECT
                h.Id,
                i.dateOnly,
                max(h.date) AS lastHousingStart,
                min(i.ReportDate) AS ReportDate @hidden,
                count(a3.project) AS researchRecordCount,
                count(t1.code) AS bottleFedRecordCount
            FROM dateRange i
            JOIN study.housing h ON (h.dateOnly <= i.dateOnly AND h.enddateCoalesced >= i.dateOnly AND h.qcstate.publicdata = TRUE)
            LEFT JOIN study.assignment a3 ON a3.id = h.id AND a3.date <= i.dateOnly AND a3.endDateCoalesced > i.dateOnly AND a3.project.Use_Category LIKE '%Research%'
            LEFT JOIN study.treatment_Order t1 ON t1.id = h.id AND t1.code.meaning LIKE '%Bottle%' AND t1.date <= i.dateOnly
            GROUP BY h.Id, i.dateOnly
        ) i2
        JOIN study.demographics d ON i2.Id = d.Id
        JOIN study.housing h3 ON (h3.Id = i2.Id AND i2.lastHousingStart = h3.date AND h3.qcstate.publicdata = TRUE)
        LEFT JOIN ( -- Then join to any assignment record overlapping each day
            SELECT
                a.lsid,
                a.id,
                a.project,
                a.project.name AS projectName,
                a.date,
                a.assignCondition,
                a.releaseCondition,
                a.projectedReleaseCondition,
                a.duration,
                a.enddate,
                a.dateOnly,
                a.enddateCoalesced,
                a.objectid
            FROM study.assignment a
            WHERE a.qcstate.publicdata = TRUE
        ) a ON (
            i2.Id = a.id
            AND a.dateOnly <= i2.dateOnly
            -- Assignments end at midnight, so an assignment doesn't count on the current date if it ends on it.
            -- However, we also include 1-day assignments, which *can* have the end date match the start date.
            AND (a.enddate IS NULL OR a.enddateCoalesced > i2.dateOnly OR (a.dateOnly = i2.dateOnly AND a.enddateCoalesced = i2.dateOnly))
        )
        LEFT JOIN ( -- For each assignment, find the co-assigned projects on that day.
            SELECT
                a2.lsid,
                a2.date,
                a2.enddate,
                a2.id,
                a2.project,
                a2.dateOnly,
                a2.enddateCoalesced
            FROM study.assignment a2
            WHERE a2.qcstate.publicdata = TRUE
        ) a2 ON (
            i2.id = a2.id
            AND a2.dateOnly <= i2.dateOnly
            AND a.project != a2.project
            -- Assignments end at midnight, so an assignment doesn't count on the current date if it ends on it.
            -- However, we also include 1-day assignments, which *can* have the end date match the start date.
            AND (a2.enddate IS NULL OR a2.enddateCoalesced > i2.dateOnly OR (a2.dateOnly = i2.dateOnly AND a2.enddateCoalesced = i2.dateOnly))
            AND a.lsid != a2.lsid
        )
        LEFT JOIN study.assignment tmb ON ( -- Find overlapping TMB on this date, which overrides the per diem.
            a.id = tmb.id
            AND tmb.dateOnly <= i2.dateOnly
            AND tmb.project != a.project
            AND tmb.endDateCoalesced >= i2.dateOnly
            AND tmb.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT')
        )
        LEFT JOIN onprc_billing.perDiemFeeDefinition pdf ON (
            pdf.housingType = h3.room.housingType
            AND pdf.housingDefinition = h3.room.housingCondition
            AND COALESCE( -- Find overlapping tier flags on that day
                (SELECT group_concat(DISTINCT f.flag.value) as tier
                    FROM study.flags f
                    --NOTE: allow flags that ended on this date
                    WHERE f.Id = i2.Id AND f.enddateCoalesced >= i2.dateOnly AND f.dateOnly <= i2.dateOnly AND f.flag.category = 'Housing Tier'),
                'Tier 2'
            ) = pdf.tier
        )
        GROUP BY i2.dateOnly, i2.Id, a.project, a.projectName, a.project.use_Category, i2.researchRecordCount, i2.bottleFedRecordCount
    ) t
)

SELECT
    REPORTDATE,
    r.building,
    r.area,
    r.room,
    r.housingType,
    COALESCE(csc.cageSpaces, 0) AS totalCageSpaces,
    COALESCE(acd.totalAnimals, 0) AS totalAnimals,
    COALESCE(pd.perDiemsEquiv, 0) AS perDiemsEquiv,
    COALESCE(COALESCE(pd.perDiemsEquiv, 0) / NULLIF(COALESCE(csc.cageSpaces*0.85, 0), 0), 0) AS percentUsed, -- 15% flex
    pd.projects,
    pd.projectNames
FROM ehr_lookups.rooms r

JOIN RoomFirstUseData rfu ON rfu.room = r.room -- rooms without a first use won't be included
LEFT JOIN AnimalCountData acd ON acd.room = r.room
LEFT JOIN (
    SELECT
        pd.rooms,
        sum(pd.effectiveDays) AS perDiemsEquiv,
        group_concat(DISTINCT pd.project, ';') as projects,
        group_concat(DISTINCT pd.projectName, ', ') as projectNames
    FROM PerDiemsEquivData pd
--    WHERE pd.project NOT IN (625, 1106, 2270) -- Exclude projectID for 0492, 0492-02, 0492-45
    WHERE pd.project NOT IN (
        SELECT
            p.project
        FROM ehr.project p
        JOIN lists.roomUtilizationHistoricalExcludedProjects ep ON ep.name = p.name
    )
    GROUP BY pd.rooms
) pd ON pd.rooms = r.room
     LEFT JOIN CageSpaceCountData csc ON csc.room = r.room
WHERE REPORTDATE <= COALESCE(r.dateDisabled, now())
  AND rfu.firstUseDate <= REPORTDATE