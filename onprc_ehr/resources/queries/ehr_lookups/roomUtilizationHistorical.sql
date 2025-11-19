PARAMETERS(ReportDate TIMESTAMP)

/* Get starting date for each room */
WITH RoomStartData AS (
    SELECT
        room,
        min(date) AS startingDate
    FROM study.housing
    GROUP BY room
),
/* Get total cage locations in each room */
CageLocationData AS (
    SELECT
        c.room,
        count(c.cage) AS cageSpots
    FROM ehr_lookups.cages c
    GROUP BY c.room
),
/* Get total animals housed in each room on the report date */
AnimalHousingData AS (
    SELECT
        h.room,
        count(h.id) AS totalAnimals
    FROM study.housing h
    WHERE
        coalesce( REPORTDATE , CAST('1900-01-01 00:00:00.0' as timestamp)) < coalesce(h.enddate, now())
        AND coalesce(REPORTDATE, now()) >= coalesce(h.date, now())
    GROUP BY h.room
),
/* A modified version of ldk.dateRange with a single date parameter ReportDate */
dateRange AS (
    SELECT
        i.date,
        CAST(i.date as DATE) as dateOnly,
        CAST(dayofyear(i.date) as INTEGER) as DayOfYear,
        CAST(dayofmonth(i.date) as INTEGER) as DayOfMonth,
        CAST(dayofweek(i.date) as INTEGER) as DayOfWeek,
        ceiling(CAST(dayofmonth(i.date) as FLOAT) / 7.0) as WeekOfMonth,
        CAST(week(i.date) as INTEGER) as WeekOfYear,
        CAST(REPORTDATE AS TIMESTAMP) as ReportDate
    FROM (
        SELECT timestampadd('SQL_TSI_DAY', i.value, CAST(coalesce(REPORTDATE, curdate()) AS TIMESTAMP)) as date
        FROM ldk.integers i
    ) i
    WHERE i.date <= REPORTDATE
),
PerDiemsEquivByDayData AS ( -- PerDiemsEquivByDayData is onprc_billing.perDiemsByDay modified to use CTE dateRange, which uses only a single data parameter: ReportDate
    SELECT
        t.*,
        CASE
            WHEN t.overlappingProjects IS NULL THEN 1 -- An assignment overlapping with TMB is not charged per diems.
            WHEN t.tmbAssignments > 0 then 0
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
        coalesce(( -- Find overlapping tier flags on that day
            SELECT group_concat(DISTINCT f.flag.value) AS tier
            FROM study.flags f
            WHERE f.Id = t.Id AND f.enddateCoalesced >= t.dateOnly AND f.dateOnly <= t.dateOnly AND f.flag.category = 'Housing Tier' -- NOTE: allow flags that ended on this date
        ), 'Tier 2') AS tier
    FROM (
        SELECT
            i2.Id,
            CAST(CAST(i2.dateOnly AS DATE) AS TIMESTAMP) AS DATE,
            i2.dateOnly @hidden,
            coalesce(a.project, (SELECT p.project FROM ehr.project p WHERE p.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_GRANT_PROJECT'))) AS project,
            a.project AS assignedProject,
            max(a.duration) AS duration,  -- should only have 1 value, no so need to include in grouping
            max(timestampdiff('SQL_TSI_DAY', d.birth, i2.dateOnly)) AS ageAtTime,
            a.project.use_Category AS ProjectType,
            count(*) AS totalAssignmentRecords,
            group_concat(DISTINCT a2.project.displayName) AS overlappingProjects,
            count(DISTINCT a2.project) AS totalOverlappingProjects,
            sum(CASE WHEN a2.project.use_Category = 'Research' THEN 1 ELSE 0 END) as totalOverlappingResearchProjects,
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
                count(a3.project) as researchRecordCount,
                count(t1.code) as bottleFedRecordCount
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
        ) a ON ( -- NOTE: We don't exclude 1-day assignments or treat them differently.
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
            AND coalesce( -- Find overlapping tier flags on that day
                (SELECT group_concat(DISTINCT f.flag.value) as tier
                    FROM study.flags f
                    --NOTE: allow flags that ended on this date
                    WHERE f.Id = i2.Id AND f.enddateCoalesced >= i2.dateOnly AND f.dateOnly <= i2.dateOnly AND f.flag.category = 'Housing Tier'),
                'Tier 2'
            ) = pdf.tier
        )
        GROUP BY i2.dateOnly, i2.Id, a.project, a.project.use_Category, i2.researchRecordCount, i2.bottleFedRecordCount
    ) t
)

SELECT
    REPORTDATE,
    r.area,
    r.room,
    r.housingType,
    coalesce(cld.cageSpots, 0) AS totalCageSpaces,
    coalesce(ahd.totalAnimals, 0) AS totalAnimals,
    coalesce(pd.perDiemsEquiv, 0) AS perDiemsEquiv,
    coalesce(coalesce(pd.perDiemsEquiv, 0) / NULLIF(coalesce(cld.cageSpots, 0), 0), 0) AS percentUsed
FROM ehr_lookups.rooms r
    JOIN RoomStartData rsd ON rsd.room = r.room
    LEFT JOIN AnimalHousingData ahd ON ahd.room = r.room
    LEFT JOIN (
        SELECT
            pd.rooms,
            sum(pd.effectiveDays) AS perDiemsEquiv
        FROM PerDiemsEquivByDayData pd
        GROUP BY pd.rooms
    ) pd ON pd.rooms = r.room
    LEFT JOIN CageLocationData cld ON cld.room = r.room
WHERE r.housingType = 205 -- Cage Location
    AND r.housingCondition != 490 -- Exclude none|NECROPSY
    AND REPORTDATE <= coalesce(r.dateDisabled, now())
    AND (coalesce(rsd.startingDate, now()) <= REPORTDATE OR rsd.startingDate IS NULL)